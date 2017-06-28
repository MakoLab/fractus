/*
name=[configuration].[p_insertConfiguration]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
0gOErrJSbRMX6TtpcBa6Ug==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_insertConfiguration]') AND type in (N'P', N'PC'))
DROP PROCEDURE [configuration].[p_insertConfiguration]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_insertConfiguration]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [configuration].[p_insertConfiguration]
@xmlVar XML
AS
BEGIN
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT,
		@error int 
    
  BEGIN TRY  
    /*Wstawienie wierszy*/
    INSERT  INTO [configuration].Configuration
            (
              id,
			  [key],
              companyContractorId,
              branchId,
              userProfileId,
              workstationId,
              applicationUserId,
              textValue,
              xmlValue,
              version,
              modificationDate,
              modificationUserName
            )
            SELECT  con.query(''id'').value(''.'', ''char(36)''),
					con.query(''key'').value(''.'', ''varchar(100)''),
                    NULLIF(con.query(''companyContractorId'').value(''.'', ''char(36)''),''''),
                    NULLIF(con.query(''branchId'').value(''.'', ''char(36)''), ''''),
                    NULLIF(con.query(''userProfileId'').value(''.'', ''char(36)''),''''),
                    NULLIF(con.query(''workstationId'').value(''.'', ''char(36)''),''''),
                    NULLIF(con.query(''applicationUserId'').value(''.'', ''char(36)''),''''),
                    NULLIF(con.query(''textValue'').value(''.'', ''nvarchar(1000)''),''''),
                    CASE WHEN con.exist(''xmlValue'') = 1
                         THEN con.query(''xmlValue/*'')
                         ELSE NULL
                    END,
                    ISNULL(NULLIF(con.query(''version'').value(''.'', ''char(36)''),''''),con.query(''_version'').value(''.'', ''char(36)'')),
                    GETDATE(),
                    NULLIF(@xmlVar.value(''(root/@applicationUserName)[1]'',''char(36)''),'''')
            FROM    @xmlVar.nodes(''/root/configuration/entry'') AS C ( con )
			WHERE con.query(''id'').value(''.'', ''char(36)'') NOT IN (SELECT id FROM configuration.Configuration)
		/*Pobranie liczby wierszy*/
		SELECT @rowcount = @@ROWCOUNT, @error = @@error

    END TRY
	BEGIN CATCH

		/*Obsługa błedów i wyjątków*/
		IF @error <> 0 
			BEGIN
            
				SELECT @errorMsg = ''Błąd wstawiania danych tabela:Configuration; error:''
				+ CAST(@@ERROR AS VARCHAR(50)) + '';Procedura:'' + ERROR_PROCEDURE() + '';Linia:'' + CAST(ERROR_LINE() as varchar(50))+ '';Opis:'' + ERROR_MESSAGE() 
            RAISERROR ( @errorMsg, 16, 1)
			END
	END CATCH

	IF @rowcount = 0 
		BEGIN
			-- RAISERROR ( 50011, 16, 1 ) ;
			/* 
				Aby zapobiec występowaniu przestojów w komunikacji zamieniam ten komunikat na próbę wstawienia jak się okazuje nowgo wpisu w konfiguracji.
				Może to spowodować błąd logiki systemu (jeśli ktoś celowo usunoł klucz w tym samym czasie z tego miejsca), jednak z punktu widzenia
				i tak koniecznej naprawy, lepiej jest mieć dane które może są niesłusznie niż wcale ich nie mieć i wykminiać czy słusznie 
			*/
			EXEC [configuration].[p_updateConfiguration] @xmlVar

		END
END
' 
END
GO
