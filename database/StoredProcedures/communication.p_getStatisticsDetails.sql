/*
name=[communication].[p_getStatisticsDetails]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
fp92bgksvsnb4ua6sVC+QA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getStatisticsDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getStatisticsDetails]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getStatisticsDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getStatisticsDetails]
@branchId uniqueidentifier
AS
BEGIN

	SELECT (
		SELECT (
			SELECT  getdate() currentTime,
					s.*
			FROM communication.[Statistics] s
				JOIN dictionary.Branch b ON s.databaseId = b.databaseId 
			WHERE b.id = @branchId
		  FOR XML PATH(''entry''),TYPE )
		FOR XML PATH(''statistics''),TYPE )
	FOR XML PATH(''root''),TYPE
	
END' 
END
GO
