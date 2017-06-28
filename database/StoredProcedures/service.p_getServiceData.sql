/*
name=[service].[p_getServiceData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
4KrlFb5BeZVvO48fQCUPWg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_getServiceData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [service].[p_getServiceData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[p_getServiceData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [service].[p_getServiceData] 
@serviceHeaderId uniqueidentifier
AS
BEGIN
SELECT (
	SELECT    ( SELECT    ( 
							SELECT    s.*
							FROM      [service].ServiceHeader s 
							WHERE     s.commercialDocumentHeaderId = @serviceHeaderId
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''serviceHeader''), TYPE
			   ),(SELECT   (
							SELECT    e.*
							FROM      service.ServiceHeaderEmployees e
							WHERE     e.serviceHeaderId = @serviceHeaderId
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''serviceHeaderEmployees''), TYPE
			   ),(SELECT   (
							SELECT    o.*
							FROM      service.ServiceHeaderServicedObjects o
							WHERE     o.serviceHeaderId = @serviceHeaderId
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''serviceHeaderServicedObjects''), TYPE
			   ),(SELECT   (
							SELECT    p.*
							FROM      service.ServiceHeaderServicePlace p
							WHERE     p.serviceHeaderId = @serviceHeaderId
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''serviceHeaderServicePlace''), TYPE                       
				)
	FOR XML PATH(''root''),TYPE 
) AS returnsXML

END
' 
END
GO
