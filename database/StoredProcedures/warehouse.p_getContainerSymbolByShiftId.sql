/*
name=[warehouse].[p_getContainerSymbolByShiftId]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
pMZK3ruva2YfomPORFfrRQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getContainerSymbolByShiftId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_getContainerSymbolByShiftId]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getContainerSymbolByShiftId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_getContainerSymbolByShiftId] 
@shiftId UNIQUEIDENTIFIER
AS
BEGIN

SELECT c.symbol 
FROM warehouse.Shift s 
	JOIN warehouse.Container c ON s.containerId = c.id
WHERE s.id = @shiftId
FOR XML PATH(''root''), TYPE
END
' 
END
GO
