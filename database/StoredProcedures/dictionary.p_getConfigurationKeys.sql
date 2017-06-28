/*
name=[dictionary].[p_getConfigurationKeys]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
vYdtapivCyL3MRTWlD6c8Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getConfigurationKeys]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getConfigurationKeys]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getConfigurationKeys]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getConfigurationKeys]
AS 
	/*Budowa XML z kluczami konfirguracji*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.ConfigurationKey
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''configurationKey''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO
