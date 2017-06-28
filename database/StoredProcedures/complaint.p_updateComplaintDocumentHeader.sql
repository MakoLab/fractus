/*
name=[complaint].[p_updateComplaintDocumentHeader]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
AY/oJLzKzBi8kuc++hBQBw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_updateComplaintDocumentHeader]') AND type in (N'P', N'PC'))
DROP PROCEDURE [complaint].[p_updateComplaintDocumentHeader]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_updateComplaintDocumentHeader]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [complaint].[p_updateComplaintDocumentHeader] 
@xmlVar XML
AS 
    BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT,
            @applicationUserId UNIQUEIDENTIFIER

		/*Pobranie uzytkownika aplikacji*/
        SELECT  @applicationUserId = a.value(''@applicationUserId'', ''char(36)'')
        FROM    @xmlVar.nodes(''root'') AS x ( a )

        /*Aktualizacja danych */
        UPDATE  complaint.ComplaintDocumentHeader
        SET    
    
        [documentTypeId] =  CASE WHEN con.exist(''documentTypeId'') = 1 THEN con.query(''documentTypeId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
        [issuerContractorId] =  CASE WHEN con.exist(''issuerContractorId'') = 1 THEN con.query(''issuerContractorId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
        [issuerContractorAddressId] =  CASE WHEN con.exist(''issuerContractorAddressId'') = 1 THEN con.query(''issuerContractorAddressId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
        [contractorId] =  CASE WHEN con.exist(''contractorId'') = 1 THEN con.query(''contractorId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
        [contractorAddressId] =  CASE WHEN con.exist(''contractorAddressId'') = 1 THEN con.query(''contractorAddressId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
        [version] =  CASE WHEN con.exist(''_version'') = 1 THEN con.query(''_version'').value(''.'',''uniqueidentifier'') ELSE NULL END,
        [status] =  CASE WHEN con.exist(''status'') = 1 THEN con.query(''status'').value(''.'',''int'') ELSE NULL END                         
        FROM    @xmlVar.nodes(''/root/complaintDocumentHeader/entry'') AS C ( con )
        WHERE   ComplaintDocumentHeader.id = con.query(''id'').value(''.'', ''char(36)'')
                AND ComplaintDocumentHeader.version = con.query(''version'').value(''.'', ''char(36)'')


		/*Pobranie liczby pozycji*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:ComplaintDocumentHeader; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        ELSE 
            BEGIN
                IF @rowcount = 0 
                    RAISERROR ( 50012, 16, 1 ) ;
            END
 END
' 
END
GO
