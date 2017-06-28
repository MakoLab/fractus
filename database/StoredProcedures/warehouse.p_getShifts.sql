/*
name=[warehouse].[p_getShifts]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ukIHyA3PkUScRK53oXly7Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getShifts]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_getShifts]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getShifts]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_getShifts] @xmlVar XML
AS
BEGIN
	DECLARE
		@dateFrom VARCHAR(50),
		@dateTo VARCHAR(50),
		@warehouseId uniqueidentifier,
		@itemId uniqueidentifier,
		@userId uniqueidentifier

	DECLARE @tmp_ TABLE (id uniqueidentifier)

	INSERT INTO @tmp_ (id)
	SELECT x.value(''.'', ''uniqueidentifier'') 
	FROM @xmlVar.nodes(''/*/incomeId'') a(x)
	
	SELECT
		@dateFrom = NULLIF(x.query(''dateFrom'').value(''.'', ''VARCHAR(50)''),''''),
		@dateTo = NULLIF(x.query(''dateTo'').value(''.'', ''VARCHAR(50)''),''''),
		@warehouseId = NULLIF(x.query(''warehouseId'').value(''.'', ''char(36)''),''''),
		@itemId = NULLIF(x.query(''itemId'').value(''.'', ''char(36)''),''''),
		@userId = NULLIF(x.query(''userId'').value(''.'', ''char(36)''),'''')
	FROM
		@xmlVar.nodes(''/*'') a(x)
		
	SELECT
	(
		SELECT
			DT.symbol + '' '' + H.fullNumber ''@incomeDocumentNumber'',
			I.code ''@itemCode'',
			I.name ''@itemName'',
			S.id ''@shiftId'',
			S.quantity ''@quantity'',
			ST.id ''@shiftTransactionId'',
			S.warehouseId ''@warehouseId'',
			S.containerId ''@containerId'',
			C.xmlLabels.query(''/*/label[1]'').value(''.'', ''varchar(100)'') ''@containerLabel'',
			SRC.containerId ''@sourceContainerId'',
			SRCC.xmlLabels.query(''/*/label[1]'').value(''.'', ''varchar(100)'') ''@sourceContainerLabel'',
			S.status ''@status'',
			ST.applicationuserId ''@userId'',
			ST.issueDate ''@date'',
			ST.description ''@desctiption'',
			ST.reasonId ''@reasonId'',
			DDT.symbol + '' '' + DH.fullNumber ''@documentNumber'',
			DH.id ''@documentId''
		FROM warehouse.Shift S
		LEFT JOIN warehouse.Container C ON C.id = S.containerId
		LEFT JOIN warehouse.Shift SRC ON SRC.id = S.sourceShiftId
		LEFT JOIN warehouse.Container SRCC ON SRCC.id = SRC.containerId
		JOIN warehouse.ShiftTransaction ST ON ST.id = S.shiftTransactionId
		JOIN document.WarehouseDocumentLine L ON L.id = S.incomeWarehouseDocumentLineId
		JOIN document.WarehouseDocumentHeader H ON H.id = L.warehouseDocumentHeaderId
		JOIN dictionary.DocumentType DT ON DT.id = H.documentTypeId
		JOIN item.Item I ON I.id = L.itemId
		LEFT JOIN document.WarehouseDocumentLine DL ON DL.id = S.warehouseDocumentLineId
		LEFT JOIN document.WarehouseDocumentHeader DH ON DH.id = DL.warehouseDocumentHeaderId
		LEFT JOIN dictionary.DocumentType DDT ON DDT.id = DH.documentTypeId
		WHERE
			(@dateFrom IS NULL OR (ST.issueDate BETWEEN @dateFrom AND @dateTo))
			AND (NOT EXISTS (SELECT id FROM @tmp_) OR S.incomeWarehouseDocumentLineId IN (SELECT id FROM @tmp_))
			AND NULLIF(@warehouseId, S.warehouseId) IS NULL
			AND NULLIF(@itemId, L.itemId) IS NULL
			AND NULLIF(@userId, ST.applicationUserId) IS NULL
		ORDER BY ST.number ASC, S.ordinalNumber ASC
		FOR XML PATH(''shift''), TYPE
	)
	FOR XML PATH(''shifts''), TYPE
END
' 
END
GO
