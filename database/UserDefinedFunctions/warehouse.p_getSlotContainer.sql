/*
name=[warehouse].[p_getSlotContainer]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
dYl+gh+47yR6LmUXFE/KGg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getSlotContainer]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [warehouse].[p_getSlotContainer]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getSlotContainer]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [warehouse].[p_getSlotContainer](@containerId UNIQUEIDENTIFIER)
RETURNS  UNIQUEIDENTIFIER
AS 
BEGIN

	DECLARE @slotContainerId UNIQUEIDENTIFIER


	SELECT @slotContainerId = CASE WHEN ct.isSlot = 1 THEN c.id ELSE ( SELECT TOP 1 slotContainerId FROM warehouse.ContainerShift  WHERE containerId = c.id ORDER BY ordinalNumber DESC ) END 
	FROM warehouse.Container c
		JOIN dictionary.ContainerType ct ON c.containerTypeId = ct.id
	WHERE c.id = @containerId
	
RETURN @slotContainerId
END
' 
END

GO
