/*
name=[warehouse].[p_getShiftContainer]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
2pWxncPUFCGDXBoTe3u5gQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getShiftContainer]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [warehouse].[p_getShiftContainer]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getShiftContainer]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [warehouse].[p_getShiftContainer](@sourceShiftId UNIQUEIDENTIFIER)
RETURNS  UNIQUEIDENTIFIER
AS 
BEGIN
	/* Pobranie źródłowego kontenera na podstawie tabeli Shift
	*/
	DECLARE @containerId UNIQUEIDENTIFIER


	SELECT @containerId = containerId
	FROM warehouse.Shift c
	WHERE c.id = @sourceShiftId
	
RETURN @containerId
END
' 
END

GO
