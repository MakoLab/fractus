/*
name=[communication].[p_createContractorPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
iJ7b9ur50NG/dM+ig8CFYA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createContractorPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_createContractorPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createContractorPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_createContractorPackage]
@xmlVar XML
AS
BEGIN

		/*Deklaracja zmiennych*/
        DECLARE @snap XML,
            @errorMsg VARCHAR(2000),
            @rowcount INT,
            @contractorId UNIQUEIDENTIFIER,
            @previousVersion UNIQUEIDENTIFIER,
            @localTransactionId UNIQUEIDENTIFIER,
            @deferredTransactionId UNIQUEIDENTIFIER,
			@databaseId UNIQUEIDENTIFIER,
			@action varchar(50)

		/*Pobranie danych o transakcji*/
        SELECT  @contractorId = x.value(''@businessObjectId'', ''char(36)''),
                @previousVersion = x.value(''@previousVersion'', ''char(36)''),
                @localTransactionId = x.value(''@localTransactionId'', ''char(36)''),
                @deferredTransactionId = x.value(''@deferredTransactionId'', ''char(36)''),
				@databaseId = x.value(''@databaseId'', ''char(36)''),
				@action =  x.value(''@action'',''varchar(50)'')
        FROM    @xmlVar.nodes(''root'') AS a ( x )

		/*Walidacja użytkownika*/
        IF NOT EXISTS ( SELECT  id
                        FROM    contractor.Contractor
                        WHERE   id = @contractorId ) 
			AND @action <> ''delete''                          
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table: OutgoingXmlQueue; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
                RETURN 0
            END



                
        IF @action = ''delete''
			BEGIN
							SELECT  @snap = (  SELECT       
												( SELECT    
														(	SELECT   @previousVersion AS ''@previousVersion'', @action AS ''@action'', @contractorId AS  ''@id''
															FOR XML PATH(''entry''), TYPE
														)
													FOR XML PATH(''item''), TYPE
												)
									FOR XML PATH(''root'') ,TYPE
								) 
			END
		ELSE
		/*Tworzenie obrazu danych*/
        SELECT  @snap = ( SELECT    @previousVersion AS ''@previousVersion'',
                                    ( SELECT    ( SELECT DISTINCT
                                                            c.*
                                                  FROM      contractor.Contractor c
                                                  WHERE     c.id = @contractorId
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''contractor''),
                                          TYPE
                                    ),
                                    ( SELECT    ( SELECT    *
                                                  FROM      contractor.Employee
                                                  WHERE     contractorId = @contractorId
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''employee''),
                                          TYPE
                                    ),
                                    ( SELECT    ( SELECT    *
                                                  FROM      contractor.Bank
                                                  WHERE     contractorId = @contractorId
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''bank''),
                                          TYPE
                                    ),
                                    ( SELECT    ( SELECT    *
                                                  FROM      contractor.ContractorAddress
                                                  WHERE     contractorId = @contractorId
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''contractorAddress''),
                                          TYPE
                                    ),
                                    ( SELECT    ( SELECT    *
                                                  FROM      contractor.ContractorAccount
                                                  WHERE     contractorId = @contractorId
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''contractorAccount''),
                                          TYPE
                                    ),

                                    ( SELECT    ( SELECT    *
                                                  FROM      contractor.ApplicationUser
                                                  WHERE     contractorId = @contractorId
                                                FOR XML PATH(''entry''), TYPE
                                                )
                                    FOR  XML PATH(''applicationUser''), TYPE
                                    ),

                                    ( SELECT    ( SELECT    *
                                                  FROM      contractor.ContractorAttrValue
                                                  WHERE     contractorId = @contractorId
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''contractorAttrValue''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''root''),
                              TYPE
                        )

		/*Wstawienie danych*/
        INSERT  INTO communication.OutgoingXmlQueue
                (
                  id,
                  localTransactionId,
                  deferredTransactionId,
				  databaseId,
                  [type],
                  [xml],
                  creationDate
                )
                SELECT  NEWID(),
                        @localTransactionId,
                        @deferredTransactionId,
						@databaseId,
                        ''ContractorSnapshot'',
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
