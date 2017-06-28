/*
name=[communication].[p_createFileDescriptorPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
SVyNtEhlzBqFMKsYV3RsyQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createFileDescriptorPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_createFileDescriptorPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createFileDescriptorPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_createFileDescriptorPackage]
@xmlVar XML
AS
BEGIN

		/*Deklaracja zmiennych*/
        DECLARE @snap XML,
            @errorMsg VARCHAR(2000),
            @rowcount INT,
            @businessObjectId UNIQUEIDENTIFIER,
            @previousVersion UNIQUEIDENTIFIER,
            @localTransactionId UNIQUEIDENTIFIER,
            @deferredTransactionId UNIQUEIDENTIFIER,
			@databaseId UNIQUEIDENTIFIER


		/*Pobranie danych o transakcji*/
        SELECT  @businessObjectId = x.value(''@businessObjectId'', ''char(36)''),
				@databaseId =  x.value(''@databaseId'', ''char(36)''),
                @previousVersion = x.value(''@previousVersion'', ''char(36)''),
                @localTransactionId = x.value(''@localTransactionId'',''char(36)''),
                @deferredTransactionId = x.value(''@deferredTransactionId'',''char(36)'')
        FROM    @xmlVar.nodes(''root'') AS a ( x )



		/*Walidacja obiektu*/
        IF NOT EXISTS ( SELECT  id
                        FROM     repository.fileDescriptor
                        WHERE   id = @businessObjectId ) 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table: OutgoingXmlQueue; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
                RETURN 0
            END

        
		/*Tworzenie obrazu danych*/
        SELECT  @snap = (         
							
							( 

							SELECT @previousVersion AS ''@previousVersion'', 
                            ( SELECT    ( SELECT   *
                                          FROM      repository.fileDescriptor
                                          WHERE     id = @businessObjectId
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

		/*Wstawienie danych*/
        INSERT  INTO communication.OutgoingXmlQueue
                (
                  id,
                  localTransactionId,
				  databaseId,
                  deferredTransactionId,
                  [type],
                  [xml],
                  creationDate
                )
                SELECT  NEWID(),
                        @localTransactionId,
						@databaseId,
                        @deferredTransactionId,
                        ''FileDescriptor'',
                        @snap,
                        GETDATE()

		/*Pobranie liczby zmodyfikowanych wierszy*/
        SET @rowcount = @@ROWCOUNT

		/*Obsługa wyjątków i błędów*/
        IF @@error <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table: OutgoingXmlQueue; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        ELSE 
            BEGIN
                
                IF @rowcount = 0 
                    RAISERROR ( 50011, 16, 1 ) ;
            END

    END
' 
END
GO
