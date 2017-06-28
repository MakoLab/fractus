/*
name=[communication].[p_getFileDescriptorPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
QJFo75SVcsfVOvFAxAInmQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getFileDescriptorPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getFileDescriptorPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getFileDescriptorPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getFileDescriptorPackage] @id UNIQUEIDENTIFIER
AS /*Gets item xml package that match input parameter*/
    BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @result XML
        
		/*Tworzenie obrazu danych*/
        SELECT  @result = (         
						
								
							( 

							SELECT 
                            ( SELECT    ( SELECT   *
                                          FROM      repository.fileDescriptor
                                          WHERE     id = @id
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''fileDescriptor''),
                                  TYPE
                            )
                FOR
                  XML PATH(''root''),
                      TYPE
                ) )

        /*Zwrócenie wyników*/                  
        SELECT  @result 
        /*Obsługa pustego resulta*/
        IF @@rowcount = 0 
            SELECT  ''''
            FOR     XML PATH(''root''),
                        TYPE
    END
' 
END
GO
