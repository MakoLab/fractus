/*
name=[translation].[p_insertPaymentMethod]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
nP6rjTVHohQlgBGsGI+2lg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertPaymentMethod]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_insertPaymentMethod]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertPaymentMethod]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [translation].[p_insertPaymentMethod]
@serverName VARCHAR (50), @dbName VARCHAR (50)
AS
BEGIN
	DECLARE @nazwa VARCHAR(50), 
			@termin_platnosci NUMERIC,
			@generuj_dok_kas CHAR(1),
			@default_zaplacono CHAR(1),
			@counter NUMERIC,
			@query NVARCHAR(max),
			@newId UNIQUEIDENTIFIER,
			@id UNIQUEIDENTIFIER,
			@paymentMethodId XML
	
	SELECT @counter = 0
	SELECT @query = ''DECLARE c CURSOR FOR SELECT LTRIM(RTRIM(nazwa)) as nazwa, termin_platnosci, generuj_dok_kas, default_zaplacono FROM [''+@serverName+''].''+@dbName+''.dbo.Slow_Formy_Platnosci''
	EXEC(@query)
	OPEN c
	FETCH FROM c INTO @nazwa, @termin_platnosci, @generuj_dok_kas, @default_zaplacono
	WHILE (@@fetch_status = 0)
	BEGIN
		SELECT @counter = MAX([order]) + 1 FROM dictionary.PaymentMethod
		UPDATE dictionary.PaymentMethod
		SET xmlLabels = (SELECT
					(SELECT ''pl'' as ''@lang'', (SELECT @nazwa as label) FOR XML PATH(''label''), TYPE)
				FOR XML PATH(''labels''), TYPE)
		WHERE xmlLabels.value(''(//labels/label)[1]'', ''nvarchar(50)'') = @nazwa
		IF NOT EXISTS(SELECT * FROM dictionary.PaymentMethod WHERE xmlLabels.value(''(//labels/label)[1]'', ''nvarchar(50)'') = @nazwa)
		BEGIN 
			SELECT @newId = NEWID()
			INSERT INTO dictionary.PaymentMethod([id],[xmlLabels], [dueDays], [isGeneratingCashierDocument], [isIncrementingDueAmount], [order], [version])
			SELECT	
				@newId,
				(SELECT
					(SELECT ''pl'' as ''@lang'',(SELECT @nazwa as label) FOR XML PATH(''label''), TYPE)
				FOR XML PATH(''labels''), TYPE) as [xmlLabels],
				(SELECT @termin_platnosci) as [dueDays],
				(SELECT CASE WHEN @generuj_dok_kas = ''T'' THEN 1 ELSE 0 END) as [isGeneratingCashierDocument],
				(SELECT CASE WHEN @default_zaplacono = ''T'' THEN 1 ELSE 0 END) as [isIncrementingDueAmount],
				(SELECT @counter) as [order],
				NEWID()
		END
		FETCH FROM c INTO @nazwa, @termin_platnosci, @generuj_dok_kas, @default_zaplacono
	END
	CLOSE c
	DEALLOCATE c
	
	
	SELECT @paymentMethodId = 
				(SELECT
					(SELECT id FROM dictionary.PaymentMethod FOR XML PATH(''''), TYPE)
				FOR XML PATH(''paymentMethods''), TYPE)

	SELECT @paymentMethodId

	UPDATE dictionary.DocumentType SET xmlOptions.modify(''delete //commercialDocument[1]/paymentMethods'') 
	SELECT @query = ''UPDATE dictionary.DocumentType SET xmlOptions.modify(''''insert ''+convert(varchar(4000),@paymentMethodId)+'' as first into /root[1]/commercialDocument[1]'''') ''
	SELECT @query
	EXEC(@query)
END
' 
END
GO
