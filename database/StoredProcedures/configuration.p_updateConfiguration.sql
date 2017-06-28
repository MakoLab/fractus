/*
name=[configuration].[p_updateConfiguration]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
xBvAXz/3MGGA4tLgxoSGcQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_updateConfiguration]') AND type in (N'P', N'PC'))
DROP PROCEDURE [configuration].[p_updateConfiguration]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_updateConfiguration]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N' 

CREATE PROCEDURE [configuration].[p_updateConfiguration] 
@xmlVar XML
AS
BEGIN
	DECLARE @errorMsg VARCHAR(2000),
			@rowcount INT,
			@error int 
    
  BEGIN TRY      
    /*Aktualizacja danych o konfiguracji*/
    UPDATE  [configuration].Configuration
    SET     companyContractorId = CASE WHEN con.exist(''companyContractorId'') = 1
                                       THEN con.query(''companyContractorId'').value(''.'', ''char(36)'')
                                       ELSE NULL
                                  END,
            [key] = CASE WHEN con.exist(''key'') = 1
                           THEN con.query(''key'').value(''.'', ''varchar(100)'')
                           ELSE NULL
                      END,
            branchId = CASE WHEN con.exist(''branchId'') = 1
                           THEN con.query(''branchId'').value(''.'', ''char(36)'')
                           ELSE NULL
                      END,
            userProfileId = CASE WHEN con.exist(''userProfileId'') = 1
                                 THEN con.query(''userProfileId'').value(''.'', ''char(36)'')
                                 ELSE NULL
                            END,
            workstationId = CASE WHEN con.exist(''workstationId'') = 1
                                 THEN con.query(''workstationId'').value(''.'', ''char(36)'')
                                 ELSE NULL
                            END,
            applicationUserId = CASE WHEN con.exist(''applicationUserId'') = 1
                                     THEN con.query(''applicationUserId'').value(''.'', ''char(36)'')
                                     ELSE NULL
                                END,
            textValue = CASE WHEN con.exist(''textValue'') = 1
                             THEN con.query(''textValue'').value(''.'', ''nvarchar(1000)'')
                             ELSE NULL
                        END,
            xmlValue = CASE WHEN con.exist(''xmlValue'') = 1
                            THEN con.query(''xmlValue/*'')
                            ELSE NULL
                       END,
            version = CASE WHEN con.exist(''_version'') = 1
                           THEN con.query(''_version'').value(''.'', ''char(36)'')
                           ELSE NULL
                      END,
            modificationDate = getdate(),
            modificationUserName = NULLIF(@xmlVar.value(''(root/@applicationUserName)[1]'',''nvarchar(300)''),'''')
    FROM    @xmlVar.nodes(''/root/configuration/entry'') AS C ( con )
    WHERE   Configuration.id = con.query(''id'').value(''.'', ''char(36)'')

	SELECT @rowcount = @@ROWCOUNT

    END TRY
	BEGIN CATCH
			SELECT @errorMsg = ''Błąd wstawiania danych tabela:Configuration; error:''
				+ CAST(@@ERROR AS VARCHAR(50)) + '';Procedura:'' + ERROR_PROCEDURE() + '';Linia:'' + CAST(ERROR_LINE() as varchar(50))+ '';Opis:'' + ERROR_MESSAGE() 
            RAISERROR ( @errorMsg, 16, 1)

    END CATCH        
	IF @rowcount = 0 
		BEGIN
		-- RAISERROR ( 50011, 16, 1 ) ;
		/* 
			Aby zapobiec występowaniu przestojów w komunikacji zamieniam ten komunikat na próbę wstawienia jak się okazuje nowgo wpisu w konfiguracji.
			Może to spowodować błąd logiki systemu (jeśli ktoś celowo usunoł klucz w tym samym czasie z tego miejsca), jednak z punktu widzenia
			i tak koniecznej naprawy, lepiej jest mieć dane które może są niesłusznie niż wcale ich nie mieć i wykminiać czy słusznie 
		*/

			EXEC [configuration].[p_insertConfiguration] @xmlVar

		END
END' 
END
GO
