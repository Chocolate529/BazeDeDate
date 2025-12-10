
CREATE OR ALTER FUNCTION checkUnitCostPositive(@unit_cost DECIMAL(8,2))
RETURNS INT
    AS
    BEGIN
        if @unit_cost < 0 return -1
        return 1
    end

CREATE OR ALTER FUNCTION checkNameNotEmpty(@name VARCHAR(255))
RETURNS INT
    AS
    BEGIN
        IF @name IS NULL
            BEGIN
                RETURN -1;
            END
        IF LTRIM(RTRIM(@name)) = ''
            BEGIN
                RETURN -1;
            END
        RETURN 1;
    end

CREATE OR ALTER PROCEDURE insertPartsInventory
    @table_name Varchar(50),
    @name VARCHAR(255),
    @supplier_id BIGINT,
    @quantity BIGINT,
    @unit_cost DECIMAL(8,2),
    @noOfRows int
AS
BEGIN
    SET NOCOUNT ON;

    if dbo.checkTableExistance(@table_name) < 0
        BEGIN
            PRINT 'Table does not exist'
            return
        end

    if dbo.checkNameNotEmpty (@name) < 0
        BEGIN
            PRINT 'Name can not be empty'
            return
        end

    if dbo.checkUnitCostPositive(@unit_cost ) < 0
        BEGIN
            PRINT 'Unit cost must be positive'
            return
        end

    DECLARE @result INT
    exec checkExistKeyInTable Suppliers, 'supplier_id', @supplier_id, @result OUTPUT
    if @result = 0
        BEGIN
            PRINT 'Provided fk value for supplier id does not exist in the Suppliers table'
            return
        end

    declare @n int =1
    while @n<=@noOfRows begin
        insert into PartsInventory(name ,supplier_id ,quantity ,unit_cost)
        Values(@name,@supplier_id,@quantity,@unit_cost)
        set @n=@n+1
    end
    print 'INSERT operation for table ' + @table_name
END


---SELECT
CREATE OR ALTER PROCEDURE selectPartsInventory
@table_name Varchar(50)
AS
BEGIN
    if dbo.checkTableExistance(@table_name) < 0
        BEGIN
            PRINT 'Table does not exist'
            return
        end
    select * from PartsInventory
    print 'SELECT operation for table ' + @table_name
END

-- UPDATE
CREATE OR ALTER PROCEDURE updatePartsInventory
    @table_name Varchar(50),
    @part_id BIGINT,
    @name VARCHAR(255) = null,
    @supplier_id BIGINT = null,
    @quantity BIGINT = null,
    @unit_cost DECIMAL(8,2) = null
AS
BEGIN
    SET NOCOUNT ON;
    if dbo.checkTableExistance(@table_name) < 0
        BEGIN
            PRINT 'Table does not exist'
            return
        end

    DECLARE @result INT
    exec checkExistKeyInTable PartsInventory, 'part_id', @part_id, @result OUTPUT

    if @result = 0
        BEGIN
            PRINT 'Provided key value does not exista in the PartsInventory table'
            return
        end

    if @supplier_id is not null
        BEGIN
            exec checkExistKeyInTable 'Suppliers', 'supplier_id', @supplier_id, @result OUTPUT

            if @result = 0
                BEGIN
                    PRINT 'Provided fk value for supplier id does not exista in the Suppliers table'
                    return
                end
        end
    else
        select @supplier_id=supplier_id from PartsInventory where part_id = @part_id

    if @name is not null
        BEGIN
            if dbo.checkNameNotEmpty (@name) < 0
                BEGIN
                    PRINT 'Name can not be empty'
                    return
                end
        end
    else
        select @name=name from PartsInventory where part_id = @part_id

    if @unit_cost is not null
        BEGIN
            if dbo.checkUnitCostPositive(@unit_cost ) < 0
                BEGIN
                    PRINT 'Unit cost must be positive'
                    return
                end
        end
    else
        select @unit_cost=unit_cost FROM PartsInventory where part_id = @part_id

    if @quantity is null select @quantity=quantity from PartsInventory where part_id = @part_id

    update PartsInventory
    set supplier_id = @supplier_id,
        name = @name,
        quantity = @quantity,
        unit_cost = @unit_cost
    where part_id = @part_id

    print 'UPDATE operation for table ' + @table_name
END

-- DELETE
CREATE OR ALTER PROCEDURE deletePartsInventory
    @table_name Varchar(50),
    @part_id BIGINT
AS
BEGIN
    DECLARE @result INT
    exec checkExistKeyInTable PartsInventory, 'part_id', @part_id, @result OUTPUT

    if @result = 0
        BEGIN
            PRINT 'Provided key value does not exista in the PartsInventory table'
            return
        end

    DECLARE @relations INT = 0
    SELECT @relations=COUNT(*)
    FROM MaintenanceParts
    WHERE part_id = @part_id

    if @relations > 0
        BEGIN
            PRINT 'Can not delete there relations with this entry'
            return
        end

    delete from PartsInventory
    where part_id=@part_id

    print 'DELETE operation for table ' + @table_name
END

EXEC insertPartsInventory
     @table_name = 'PartsInventory',
     @name = 'Part',
     @supplier_id = 10,
     @quantity = 150,
     @unit_cost = 2.2,
     @noOfRows = 3;

exec selectPartsInventory PartsInventory

exec updatePartsInventory PartsInventory, 19
exec updatePartsInventory PartsInventory, 17, @name = 'nume nou'
exec updatePartsInventory PartsInventory, 17, @name = 'das', @unit_cost = -2

exec deletePartsInventory PartsInventory, 12