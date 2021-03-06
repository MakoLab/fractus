/*
name=[dictionary].[p_getJobPositions]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
FUdkeNerxMl30dYgoEVERw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getJobPositions]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getJobPositions]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getJobPositions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getJobPositions]
AS
SELECT (
SELECT (
	SELECT 
		(SELECT id,xmlLabels,version 
			FROM dictionary.JobPosition  
			ORDER BY [order]
			FOR XML PATH(''entry''),TYPE)
		FOR XML PATH(''jobPosition''), TYPE
		) 
FOR  XML PATH(''root''), TYPE
) AS returnsXML
' 
END
GO
