/*
name=[custom].[p_WMS_validateDocument]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
wAivGSBQzsoZHcHDsozGxQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_WMS_validateDocument]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_WMS_validateDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_WMS_validateDocument]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


CREATE PROCEDURE [custom].[p_WMS_validateDocument]
	@xmlVar xml
AS

	DECLARE @message varchar(500), @action varchar(10), @documentId uniqueidentifier, @documentTypeId uniqueidentifier, @documentTypeSymbol varchar(10)
/*
Na jakiś czas umieszę komunikat w tabeli by łatwiej wychwycić fakt występowania błędów, mogą się nie przyznać
select * from tmp_testrace 
*/
    SELECT  
            @action = x.value(''@action[1]'', ''varchar(10)''),
			@documentId = x.value(''id[1]'', ''uniqueidentifier''),
			@documentTypeId = x.value(''documentTypeId[1]'', ''uniqueidentifier''),
			@documentTypeSymbol = x.value(''symbol[1]'', ''varchar(10)'')
    FROM    @xmlVar.nodes(''/*'') a(x)
	
	-- warunki

	-- zablokowanie starych stawek VAT
	IF @documentTypeSymbol IN (''FVS'', ''PA'', ''FW'', ''PROFORMA'')
	  BEGIN
		IF EXISTS (
			SELECT h.id
			FROM document.CommercialDocumentLine l
			JOIN document.CommercialDocumentHeader h ON h.id = l.commercialDocumentHeaderId
			WHERE
				h.id = @documentId AND
				eventDate >= ''2011-01-01'' AND
				l.vatRateId IN (''F8D50E4D-066E-4F0A-BD58-C2BC708BEB0F'', ''C4CADF31-1A15-4CE0-9F97-60676A86AB1D'')
		) SET @message = ''Niedozwolona stawka VAT''
	  END

	--IF @documentTypeSymbol IN (''FVE'', ''FKE'')
	--	BEGIN
	--		IF ISNULL((
	--				SELECT textValue
	--				FROM document.DocumentAttrValue DAV
	--				JOIN dictionary.DocumentField DF ON DF.id = DAV.documentFieldId
	--				WHERE DAV.commercialDocumentHeaderId = @documentId AND DF.name = ''Attribute_StatusSales''
	--			), '''') = ''''
	--		SET @message = ''Nie wybrano statusu księgowego.''
	--	END
	
	IF EXISTS (SELECT * FROM dictionary.DocumentType where documentCategory in (1,7,8) AND id = @documentTypeId )
		BEGIN 
		IF EXISTS(
			SELECT s.id
			FROM  warehouse.Shift s
				LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.[status] >= 40 GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId
				LEFT JOIN document.WarehouseDocumentLine l ON s.incomeWarehouseDocumentLineId = l.id
				LEFT JOIN item.Item i ON l.itemId = i.id
			WHERE   ISNULL((s.quantity - ISNULL(x.q,0)),0) < 0 AND s.containerId IS NOT NULL AND s.[status] >= 40
				AND i.id IN (SELECT itemId FROM document.WarehouseDocumentLine l WHERE warehouseDocumentHeaderId = @documentId)
			UNION ALL
			SELECT   l.id
			FROM document.WarehouseDocumentLine l
				LEFT JOIN (
							SELECT s.warehouseDocumentLineId, SUM( s.quantity - ISNULL(x.q , 0))  qty
							FROM  warehouse.Shift s
								LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.[status] >= 40 GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId
							WHERE   ISNULL((s.quantity - ISNULL(x.q,0)),0) >= 0  AND s.containerId IS NOT NULL AND s.[status] >= 40
							GROUP BY s.warehouseDocumentLineId

						) x ON x.warehouseDocumentLineId = l.id
				LEFT JOIN item.Item i ON l.itemId = i.id
			WHERE  (l.quantity * l.direction ) > 0 AND  x.qty IS NOT NULL AND  (l.quantity * l.direction ) < x.qty
				AND i.id IN (SELECT itemId FROM document.WarehouseDocumentLine l WHERE warehouseDocumentHeaderId = @documentId)
			UNION ALL
			SELECT  ws.id
			FROM  document.WarehouseStock ws 
				JOIN item.Item i ON ws.itemId = i.id
				JOIN (	SELECT l.itemId , l.warehouseId, SUM(qty) qty
						FROM document.WarehouseDocumentLine l 
							JOIN ( SELECT  SUM( s.quantity - ISNULL(x.q , 0))  qty, s.incomeWarehouseDocumentLineId
								   FROM warehouse.Shift s 
									LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.[status] >= 40 GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId
								   WHERE   ISNULL((s.quantity - ISNULL(x.q,0)),0) >= 0  AND s.containerId IS NOT NULL AND s.[status] >= 40
									GROUP BY s.incomeWarehouseDocumentLineId
								) cc ON cc.incomeWarehouseDocumentLineId = l.id
						GROUP BY l.itemId , l.warehouseId
				) x ON ws.itemId = x.itemId AND ws.warehouseId = x.warehouseId
			WHERE ws.quantity - ISNULL(qty,0) < 0 
				AND i.id IN (SELECT itemId FROM document.WarehouseDocumentLine l WHERE warehouseDocumentHeaderId = @documentId)
			UNION ALL
			SELECT v.id
				FROM document.v_getAvailableDeliveries v 
					left join (				
							SELECT s.incomeWarehouseDocumentLineId, SUM(s.quantity - ISNULL(x.q , 0))  quantity
							FROM  warehouse.Shift s
								LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.[status] >= 40 GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId
							WHERE   ISNULL((s.quantity - ISNULL(x.q,0)),0) > 0 
									AND s.containerId IS NOT NULL 
									AND s.[status] >= 40
							GROUP BY s.incomeWarehouseDocumentLineId
						) x ON v.id = x.incomeWarehouseDocumentLineId
			WHERE v.quantity < x.quantity AND v.itemId IN (SELECT itemId FROM document.WarehouseDocumentLine l WHERE warehouseDocumentHeaderId = @documentId)
				)
		
				SET @message = ''Błąd stanu dostaw''
		
			 
		END

--INSERT INTO tmp_testrace(x)
--SELECT (SELECT CASE WHEN @message IS NULL THEN '''' ELSE (SELECT @message FOR XML PATH(''error''), TYPE) END FOR XML PATH(''root''))

	SELECT CASE WHEN @message IS NULL THEN '''' ELSE (SELECT @message FOR XML PATH(''error''), TYPE) END FOR XML PATH(''root'')
' 
END
GO
