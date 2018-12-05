USE AdventureWorks2012
GO

IF OBJECT_ID('[HumanResources].[dEmployee]', 'TR') IS NOT NULL
	DROP TRIGGER [HumanResources].[dEmployee]
GO

USE [AdventureWorks2012]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [HumanResources].[dEmployee] ON [HumanResources].[Employee] 
	INSTEAD OF DELETE 
AS 

BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN
        RAISERROR
            (N'Employees cannot be deleted. They can only be marked as not current.', -- Message
            10, -- Severity.
            1); -- State.

        -- Rollback any active or uncommittable transactions
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END
    END;
END;

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'INSTEAD OF DELETE trigger which keeps Employees from being deleted.' , @level0type=N'SCHEMA',@level0name=N'HumanResources', @level1type=N'TABLE',@level1name=N'Employee', @level2type=N'TRIGGER',@level2name=N'dEmployee'
GO

