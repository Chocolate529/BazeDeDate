CREATE TABLE PartsInventoryLogsDelete(
                                             log_id BIGINT PRIMARY KEY IDENTITY ,
                                             table_name varchar(100),
                                             part_id BIGINT,
                                             name VARCHAR(100),
                                             supplier_id BIGINT,
                                             quantity BIGINT,
                                             unit_cost DECIMAL(8, 2),
                                             operation_type varchar(50),
                                             affected_rows int,
                                             execution_date datetime,
                                             sLogin nvarchar(256)
)


CREATE OR ALTER TRIGGER UpdateDelete_PartsInventory
    ON PartsInventory
    FOR UPDATE, DELETE
    AS
BEGIN
    DECLARE @operation CHAR(1)
    SET @operation = CASE
                         WHEN EXISTS(SELECT * FROM inserted) AND
                              EXISTS(SELECT * FROM deleted)
                             THEN 'UPDATE'
                         WHEN EXISTS(SELECT * FROM inserted)
                             THEN 'INSERT'
                         WHEN EXISTS(SELECT * FROM deleted)
                             THEN 'DELETE'
        END
    IF @operation IS NULL
        RETURN
    IF @operation = 'D'
        BEGIN
            INSERT INTO PartsInventoryLogsDelete (
                table_name, part_id, name, supplier_id, quantity, unit_cost,
                operation_type, affected_rows, execution_date, sLogin
            )
            SELECT
                'PartsInventory', d.part_id, d.name, d.supplier_id,d.quantity,d.unit_cost,
                @operation,@@ROWCOUNT, GETDATE(), SUSER_SNAME()
            FROM deleted d;
        END

    IF @operation = 'U'
        BEGIN
            INSERT INTO PartsInventoryLogsDelete (
                table_name, part_id, name, supplier_id, quantity, unit_cost,
                operation_type, affected_rows, execution_date, sLogin
            )
            SELECT
                'MaintenanceRecords',
                d.part_id,
                IIF(d.name <> i.name, d.name, NULL)                      AS name,
                IIF(d.supplier_id <> i.supplier_id, d.supplier_id, NULL) AS supplier_id,
                IIF(d.quantity <> i.quantity, d.quantity, NULL)          AS quantity,
                IIF(d.unit_cost <> i.unit_cost, d.unit_cost, NULL)       AS unit_cost,
                @operation,
                @@ROWCOUNT,
                GETDATE(),
                SUSER_SNAME()
            FROM deleted d
                     INNER JOIN inserted i ON d.part_id = i.part_id
            WHERE d.name <> i.name
               OR d.supplier_id <> i.supplier_id
               OR d.quantity <> i.quantity
               OR d.unit_cost <> i.unit_cost
        END
END


exec updatePartsInventory PartsInventory, 2, @name = 'nume nou', @quantity = 10
exec deletePartsInventory PartsInventory, 16
select * from PartsInventoryLogsDelete