/*
name=[item].[p_getPriceRule]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
YYALb+Zn97CcYFpbocctuQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getPriceRule]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getPriceRule]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getPriceRule]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [item].[p_getPriceRule]
@xmlVar XML
AS
BEGIN
SELECT (
	SELECT id AS ''@id'' ,name AS ''@name'',--[definition] AS ''@definition'',
		[procedure] AS ''@procedure'',[status] AS ''@status'', [version] AS ''@version'', [order] AS ''@order''
	FROM item.PriceRule
	ORDER BY [name] ASC
	FOR XML PATH(''priceRule''), TYPE
) FOR XML PATH(''root''), TYPE
	
END' 
END
GO
