/*
name=[crm].[p_updateEvent]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
xwRswCJpwTun4tuiF+bsSg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_updateEvent]') AND type in (N'P', N'PC'))
DROP PROCEDURE [crm].[p_updateEvent]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_updateEvent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE crm.p_updateEvent 
	@xmlVar XML
AS
BEGIN
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT
        
        
        UPDATE crm.[Event]
        SET
			[eventTypeId] =  CASE WHEN con.exist(''eventTypeId'') = 1 THEN con.query(''eventTypeId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[contractorId] =  CASE WHEN con.exist(''contractorId'') = 1 THEN con.query(''contractorId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[number] =  CASE WHEN con.exist(''number'') = 1 THEN con.query(''number'').value(''.'',''int'') ELSE NULL END ,  
			[fullNumber] =  CASE WHEN con.exist(''fullNumber'') = 1 THEN con.query(''fullNumber'').value(''.'',''nvarchar(50)'') ELSE NULL END ,  
			[issueDate] =  CASE WHEN con.exist(''issueDate'') = 1 THEN con.query(''issueDate'').value(''.'',''datetime'') ELSE NULL END ,  
			[seriesId] =  CASE WHEN con.exist(''seriesId'') = 1 THEN con.query(''seriesId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[issuingPersonContractorId] =  CASE WHEN con.exist(''issuingPersonContractorId'') = 1 THEN con.query(''issuingPersonContractorId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[modificationDate] =  CASE WHEN con.exist(''modificationDate'') = 1 THEN con.query(''modificationDate'').value(''.'',''datetime'') ELSE NULL END ,  
			[modificationApplicationUserId] =  CASE WHEN con.exist(''modificationApplicationUserId'') = 1 THEN con.query(''modificationApplicationUserId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[version] =  CASE WHEN con.exist(''_version'') = 1 THEN con.query(''_version'').value(''.'',''uniqueidentifier'') ELSE NULL END , 
			[status] =  CASE WHEN con.exist(''status'') = 1 THEN con.query(''status'').value(''.'',''int'') ELSE NULL END ,  
			[companyId] =  CASE WHEN con.exist(''companyId'') = 1 THEN con.query(''companyId'').value(''.'',''uniqueidentifier'') ELSE NULL END 
		FROM    @xmlVar.nodes(''/root/event/entry'') AS C ( con )
        WHERE   [Event].id = con.query(''id'').value(''.'', ''char(36)'')
                AND [Event].version = con.query(''version'').value(''.'', ''char(36)'')
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obs?uga błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:Event ; error:''
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
