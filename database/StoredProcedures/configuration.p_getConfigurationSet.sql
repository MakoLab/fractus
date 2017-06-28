/*
name=[configuration].[p_getConfigurationSet]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
mqRml23EvTWNZqQ0P2o2Xw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_getConfigurationSet]') AND type in (N'P', N'PC'))
DROP PROCEDURE [configuration].[p_getConfigurationSet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_getConfigurationSet]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [configuration].[p_getConfigurationSet] @xmlVar XML
AS 
	/*Deklaracja zmiennych*/
    DECLARE @returnXML XML

	/*Budowa XML z danymi o konfiguracji*/
    SELECT  @returnXML = ( SELECT   ( SELECT    entry.*
                                      FROM      configuration.Configuration entry
                                                JOIN @xmlVar.nodes(''root/entry'') a ( x ) ON [entry].[key] = x.value(''.'', ''varchar(250)'')
                                      ORDER BY  companyContractorId,
                                                branchId,
                                                userProfileId,
                                                workstationId,
                                                applicationUserId
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
