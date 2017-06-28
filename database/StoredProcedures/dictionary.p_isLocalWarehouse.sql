/*
name=[dictionary].[p_isLocalWarehouse]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
EMBsOLoA9hOMvUN2vwxftQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_isLocalWarehouse]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_isLocalWarehouse]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_isLocalWarehouse]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_isLocalWarehouse]
@xmlVar XML
AS
BEGIN
SELECT (
	SELECT   sub.warehouseId , CASE WHEN b.id IS NULL THEN ''false'' ELSE ''true'' END isLocal
	FROM (
			SELECT x.value(''.'',''char(36)'') warehouseId 
			FROM @xmlVar.nodes(''root/warehouseId'') AS a(x) 
			) sub 
		JOIN dictionary.Warehouse w ON w.id = sub.warehouseId
		LEFT JOIN dictionary.Branch b ON w.BranchId = b.id 
			AND b.databaseId = (	SELECT x.value(''@databaseId'', ''char(36)'') FROM @xmlVar.nodes(''root'') AS a(x)	)
	FOR XML PATH(''warehouse''), TYPE	) FOR XML PATH(''root''), TYPE	
END
' 
END
GO
