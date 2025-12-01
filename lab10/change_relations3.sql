BACKUP DATABASE transpaleti
    TO DISK = 'E:\backups\transpaleti\transpaletiDB_Backup3.bak'

CREATE OR ALTER PROCEDURE OneToManyFromManyToMany
    @left_table      VARCHAR(100), -- One side
    @pk_left_table   VARCHAR(100),
    @right_table     VARCHAR(100), -- Many side
    @pk_right_table  VARCHAR(100),
    @junction_table  VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @checkMsg VARCHAR(MAX);

    -- 1. Checks
    EXEC checkExistance @left_table, @pk_left_table, @right_table, @pk_right_table, @checkMsg OUTPUT
    IF @checkMsg <> 'PASSED' BEGIN PRINT @checkMsg; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @junction_table)
        BEGIN PRINT 'JUNCTION TABLE NOT FOUND'; RETURN; END

    -- 2. Add FK Column to Right Table
    SET @sql = 'ALTER TABLE ' + QUOTENAME(@right_table) + ' ADD ' + QUOTENAME(@pk_left_table) + ' BIGINT NULL;';
    EXEC sp_executesql @sql;

    -- 3. Populate with MAX
    SET @sql = 'UPDATE R SET R.' + QUOTENAME(@pk_left_table) + ' = J.MaxLeftID
                FROM ' + QUOTENAME(@right_table) + ' R
                INNER JOIN (
                    SELECT ' + QUOTENAME(@pk_right_table) + ', MAX(' + QUOTENAME(@pk_left_table) + ') AS MaxLeftID
                    FROM ' + QUOTENAME(@junction_table) + '
                    GROUP BY ' + QUOTENAME(@pk_right_table) + '
                ) J ON R.' + QUOTENAME(@pk_right_table) + ' = J.' + QUOTENAME(@pk_right_table);
    EXEC sp_executesql @sql;

    -- 4. Log Lost Connections
    SET @sql = 'INSERT INTO RelationChangeRecord (left_table, pk_left_table, right_table, pk_right_table, description, procedure_used)
                SELECT ''' + @left_table + ''', ' + QUOTENAME(@pk_left_table) + ', ''' + @right_table + ''', ' + QUOTENAME(@pk_right_table) + ',
                ''Lost connection M:N->1:N (Non-Max value)'', ''OneToManyFromManyToMany''
                FROM ' + QUOTENAME(@junction_table) + ' J
                WHERE J.' + QUOTENAME(@pk_left_table) + ' <> (
                    SELECT MAX(' + QUOTENAME(@pk_left_table) + ')
                    FROM ' + QUOTENAME(@junction_table) + ' J2
                    WHERE J2.' + QUOTENAME(@pk_right_table) + ' = J.' + QUOTENAME(@pk_right_table) + ')';
    EXEC sp_executesql @sql;

    -- 5. Add FK Constraint
    SET @sql = 'ALTER TABLE ' + QUOTENAME(@right_table) + ' ADD CONSTRAINT FK_' + @right_table + '_' + @left_table +
               ' FOREIGN KEY (' + QUOTENAME(@pk_left_table) + ') REFERENCES ' + QUOTENAME(@left_table) + '(' + QUOTENAME(@pk_left_table) + ');';
    EXEC sp_executesql @sql;

    -- 6. Drop Junction Table
    SET @sql = 'DROP TABLE ' + QUOTENAME(@junction_table);
    EXEC sp_executesql @sql;

    EXEC logRelationChangeRecord
         @left_table,
         @pk_left_table,
         @right_table ,
         @pk_right_table ,
         @description= '1.create new column in right_table,
                        2.populating new column (solving colisions by picking max),
                        3.log lost realtions,
                        4.add fk constraint in right_table
                        5.drop junction table',
         @procedure_used = 'OneToManyFromManyToMany'
    PRINT 'Successfully transformed M:N to 1:N';
    PRINT 'Dropped table' + @junction_table
END
GO

-- Execution
EXEC OneToManyFromManyToMany 'PartsInventory', 'part_id', 'MaintenanceRecords', 'record_id', 'MaintenanceParts';
SELECT * FROM RelationChangeRecord;
Select * FROM PartsInventory
SELECT * FROM MaintenanceRecords