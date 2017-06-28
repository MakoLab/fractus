/*
name=[document].[p_hasOutcomeAnyCommercialRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
SuH05cT48v0YaTPHcDSg7A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_hasOutcomeAnyCommercialRelation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_hasOutcomeAnyCommercialRelation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_hasOutcomeAnyCommercialRelation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_hasOutcomeAnyCommercialRelation] 
@id uniqueidentifier
AS
BEGIN
	IF EXISTS (
			SELECT cr.id 
			FROM document.WarehouseDocumentLine wl WITH(NOLOCK)
				JOIN document.CommercialWarehouseRelation cr WITH(NOLOCK) ON wl.id = cr.warehouseDocumentLineId AND isCommercialRelation = 1
			WHERE wl.warehouseDocumentHeaderId = @id
			)
		SELECT CAST(''<root>true</root>'' AS XML)
	ELSE
		SELECT CAST(''<root>false</root>'' AS XML)
END
' 
END
GO
