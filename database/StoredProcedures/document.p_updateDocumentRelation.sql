/*
name=[document].[p_updateDocumentRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
6oMjrPC8gaQw1wT5lDbw1A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateDocumentRelation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateDocumentRelation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateDocumentRelation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_updateDocumentRelation] 
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
        UPDATE  document.DocumentRelation
        SET    
	        [id] =  CASE WHEN con.exist(''id'') = 1 THEN con.query(''id'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
	        [firstCommercialDocumentHeaderId] =  CASE WHEN con.exist(''firstCommercialDocumentHeaderId'') = 1 THEN con.query(''firstCommercialDocumentHeaderId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
	        [secondCommercialDocumentHeaderId] =  CASE WHEN con.exist(''secondCommercialDocumentHeaderId'') = 1 THEN con.query(''secondCommercialDocumentHeaderId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
	        [firstWarehouseDocumentHeaderId] =  CASE WHEN con.exist(''firstWarehouseDocumentHeaderId'') = 1 THEN con.query(''firstWarehouseDocumentHeaderId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
	        [secondWarehouseDocumentHeaderId] =  CASE WHEN con.exist(''secondWarehouseDocumentHeaderId'') = 1 THEN con.query(''secondWarehouseDocumentHeaderId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
	        [firstFinancialDocumentHeaderId] =  CASE WHEN con.exist(''firstFinancialDocumentHeaderId'') = 1 THEN con.query(''firstFinancialDocumentHeaderId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
	        [secondFinancialDocumentHeaderId] =  CASE WHEN con.exist(''secondFinancialDocumentHeaderId'') = 1 THEN con.query(''secondFinancialDocumentHeaderId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
	        [firstComplaintDocumentHeaderId] =  CASE WHEN con.exist(''firstComplaintDocumentHeaderId'') = 1 THEN con.query(''firstComplaintDocumentHeaderId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
	        [secondComplaintDocumentHeaderId] =  CASE WHEN con.exist(''secondComplaintDocumentHeaderId'') = 1 THEN con.query(''secondComplaintDocumentHeaderId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
	        [firstInventoryDocumentHeaderId] =  CASE WHEN con.exist(''firstInventoryDocumentHeaderId'') = 1 THEN con.query(''firstInventoryDocumentHeaderId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
	        [secondInventoryDocumentHeaderId] =  CASE WHEN con.exist(''secondInventoryDocumentHeaderId'') = 1 THEN con.query(''secondInventoryDocumentHeaderId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
	        [relationType] =  CASE WHEN con.exist(''relationType'') = 1 THEN con.query(''relationType'').value(''.'',''int'') ELSE NULL END ,  
	        [version] =  CASE WHEN con.exist(''_version'') = 1 THEN con.query(''_version'').value(''.'',''uniqueidentifier'') ELSE NULL END ,
			[decimalValue] =  CASE WHEN con.exist(''decimalValue'') = 1 THEN con.query(''decimalValue'').value(''.'',''decimal(18,6)'') ELSE NULL END ,
			[xmlValue] =  CASE WHEN con.exist(''xmlValue'') = 1 THEN con.query(''xmlValue/*'') ELSE NULL END 	                             
                                 
        FROM    @xmlVar.nodes(''/root/documentRelation/entry'') AS C ( con )
        WHERE   DocumentRelation.id = con.query(''id'').value(''.'', ''char(36)'')
                AND DocumentRelation.version = con.query(''version'').value(''.'', ''char(36)'')


		/*Pobranie liczby pozycji*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:DocumentRelation; error:''
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
