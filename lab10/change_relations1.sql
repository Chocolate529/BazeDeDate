BACKUP DATABASE transpaleti
    TO DISK = 'E:\backups\transpaleti\transpaletiDB_Backup1.bak'
GO
-- 1. Setup Logging Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RelationChangeRecord')
    BEGIN
        CREATE TABLE RelationChangeRecord (
                                              change_id BIGINT PRIMARY KEY IDENTITY(1,1),
                                              left_table VARCHAR(100) NOT NULL,
                                              pk_left_table VARCHAR(100) NOT NULL,
                                              right_table VARCHAR(100) NOT NULL,
                                              pk_right_table VARCHAR(100) NOT NULL,
                                              changed_at DATETIME DEFAULT(GETDATE()),
                                              description VARCHAR(MAX),
                                              procedure_used VARCHAR(100),

        )
    END
GO

CREATE OR ALTER PROCEDURE checkExistance
    @left_table varchar(100),
    @pk_left_table varchar(100),
    @right_table varchar(100),
    @pk_right_table varchar(100),
    @result varchar(max) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @left_table)
        BEGIN SET @result = 'LEFT TABLE DOES NOT EXIST'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @right_table)
        BEGIN SET @result = 'RIGHT TABLE DOES NOT EXIST'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE name = @pk_left_table AND object_id = OBJECT_ID(@left_table))
        BEGIN SET @result = 'LEFT PK DOES NOT EXIST'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE name = @pk_right_table AND object_id = OBJECT_ID(@right_table))
        BEGIN SET @result = 'RIGHT PK DOES NOT EXIST'; RETURN; END

    SET @result = 'PASSED'
END
GO

CREATE OR ALTER PROCEDURE logRelationChangeRecord
    @left_table varchar(100),
    @pk_left_table varchar(100),
    @right_table varchar(100),
    @pk_right_table varchar(100),
    @description varchar(max),
    @procedure_used varchar(100)
AS
BEGIN
    INSERT INTO RelationChangeRecord(left_table, pk_left_table, right_table, pk_right_table, description, procedure_used)
    VALUES(@left_table, @pk_left_table, @right_table, @pk_right_table, @description, @procedure_used)
END
GO

CREATE OR ALTER PROCEDURE ManyToOneFromOneToMany
    @left_table      VARCHAR(100), -- the "One" side
    @pk_left_table   VARCHAR(100),
    @right_table     VARCHAR(100), -- the "Many" side
    @pk_right_table  VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @checkMsg VARCHAR(MAX);
    DECLARE @fk_column_name VARCHAR(100);
    DECLARE @fk_constraint_name VARCHAR(100);

    -- 1. Check Tables
    EXEC checkExistance @left_table, @pk_left_table, @right_table, @pk_right_table, @checkMsg OUTPUT
    IF @checkMsg <> 'PASSED' BEGIN PRINT @checkMsg; RETURN; END

    -- 2. Identify FK in Right Table
    SELECT TOP 1 @fk_column_name = c.name, @fk_constraint_name = fk.name
    FROM sys.foreign_key_columns fkc
             JOIN sys.columns c ON fkc.parent_column_id = c.column_id AND fkc.parent_object_id = c.object_id
             JOIN sys.foreign_keys fk ON fkc.constraint_object_id = fk.object_id
    WHERE fkc.parent_object_id = OBJECT_ID(@right_table) AND fkc.referenced_object_id = OBJECT_ID(@left_table);

    IF @fk_column_name IS NULL
        BEGIN PRINT 'ABORT: No FK found linking tables.'; RETURN; END

    -- 3. Add new FK column to Left Table
    SET @sql = 'ALTER TABLE ' + QUOTENAME(@left_table) + ' ADD ' + QUOTENAME(@pk_right_table) + ' BIGINT NULL;';
    EXEC sp_executesql @sql;

    -- 4. UPDATE with MAX Value
    -- Keep the foreign key corresponding to the record with the largest value
    SET @sql = 'UPDATE L
                SET L.' + QUOTENAME(@pk_right_table) + ' = (
                    SELECT MAX(R.' + QUOTENAME(@pk_right_table) + ')
                    FROM ' + QUOTENAME(@right_table) + ' R
                    WHERE R.' + QUOTENAME(@fk_column_name) + ' = L.' + QUOTENAME(@pk_left_table) + '
                )
                FROM ' + QUOTENAME(@left_table) + ' L;';
    EXEC sp_executesql @sql;

    -- 5. LOG Lost Relationships (Rows in Right Table that are NOT the Max)
    SET @sql = 'INSERT INTO RelationChangeRecord (left_table, pk_left_table, right_table, pk_right_table, description, procedure_used)
                SELECT ''' + @left_table + ''', ' + @fk_column_name + ', ''' + @right_table + ''', ' + @pk_right_table + ',
                ''Lost connection (Not Max ID) during 1:N->N:1 switch'', ''ManyToOneFromOneToMany''
                FROM ' + QUOTENAME(@right_table) + ' R
                WHERE ' + @pk_right_table + ' NOT IN (SELECT ' + QUOTENAME(@pk_right_table) + ' FROM ' + QUOTENAME(@left_table) + ' WHERE ' + QUOTENAME(@pk_right_table) + ' IS NOT NULL)';
    EXEC sp_executesql @sql;

    -- 6. Drop Old Constraint and Column
    SET @sql = 'ALTER TABLE ' + QUOTENAME(@right_table) + ' DROP CONSTRAINT ' + QUOTENAME(@fk_constraint_name);
    EXEC sp_executesql @sql;

    SET @sql = 'ALTER TABLE ' + QUOTENAME(@right_table) + ' DROP COLUMN ' + QUOTENAME(@fk_column_name);
    EXEC sp_executesql @sql;

    -- 7. Add New Constraint
    SET @sql = 'ALTER TABLE ' + QUOTENAME(@left_table) + ' ADD CONSTRAINT FK_' + @left_table + '_' + @right_table +
               ' FOREIGN KEY (' + QUOTENAME(@pk_right_table) + ') REFERENCES ' + QUOTENAME(@right_table) + '(' + QUOTENAME(@pk_right_table) + ');';
    EXEC sp_executesql @sql;

    EXEC logRelationChangeRecord
         @left_table,
         @pk_left_table,
         @right_table ,
         @pk_right_table ,
         @description= '1.add foreign key column to left table named after the pk_right_table,
                        2.populate new column with max value coresponding to a record,
                        3.log lost realtions,
                        4.drop old constraint and column from right_table
                        5.add new constraint in the left table',
         @procedure_used = 'ManyToOneFromOneToMany'

    PRINT 'Successfully transformed 1:N to N:1';
END
GO

-- Execution
EXEC ManyToOneFromOneToMany 'PalletTrucks', 'truck_id', 'Rentals', 'rental_id';
SELECT * FROM RelationChangeRecord;
SELECT * FROm PalletTrucks
SELECT * FROM Rentals