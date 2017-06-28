/*
name=[communication].[p_getContractorPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
9Mkid9hBFBc7McLtR08S2A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getContractorPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getContractorPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getContractorPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getContractorPackage]
    @contractorId UNIQUEIDENTIFIER
AS 
    BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @result XML
        
		/*Budowa obrazu danych*/
        SELECT  @result = ( SELECT  ( SELECT    ( SELECT DISTINCT
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
