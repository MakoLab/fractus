/*
name=[communication].[p_getSeriesPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
D++zlozQtkEjojVb2cuORg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getSeriesPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getSeriesPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getSeriesPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [communication].[p_getSeriesPackage]
    @seriesId UNIQUEIDENTIFIER
AS 
    BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @result XML
        
		/*Budowa obrazu danych*/
        SELECT  @result = ( SELECT  ( SELECT    ( SELECT DISTINCT
                                                            s.id,[numberSettingId], RTRIM([seriesValue]) [seriesValue],[lastNumber]
                                                  FROM      document.Series s
                                                  WHERE     s.id = @seriesId
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''series''),
                                          TYPE
                                    )                          
							FOR
                            XML PATH(''root''),
                                TYPE
                          )
		/*Zwrócenie danych*/
        SELECT  @result 
        /*Obsługa pustego rasulta*/
        IF @@rowcount = 0 
            SELECT  ''''
            FOR     XML PATH(''root''),
                        TYPE
    END
' 
END
GO
