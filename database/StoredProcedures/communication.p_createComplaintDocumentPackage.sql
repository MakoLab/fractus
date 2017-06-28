/*
name=[communication].[p_createComplaintDocumentPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Q1EbCLJ/BajUgEl01Ho5Nw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createComplaintDocumentPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_createComplaintDocumentPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createComplaintDocumentPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_createComplaintDocumentPackage]
@xmlVar XML
AS
BEGIN

		/*Deklaracja zmiennych*/
        DECLARE @snap XML,
            @errorMsg VARCHAR(2000),
            @rowcount INT,
            @complaintDocumentHeaderId UNIQUEIDENTIFIER,
            @previousVersion UNIQUEIDENTIFIER,
            @localTransactionId UNIQUEIDENTIFIER,
            @deferredTransactionId UNIQUEIDENTIFIER,
			@databaseId UNIQUEIDENTIFIER


		/*Pobranie danych o transakcji*/
        SELECT  @complaintDocumentHeaderId = x.value(''@businessObjectId'', ''char(36)''),
				@databaseId =  x.value(''@databaseId'', ''char(36)''),
                @previousVersion = x.value(''@previousVersion'', ''char(36)''),
                @localTransactionId = x.value(''@localTransactionId'',''char(36)''),
                @deferredTransactionId = x.value(''@deferredTransactionId'',''char(36)'')
        FROM    @xmlVar.nodes(''root'') AS a ( x )

		/*Walidacja dokumentu*/
        IF NOT EXISTS ( SELECT  id
                        FROM     [complaint].ComplaintDocumentHeader
                        WHERE   id = @complaintDocumentHeaderId ) 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych; table: OutgoingXmlQueue; Brak dokumentu o id = ''
					+ CAST(@complaintDocumentHeaderId AS VARCHAR(36)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
                RETURN 0
            END

        
		/*Tworzenie obrazu danych*/
        SELECT  @snap = (         
							
							( 

				SELECT @previousVersion AS ''@previousVersion'',  
				 ( SELECT    
					( SELECT    CDL.*,  s.[numberSettingId]
                      FROM      [complaint].ComplaintDocumentHeader CDL 
						LEFT JOIN document.Series s ON CDL.seriesId = s.id
                      WHERE     CDL.id = @complaintDocumentHeaderId
                      FOR XML PATH(''entry''), TYPE
                    )
                    FOR XML PATH(''complaintDocumentHeader''), TYPE
                    ),
			   (SELECT   (
							SELECT    e.*
							FROM      complaint.ComplaintDocumentLine e
							WHERE     e.complaintDocumentHeaderId = @complaintDocumentHeaderId
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''complaintDocumentLine''), TYPE
			   ),
			   	(SELECT   (
							SELECT    e.*
							FROM      document.DocumentAttrValue e
							WHERE     e.complaintDocumentHeaderId = @complaintDocumentHeaderId
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''documentAttrValue''), TYPE
			   ),
   			   (SELECT   (
							SELECT    e.*
							FROM      complaint.ComplaintDecision e
							WHERE     e.complaintDocumentLineId IN (SELECT id FROM complaint.ComplaintDocumentLine WHERE complaintDocumentHeaderId = @complaintDocumentHeaderId)
							FOR XML PATH(''entry''), TYPE
						   )
						   FOR XML PATH(''complaintDecision''), TYPE
			   )  
			   FOR XML PATH(''root''), TYPE
                ) )

		/*Wstawienie danych*/
        INSERT  INTO communication.OutgoingXmlQueue
                (
                  id,
                  localTransactionId,
				  databaseId,
                  deferredTransactionId,
                  [type],
                  [xml],
                  creationDate
                )
                SELECT  NEWID(),
                        @localTransactionId,
						@databaseId,
                        @deferredTransactionId,
                        ''ComplaintDocumentSnapshot'',
                        @snap,
                        GETDATE()

		/*Pobranie liczby zmodyfikowanych wierszy*/
        SET @rowcount = @@ROWCOUNT

		/*Obsługa wyjątków i błędów*/
        IF @@error <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table: OutgoingXmlQueue; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
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
