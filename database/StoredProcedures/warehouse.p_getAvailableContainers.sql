/*
name=[warehouse].[p_getAvailableContainers]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
q2X6g5OCdEo7SnHi8bGO6g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getAvailableContainers]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_getAvailableContainers]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getAvailableContainers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_getAvailableContainers]
@xmlVar XML
AS

BEGIN

	DECLARE
		@containerId uniqueidentifier,
		@shiftTransactionId char(36),
		@quantity NUMERIC(18,6), 
		@count int

	DECLARE @tmp_ TABLE (containerId UNIQUEIDENTIFIER )


	/*Not in list*/
	INSERT INTO @tmp_ 
	SELECT x.query(''containerId'').value(''.'',''char(36)'')
	FROM @xmlVar.nodes(''root/containers'') AS a(x)

	
	SELECT @shiftTransactionId = NULLIF(x.query(''shiftTransactionId'').value(''.'',''char(36)''),'''')
	FROM @xmlVar.nodes(''root'') AS a(x)

	SELECT (
		SELECT c.id AS ''@id'', c.symbol AS ''@containerSymbol'', SUM(ISNULL(cc.qty,0))  AS ''@quantity'',
			CASE WHEN SUM(ISNULL(cc.qty,0)) = 0 THEN 3 WHEN SUM(ISNULL(cc.qty,0)) < 20 THEN 2 ELSE 1 END AS ''@available''
		FROM warehouse.Container c 
			LEFT JOIN (
								SELECT   s.quantity - ISNULL(x.q,0) qty, l.itemId, s.containerId
								FROM  warehouse.Shift s
									LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.status >= 40 AND (sx.shiftTransactionId <> @shiftTransactionId OR @shiftTransactionId IS NULL ) GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId
									JOIN document.WarehouseDocumentLine l ON s.incomeWarehouseDocumentLineId = l.id
								WHERE s.containerId IS NOT NULL AND ( s.shiftTransactionId <> @shiftTransactionId OR @shiftTransactionId IS NULL ) AND s.status >= 40
					) cc ON c.id = cc.containerId 
		WHERE c.isActive = 1 AND c.id NOT IN ( SELECT containerId FROM @tmp_ ) 
		GROUP BY c.id, c.symbol
		FOR XML PATH(''container''), TYPE ) 
	FOR XML PATH(''root''), TYPE
END
' 
END
GO
