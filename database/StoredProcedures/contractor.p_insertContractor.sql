/*
name=[contractor].[p_insertContractor]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
5Jh9qv6rq1Xb7a4158++jQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertContractor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_insertContractor]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertContractor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_insertContractor] @xmlVar XML
AS 
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT,
        @userId char(36),
		@error int 
    
  BEGIN TRY
        

    
    SELECT @userId = @xmlVar.value(''(root/@applicationUserId)[1]'',''char(36)'')


	/*Wstawienie danych o kontrhencie*/
    INSERT  INTO contractor.Contractor
            (
              id,
              code,
              isSupplier,
              isReceiver,
              isBusinessEntity,
              isBank,
              fullName,
              shortName,
              nip,
              strippedNip,
              nipPrefixCountryId,
              isOwnCompany,
              version,
              creationDate,
              modificationUserId,
              creationUserId
            )
            SELECT  con.value(''(id)[1]'', ''char(36)''),
                    con.value(''(code)[1]'', ''varchar(50)''),
                    con.value(''(isSupplier)[1]'', ''bit''),
                    con.value(''(isReceiver)[1]'', ''bit''),
                    con.value(''(isBusinessEntity)[1]'', ''bit''),
                    con.value(''(isBank)[1]'', ''bit''),
                    con.value(''(fullName)[1]'', ''varchar(500)''),
                    con.value(''(shortName)[1]'', ''varchar(40)''),
                    NULLIF(con.value(''(nip)[1]'', ''nvarchar(40)''), ''''),
                    REPLACE(REPLACE(NULLIF(con.value(''(nip)[1]'', ''nvarchar(40)''),''''), ''-'', ''''), '' '', ''''),
                    NULLIF(con.value(''(nipPrefixCountryId)[1]'', ''char(36)''),''''),
                    con.value(''(isOwnCompany)[1]'', ''bit''),
                    ISNULL(con.value(''(_version)[1]'', ''char(36)''),  con.value(''(version)[1]'', ''char(36)'')),
                    GETDATE(),
                    NULLIF(con.value(''(modificationUserId)[1]'', ''char(36)''),''''),
                    ISNULL(NULLIF(con.value(''(creationUserId)[1]'', ''char(36)''),''''),@userId)
            FROM    @xmlVar.nodes(''/root/contractor/entry'') AS C ( con )
			WHERE con.value(''(id)[1]'', ''char(36)'') NOT IN (SELECT id FROM contractor.Contractor)

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
			EXEC contractor.p_updateContractor @xmlVar
		END

    EXEC contractor.p_insertContractorDictionary @xmlVar

END
' 
END
GO
