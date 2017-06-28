/*
name=[tools].[p_testWMS]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
28KNJZbRypYseCgprJXNKQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_testWMS]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_testWMS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_testWMS]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [tools].[p_testWMS]
AS
SELECT (
SELECT (
SELECT * FROM (
	SELECT s.quantity - ISNULL(x.q , 0) diff ,i.name itemName , ''Przerozchodowanie Shifta'' blad
	FROM  warehouse.Shift s
		LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.[status] >= 40 GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId
		LEFT JOIN document.WarehouseDocumentLine l ON s.incomeWarehouseDocumentLineId = l.id
		LEFT JOIN item.Item i ON l.itemId = i.id
	WHERE   ISNULL((s.quantity - ISNULL(x.q,0)),0) < 0 AND s.containerId IS NOT NULL AND s.[status] >= 40
	UNION ALL
	SELECT   (l.quantity * l.direction ) - x.qty diff ,i.name itemName , ''Niezgodność dokumentów z rozchodowymi shiftami'' blad
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
	UNION ALL
	SELECT  ws.quantity - ISNULL(qty,0) diff,i.name itemName , ''Niezgodność stanu kontenerów i magazynów'' blad
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
	UNION ALL
SELECT v.quantity - x.quantity diff, i.name itemName, ''Więcej na transzach niż dostępnych dostaw'' blad
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
		LEFT JOIN item.Item i on v.itemId = i.id 
WHERE v.quantity < x.quantity			
			 

) xxx
	FOR XML PATH(''''), TYPE
) 	FOR XML PATH(''lines''), TYPE
) 	FOR XML PATH(''root''), TYPE
' 
END
GO
