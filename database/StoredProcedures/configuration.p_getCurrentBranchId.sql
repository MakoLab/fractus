/*
name=[configuration].[p_getCurrentBranchId]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
PlW1NOTsCDKiD48VawI7fA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_getCurrentBranchId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [configuration].[p_getCurrentBranchId]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_getCurrentBranchId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE configuration.p_getCurrentBranchId   @xmlVar XML
AS 
BEGIN
	DECLARE @id UNIQUEIDENTIFIER
	SELECT @id = id 
	FROM dictionary.Branch 
	WHERE databaseId = CAST((SELECT textValue FROM configuration.Configuration WHERE [key] like ''communication.databaseId'') as uniqueidentifier)
	
	SELECT @id FOR XML PATH(''root''),TYPE
END
' 
END
GO
