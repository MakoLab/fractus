/*
name=[contractor].[p_updateContractorDictionary]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
C6vwt6xKvpUmMQ2bLOWZYw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_updateContractorDictionary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_updateContractorDictionary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_updateContractorDictionary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [contractor].[p_updateContractorDictionary]
--declare
@xmlVar XML
AS
BEGIN
--set @xmlVar = ''<root businessObjectId="58EE4E77-7E4A-48D0-BDBF-1659D49C4986" mode="update" applicationUserId="D1F80960-EC30-48E4-979B-F7A5D33C25B3"/>''
		
		/*Deklaracja zmiennych*/
        DECLARE @snap XML,
            @errorMsg VARCHAR(2000),
            @rowcount INT,
            @contractorId UNIQUEIDENTIFIER,
            @mode VARCHAR(50)

		/*Pobranie danych o operacji*/
        SELECT  @contractorId = @xmlVar.value(''(root/@businessObjectId)[1]'', ''char(36)''),
                @mode = @xmlVar.value(''(root/@mode)[1]'', ''varchar(50)'')
       -- FROM    @xmlVar.nodes(''root'') AS a ( x )

        
		/*Tworzenie snapshota kontrahenta*/
        SELECT  @snap = ( SELECT    ( SELECT    ( SELECT DISTINCT
                                                            c.*
                                                  FROM      contractor.Contractor c
                                                  WHERE     c.id = @contractorId
--                                                            OR c.id IN (
--                                                            SELECT  relatedContractorId
--                                                            FROM    contractor.ContractorRelation
--                                                            WHERE   ContractorId = @contractorId )
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
                                                  FROM      contractor.ContractorRelation
                                                  WHERE     contractorId = @contractorId
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''contractorRelation''),
                                          TYPE
                                    ),
                                    ( SELECT    ( SELECT    *
                                                  FROM      contractor.ContractorGroupMembership
                                                  WHERE     contractorId = @contractorId
                                                FOR
                                                  XML PATH(''entry''),
                                                      TYPE
                                                )
                                    FOR
                                      XML PATH(''contractorGroupMembership''),
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


		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd pobrania danych table: ContractorSnapshot; error:''
                    + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
	
		/*Aktualizacja słownika kontrahenta*/
        IF @mode = ''insert'' 
            EXEC contractor.p_insertContractorDictionary @snap
        IF @mode = ''update'' 
            BEGIN
                DELETE  FROM contractor.ContractorDictionary
                WHERE id IN (
                        SELECT  cdr.contractorDictionaryId
                        FROM contractor.ContractorDictionaryRelation cdr
							LEFT JOIN  contractor.ContractorDictionaryRelation cdr1 ON cdr.contractorDictionaryId = cdr1.contractorDictionaryId AND cdr1.contractorId <> @contractorId
                        WHERE   cdr.contractorId = @contractorId AND cdr1.contractorDictionaryId IS NULL )
                       

				--/*Kasowanie danych o powiązaniach z indeksem*/
    --            DELETE  FROM contractor.ContractorDictionaryRelation
    --            WHERE   contractorId = @contractorId


                /*Wstawienie słów i powiązań*/
                EXEC contractor.p_insertContractorDictionary @snap
                                /*Kasowanie powiązań bes słów kluczowych*/

            END

		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd aktualizacji słownika: Contractor; error:''
                    + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
            
	
    END
' 
END
GO
