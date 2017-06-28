/*
name=[dictionary].[p_getSlotGroupById]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
tkGER+W46cohTmmsz7NYxw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getSlotGroupById]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getSlotGroupById]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getSlotGroupById]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getSlotGroupById]
@id uniqueidentifier
AS
SELECT xmlValue.query(''/warehouseMap/slotGroup/slotGroup[@id = sql:variable("@id")]'') 
FROM configuration.Configuration 
WHERE [key] = ''warehouse.warehouseMap''
' 
END
GO
