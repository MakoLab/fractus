/*
name=[communication].[p_getComplaintDocumentPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
fVT3W/9fluo8iL06MIYswg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getComplaintDocumentPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_getComplaintDocumentPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_getComplaintDocumentPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_getComplaintDocumentPackage] @id UNIQUEIDENTIFIER
AS /*Gets item xml package that match input parameter*/
    BEGIN
		/*Deklaracja zmiennych*/
        DECLARE @result XML
        
	/*Tworzenie obrazu danych*/
        SELECT  @result = ( ( 
				SELECT  
				 ( SELECT    
					( SELECT    CDL.*,  s.[numberSettingId]
                      FROM      [complaint].ComplaintDocumentHeader CDL 
						LEFT JOIN document.Series s ON CDL.seriesId = s.id
                      WHERE     CDL.id = @id
                      FOR XML PATH(''entry''), TYPE
                    )
                    FOR XML PATH(''complaintDocumentHeader''), TYPE
                    ),
			   (SELECT   (
							SELECT    e.*
							FROM      complaint.ComplaintDocumentLine e
							WHERE     e.complaintDocumentHeaderId = @id
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''complaintDocumentLine''), TYPE
			   ),
			   	(SELECT   (
							SELECT    e.*
							FROM      document.DocumentAttrValue e
							WHERE     e.complaintDocumentHeaderId = @id
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''documentAttrValue''), TYPE
			   ),
   			   (SELECT   (
							SELECT    e.*
							FROM      complaint.ComplaintDecision e
							WHERE     e.complaintDocumentLineId IN (SELECT id FROM complaint.ComplaintDocumentLine WHERE complaintDocumentHeaderId = @id)
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''complaintDecision''), TYPE
			   )  
			   FOR XML PATH(''root''), TYPE
                ) )


        /*Zwrócenie wyników*/                  
        SELECT  @result 
        /*Obsługa pustego resulta*/
        IF @@rowcount = 0 
            SELECT  ''''
            FOR     XML PATH(''root''),
                        TYPE
    END
' 
END
GO
