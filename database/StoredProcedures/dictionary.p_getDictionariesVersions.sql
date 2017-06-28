/*
name=[dictionary].[p_getDictionariesVersions]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
wUD4RnJrRqIOlq6nf9nsXg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getDictionariesVersions]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getDictionariesVersions]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getDictionariesVersions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE  [dictionary].[p_getDictionariesVersions]
AS 
	/*Budowa XML z wersjami słowników*/
    SELECT  ( SELECT    ( SELECT    ( SELECT * FROM (
									 SELECT    id,
                                                tableName,
                                                versionNumber,
                                                version
                                      FROM      Dictionary.DictionaryVersion
                                      UNION
                                      SELECT	id,
												''items.group'' tableName, 
												1 versionNumber,
												version
                                      FROM configuration.Configuration
                                      WHERE [key] = ''items.group''
                                      UNION
                                      SELECT	id,
												''document.validation.minimalProfitMargin'' tableName, 
												1 versionNumber,
												version
                                      FROM configuration.Configuration
                                      WHERE [key] = ''document.validation.minimalProfitMargin''
                                      ) x
                                      ORDER BY  tableName ASC
                                    FOR
                                      XML PATH(''entry''),TYPE
                                    )
                        FOR
                          XML PATH(''dictionaryVersion''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO
