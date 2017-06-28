/*
name=[service].[pGetServicedObjectHistory]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
/lHteLebJkyOFq/3gY81/w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[pGetServicedObjectHistory]') AND type in (N'P', N'PC'))
DROP PROCEDURE [service].[pGetServicedObjectHistory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[service].[pGetServicedObjectHistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [service].[pGetServicedObjectHistory]
@servicedObjectId uniqueidentifier
AS 
BEGIN
SELECT * 
FROM service.ServicedObject so
	JOIN service.ServiceHeaderServicedObjects shso ON so.id = shso.servicedObjectId
	JOIN service.ServiceHeader sh ON sh.commercialDocumentHeaderId =shso.serviceHeaderId
	JOIN document.CommercialDocumentHeader cdh ON cdh.id = sh.commercialDocumentHeaderId
WHERE so.id = @servicedObjectId




END

select * from configuration.Configuration where [key] not like ''templat%'' and [key] not like ''printing%'' and xmlValue is not null
' 
END
GO
