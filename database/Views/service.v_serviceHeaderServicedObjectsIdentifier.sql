/*
name=[service].[v_serviceHeaderServicedObjectsIdentifier]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
78CC9tcEVlwC9M/x4DxEMg==
*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[service].[v_serviceHeaderServicedObjectsIdentifier]'))
DROP VIEW [service].[v_serviceHeaderServicedObjectsIdentifier]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[service].[v_serviceHeaderServicedObjectsIdentifier]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [service].[v_serviceHeaderServicedObjectsIdentifier] WITH SCHEMABINDING AS
SELECT    COUNT_BIG(*) counter, so.identifier field, sso.serviceHeaderId commercialDocumentHeaderId
FROM   [service].ServiceHeader h
		JOIN [service].ServiceHeaderServicedObjects  sso ON h.commercialDocumentHeaderId = sso.serviceHeaderId
        JOIN [service].ServicedObject so ON sso.servicedObjectId = so.id
GROUP BY so.identifier, sso.serviceHeaderId
' 
GO
