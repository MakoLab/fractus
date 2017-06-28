/*
name=[warehouse].[p_getShiftsForIncomeWarehouseLines]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Z9STFzpPnTqS1M3gLw17pw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getShiftsForIncomeWarehouseLines]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_getShiftsForIncomeWarehouseLines]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getShiftsForIncomeWarehouseLines]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_getShiftsForIncomeWarehouseLines] 
@xmlVar XML
AS 

DECLARE @tmp_ TABLE (id uniqueidentifier)

INSERT INTO @tmp_ (id)
SELECT x.value(''@id'',''char(36)'')
FROM @xmlVar.nodes(''/root/line'') AS a(x)

SELECT (
SELECT t.id AS ''@id'',ISNULL( v.quantity ,0) AS ''@quantity'' , (


				SELECT s.id AS ''@id'', s.quantity - ISNULL(x.q , 0) AS ''@quantity'' 
				FROM  warehouse.Shift s
					LEFT JOIN ( SELECT SUM(sx.quantity) q , sx.sourceShiftId FROM warehouse.Shift sx WHERE sx.[status] >= 40 GROUP BY sx.sourceShiftId ) x ON s.id = x.sourceShiftId
				WHERE  s.incomeWarehouseDocumentLineId = t.id 
						AND ISNULL((s.quantity - ISNULL(x.q,0)),0) > 0 
						AND s.containerId IS NOT NULL 
						AND s.[status] >= 40
				FOR XML PATH(''shift''), TYPE 
			) 
	FROM @tmp_ t 
		LEFT JOIN document.v_getAvailableDeliveries v ON t.id = v.id
FOR XML PATH(''line''), TYPE )
FOR XML PATH(''root''), TYPE
' 
END
GO
