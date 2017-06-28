/*
name=[item].[p_deletePriceRule]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
QziekmHAFVxzF14que9eeA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_deletePriceRule]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_deletePriceRule]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_deletePriceRule]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


CREATE PROCEDURE item.p_deletePriceRule
@xmlVar XML
AS
BEGIN
DECLARE @id uniqueidentifier

SELECT @id = @xmlVar.query(''root'').value(''.'',''char(36)'')

DELETE FROM item.PriceRule WHERE id = @id
EXEC  item.p_getPriceRule ''<root/>''
	
END' 
END
GO
