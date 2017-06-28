/*
name=[warehouse].[p_getContainerContent]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
elVno4Nz5BnoC3Kl+xlHIQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getContainerContent]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_getContainerContent]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getContainerContent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_getContainerContent]
@xmlVar XML
AS
BEGIN

	DECLARE
		@id uniqueidentifier,
		@i int, 
		@count int,
		@documentId uniqueidentifier,
		@containerId uniqueidentifier,
		@label varchar(50)

/*Parametry wejściowe*/
SELECT @id = @xmlVar.query(''*/containerId'').value(''.'',''char(36)'')	-- zmylka - moze byc id kontenera lub dokumentu

IF EXISTS (SELECT id FROM warehouse.Container WHERE id = @id) SET @containerId = @id
ELSE SET @documentId = @id

IF (@containerId IS NOT NULL)
	
	-- zwracamy wszystkie transze AKTUALNIE znajdujace sie na danym KONTENERZE
	SELECT GETDATE() AS ''@currentDateTime'', (
			SELECT  i.name ''@name'', i.code ''@code'', l.itemId ''@itemId'', l.id ''@incomeLineId'', dt.symbol + '' '' + h.fullNumber ''@incomeNumber'', h.issueDate ''@incomeDate'', st.number ''@shiftTransactionNumber'',s.id ''@shiftId'', st.issueDate ''@shiftDate'', s.quantity - ISNULL(x.q,0)  ''@quantity'' , l.price ''@price'', con.shortName ''@contractor'',
				C.xmlLabels.value(''(labels/label)[1]'',''varchar(50)'') AS ''@slot''
			FROM  warehouse.Shift s
				LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.status >= 40 GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId
				LEFT JOIN document.WarehouseDocumentLine l ON s.incomeWarehouseDocumentLineId = l.id
				LEFT JOIN document.WarehouseDocumentHeader h ON l.warehouseDocumentHeaderId = h.id
				LEFT JOIN contractor.Contractor con ON h.contractorId = con.id
				LEFT JOIN dictionary.DocumentType DT ON DT.id = H.documentTypeId
				JOIN item.Item i ON l.itemId = i.id
				JOIN warehouse.ShiftTransaction st ON s.shiftTransactionId = st.id
				LEFT JOIN warehouse.Container C ON C.id = S.containerId
			WHERE
				(s.quantity - ISNULL(x.q,0)) > 0
				AND @containerId = s.containerId AND s.status >= 40
			ORDER BY st.number 
			FOR XML PATH(''lines''),TYPE
	)   FOR XML PATH(''root''),TYPE 

ELSE IF EXISTS (SELECT id FROM configuration.Configuration WHERE [key] = ''warehouse.isWmsEnabled'' AND textValue = ''false'')
	BEGIN
		SELECT GETDATE() AS ''@currentDateTime'',(
			SELECT  i.name ''@name'', i.code ''@code'', l.itemId ''@itemId'', l.id ''@incomeLineId'', dt.symbol + '' '' + h.fullNumber ''@incomeNumber'', 
					h.issueDate ''@incomeDate'', null ''@shiftTransactionNumber'', newid() ''@shiftId'', getdate() ''@shiftDate'', 
					l.quantity ''@quantity'' , l.price ''@price'', con.shortName ''@contractor'' 
			FROM  document.WarehouseDocumentLine l 
				LEFT JOIN document.WarehouseDocumentHeader h ON l.warehouseDocumentHeaderId = h.id
				LEFT JOIN contractor.Contractor con ON h.contractorId = con.id
				LEFT JOIN dictionary.DocumentType DT ON DT.id = H.documentTypeId
				JOIN item.Item i ON l.itemId = i.id
				
			WHERE
				h.status >= 40 AND 
				l.warehouseDocumentHeaderId = @documentId
			ORDER BY l.ordinalNumber 
			FOR XML PATH(''lines''),TYPE
	)   FOR XML PATH(''root''),TYPE 	
	END
ELSE
	-- zwracamy wszystkie transze PIERWOTNIE przyjete danym DOKUMENTEM
	SELECT GETDATE() AS ''@currentDateTime'', (
			SELECT  i.name ''@name'', i.code ''@code'', l.itemId ''@itemId'', l.id ''@incomeLineId'', dt.symbol + '' '' + h.fullNumber ''@incomeNumber'', h.issueDate ''@incomeDate'', st.number ''@shiftTransactionNumber'',s.id ''@shiftId'', st.issueDate ''@shiftDate'', s.quantity ''@quantity'' , l.price ''@price'', con.shortName ''@contractor'',
				C.xmlLabels.value(''(labels/label)[1]'',''varchar(50)'') AS ''@slot''
			FROM  warehouse.Shift s
				LEFT JOIN document.WarehouseDocumentLine l ON s.incomeWarehouseDocumentLineId = l.id
				LEFT JOIN document.WarehouseDocumentHeader h ON l.warehouseDocumentHeaderId = h.id
				LEFT JOIN contractor.Contractor con ON h.contractorId = con.id
				LEFT JOIN dictionary.DocumentType DT ON DT.id = H.documentTypeId
				JOIN item.Item i ON l.itemId = i.id
				JOIN warehouse.ShiftTransaction st ON s.shiftTransactionId = st.id
				LEFT JOIN warehouse.Container C ON C.id = S.containerId
			WHERE
				s.status >= 40 AND 
				s.warehouseDocumentLineId IN (SELECT id FROM document.WarehouseDocumentLine WHERE warehouseDocumentHeaderId = @documentId)
			ORDER BY st.number 
			FOR XML PATH(''lines''),TYPE
	)   FOR XML PATH(''root''),TYPE 	
	-- [warehouse].[p_getContainerContent] ''<params><containerId>6ADFA297-D3A1-4E3E-83B1-19F33938FFA4</containerId></params>''
END
' 
END
GO
