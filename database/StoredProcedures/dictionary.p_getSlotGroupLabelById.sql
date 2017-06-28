/*
name=[dictionary].[p_getSlotGroupLabelById]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
/aylfEzrebVVFcy9F5tdug==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getSlotGroupLabelById]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getSlotGroupLabelById]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getSlotGroupLabelById]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getSlotGroupLabelById]
@id uniqueidentifier
AS
SELECT xmlValue.value(''(/warehouseMap/slotGroup/slotGroup[@id = sql:variable("@id")]/@label)[1]'',''varchar(100)'') 
FROM configuration.Configuration 
WHERE [key] = ''warehouse.warehouseMap''
' 
END
GO
