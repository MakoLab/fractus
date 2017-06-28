/*
name=[document].[p_hasIncomeAnyOutcome]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
MzWw7aokRKdB1j1HfFi5Yw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_hasIncomeAnyOutcome]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_hasIncomeAnyOutcome]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_hasIncomeAnyOutcome]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_hasIncomeAnyOutcome] 
@id uniqueidentifier
AS
BEGIN
	IF EXISTS (
			SELECT ir.id 
			FROM document.WarehouseDocumentLine wl WITH(NOLOCK)
				JOIN document.IncomeOutcomeRelation ir WITH(NOLOCK) 
					ON wl.id = ir.incomeWarehouseDocumentLineId
			WHERE wl.warehouseDocumentHeaderId = @id
			)
		SELECT CAST(''<root>true</root>'' AS XML)
	ELSE
		SELECT CAST(''<root>false</root>'' AS XML)
END
' 
END
GO
