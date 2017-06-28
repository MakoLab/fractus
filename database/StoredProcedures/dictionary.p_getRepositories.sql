/*
name=[dictionary].[p_getRepositories]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
9VLSoAiGjkzKcLrBCFeZxw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getRepositories]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getRepositories]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getRepositories]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getRepositories]
AS 
	/*Budowa XML z repozytorium plików*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    id,
                                                url,
                                                version
                                      FROM      dictionary.Repository
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''repository''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO
