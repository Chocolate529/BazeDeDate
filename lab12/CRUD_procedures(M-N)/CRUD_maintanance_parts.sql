
CREATE OR ALTER FUNCTION checkQuantityPositive(@quantity BIGINT)
    RETURNS INT
AS
BEGIN
    if @quantity < 0 return -1
    return 1
end

CREATE OR ALTER PROCEDURE checkExistRelationMaintananceParts(
    @part_id BIGINT,
    @record_id BIGINT,
    @result INT OUTPUT
) AS
    BEGIN
        SELECT @result=COUNT(*)
        FROM MaintenanceParts
        WHERE part_id = @part_id and record_id= @record_id
    end

CREATE OR ALTER PROCEDURE insertMaintananceParts
    @table_name Varchar(50),
    @part_id BIGINT,
    @record_id BIGINT,
    @quantity BiGINT
AS
BEGIN
    SET NOCOUNT ON;

    if dbo.checkTableExistance(@table_name) < 0
        BEGIN
            PRINT 'Table does not exist'
            return
        end

    if dbo.checkQuantityPositive (@quantity ) < 0
        BEGIN
            PRINT 'Quantity must be positive'
            return
        end

    DECLARE @result INT
    exec checkExistKeyInTable PartsInventory, 'part_id', @part_id, @result OUTPUT

    if @result = 0
        BEGIN
            PRINT 'Provided key value does not exista in the PartsInventory table'
            return
        end

    exec checkExistKeyInTable MaintenanceRecords, 'record_id', @record_id, @result OUTPUT

    if @result = 0
        BEGIN
            PRINT 'Provided key value does not exista in the MaintananceRecords table'
            return
        end

    exec checkExistRelationMaintananceParts
    @part_id, @record_id, @result OUTPUT
    if @result != 0
        BEGIN
            PRINT 'Entry already exists'
            return
        end


        insert into MaintenanceParts(part_id,record_id,quantity_used)
        Values(@part_id,@record_id, @quantity)
    print 'INSERT operation for table ' + @table_name
END


---SELECT
CREATE OR ALTER PROCEDURE selectMaintanceParts
@table_name Varchar(50)
AS
BEGIN
    if dbo.checkTableExistance(@table_name) < 0
        BEGIN
            PRINT 'Table does not exist'
            return
        end
    select * from MaintenanceParts
    print 'SELECT operation for table ' + @table_name
END

-- UPDATE
CREATE OR ALTER PROCEDURE updateMaintananceParts
    @table_name Varchar(50),
    @part_id BIGINT = null,
    @record_id BIGINT = null,
    @quantity BiGINT
AS
BEGIN
    SET NOCOUNT ON;
    if dbo.checkTableExistance(@table_name) < 0
        BEGIN
            PRINT 'Table does not exist'
            return
        end

    if @part_id is null and @record_id is null
        BEGIN
            Print 'Both ids can not be null '
            return
        end
    DECLARE @result INT

    if dbo.checkQuantityPositive (@quantity ) < 0
        BEGIN
            PRINT 'Quantity must be positive'
            return
        end
    if @part_id is null and @record_id is not null
        BEGin
            update MaintenanceParts
            set quantity_used = @quantity
            where @record_id = record_id
        end
    else if @part_id is not null and @record_id is null
        BEGIN
            update MaintenanceParts
            set quantity_used = @quantity
            where part_id = @part_id
        end
    else
        BEGIN
            update MaintenanceParts
            set quantity_used = @quantity
            where part_id = @part_id and @record_id = record_id
        end
    print 'UPDATE operation for table ' + @table_name
END

-- DELETE
CREATE OR ALTER PROCEDURE deleteMaintananceParts
    @table_name Varchar(50),
    @part_id BIGINT = null,
    @record_id BIGINT = null
AS
BEGIN
    SET NOCOUNT ON;
    if dbo.checkTableExistance(@table_name) < 0
        BEGIN
            PRINT 'Table does not exist'
            return
        end

    if @part_id is null and @record_id is null
        BEGIN
            Print 'Both ids can not be null '
            return
        end
    DECLARE @result INT
    if @part_id is null and @record_id is not null
        BEGin
            exec checkExistKeyInTable MaintenanceParts, 'record_id', @record_id, @result OUTPUT

            if @result = 0
                BEGIN
                    PRINT 'Provided key value does not exista in the MaintananceParts table'
                    return
                end

            delete from MaintenanceParts
            where @record_id = record_id
        end
    else if @part_id is not null and @record_id is null
        BEGIN
            exec checkExistKeyInTable MaintenanceParts, 'part_id', @part_id, @result OUTPUT

            if @result = 0
                BEGIN
                    PRINT 'Provided key value does not exista in the MaintananceParts table'
                    return
                end


            delete from  MaintenanceParts
            where part_id = @part_id
        end
    else
        BEGIN
            exec checkExistRelationMaintananceParts
                 @part_id, @record_id, @result OUTPUT
            if @result = 0
                BEGIN
                    PRINT 'Entry does not exist'
                    return
                end

            delete from  MaintenanceParts
            where part_id = @part_id and @record_id = record_id
        end

    print 'DELETE operation for table ' + @table_name
END

EXEC insertMaintananceParts
     @table_name = MaintenanceParts,
     @part_id = 10,
     @record_id = 15,
    @quantity = 20

exec selectMaintanceParts MaintenanceParts

exec updateMaintananceParts MaintenanceParts, 10, @quantity = 123
exec updateMaintananceParts MaintenanceParts, @record_id = 15, @quantity = 12

exec deleteMaintananceParts PartsInventory, @record_id = 12
exec deleteMaintananceParts PartsInventory, 15
exec deleteMaintananceParts PartsInventory, 100
exec deleteMaintananceParts PartsInventory, @record_id = 100
exec deleteMaintananceParts PartsInventory, 100,100
exec deleteMaintananceParts PartsInventory, 13,13