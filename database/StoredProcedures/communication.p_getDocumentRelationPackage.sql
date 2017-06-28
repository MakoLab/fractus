/*
name=[communication].[p_getDocumentRelationPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
QSwZVzFduahsyhqs8rzBDQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getDocumentRelationPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getDocumentRelationPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getDocumentRelationPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getDocumentRelationPackage] 
@id UNIQUEIDENTIFIER 
AS /*Create object XML package, after create XML is stored in OutgoingXmlQueue*/
    BEGIN

		/*Deklaracja zmiennych*/
        DECLARE @snap XML


		/*Budowa obrazu danych*/
        SELECT  @snap = ( SELECT    
								( SELECT
										( SELECT   
                                                @id ''id'',
                                                firstCommercialDocumentHeaderId ''firstCommercialDocumentHeaderId'',
                                                secondCommercialDocumentHeaderId ''secondCommercialDocumentHeaderId'',
												firstWarehouseDocumentHeaderId ''firstWarehouseDocumentHeaderId'',
												secondWarehouseDocumentHeaderId	''secondWarehouseDocumentHeaderId'',										
												firstFinancialDocumentHeaderId ''firstFinancialDocumentHeaderId'',
												secondFinancialDocumentHeaderId	''secondFinancialDocumentHeaderId'',
												firstComplaintDocumentHeaderId ''firstComplaintDocumentHeaderId'',
												secondComplaintDocumentHeaderId	''secondComplaintDocumentHeaderId'',
												decimalValue ''decimalValue'',
												relationType ''relationType'',
                                                version ''version''
                                      FROM      document.DocumentRelation i 
									  WHERE i.id = @id
                                      FOR XML PATH(''entry''), TYPE )
                                FOR XML PATH(''documentRelation''), TYPE
                                )
                        FOR XML PATH(''root''), TYPE
                        )  

		SELECT @snap
    END
' 
END
GO
