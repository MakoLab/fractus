/*
name=[crm].[p_insertEvent]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
8pVVFxGxIoYX0q31RAj7/w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_insertEvent]') AND type in (N'P', N'PC'))
DROP PROCEDURE [crm].[p_insertEvent]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_insertEvent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE crm.p_insertEvent 
	@xmlVar XML
AS
BEGIN
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT
INSERT INTO crm.Event ([id],  [eventTypeId],  [contractorId],  [number],  [fullNumber],  [issueDate],  [seriesId],  [issuingPersonContractorId],  [modificationDate],  [modificationApplicationUserId],  [version],  [status],  [companyId])   
SELECT NULLIF(x.value(''(id)[1]'',''uniqueidentifier'') ,''''),  
		NULLIF(x.value(''(eventTypeId)[1]'',''uniqueidentifier'') ,''''), 
		NULLIF(x.value(''(contractorId)[1]'',''char(36)'') ,''''),  
		NULLIF(x.value(''(number)[1]'',''int'') ,''''),  
		NULLIF(x.value(''(fullNumber)[1]'',''nvarchar(50)'') ,''''),  
		NULLIF(x.value(''(issueDate)[1]'',''datetime'') ,''''),  
		NULLIF(x.value(''(seriesId)[1]'',''char(36)'') ,''''),  
		NULLIF(x.value(''(issuingPersonContractorId)[1]'',''char(36)'') ,''''),  
		NULLIF(x.value(''(modificationDate)[1]'',''datetime'') ,''''),  
		NULLIF(x.value(''(modificationApplicationUserId)[1]'',''char(36)'') ,''''),  
		x.value(''(version)[1]'',''char(36)''),  
		NULLIF(x.value(''(status)[1]'',''int'') ,''''),  
		NULLIF(x.value(''(companyId)[1]'',''char(36)'') ,'''')
FROM @xmlVar.nodes(''root'') as a(x) 
  
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błądów i wyjątków*/
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
