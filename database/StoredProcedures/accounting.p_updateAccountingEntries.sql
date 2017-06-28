/*
name=[accounting].[p_updateAccountingEntries]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
2j4uMyAnPfjnYxThJwPYQw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_updateAccountingEntries]') AND type in (N'P', N'PC'))
DROP PROCEDURE [accounting].[p_updateAccountingEntries]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_updateAccountingEntries]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [accounting].[p_updateAccountingEntries]
	@xmlVar xml
AS
BEGIN
	

	DECLARE @cnt	int
	DECLARE @id		UNIQUEIDENTIFIER
	
	SET @id = @xmlVar.value(''(/accountingEntries/@id)[1]'', ''varchar(36)'' )

	IF (@id IS NULL)
		SELECT CAST(''<result>W XLM-u brak id dokumentu</result>'' AS XML)	
	ELSE
	BEGIN
		DELETE FROM accounting.AccountingEntries WHERE documentHeaderId = @id

		INSERT INTO [accounting].AccountingEntries
			(
				[order],
				[documentHeaderId],
				[debitAccount],
				[debitAmount],
				[creditAccount],
				[creditAmount],
				[description]
			)
		SELECT
			NULLIF(con.query(''order'').value(''.'', ''int''), ''''),
			@id,
			con.query(''debitAccount'').value(''.'', ''varchar(50)''),
			CASE WHEN ISNULL(con.query(''debitAmount'').value(''.'', ''varchar(20)''),'''') = '''' THEN 0.0 ELSE CAST(con.query(''debitAmount'').value(''.'', ''varchar(20)'') AS numeric(18,1)) END,
			con.query(''creditAccount'').value(''.'', ''varchar(50)''),
			CASE WHEN ISNULL(con.query(''creditAmount'').value(''.'', ''varchar(20)''),'''') = '''' THEN 0.0 ELSE CAST(con.query(''creditAmount'').value(''.'', ''varchar(20)'') AS numeric(18,1)) END,
			con.query(''description'').value(''.'', ''varchar(255)'')
		FROM @xmlVar.nodes(''/accountingEntries/accountingEntry'') AS C ( con )

		SELECT CAST(''<result/>'' AS XML)
	END
END' 
END
GO
