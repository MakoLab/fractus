/*
name=[item].[p_getPriceRuleById]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
TtSN1qLQTEZfTLO46ukEAw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getPriceRuleById]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getPriceRuleById]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getPriceRuleById]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [item].[p_getPriceRuleById]
@xmlVar XML
AS

DECLARE @id UNIQUEIDENTIFIER

	SELECT @id = @xmlVar.value(''.'',''char(36)'')
	
	SELECT [definition]
	FROM item.PriceRule
	WHERE id = @id
' 
END
GO
