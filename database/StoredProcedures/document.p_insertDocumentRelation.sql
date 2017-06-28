/*
name=[document].[p_insertDocumentRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
zJ7eJNgbE7n0QSx6mEifww==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertDocumentRelation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_insertDocumentRelation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_insertDocumentRelation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_insertDocumentRelation] 
	@xmlVar XML
AS
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT,
			@idoc int

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

	INSERT INTO document.DocumentRelation ([id],  [firstCommercialDocumentHeaderId],  [secondCommercialDocumentHeaderId],  [firstWarehouseDocumentHeaderId],  [secondWarehouseDocumentHeaderId],  [firstFinancialDocumentHeaderId],  [secondFinancialDocumentHeaderId],[firstComplaintDocumentHeaderId], [secondComplaintDocumentHeaderId] , [firstInventoryDocumentHeaderId],[secondInventoryDocumentHeaderId],[relationType],  [version],[decimalValue],[xmlValue])   
	SELECT [id],  [firstCommercialDocumentHeaderId],  [secondCommercialDocumentHeaderId],  [firstWarehouseDocumentHeaderId],  [secondWarehouseDocumentHeaderId],  [firstFinancialDocumentHeaderId],  [secondFinancialDocumentHeaderId], [firstComplaintDocumentHeaderId], [secondComplaintDocumentHeaderId] ,[firstInventoryDocumentHeaderId],[secondInventoryDocumentHeaderId],[relationType],  [version],[decimalValue],[xmlValue]
	FROM OPENXML(@idoc, ''/root/documentRelation/entry'')
				WITH(
					id uniqueidentifier ''id'' ,  
					firstCommercialDocumentHeaderId uniqueidentifier ''firstCommercialDocumentHeaderId'' ,  
					secondCommercialDocumentHeaderId uniqueidentifier ''secondCommercialDocumentHeaderId'' ,  
					firstWarehouseDocumentHeaderId uniqueidentifier ''firstWarehouseDocumentHeaderId'' ,  
					secondWarehouseDocumentHeaderId uniqueidentifier ''secondWarehouseDocumentHeaderId'' ,  
					firstFinancialDocumentHeaderId uniqueidentifier ''firstFinancialDocumentHeaderId'' ,  
					secondFinancialDocumentHeaderId uniqueidentifier ''secondFinancialDocumentHeaderId'' ,
					firstComplaintDocumentHeaderId uniqueidentifier ''firstComplaintDocumentHeaderId'' ,  
					secondComplaintDocumentHeaderId uniqueidentifier ''secondComplaintDocumentHeaderId'' ,  
					firstInventoryDocumentHeaderId uniqueidentifier ''firstInventoryDocumentHeaderId'' ,  
					secondInventoryDocumentHeaderId uniqueidentifier ''secondInventoryDocumentHeaderId'' ,   
					relationType int ''relationType'' ,  
					[version] uniqueidentifier ''version'',
					[decimalValue] decimal(18,6) ''decimalValue'',
					[xmlValue] xml ''xmlValue'' 
					)
	EXEC sp_xml_removedocument @idoc

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:DocumentRelation; error:''
                + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            IF @rowcount = 0 
                RAISERROR ( 50011, 16, 1 ) ;
        END
        
END' 
END
GO
