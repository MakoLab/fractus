/*
name=[custom].[makolabSplitDiscountItemGroup]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
03CFUQ2PCb8RwGxb3WEHZg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[makolabSplitDiscountItemGroup]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [custom].[makolabSplitDiscountItemGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[makolabSplitDiscountItemGroup]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [custom].[makolabSplitDiscountItemGroup]
(
    -- Add the parameters for the function here
    @myString NVARCHAR(4000),
    @deliminator varchar(10),
	@DISCOUNT DECIMAL(18,2)
)
RETURNS 
@ReturnTable TABLE 
(
    -- Add the column definitions for the TABLE variable here
    [Id]          [INT] IDENTITY(1,1) NOT NULL,
    [ItemGroupId] [NVARCHAR](4000) NULL,
	[Discount]    [DECIMAL](18,2) NULL
)
AS
BEGIN
        Declare @iSpaces int
        Declare @part NVARCHAR(4000)

        --initialize spaces
        Select @iSpaces = charindex(@deliminator,@myString,0)
        While @iSpaces > 0

        Begin
            Select @part = substring(@myString,0,charindex(@deliminator,@myString,0))

            Insert Into @ReturnTable(ItemGroupId, Discount)
            Select @part, @DISCOUNT

            Select @myString = substring(@mystring,charindex(@deliminator,@myString,0)+ len(@deliminator),len(@myString) - charindex('' '',@myString,0))

            Select @iSpaces = charindex(@deliminator, @myString, 0)
        end

        If len(@myString) > 0
            Insert Into @ReturnTable
            Select @myString, @DISCOUNT

    RETURN 
END

' 
END

GO
