/*
name=[warehouse].[p_getContainers]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ZLbvfsndkIp8gT6e93wSkQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getContainers]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_getContainers]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getContainers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_getContainers]
AS
BEGIN

SELECT (
	SELECT (
		SELECT * 
		FROM warehouse.Container
		FOR XML PATH(''container''), TYPE
	) 	FOR XML PATH(''container''), TYPE
) 	FOR XML PATH(''root''), TYPE

END
' 
END
GO
