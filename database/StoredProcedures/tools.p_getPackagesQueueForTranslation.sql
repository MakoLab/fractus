/*
name=[tools].[p_getPackagesQueueForTranslation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
yLFZfcJVttko4gDS1GSWFQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_getPackagesQueueForTranslation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_getPackagesQueueForTranslation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_getPackagesQueueForTranslation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tools].[p_getPackagesQueueForTranslation]
    @maxPackages INT
AS 
    BEGIN
		 SELECT TOP ( SELECT @maxPackages ) CAST([ciq].[id] AS CHAR(36)) AS id, 
				 CAST([ciq].[order] AS NUMERIC(18, 0)) AS [order], 
                 [type], 
                 CAST([b].[id] AS CHAR(36)) AS sourceId, 
                 CAST([ciq].[xml] AS VARCHAR(MAX)) AS [xml]
			FROM communication.IncomingXmlQueue AS ciq INNER JOIN dictionary.branch AS b ON ciq.databaseId = b.databaseId
			WHERE executionDate IS NOT NULL
				  AND isComplited = 1
				  AND translationDate IS NULL
			ORDER BY [order]
    END
' 
END
GO
