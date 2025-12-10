CREATE TABLE MaintanancePartsLogsDelete(
                                             log_id BIGINT PRIMARY KEY IDENTITY ,
                                             table_name varchar(100),
                                             record_id BIGINT,
                                             part_id BIGINT,
                                             quantity_used BIGINT,
                                             operation_type varchar(50),
                                             affected_rows int,
                                             execution_date datetime,
                                             sLogin nvarchar(256)
)
CREATE OR ALTER TRIGGER UpdateDelete_MaintananceParts
    ON MaintenanceParts
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
            INSERT INTO MaintanancePartsLogsDelete (
                table_name, record_id,part_id, quantity_used,
                operation_type, affected_rows, execution_date, sLogin
            )
            SELECT
                'MaintenanceParts', d.record_id, d.part_id ,d.quantity_used, @operation,
                @@ROWCOUNT, GETDATE(), SUSER_SNAME()
            FROM deleted d;
        END

    IF @operation = 'U'
        BEGIN
            INSERT INTO MaintanancePartsLogsDelete (
                table_name, record_id,
                part_id, quantity_used,
                operation_type, affected_rows, execution_date, sLogin
            )
            SELECT
                'MaintenanceParts',
                d.record_id,
                d.part_id,
                IIF(d.quantity_used <> i.quantity_used, d.quantity_used, NULL) AS service_date,
                @operation,
                @@ROWCOUNT,
                GETDATE(),
                SUSER_SNAME()
            FROM deleted d
                     INNER JOIN inserted i ON d.record_id = i.record_id and d.part_id = i.part_id
            WHERE d.quantity_used <> i.quantity_used
        END
END

    exec updateMaintananceParts MaintenanceParts, 10
    exec deleteMaintananceParts MaintenanceParts, 10
    SELECT * FROM MaintenanceParts
    SELECT * FROM MaintanancePartsLogsDelete

