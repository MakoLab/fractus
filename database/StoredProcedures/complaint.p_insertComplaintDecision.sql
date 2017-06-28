/*
name=[complaint].[p_insertComplaintDecision]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ZW7ClvTE2rE+AUkgeR20Tg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_insertComplaintDecision]') AND type in (N'P', N'PC'))
DROP PROCEDURE [complaint].[p_insertComplaintDecision]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_insertComplaintDecision]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [complaint].[p_insertComplaintDecision] 
	@xmlVar XML
AS
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT,
			@idoc int

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

	INSERT INTO complaint.ComplaintDecision ([id],  [complaintDocumentLineId],  [issueDate],  [issuingPersonContractorId],  [replacementItemId],  [replacementItemName],  [warehouseId],  [quantity],  [decisionText],  [decisionType],  [version],  [order], [realizeOption], [replacementUnitId ])   
	SELECT [id],  [complaintDocumentLineId],  [issueDate],  [issuingPersonContractorId],  [replacementItemId],  [replacementItemName],  [warehouseId],  [quantity],  [decisionText],  [decisionType],  [version],  [order] , [realizeOption], [replacementUnitId ]
	FROM OPENXML(@idoc, ''/root/complaintDecision/entry'')
				WITH(
						id uniqueidentifier ''id'' ,  
						complaintDocumentLineId uniqueidentifier ''complaintDocumentLineId'' ,  
						issueDate datetime ''issueDate'' ,  
						issuingPersonContractorId uniqueidentifier ''issuingPersonContractorId'' ,  
						replacementItemId uniqueidentifier ''replacementItemId'' ,  
						replacementItemName nvarchar(500) ''replacementItemName'' ,  
						warehouseId uniqueidentifier ''warehouseId'' ,  
						quantity numeric(18,6) ''quantity'' ,  
						decisionText nvarchar(2000) ''decisionText'' ,  
						decisionType int ''decisionType'' ,  
						[version] uniqueidentifier ''version'' ,  
						[order] int ''order'',
						realizeOption int ''realizeOption'',
						replacementUnitId  uniqueidentifier ''replacementUnitId''
					)
	EXEC sp_xml_removedocument @idoc

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:ComplaintDecision; error:''
                + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
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
