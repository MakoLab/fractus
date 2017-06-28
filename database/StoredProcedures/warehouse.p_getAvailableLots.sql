/*
name=[warehouse].[p_getAvailableLots]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Lq3zKR47eiFWCU5b+HOxYQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getAvailableLots]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_getAvailableLots]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getAvailableLots]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE  PROCEDURE [warehouse].[p_getAvailableLots]
@xmlVar XML
AS

BEGIN

	DECLARE
		@itemId char(36),
		@i int, 
		@count int,
		@shiftTransactionId char(36),
		@warehouseDocumentHeaderId char(36),
		@attrLabels nvarchar(4000)


	DECLARE @tmp TABLE ( shiftId uniqueidentifier,incomeWarehouseDocumentLineId uniqueidentifier ,quantity numeric(18,6), containerId uniqueidentifier, containerLabel varchar(50), slotContainerLabel varchar(50), incomeDate datetime, fullNumber varchar(50),price numeric(18,2) , [status] int, [version] uniqueidentifier, itemId uniqueidentifier not null, warehouseId uniqueidentifier not null, shiftDate datetime , lp int)
	DECLARE @tmp_income TABLE (lp int identity(1,1),warehouseDocumentHeaderId uniqueidentifier, incomeWarehouseDocumentLineId uniqueidentifier ,quantity numeric(18,6), itemId uniqueidentifier, warehouseId uniqueidentifier not null, incomeDate datetime, price numeric(18,2))
	DECLARE @warehouseId uniqueidentifier, @dateFrom datetime, @dateTo datetime, @unassigned int
	DECLARE @container_ TABLE (containerId uniqueidentifier) 
/*Można dodać konfigurację zwracanych atrybutów w postaci : <attributes>Attribute_Voltage,Attribute_Current,Attribute_MeasureTime</attributes> , 
	obecnie należy umieścić tam nazwy atrybutów transz po przecinku. Pozostaje domyślna wartość będąca pozostałością po fundatorze funkcji*/
/*Parametry wejściowe*/
SELECT
	@itemId = NULLIF(x.value(''(itemId)[1]'', ''varchar(36)''), ''''),
	@warehouseId = NULLIF(x.value(''(warehouseId)[1]'', ''varchar(36)''), ''''),
	@dateFrom = NULLIF(x.value(''(dateFrom)[1]'', ''varchar(30)''), ''''),
	@dateTo = NULLIF(x.value(''(dateTo)[1]'', ''varchar(30)''), ''''),
	@unassigned = NULLIF(x.value(''(unassigned)[1]'', ''char(1)''), ''''),
	@shiftTransactionId = NULLIF(x.value(''(shiftTransactionId)[1]'', ''char(36)''), ''''),
	@warehouseDocumentHeaderId = NULLIF(x.value(''(warehouseDocumentHeaderId)[1]'', ''char(36)''), ''''),
	@attrLabels = NULLIF(x.value(''(attributes)[1]'', ''nvarchar(4000)''), '''')
FROM @xmlVar.nodes(''/*'') AS a(x)	

INSERT INTO @container_ (containerId )
SELECT x.value(''.'', ''uniqueidentifier'') 
FROM @xmlVar.nodes(''*/containerId'') a(x)

	-- warunek na kontenery zawarty w kwerendzie

/*Zebranie informacji o przypisaniach do kontenerów*/
INSERT INTO @tmp (shiftId,quantity,containerId,containerLabel,slotContainerLabel,incomeDate,fullNumber, price, incomeWarehouseDocumentLineId, [status] ,[version], itemId, warehouseId, shiftDate)
		SELECT DISTINCT	s.id,
				ISNULL(s.quantity - ISNULL(x.q,0),0), 
				s.containerId , 
				c.xmlLabels.value(''(labels/label[@lang = "pl"])[1]'',''varchar(100)''),
				(SELECT c.xmlLabels.value(''(labels/label[@lang = "pl"])[1]'', ''varchar(100)'') FROM warehouse.Container WHERE id = warehouse.p_getSlotContainer(c.id)),
				l.incomeDate ,
				dt.symbol + '' '' + h.fullNumber ,
				l.price ,
				s.incomeWarehouseDocumentLineId ,
			    h.status,
				h.version,
				l.itemId,
				h.warehouseId,
				ST.issueDate
		FROM 
			warehouse.Shift s
			LEFT JOIN ( 
				SELECT SUM(sx.quantity) q , sx.sourceShiftId
				FROM warehouse.Shift sx
				WHERE
					-- zwracamy jako dostepne ilosci pobrane przez shifty ktore wlasnie sa edytowane
					( @shiftTransactionId IS NULL OR sx.shiftTransactionId <> @shiftTransactionId ) AND sx.status >= 40
				GROUP BY
					sx.sourceShiftId
			) X ON s.id = X.sourceShiftId

			LEFT JOIN document.WarehouseDocumentLine l ON s.incomeWarehouseDocumentLineId = l.id
			LEFT JOIN document.WarehouseDocumentHeader h ON l.warehouseDocumentHeaderId = h.id
			LEFT JOIN dictionary.DocumentType DT ON DT.id = H.documentTypeId


			LEFT JOIN warehouse.Container c ON s.containerId = c.id
			LEFT JOIN warehouse.ShiftTransaction ST ON ST.id = s.shiftTransactionId
		WHERE
			ISNULL((s.quantity - ISNULL(x.q,0)),0) > 0 AND s.containerId IS NOT NULL
			AND NULLIF(@itemId, l.itemId) IS NULL
			AND NULLIF(@warehouseId, s.warehouseId) IS NULL
			AND ( ( NOT EXISTS (SELECT containerId FROM @container_) AND s.containerId IS NOT NULL ) OR s.containerId IN (SELECT containerId FROM @container_) )
			AND (@dateFrom IS NULL OR l.incomeDate BETWEEN @dateFrom AND @dateTo)
			AND s.status >= 40


/*Jeśli suma ilości dostępnych dostaw jest różna od sumy ilości dostępnych przypisanych do kontenerów, 
nastąpi uzupełnienie ilości o wiersz odpowiadający dostawom wolnym */

IF @xmlVar.exist(''/*/containerId'') = 0 AND ISNULL(( SELECT SUM(quantity) FROM @tmp ),0) <> (	
																							SELECT SUM(quantity) FROM (
																							SELECT d.quantity
																							FROM document.v_getAvailableDeliveries d 
																							WHERE (@itemId IS NULL OR @itemId = d.itemId)
																									AND ( @warehouseId IS NULL OR @warehouseId = d.warehouseId)
																							UNION ALL 
																							SELECT quantity
																							FROM document.WarehouseDocumentLine l 
																							WHERE l.warehouseDocumentHeaderId = @warehouseDocumentHeaderId 
																								AND (@itemId IS NULL OR @itemId = l.itemId)
																								AND ( @warehouseId IS NULL OR @warehouseId = l.warehouseId)
																							) x )
	BEGIN

	INSERT INTO @tmp_income (warehouseDocumentHeaderId , incomeWarehouseDocumentLineId ,quantity, itemId, warehouseId, incomeDate, price)
	SELECT warehouseDocumentHeaderId, id, quantity, itemId, warehouseId, incomeDate, price
	FROM document.v_getAvailableDeliveries d 
	WHERE
		(@itemId IS NULL OR @itemId = d.itemId)
		AND ( @warehouseId IS NULL OR @warehouseId = d.warehouseId)
		AND (@dateFrom IS NULL OR d.incomeDate BETWEEN @dateFrom AND @dateTo)
	UNION ALL
	SELECT l2.warehouseDocumentHeaderId, ir.incomeWarehouseDocumentLineId, ir.quantity, l.itemId, l.warehouseId, l2.incomeDate, l2.price
	FROM document.WarehouseDocumentLine l
		JOIN document.IncomeOutcomeRelation ir ON l.id = ir.outcomeWarehouseDocumentLineId
		JOIN document.WarehouseDocumentLine l2 ON  l2.id = ir.incomeWarehouseDocumentLineId
	WHERE l.warehouseDocumentHeaderId = @warehouseDocumentHeaderId
		AND (@itemId IS NULL OR @itemId = l.itemId)
		AND ( @warehouseId IS NULL OR @warehouseId = l.warehouseId)

	SELECT @count = @@rowcount, @i = 1
	
				
	WHILE	@i <= @count AND ISNULL((SELECT SUM(quantity) FROM  @tmp_income ),0) > ISNULL((SELECT SUM(quantity) FROM  @tmp ),0)
		BEGIN
			IF ISNULL(( SELECT SUM(quantity) FROM  @tmp_income WHERE lp = @i ),0) > 
				ISNULL((SELECT SUM(quantity) FROM  @tmp WHERE incomeWarehouseDocumentLineId = ( SELECT incomeWarehouseDocumentLineId FROM  @tmp_income WHERE lp = @i )),0)
				BEGIN

					INSERT INTO @tmp (quantity,containerId,containerLabel,slotContainerLabel,  incomeDate,                     fullNumber,   price, incomeWarehouseDocumentLineId, [status] ,[version], itemId, warehouseId , lp)
					SELECT 
					( SELECT SUM(quantity) FROM  @tmp_income WHERE lp = @i ) - ISNULL((SELECT SUM(quantity) FROM  @tmp WHERE incomeWarehouseDocumentLineId = ( SELECT incomeWarehouseDocumentLineId FROM  @tmp_income WHERE lp = @i )),0)
					                          ,       NULL,          NULL,              NULL, d.incomeDate, DT.symbol + '' '' + h.fullNumber, d.price, d.incomeWarehouseDocumentLineId, h.status,h.version, d.itemId, d.warehouseId, d.lp
					FROM (SELECT  warehouseDocumentHeaderId, incomeWarehouseDocumentLineId , lp, itemId, warehouseId, incomeDate, price, quantity FROM  @tmp_income WHERE lp = @i ) d
						JOIN document.WarehouseDocumentHeader h ON d.warehouseDocumentHeaderId = h.id
						JOIN dictionary.DocumentType DT ON DT.id = H.documentTypeId						
					WHERE ( @warehouseId IS NULL OR @warehouseId = d.warehouseId )
					GROUP BY d.incomeWarehouseDocumentLineId, d.incomeDate, h.fullNumber, dt.symbol, d.price,  h.status ,h.version, d.itemId, d.warehouseId,  d.lp
				END

		SELECT  @i = @i + 1
		END

	END

	SELECT (
			 SELECT DISTINCT
				t.shiftId as ''@shiftId'',
				t.quantity  as ''@quantity'' ,
				t.containerId as ''@containerId'', 
				t.containerLabel as ''@containerLabel'',  
				t.slotContainerLabel as ''@slotContainerLabel'',
				t.incomeDate as ''@incomeDate'',
				t.fullNumber as ''@fullNumber'',
				t.price as ''@price'',
				t.incomeWarehouseDocumentLineId as ''@incomeWarehouseDocumentLineId'',
				t.status as ''@status'',
				t.version as ''@version'',
				I.id as ''@itemId'',
				I.code as ''@itemCode'',
				I.[name] as ''@itemName'',
				t.warehouseId as ''@warehouseId'',
				t.shiftDate as ''@shiftDate'',
				RTRIM(CAST( (	SELECT isnull(sav.textValue,REPLACE(CAST(sav.decimalValue AS float),''.'','','')) + ISNULL(sf.xmlMetadata.value(''(metadata/valueSuffix)[1]'',''varchar(50)''),'''') + '' '' as ''data()''
					FROM warehouse.ShiftAttrValue  sav
						JOIN dictionary.ShiftField sf ON sf.id = sav.shiftFieldId
					WHERE sav.shiftId = t.shiftId AND ( ( @attrLabels IS NULL AND sf.name IN (''Attribute_Voltage'',''Attribute_Current'',''Attribute_MeasureTime'' )) OR ( @attrLabels IS NOT NULL AND sf.name IN( SELECT word FROM xp_split(ISNULL(@attrLabels, ''''), '','') ))  ) --Tu jest na pałę ustawiona lista zwracanych atrybutów dla klienta
					ORDER BY sf.[order]
					FOR XML PATH(''''), TYPE ) AS nvarchar(4000))) as ''@attributes''
			FROM @tmp t
				JOIN item.Item I ON t.itemId = I.id
				
			WHERE (ISNULL(@unassigned, 0) = 0 OR t.containerId IS NULL)
			ORDER BY t.incomeDate ASC, t.shiftDate ASC
			FOR XML PATH(''shifts''),TYPE
	)   FOR XML PATH(''root''),TYPE 

END
' 
END
GO
