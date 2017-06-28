/*
name=[configuration].[p_getConfigurationById]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
S3kmycOY2iOfbhF2E0XhLg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_getConfigurationById]') AND type in (N'P', N'PC'))
DROP PROCEDURE [configuration].[p_getConfigurationById]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_getConfigurationById]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [configuration].[p_getConfigurationById] @id UNIQUEIDENTIFIER
AS 
	
	/*Deklaracja zmiennych*/
    DECLARE @returnXML XML

	/*Budowa XML z konfiguracją*/
    SELECT  @returnXML = ( SELECT   ( SELECT    entry.*
                                      FROM      configuration.Configuration entry
                                      WHERE     id = @id
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                         )
	/*Zwrócenie wyników*/
    SELECT  ( SELECT    @returnXML
            FOR
              XML PATH(''configuration''),
                  TYPE
            )
    FOR     XML PATH(''root''),
                TYPE
' 
END
GO
