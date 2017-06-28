/*
name=[crm].[p_updateOffer]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
CVv/D6uItoM08EqOTEaWxQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_updateOffer]') AND type in (N'P', N'PC'))
DROP PROCEDURE [crm].[p_updateOffer]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_updateOffer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE crm.p_updateOffer 
	@xmlVar XML
AS
BEGIN
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT
        
        UPDATE crm.Offer
        SET
			[documentTypeId] =  CASE WHEN con.exist(''documentTypeId'') = 1 THEN con.query(''documentTypeId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[contractorId] =  CASE WHEN con.exist(''contractorId'') = 1 THEN con.query(''contractorId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[number] =  CASE WHEN con.exist(''number'') = 1 THEN con.query(''number'').value(''.'',''int'') ELSE NULL END ,  
			[fullNumber] =  CASE WHEN con.exist(''fullNumber'') = 1 THEN con.query(''fullNumber'').value(''.'',''nvarchar(50)'') ELSE NULL END ,  
			[seriesId] =  CASE WHEN con.exist(''seriesId'') = 1 THEN con.query(''seriesId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[statusId] =  CASE WHEN con.exist(''statusId'') = 1 THEN con.query(''statusId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[issueDate] =  CASE WHEN con.exist(''issueDate'') = 1 THEN con.query(''issueDate'').value(''.'',''datetime'') ELSE NULL END ,  
			[title] =  CASE WHEN con.exist(''title'') = 1 THEN con.query(''title'').value(''.'',''varchar(4000)'') ELSE NULL END ,  
			[creationDate] =  CASE WHEN con.exist(''creationDate'') = 1 THEN con.query(''creationDate'').value(''.'',''datetime'') ELSE NULL END ,  
			[modificationDate] =  CASE WHEN con.exist(''modificationDate'') = 1 THEN con.query(''modificationDate'').value(''.'',''datetime'') ELSE NULL END ,  
			[modificationApplicationUserId] =  CASE WHEN con.exist(''modificationApplicationUserId'') = 1 THEN con.query(''modificationApplicationUserId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[creationApplicationUserId] =  CASE WHEN con.exist(''creationApplicationUserId'') = 1 THEN con.query(''creationApplicationUserId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[version] =  CASE WHEN con.exist(''version'') = 1 THEN con.query(''version'').value(''.'',''uniqueidentifier'') ELSE NULL END 
		FROM    @xmlVar.nodes(''/root/offer/entry'') AS C ( con )
        WHERE   Offer.id = con.query(''id'').value(''.'', ''char(36)'')
                AND Offer.version = con.query(''version'').value(''.'', ''char(36)'')
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obs?uga błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:Offer ; error:''
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
