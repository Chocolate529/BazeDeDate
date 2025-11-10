IF OBJECT_ID('dbo.Versions','U') IS NULL
    BEGIN
        CREATE TABLE dbo.Versions (
            current_version BIGINT NOT NULL,
            max_version BIGINT
        )
        INSERT into Versions(current_version) VALUES (0)
        UPDATE Versions set Versions.max_version = 5 WHERE Versions.max_version IS NULL
    END;

--PROC 1
-- Changes Suppliers name type to support Unicode
ALTER PROCEDURE do_proc_1
AS
BEGIN
    SET NOCOUNT ON;
ALTER TABLE Suppliers
ALTER COLUMN name nvarchar(255) NOT NULL
    PRINT 'Supplier name type changed to nvarchar(255) not null'
    UPDATE Versions SET current_version = 1 WHERE current_version = 0
    PRINT 'Updated to version 1'
END
GO

-- Chages Supplier name type back to varchar
ALTER PROCEDURE undo_proc_1
AS
BEGIN
ALTER TABLE Suppliers
ALTER COLUMN name varchar(255) NOT NULL
PRINT 'Supplier name type changed to varchar(255) not null'
UPDATE Versions SET current_version = 0 WHERE current_version = 1
PRINT 'Updated to version 0'

END
GO

--PROC 2
-- Add default value to Rentals return_status 'Active'
ALTER PROCEDURE do_proc_2
AS
BEGIN
ALTER TABLE Rentals
ADD CONSTRAINT df_Return_Status DEFAULT 'Active' FOR return_status
PRINT 'Added default value(Active) for return_status column in Rentals'
UPDATE Versions SET current_version = 2 WHERE current_version = 1
PRINT 'Updated to version 2'

END
GO

-- Drop default value to Rentals return_status 'Active'
ALTER PROCEDURE undo_proc_2
AS
BEGIN
    ALTER TABLE Rentals
    DROP CONSTRAINT df_Return_Status
    PRINT 'Dropped default value(Active) for return_status column in Rentals'
    UPDATE Versions SET current_version = 1 WHERE current_version = 2
    PRINT 'Updated to version 1'

END
GO

--PROC3
--Creates Reviews table
ALTER PROCEDURE do_proc_3
AS
BEGIN
    CREATE TABLE dbo.Reviews (
     review_id BIGINT IDENTITY(1,1) PRIMARY KEY,
     rating DECIMAL(10,2) NOT NULL,
     description VARCHAR(MAX) NULL,
     CONSTRAINT CK_Reviews_Rating_range CHECK (rating >= 0 AND rating <= 10),
    );
    PRINT 'Created Reviews table with auto-increment review_id, rating (0..10) and description';
    UPDATE Versions SET current_version = 3 WHERE current_version = 2
    PRINT 'Updated to version 3'

END
GO

-- Drop Reviews table
ALTER PROCEDURE undo_proc_3
AS
BEGIN
    DROP TABLE Reviews
    PRINT 'Droped Table Reviews'
    UPDATE Versions SET current_version = 2 WHERE current_version = 3
    PRINT 'Updated to version 2'

END
GO

--PROC 4
--Adds customer_id column to Reviews table
ALTER PROCEDURE do_proc_4
AS
BEGIN
    ALTER TABLE Reviews
    ADD customer_id BIGINT
    PRINT 'Added customer_id column to Reviews';
    UPDATE Versions SET current_version = 4 WHERE current_version = 3
    PRINT 'Updated to version 4'

END
GO

--Drops customer_id column from Reviews table
ALTER PROCEDURE undo_proc_4
AS
BEGIN
    ALTER TABLE Reviews
    DROP COLUMN customer_id
    PRINT 'Dropped customer_id column from Reviews';
    UPDATE Versions SET current_version = 3 WHERE current_version = 4
    PRINT 'Updated to version 3'

END
GO

--PROC 5
--Add foreign key constraint to customer_id column in Reviews table with reference to Customer(customer_id)
ALTER PROCEDURE do_proc_5
AS
BEGIN
   ALTER TABLE Reviews
    ADD CONSTRAINT fk_customer FOREIGN KEY(customer_id) REFERENCES Customers(customer_id)
    PRINT 'Added foreign key constraint for customer_id column in Reviews'
   UPDATE Versions SET current_version = 5 WHERE current_version = 4
   PRINT 'Updated to version 5'

END
GO

--Drops foreign key constraint from customer_id column in Reviews table
ALTER PROCEDURE undo_proc_5
AS
BEGIN
    ALTER TABLE Reviews
    DROP CONSTRAINT fk_customer
    PRINT 'Dropped foreign key constraint for customer_id column in Reviews'
    UPDATE Versions SET current_version = 4 WHERE current_version = 5
    PRINT 'Updated to version 4'

END
GO

exec do_proc_1
exec do_proc_2
exec do_proc_3
exec do_proc_4
exec do_proc_5


exec undo_proc_5
exec undo_proc_4
exec undo_proc_3
exec undo_proc_2
exec undo_proc_1


--Main switch version procedure accepts BIGINT input values which represent the version to switch to
CREATE OR ALTER PROCEDURE switch_version
    @to_version BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @current_version AS BIGINT
    DECLARE @max_version AS BIGINT

    SELECT @current_version = current_version, @max_version = Versions.max_version from Versions
    IF (@to_version > @max_version)
    BEGIN
        PRINT 'Maximum version is ' + CAST(@max_version AS VARCHAR(20))
    END ELSE IF (@to_version < 0)
    BEGIn
        PRINT 'Minimum version is 0'
    END ELSE IF (@to_version = @current_version)
    BEGIn
        PRINT 'Database already in version ' + CAST(@current_version AS VARCHAR(20))
    END ELSE
    BEGIN
        WHILE(@to_version != @current_version)
        BEGIN
            IF @to_version < @current_version
            BEGIn
                IF (@current_version = 5) EXEC undo_proc_5;
                ELSE IF (@current_version = 4) EXEC undo_proc_4;
                ELSE IF (@current_version = 3) EXEC undo_proc_3;
                ELSE IF (@current_version = 2) EXEC undo_proc_2;
                ELSE IF (@current_version = 1) EXEC undo_proc_1;

                SET @current_version = @current_version - 1;
            END
            ELSE
            BEGIN
                SET @current_version = @current_version + 1;

                IF (@current_version = 1) EXEC do_proc_1;
                ELSE IF (@current_version = 2) EXEC do_proc_2;
                ELSE IF (@current_version = 3) EXEC do_proc_3;
                ELSE IF (@current_version = 4) EXEC do_proc_4;
                ELSE IF (@current_version = 5) EXEC do_proc_5;
            END
        END
        UPDATE Versions
        SET current_version = @current_version WHERE max_version = @max_version;
        PRINT 'NEW CURRENT VERSION ' + CAST(@current_version AS VARCHAR(20));
    END
END

--test
exec switch_version -1
exec switch_version 6
exec switch_version 2
exec switch_version 5
exec switch_version 3
exec switch_version 0
exec switch_version 0


