/*
name=[complaint].[p_insertComplaintDocumentLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
UFicjn2YZGA5o9sqlljk/A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_insertComplaintDocumentLine]') AND type in (N'P', N'PC'))
DROP PROCEDURE [complaint].[p_insertComplaintDocumentLine]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_insertComplaintDocumentLine]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [complaint].[p_insertComplaintDocumentLine] 
	@xmlVar XML
AS
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT,
			@idoc int

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

	INSERT INTO complaint.ComplaintDocumentLine ([id],  [complaintDocumentHeaderId],  [itemId],  [itemName],  [quantity],  [remarks],  [issueDate],  [issuingPersonContractorId],  [version],  [ordinalNumber], [unitId])   
	SELECT [id],  [complaintDocumentHeaderId],  [itemId],  [itemName],  [quantity],  [remarks],  [issueDate],  [issuingPersonContractorId],  [version],  [ordinalNumber] , [unitId]

	FROM OPENXML(@idoc, ''/root/complaintDocumentLine/entry'')
				WITH(
						id uniqueidentifier ''id'' ,  
						complaintDocumentHeaderId uniqueidentifier ''complaintDocumentHeaderId'' ,  
						itemId uniqueidentifier ''itemId'' ,  
						itemName nvarchar(500) ''itemName'' ,  
						quantity numeric(18,6) ''quantity'' ,  
						remarks nvarchar(2000) ''remarks'' ,  
						issueDate datetime ''issueDate'' ,  
						issuingPersonContractorId uniqueidentifier ''issuingPersonContractorId'' ,  
						[version] uniqueidentifier ''version'' ,  
						ordinalNumber int ''ordinalNumber'',
						unitId uniqueidentifier ''unitId'' 
					)
	EXEC sp_xml_removedocument @idoc

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:ComplaintDocumentLine; error:''
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
