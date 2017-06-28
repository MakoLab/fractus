/*
name=[custom].[makolabGetItemGroupDiscount]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
kirkhAXbknl0KKUlnOzKZQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[makolabGetItemGroupDiscount]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [custom].[makolabGetItemGroupDiscount]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[makolabGetItemGroupDiscount]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

CREATE FUNCTION [custom].[makolabGetItemGroupDiscount] ( @p_ItemGroupId uniqueidentifier)
RETURNS DECIMAL(18,2)
AS
BEGIN
	DECLARE @r_Discount DECIMAL(18,2);
	SET @r_Discount = 0;

	SELECT 
	    @r_Discount =
	    (
		    SELECT CAST(Tab.Col.value(''(action/value)[1]'', ''varchar(500)'') AS DECIMAL(18,2)) AS Discount
			FROM definition.nodes(''/root/actions'') AS Tab(Col)
			CROSS APPLY Tab.Col.nodes(''action'') AS Tab1(Col1)
			WHERE Tab1.Col1.value(''@name'', ''varchar(500)'') = ''discoutRateValue''
		) 
	FROM
	item.PriceRule


    RETURN ISNULL(@r_Discount, 0);
END

' 
END

GO
