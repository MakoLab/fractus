/*
name=[accounting].[p_setDocumentData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
f7yTH7oEh4A2L4USCj/2iQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_setDocumentData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [accounting].[p_setDocumentData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_setDocumentData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [accounting].[p_setDocumentData] @xmlVar XML
AS 
	/*Deklaracja zmiennych*/
    DECLARE
		@id UNIQUEIDENTIFIER, 
		@commercialDocumentId UNIQUEIDENTIFIER,
		@warehouseDocumentId UNIQUEIDENTIFIER,
		@financialDocumentId UNIQUEIDENTIFIER,
		@errorMsg VARCHAR(2000),
        @rowcount INT

    BEGIN TRAN


	SELECT @id = NULLIF(@xmlVar.query(''root/id'').value(''.'',''char(36)''), '''')

	SELECT
		@id = NULLIF(x.query(''id'').value(''.'',''char(36)''), ''''),
		@warehouseDocumentId = NULLIF(x.query(''warehouseDocumentId'').value(''.'',''char(36)''),''''),
		@commercialDocumentId = NULLIF(x.query(''commercialDocumentId'').value(''.'',''char(36)''),''''),
		@financialDocumentId = NULLIF(x.query(''financialDocumentId'').value(''.'',''char(36)''),'''')
	FROM @xmlVar.nodes(''root/documentData'') AS a(x)


	IF @id IS NULL
		BEGIN
			/*Wstawienie danych*/
			INSERT  INTO accounting.DocumentData
				   ([id]
				   ,[commercialDocumentId]
				   ,[warehouseDocumentId]
				   ,[financialDocumentId]
				   ,[vatRegisterId]
				   ,[month]
				   ,[year]
				   ,[vat7]
				   ,[vatUe]
				   ,[accountingRuleId]
				   ,[accountingJournalId]
				   ,[date]
				   ,[applicationUserId]
				   ,[transactionType]
				   ,[entriesCreated])
			SELECT  NEWID(),
					@commercialDocumentId,
					@warehouseDocumentId,
					@financialDocumentId,
					NULLIF(con.query(''vatRegisterId'').value(''.'', ''char(36)''),''''),
					NULLIF(con.query(''month'').value(''.'', ''int''),''''),
					NULLIF(con.query(''year'').value(''.'', ''int''),''''),
					NULLIF(con.query(''vat7'').value(''.'', ''int''),''''),
					NULLIF(con.query(''vatUe'').value(''.'', ''int''),''''),
					NULLIF(con.query(''accountingRuleId'').value(''.'', ''char(36)''),''''),
					NULLIF(con.query(''accountingJournalId'').value(''.'', ''char(36)''),''''),
					NULLIF(con.query(''date'').value(''.'', ''datetime''),''''),
					NULLIF(con.query(''applicationUserId'').value(''.'', ''char(36)''),''''),
					NULLIF(con.query(''transactionType'').value(''.'', ''varchar(20)''),''''),
					NULLIF(con.query(''entriesCreated'').value(''.'', ''char(1)''), '''')
			FROM    @xmlVar.nodes(''/root/documentData'') AS C ( con )
		END
	ELSE
		BEGIN 

			UPDATE accounting.DocumentData
				SET 
				   [commercialDocumentId] = @commercialDocumentId,
				   [warehouseDocumentId] = @warehouseDocumentId,
				   [financialDocumentId] = @financialDocumentId,
				   [vatRegisterId] = NULLIF(con.query(''vatRegisterId'').value(''.'', ''char(36)''),''''),
				   [month] = NULLIF(con.query(''month'').value(''.'', ''int''),''''),
				   [year] = NULLIF(con.query(''year'').value(''.'', ''int''),''''),
				   [vat7] = NULLIF(con.query(''vat7'').value(''.'', ''int''),''''),
				   [vatUe] = NULLIF(con.query(''vatUe'').value(''.'', ''int''),''''),
				   [accountingRuleId] = NULLIF(con.query(''accountingRuleId'').value(''.'', ''char(36)''),''''),
				   [accountingJournalId] = NULLIF(con.query(''accountingJournalId'').value(''.'', ''char(36)''),''''),
				   [date] = NULLIF(con.query(''date'').value(''.'', ''datetime''),''''),
				   [applicationUserId] = NULLIF(con.query(''applicationUserId'').value(''.'', ''char(36)''),''''),
				   [transactionType] = NULLIF(con.query(''transactionType'').value(''.'', ''varchar(20)''),''''),
				   [entriesCreated] = NULLIF(con.query(''entriesCreated'').value(''.'', ''char(1)''), '''')
				FROM  accounting.DocumentData d
					JOIN @xmlVar.nodes(''/root/documentData'') AS C ( con ) on d.id = con.query(''id'').value(''.'',''char(36)'')



			/*Pobranie liczby wierszy*/
			SET @rowcount = @@ROWCOUNT
		END    

    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            ROLLBACK TRAN
            SET @errorMsg = ''Błąd wstawiania danych table:DocumentData; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            COMMIT TRAN
            IF @rowcount = 0 
                BEGIN 
                    SELECT  @xmlVar
                    RAISERROR ( 50011, 16, 1 ) ;
                END
			SELECT CAST(''<root></root>'' AS XML ) returnXML
        END



/****** Object:  StoredProcedure [accounting].[p_setObjectMapping]    Script Date: 11/19/2009 11:18:12 ******/
SET ANSI_NULLS ON



set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
' 
END
GO
