--- M:N (MaintananceRecords : PartsINventory  - MaintananceParts)


CREATE OR ALTER FUNCTION checkTableExistance(
    @table_name VARCHAR(100)
) RETURNS INT
    AS
    BEGIN
        IF OBJECT_ID(@table_name,'U') IS NULL
        BEGin
            return -1
        end
        return 1
    end

CREATE OR ALTER PROCEDURE checkExistKeyInTable
    @table_name VARCHAR(100),
    @column_name VARCHAR(100),
    @key_value BIGINT,
    @key_exists INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @sql NVARCHAR(MAX);

    SET @sql = N'SELECT @CountOut = COUNT(*)
                 FROM ' + QUOTENAME(@table_name) + N' T
                 WHERE T.' + QUOTENAME(@column_name) + N' = @ValueIn;';

    EXEC sp_executesql
         @sql,
         N'@CountOut INT OUTPUT, @ValueIn BIGINT',
         @CountOut = @key_exists OUTPUT,
         @ValueIn = @key_value;
END
GO

CREATE OR ALTER FUNCTION checkDesciptionNotEmpty(
    @description NVARCHAR(MAX)
)RETURNS INT
AS
BEGIN
    IF @description IS NULL
        BEGIN
            RETURN -1;
        END
    IF LTRIM(RTRIM(@description)) = ''
        BEGIN
            RETURN -1;
        END
    RETURN 1;
END
GO

CREATE OR ALTER PROCEDURE insertMaintananceRecord
    @table_name Varchar(50),
    @truck_id BIGINT,
    @service_date DATE,
    @description TEXT,
    @cost DECIMAL(10, 2),
    @employee_id BIGINT,
    @noOfRows int
AS
BEGIN
    SET NOCOUNT ON;

    if dbo.checkTableExistance(@table_name) < 0
    BEGIN
        PRINT 'Table does not exist'
        return
    end

    if dbo.checkDesciptionNotEmpty(@description) < 0
        BEGIN
            PRINT 'Description can not be empty'
            return
        end

    DECLARE @result INT
    exec checkExistKeyInTable 'PalletTrucks', 'truck_id', @truck_id, @result OUTPUT
    if @result = 0
        BEGIN
            PRINT 'Provided fk value for truck id does not exista in the PalletTrucks table'
            return
        end

    exec checkExistKeyInTable 'Employees', 'employee_id', @employee_id, @result OUTPUT

    if @result = 0
        BEGIN
            PRINT 'Provided fk value for employee id does not exista in the Employees table'
            return
        end

    declare @n int =1
    while @n<=@noOfRows begin
        insert into MaintenanceRecords(truck_id, service_date, description, cost, employee_id)
        Values(@truck_id, @service_date, @description, @cost, @employee_id)
        set @n=@n+1
    end
    print 'INSERT operation for table ' + @table_name
END


---SELECT
CREATE OR ALTER PROCEDURE selectMaintanceRecords
    @table_name Varchar(50)
AS
BEGIN
    if dbo.checkTableExistance(@table_name) < 0
        BEGIN
            PRINT 'Table does not exist'
            return
        end
    select * from MaintenanceRecords
    print 'SELECT operation for table ' + @table_name
END

-- UPDATE
CREATE OR ALTER PROCEDURE updateMaintananceRecords
    @table_name Varchar(50),
    @record_id BIGINT,
    @truck_id BIGINT = null,
    @service_date DATE = null,
    @description TEXT = null,
    @cost DECIMAL(10, 2) = null,
    @employee_id BIGINT = null
AS
BEGIN
    SET NOCOUNT ON;
    if dbo.checkTableExistance(@table_name) < 0
        BEGIN
            PRINT 'Table does not exist'
            return
        end

    DECLARE @result INT
    exec checkExistKeyInTable MaintenanceRecords, 'record_id', @record_id, @result OUTPUT

    if @result = 0
        BEGIN
            PRINT 'Provided key value does not exista in the MaintananceRecords table'
            return
        end

    if @truck_id is not null
        BEGIN
            exec checkExistKeyInTable 'PalletTrucks', 'truck_id', @truck_id, @result OUTPUT

            if @result = 0
                BEGIN
                    PRINT 'Provided fk value for truck id does not exista in the PalletTrucks table'
                    return
                end
        end
    else
        select @truck_id=truck_id from MaintenanceRecords where record_id = @record_id


    if @employee_id is not null
        BEGIN
            exec checkExistKeyInTable 'Employees', 'employee_id', @employee_id, @result OUTPUT

            if @result = 0
                BEGIN
                    PRINT 'Provided fk value for employee id does not exista in the Employees table'
                    return
                end
        end
    else
        select @employee_id=employee_id from MaintenanceRecords where record_id = @record_id

    if @description is not null
        BEGIN
            if dbo.checkDesciptionNotEmpty(@description) < 0
                BEGIN
                    PRINT 'Description can not be empty'
                    return
                end
        end
    else
        select @description=description from MaintenanceRecords where record_id = @record_id

    if @service_date is null select @service_date=service_date from MaintenanceRecords where record_id = @record_id
    if @cost is null select @cost=cost from MaintenanceRecords where record_id = @record_id

    update MaintenanceRecords
    set truck_id = @truck_id,
        service_date = @service_date,
        description = @description,
        cost = @cost,
        employee_id = @employee_id
    where record_id = @record_id

    print 'UPDATE operation for table ' + @table_name
END

-- DELETE
CREATE OR ALTER PROCEDURE deleteMaintananceRecords
    @table_name Varchar(50),
    @record_id BIGINT
AS
BEGIN
    DECLARE @result INT
    exec checkExistKeyInTable MaintenanceRecords, 'record_id', @record_id, @result OUTPUT

    if @result = 0
        BEGIN
            PRINT 'Provided key value does not exista in the MaintananceRecords table'
            return
        end

    DECLARE @relations INT = 0
    SELECT @relations=COUNT(*)
    FROM MaintenanceParts
    WHERE record_id = @record_id

    if @relations > 0
        BEGIN
            PRINT 'Can not delete there relations with this entry'
            return
        end

    delete from MaintenanceRecords
    where record_id=@record_id

    print 'DELETE operation for table ' + @table_name
END

EXEC insertMaintananceRecord
     @table_name = 'MaintenanceRecords',
     @truck_id = 20,
     @service_date = '2025-12-09',
     @description = 'Routine winter service and lubrication.',
     @cost = 150.00,
     @employee_id = 1,   -- Assumed to exist
     @noOfRows = 3;

exec selectMaintanceRecords MaintenanceRecords

exec updateMaintananceRecords MaintenanceRecords, 18
exec updateMaintananceRecords MaintenanceRecords, 17, @description = 'descriere noua'

exec deleteMaintananceRecords MaintenanceRecords, 17