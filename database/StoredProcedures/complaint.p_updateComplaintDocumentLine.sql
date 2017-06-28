/*
name=[complaint].[p_updateComplaintDocumentLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
hKsVE3ptOeYGXUFjVd8r4g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_updateComplaintDocumentLine]') AND type in (N'P', N'PC'))
DROP PROCEDURE [complaint].[p_updateComplaintDocumentLine]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_updateComplaintDocumentLine]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [complaint].[p_updateComplaintDocumentLine] 
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
        UPDATE  complaint.ComplaintDocumentLine
        SET    
        [id] =  CASE WHEN con.exist(''id'') = 1 THEN con.query(''id'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
        [complaintDocumentHeaderId] =  CASE WHEN con.exist(''complaintDocumentHeaderId'') = 1 THEN con.query(''complaintDocumentHeaderId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
        [itemId] =  CASE WHEN con.exist(''itemId'') = 1 THEN con.query(''itemId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,
        [unitId] =  CASE WHEN con.exist(''unitId'') = 1 THEN con.query(''unitId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
        [itemName] =  CASE WHEN con.exist(''itemName'') = 1 THEN con.query(''itemName'').value(''.'',''nvarchar(500)'') ELSE NULL END ,  
        [quantity] =  CASE WHEN con.exist(''quantity'') = 1 THEN con.query(''quantity'').value(''.'',''numeric(18,6)'') ELSE NULL END ,  
        [remarks] =  CASE WHEN con.exist(''remarks'') = 1 THEN con.query(''remarks'').value(''.'',''nvarchar(2000)'') ELSE NULL END ,  
        [issueDate] =  CASE WHEN con.exist(''issueDate'') = 1 THEN con.query(''issueDate'').value(''.'',''datetime'') ELSE NULL END ,  
        [issuingPersonContractorId] =  CASE WHEN con.exist(''issuingPersonContractorId'') = 1 THEN con.query(''issuingPersonContractorId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
        [version] =  CASE WHEN con.exist(''version'') = 1 THEN con.query(''version'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
        [ordinalNumber] =  CASE WHEN con.exist(''ordinalNumber'') = 1 THEN con.query(''ordinalNumber'').value(''.'',''int'') ELSE NULL END                           
        FROM    @xmlVar.nodes(''/root/complaintDocumentLine/entry'') AS C ( con )
        WHERE   ComplaintDocumentLine.id = con.query(''id'').value(''.'', ''char(36)'')
                AND ComplaintDocumentLine.version = con.query(''version'').value(''.'', ''char(36)'')


		/*Pobranie liczby pozycji*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:ComplaintDocumentLine; error:''
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
