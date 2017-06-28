/*
name=[warehouse].[p_handheld_GetContainerByName]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
M20MxVn1AsO/+E9WM/k0+g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_handheld_GetContainerByName]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_handheld_GetContainerByName]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_handheld_GetContainerByName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_handheld_GetContainerByName]
	@containerName varchar(50)
AS
	SELECT
		id,
		[name],
		CASE WHEN CHARINDEX(''p'', [name]) > 0 THEN CAST(NULLIF(SUBSTRING(name, CHARINDEX(''p'', name) + 1, 10),'''') AS int) ELSE NULL END
	FROM warehouse.Container
	WHERE [name] LIKE @containerName + ''p%'' OR [name] = @containerName
	ORDER BY [order]
' 
END
GO
