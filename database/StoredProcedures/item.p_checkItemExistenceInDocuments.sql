/*
name=[item].[p_checkItemExistenceInDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
fLwirya9Un85ex4TzfuxxA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_checkItemExistenceInDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_checkItemExistenceInDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_checkItemExistenceInDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_checkItemExistenceInDocuments] @itemId UNIQUEIDENTIFIER
AS
BEGIN

IF EXISTS(SELECT id FROM document.CommercialDocumentLine WHERE itemId = @itemId) 
		OR EXISTS (SELECT id FROM document.WarehouseDocumentLine WHERE itemId = @itemId)
	SELECT CAST(''<root>true</root>'' AS XML)
ELSE
	SELECT CAST(''<root>false</root>'' AS XML)
END
' 
END
GO
