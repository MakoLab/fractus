/*
name=[complaint].[p_updateComplaintDecision]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Q8qzEJnRswWg0u/LbEQXug==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_updateComplaintDecision]') AND type in (N'P', N'PC'))
DROP PROCEDURE [complaint].[p_updateComplaintDecision]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_updateComplaintDecision]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [complaint].[p_updateComplaintDecision] 
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
        UPDATE  complaint.ComplaintDecision
        SET    
		   [id] =  CASE WHEN con.exist(''id'') = 1 THEN con.query(''id'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
		   [complaintDocumentLineId] =  CASE WHEN con.exist(''complaintDocumentLineId'') = 1 THEN con.query(''complaintDocumentLineId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
		   [issueDate] =  CASE WHEN con.exist(''issueDate'') = 1 THEN con.query(''issueDate'').value(''.'',''datetime'') ELSE NULL END ,  
		   [issuingPersonContractorId] =  CASE WHEN con.exist(''issuingPersonContractorId'') = 1 THEN con.query(''issuingPersonContractorId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
		   [replacementItemId] =  CASE WHEN con.exist(''replacementItemId'') = 1 THEN con.query(''replacementItemId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
		   [replacementItemName] =  CASE WHEN con.exist(''replacementItemName'') = 1 THEN con.query(''replacementItemName'').value(''.'',''nvarchar(500)'') ELSE NULL END ,  
		   [warehouseId] =  CASE WHEN con.exist(''warehouseId'') = 1 THEN con.query(''warehouseId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
		   [quantity] =  CASE WHEN con.exist(''quantity'') = 1 THEN con.query(''quantity'').value(''.'',''numeric(18,6)'') ELSE NULL END ,  
		   [decisionText] =  CASE WHEN con.exist(''decisionText'') = 1 THEN con.query(''decisionText'').value(''.'',''nvarchar(2000)'') ELSE NULL END ,  
		   [decisionType] =  CASE WHEN con.exist(''decisionType'') = 1 THEN con.query(''decisionType'').value(''.'',''int'') ELSE NULL END ,  
		   [version] =  CASE WHEN con.exist(''version'') = 1 THEN con.query(''version'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
		   [order] =  CASE WHEN con.exist(''order'') = 1 THEN con.query(''order'').value(''.'',''int'') ELSE NULL END,
		   [realizeOption] =  CASE WHEN con.exist(''realizeOption'') = 1 THEN con.query(''realizeOption'').value(''.'',''int'') ELSE NULL END ,  
		   [replacementUnitId] =  CASE WHEN con.exist(''replacementUnitId'') = 1 THEN con.query(''replacementUnitId'').value(''.'',''uniqueidentifier'') ELSE NULL END                                 
        FROM    @xmlVar.nodes(''/root/complaintDecision/entry'') AS C ( con )
        WHERE   ComplaintDecision.id = con.query(''id'').value(''.'', ''char(36)'')
                AND ComplaintDecision.version = con.query(''version'').value(''.'', ''char(36)'')


		/*Pobranie liczby pozycji*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:ComplaintDecision; error:''
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
