BACKUP DATABASE transpaleti
    TO DISK = 'E:\backups\transpaleti\transpaletiDB_Backup2.bak'

CREATE OR ALTER PROCEDURE ManyToManyFromOneToMany
    @left_table      VARCHAR(100),
    @pk_left_table   VARCHAR(100),
    @right_table     VARCHAR(100),
    @pk_right_table  VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @checkMsg VARCHAR(MAX);
    DECLARE @fk_column_name VARCHAR(100);
    DECLARE @fk_constraint_name VARCHAR(100);
    DECLARE @junction_table VARCHAR(100) = @left_table + '_' + @right_table;

    -- 1. Check Tables
    EXEC checkExistance @left_table, @pk_left_table, @right_table, @pk_right_table, @checkMsg OUTPUT
    IF @checkMsg <> 'PASSED' BEGIN PRINT @checkMsg; RETURN; END

    -- 2. Find FK
    SELECT TOP 1 @fk_column_name = c.name, @fk_constraint_name = fk.name
    FROM sys.foreign_key_columns fkc
             JOIN sys.columns c ON fkc.parent_column_id = c.column_id AND fkc.parent_object_id = c.object_id
             JOIN sys.foreign_keys fk ON fkc.constraint_object_id = fk.object_id
    WHERE fkc.parent_object_id = OBJECT_ID(@right_table) AND fkc.referenced_object_id = OBJECT_ID(@left_table);

    IF @fk_column_name IS NULL BEGIN PRINT 'ABORT: No FK found.'; RETURN; END

    -- 3. Create Junction Table
    SET @sql = 'CREATE TABLE ' + QUOTENAME(@junction_table) + ' (' +
               QUOTENAME(@pk_left_table) + ' BIGINT NOT NULL, ' +
               QUOTENAME(@pk_right_table) + ' BIGINT NOT NULL, ' +
               'CONSTRAINT PK_' + @junction_table + ' PRIMARY KEY (' + QUOTENAME(@pk_left_table) + ', ' + QUOTENAME(@pk_right_table) + '));';
    EXEC sp_executesql @sql;

    -- 4. Migrate Data
    SET @sql = 'INSERT INTO ' + QUOTENAME(@junction_table) +
               ' SELECT ' + QUOTENAME(@fk_column_name) + ', ' + QUOTENAME(@pk_right_table) +
               ' FROM ' + QUOTENAME(@right_table) + ' WHERE ' + QUOTENAME(@fk_column_name) + ' IS NOT NULL;';
    EXEC sp_executesql @sql;

    -- 5. Drop Old FK
    SET @sql = 'ALTER TABLE ' + QUOTENAME(@right_table) + ' DROP CONSTRAINT ' + QUOTENAME(@fk_constraint_name);
    EXEC sp_executesql @sql;
    SET @sql = 'ALTER TABLE ' + QUOTENAME(@right_table) + ' DROP COLUMN ' + QUOTENAME(@fk_column_name);
    EXEC sp_executesql @sql;

    EXEC logRelationChangeRecord
         @left_table,
         @pk_left_table,
         @right_table ,
         @pk_right_table ,
         @description= '1.create new junction table named: <[left_table]_[right_table]>,
                        2.migrate data,
                        3.drop old fk and column from right_table',
         @procedure_used = 'ManyToManyFromOneToMany'

    PRINT 'Successfully transformed 1:N to M:N';
    PRINT 'Junction table ' + @junction_table
END
GO

-- Execution
EXEC ManyToManyFromOneToMany 'Employees', 'employee_id', 'MaintenanceRecords', 'record_id';
SELECT * FROM RelationChangeRecord;
SELECT * FROM Employees
SELECT * FROM MaintenanceRecords
SELECT * FROM Employees_MaintenanceRecords
