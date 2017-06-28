/*
name=[dbo].[v_getWarehouseStates]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
0d933oL851NACF37+JR2PQ==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_getWarehouseStates]'))
DROP VIEW [dbo].[v_getWarehouseStates]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_getWarehouseStates]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[v_getWarehouseStates]
AS
SELECT 
ww.symbol [Warehouse symbol] ,i.name [Item name], i.code [Item code],u.symbol [Item unit symbol],
w.quantity [Item quantity], w.reservedQuantity [Item reserved quantity], w.orderedQuantity [Item ordered quantity]
FROM document.WarehouseStock w WITH(NOLOCK)
	JOIN dictionary.Warehouse ww WITH(NOLOCK) ON w.warehouseId = ww.id
	JOIN item.Item i WITH(NOLOCK) ON w.itemId = i.id
	JOIN (  SELECT xmlLabels.value(''(labels/label[@lang = "pl"]/@symbol)[1]'',''varchar(50)'') symbol, id
			FROM  dictionary.Unit WITH(NOLOCK)
		 ) u ON w.unitId = u.id
' 
GO
