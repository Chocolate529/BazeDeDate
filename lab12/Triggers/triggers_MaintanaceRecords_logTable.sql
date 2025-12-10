CREATE TABLE MaintananceRecordsLogsDelete(
    log_id BIGINT PRIMARY KEY IDENTITY ,
    table_name varchar(100),
    record_id BIGINT,
    truck_id BIGINT,
    service_date DATETIME,
    description varchar(max),
    cost DECIMAL(10, 2),
    employee_id BIGINT,
    operation_type varchar(50),
    affected_rows int,
    execution_date datetime,
    sLogin nvarchar(256)
)
CREATE OR ALTER TRIGGER UpdateDelete_MaintananceRecords
    ON MaintenanceRecords
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
            INSERT INTO MaintananceRecordsLogsDelete (
                table_name, record_id, truck_id, service_date, description, cost, employee_id,
                operation_type, affected_rows, execution_date, sLogin
            )
            SELECT
                'MaintenanceRecords', d.record_id, d.truck_id, d.service_date,
                d.description, d.cost, d.employee_id, @operation,
                @@ROWCOUNT, GETDATE(), SUSER_SNAME()
            FROM deleted d;
        END

    IF @operation = 'U'
        BEGIN
            INSERT INTO MaintananceRecordsLogsDelete (
                table_name, record_id,
                truck_id, service_date, description, cost, employee_id,
                operation_type, affected_rows, execution_date, sLogin
            )
            SELECT
                'MaintenanceRecords',
                d.record_id,
                IIF(d.truck_id <> i.truck_id, d.truck_id, NULL)             AS truck_id,
                IIF(d.service_date <> i.service_date, d.service_date, NULL) AS service_date,
                IIF(d.description <> i.description, d.description, NULL)    AS description,
                IIF(d.cost <> i.cost, d.cost, NULL)                         AS cost,
                IIF(d.employee_id <> i.employee_id, d.employee_id, NULL)    AS employee_id,
                @operation,
                @@ROWCOUNT,
                GETDATE(),
                SUSER_SNAME()
            FROM deleted d
                     INNER JOIN inserted i ON d.record_id = i.record_id
            WHERE d.truck_id <> i.truck_id
               OR d.service_date <> i.service_date
               OR d.description <> i.description
               OR d.cost <> i.cost
               OR d.employee_id <> i.employee_id;
        END
END

exec updateMaintananceRecords MaintenanceRecords, 15, @description = 'asda'
exec deleteMaintananceRecords MaintenanceRecords, 16
SELECT * FROM MaintananceRecordsLogsDelete

