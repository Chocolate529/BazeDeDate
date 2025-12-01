BACKUP DATABASE transpaleti
    TO DISK = 'E:\backups\transpaleti\transpaletiDB_Backup4.bak'

CREATE OR ALTER PROCEDURE OneToOneFromOneToMany
    @left_table      VARCHAR(100), -- 1 side
    @pk_left_table   VARCHAR(100),
    @right_table     VARCHAR(100), -- N side
    @pk_right_table  VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @checkMsg VARCHAR(MAX);
    DECLARE @fk_column_name VARCHAR(100);

    -- 1. Checks
    EXEC checkExistance @left_table, @pk_left_table, @right_table, @pk_right_table, @checkMsg OUTPUT
    IF @checkMsg <> 'PASSED' BEGIN PRINT @checkMsg; RETURN; END

    SELECT TOP 1 @fk_column_name = c.name
    FROM sys.foreign_key_columns fkc
             JOIN sys.columns c ON fkc.parent_column_id = c.column_id AND fkc.parent_object_id = c.object_id
    WHERE fkc.parent_object_id = OBJECT_ID(@right_table) AND fkc.referenced_object_id = OBJECT_ID(@left_table);

    IF @fk_column_name IS NULL BEGIN PRINT 'ABORT: No FK found.'; RETURN; END

    -- 2. Log Rows to be Deleted (Duplicates)
    SET @sql = 'INSERT INTO RelationChangeRecord (left_table, pk_left_table, right_table, pk_right_table, description, procedure_used)
                SELECT ''' + @left_table + ''', ' + @fk_column_name + ', ''' + @right_table + ''', ' + @pk_right_table + ',
                ''Deleted duplicate record ID '' + CAST(' + @pk_right_table + ' AS VARCHAR) + '' to enforce 1:1'', ''OneToOneFromOneToMany''
                FROM ' + QUOTENAME(@right_table) + '
                WHERE ' + @pk_right_table + ' NOT IN (
                    SELECT MAX(' + @pk_right_table + ')
                    FROM ' + QUOTENAME(@right_table) + '
                    GROUP BY ' + QUOTENAME(@fk_column_name) + '
                )';
    EXEC sp_executesql @sql;

    -- 3. DELETE Duplicates (Strict Rule: Keep Max ID)
    -- "Otherwise, for each foreign key value keep only the (primary) key with the maximum value, and delete the rest" [cite: 455]
    SET @sql = 'DELETE FROM ' + QUOTENAME(@right_table) + '
                WHERE ' + @pk_right_table + ' NOT IN (
                    SELECT MAX(' + @pk_right_table + ')
                    FROM ' + QUOTENAME(@right_table) + '
                    GROUP BY ' + QUOTENAME(@fk_column_name) + '
                );';
    EXEC sp_executesql @sql;

    -- 4. Add UNIQUE Constraint to FK
    SET @sql = 'ALTER TABLE ' + QUOTENAME(@right_table) + '
                ADD CONSTRAINT UQ_' + @right_table + '_' + @fk_column_name + ' UNIQUE (' + QUOTENAME(@fk_column_name) + ');';
    EXEC sp_executesql @sql;
    EXEC logRelationChangeRecord
         @left_table,
         @pk_left_table,
         @right_table ,
         @pk_right_table ,
         @description= '1.log tuples to be deleted(duplicates),
                        2.delete duplicates keeping only max,
                        3.add UNIQUE constraint on the fk column in right_table',
         @procedure_used = 'OneToOneFromOneToMany'
    PRINT 'Successfully transformed 1:N to 1:1';
END
GO

-- Execution
-- Suppliers (1) -> PartsInventory (N) becomes 1:1
EXEC OneToOneFromOneToMany 'Suppliers', 'supplier_id', 'PartsInventory', 'part_id';
SELECT * FROM RelationChangeRecord;
SELECT * FROM Suppliers
SELECT * FROM PartsInventory