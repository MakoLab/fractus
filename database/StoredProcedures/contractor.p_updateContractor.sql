/*
name=[contractor].[p_updateContractor]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Rrt0pWJlVW7CEWK+MG/V+A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_updateContractor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_updateContractor]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_updateContractor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [contractor].[p_updateContractor] @xmlVar XML
AS 
    BEGIN
    
	/*Deklaracja zmiennych*/
		DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT,
			@error int 
    
	BEGIN TRY
        
        /*Aktualizacja danych kontrahenta*/
        UPDATE  contractor.Contractor
        SET     code = con.value(''(code)[1]'', ''varchar(50)''),
                isSupplier = con.value(''(isSupplier)[1]'', ''bit''),
                isReceiver = con.value(''(isReceiver)[1]'', ''bit''),
                isBusinessEntity = con.value(''(isBusinessEntity)[1]'', ''bit''),
                isBank = con.value(''(isBank)[1]'', ''bit''),
                fullName = con.value(''(fullName)[1]'', ''varchar(500)''),
                shortName = con.value(''(shortName)[1]'', ''varchar(40)''),
                nip =  con.value(''(nip)[1]'', ''nvarchar(40)''),
                strippedNip = REPLACE(REPLACE(con.value(''(nip)[1]'', ''nvarchar(40)'') , ''-'', ''''), '' '', ''''),
                nipPrefixCountryId =  con.value(''(nipPrefixCountryId)[1]'', ''char(36)'') ,
                [version] = ISNULL(con.value(''(_version)[1]'', ''char(36)''),con.value(''(version)[1]'', ''char(36)'')) ,
                modificationDate = getdate(),
                modificationUserId = NULLIF(@xmlVar.value(''(root/@applicationUserId)[1]'',''char(36)''),'''')
        FROM    @xmlVar.nodes(''/root/contractor/entry'') AS C ( con )
        WHERE   Contractor.id = con.value(''(id)[1]'', ''char(36)'')
                
		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT	

    END TRY
	BEGIN CATCH
			SELECT @errorMsg = ''Błąd wstawiania danych tabela:Contractor; error:''
				+ CAST(@@ERROR AS VARCHAR(50)) + '';Procedura:'' + ERROR_PROCEDURE() + '';Linia:'' + CAST(ERROR_LINE() as varchar(50))+ '';Opis:'' + ERROR_MESSAGE() 
            RAISERROR ( @errorMsg, 16, 1)
    END CATCH        
	IF @rowcount = 0 
		BEGIN
			EXEC contractor.p_insertContractor @xmlVar
		END
    END
' 
END
GO
