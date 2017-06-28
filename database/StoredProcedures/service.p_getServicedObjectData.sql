/*
name=[service].[p_getServicedObjectData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
lZ3mcK9vuTbLQFSUq4b9DQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_getServicedObjectData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [service].[p_getServicedObjectData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_getServicedObjectData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [service].[p_getServicedObjectData] 
@servicedObjectId uniqueidentifier
AS
BEGIN
SELECT (
	SELECT    ( SELECT    ( 
							SELECT    s.*
							FROM      service.ServicedObject  s 
							WHERE     s.id = @servicedObjectId
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''servicedObject''), TYPE
			   )
	FOR XML PATH(''root''),TYPE 
) AS returnsXML

END
' 
END
GO
