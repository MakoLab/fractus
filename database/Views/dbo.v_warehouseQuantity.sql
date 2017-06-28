/*
name=[dbo].[v_warehouseQuantity]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
IiVqFob6fOCEins1fDWZ1g==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_warehouseQuantity]'))
DROP VIEW [dbo].[v_warehouseQuantity]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_warehouseQuantity]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[v_warehouseQuantity]
AS

SELECT SUM(l.quantity * l.direction) quantity, unitId, itemId, warehouseId
FROM document.WarehouseDocumentLine l 
GROUP BY  unitId, itemId, warehouseId
' 
GO
