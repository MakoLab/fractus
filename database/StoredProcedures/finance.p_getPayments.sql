/*
name=[finance].[p_getPayments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
xVyX2iDZizZfpd+4b8+wCw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getPayments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_getPayments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_getPayments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [finance].[p_getPayments]
@xmlVar XML
AS
BEGIN
	DECLARE
		@dateFrom datetime, @dateTo datetime,		-- data platnosci
		@dueDateFrom datetime, @dueDateTo datetime,	-- termin platnosci
		@direction int,		-- -1 dla wyplat/naleznosci, 1 dla wplat/zobowiazan
		@settled int,	-- 1 pokazuje tylko rozliczone calkowicie, 0 wyswietla nierozliczone i rozliczone niecalkowicie
		@contractorId uniqueidentifier,
		@paymentId uniqueidentifier,	-- id platnosci, ktora nie bedzie wyswietlana i brana pod uwage podczas obliczania kwoty nierozliczonej
		@fullNumber nvarchar(100) ,
		@branchSymbol varchar(10) ,
		@branchId uniqueidentifier,
		@showExternalPayments varchar(50),
		@showNonLocalPayments varchar(50),
		@isHeadquarter varchar(50),
		@documentInfo nvarchar(100),
		@paymentCurrencyId uniqueidentifier

	DECLARE
		@where nvarchar(max),
		@where2 nvarchar(max),		
		@query nvarchar(max)
		
				
	SELECT
		@dateFrom = NULLIF(x.value(''(dateFrom)[1]'',''datetime''), ''''),
		@dateTo = NULLIF(x.value(''(dateTo)[1]'',''datetime''), ''''),
		@dueDateFrom = NULLIF(x.value(''(dueDateFrom)[1]'',''datetime''), ''''),
		@dueDateTo = NULLIF(x.value(''(dueDateTo)[1]'',''datetime''), ''''),
		@direction = NULLIF(x.value(''(direction)[1]'',''varchar(5)''), ''''),
		@settled = NULLIF(x.value(''(settled)[1]'',''varchar(5)''), ''''),
		@contractorId = CAST(NULLIF(x.value(''(contractorId)[1]'',''char(36)''), '''') AS uniqueidentifier),
		@paymentId = CAST(NULLIF(x.value(''(paymentId)[1]'',''char(36)''), '''') AS uniqueidentifier),
		@fullNumber = NULLIF(x.value(''(fullNumber)[1]'',''varchar(100)''), ''''),
		@documentInfo = NULLIF(x.value(''(documentInfo)[1]'',''nvarchar(100)''), ''''),
		@paymentCurrencyId = ISNULL(CAST(NULLIF(x.value(''(documentCurrencyId)[1]'',''char(36)''), '''') AS uniqueidentifier),CAST(NULLIF(x.value(''(paymentCurrencyId)[1]'',''char(36)''), '''') AS uniqueidentifier))
	FROM
		@xmlVar.nodes(''*'') AS A(x)

		/*Pobranie konfiguracji*/
		--gdereck - wykomentowuje ze wzgledu na batcar
		--SELECT @showExternalPayments = textValue FROM configuration.Configuration WITH(NOLOCK) WHERE [key] like ''finance.showExternalPayments''
		SELECT @showNonLocalPayments = textValue FROM configuration.Configuration WITH(NOLOCK) WHERE [key] like ''finance.showNonLocalPayments''
		SELECT @isHeadquarter = textValue FROM configuration.Configuration WITH(NOLOCK) WHERE [key] = ''system.isHeadquarter''

		/*Jeśli nie ma konfiguracji*/
		SELECT @showExternalPayments = ISNULL(@showExternalPayments,''true''), @showNonLocalPayments = ISNULL(@showNonLocalPayments,''false''), @isHeadquarter = ISNULL(@isHeadquarter,''false'')

		SELECT @branchSymbol = RTRIM(symbol) , @branchId = id
		FROM dictionary.Branch 
		WHERE databaseId = (
			SELECT TOP 1 CAST( textValue AS UNIQUEIDENTIFIER )
			FROM configuration.Configuration 
			WHERE [key] = ''communication.databaseId''
			)

	SELECT
		@where =
			ISNULL('' AND P.date BETWEEN '''''' + CONVERT(varchar(30), @dateFrom, 21) + '''''' AND '''''' + CONVERT(varchar(30), @dateTo, 21) + '''''''', '''') +
			ISNULL('' AND P.dueDate BETWEEN '''''' + CONVERT(varchar(30), @dueDateFrom, 21) + '''''' AND '''''' + CONVERT(varchar(30), @dueDateTo, 21) + '''''''', '''') +
			ISNULL('' AND '' + CAST(@direction  AS varchar(2)) + '' * P.amount * P.direction > 0'', '''') +
			ISNULL('' AND P.contractorId = '''''' + CAST(@contractorId AS char(36)) + '''''''', '''') +
			ISNULL('' AND P.paymentCurrencyId = '''''' + CAST(@paymentCurrencyId AS char(36)) + '''''''', '''') +
			/*
			Nie mozna uzyc zwyklego porownania PS.incomePaymentId <> @paymentId bo jezeli incomePaymentId jest NULLem (LEFT JOIN nie znalazl wiersza),
			wynik porownania tez bedzie nieprawdziwy i nie otrzymamy zadnego wyniku. Trzebaby albo stosowac PS.incomePaymentId IS NULL OR ...,
			albo jakies porownanie z ISNULL''em. To z kolei skomplikowaloby kod bo wymagaloby cast''ow lub podania przypadkowego GUID''a do ISNULL''a.
			*/
			ISNULL
			(
				'' AND P.id <> '''''' + CAST(@paymentId AS char(36)) + '''''''' +
				'' AND NULLIF('''''' + CAST(@paymentId AS char(36)) + '''''', PS.incomePaymentId) IS NOT NULL'' +
				'' AND NULLIF('''''' + CAST(@paymentId AS char(36)) + '''''', PS.outcomePaymentId) IS NOT NULL''
			,'''') +
			ISNULL( '' AND p.documentInfo like ''''%'' + REPLACE(REPLACE(@fullNumber,'''''''',''''),''%'','''') + ''%'''''', '''')  
			+
			ISNULL( '' AND p.documentInfo like ''''%'' + REPLACE(REPLACE(@documentInfo,'''''''',''''),''%'','''') + ''%'''''', '''') 

	SELECT @where2 = CASE WHEN @settled = 1 THEN '' WHERE ( unsettledAmount = 0 OR ISNULL([requireSettlement] ,1) = 0) '' WHEN @settled = 0 THEN '' WHERE ( unsettledAmount <> 0 AND ISNULL([requireSettlement] ,1) = 1) '' ELSE '''' END

	SELECT @query =
		''SELECT (
			SELECT
				id AS ''''@id'''', date AS ''''@date'''', dueDate AS ''''@dueDate'''', contractorId AS ''''@contractorId'''', contractorName AS ''''@contractorName'''',
				paymentMethodId AS ''''@paymentMethodId'''', paymentCurrencyId AS ''''@currencyId'''',
				direction AS ''''@direction'''', ABS(amount) AS ''''@amount'''', sysAmount AS ''''@sysAmount'''', 
				REPLACE(documentInfo,
					RTRIM(documentNumber),
					RTRIM(documentNumber) + ISNULL( ''''('''' +
												(SELECT ch.fullNumber FROM document.DocumentRelation dr WITH(NOLOCK) JOIN document.CommercialDocumentHeader ch WITH(NOLOCK) ON ch.id  IN (dr.secondCommercialDocumentHeaderId) WHERE dr.relationType  = 1 AND dr.firstCommercialDocumentHeaderId = commercialDocumentId )
												 +'''')'''' , '''''''') )AS ''''@documentInfo'''',
				RTRIM(documentNumber) AS ''''@documentNumber'''', commercialDocumentId AS ''''@commercialDocumentId'''', financialDocumentId AS ''''@financialDocumentId'''',
				CASE WHEN unsettledAmount = 0 THEN 1 ELSE 0 END AS ''''@isSettled'''',
				CASE WHEN unsettledAmount <> 0 AND dueDate < getdate() THEN 1 ELSE 0 END AS ''''@isOverdue'''',
				ABS(unsettledAmount) AS ''''@unsettledAmount'''', exchangeRate AS ''''@exchangeRate'''', exchangeScale AS ''''@exchangeScale'''',
				supplierDocumentNumber as ''''@supplierDocumentNumber''''
			FROM
			(
				SELECT
					P.id, P.date, P.dueDate, P.contractorId, P.paymentMethodId, P.paymentCurrencyId, P.ordinalNumber, C.shortName as contractorName,
					ISNULL(CD.fullNumber, FD.fullNumber) AS documentNumber, FD.id AS financialDocumentId, CD.id AS commercialDocumentId,
					CAST(SIGN(P.direction * P.amount) AS int) AS direction, P.amount AS amount, P.sysAmount, P.documentInfo AS documentInfo,
					P.unsettledAmount AS unsettledAmount, P.requireSettlement, P.exchangeRate AS exchangeRate, P.exchangeScale AS exchangeScale,
					(
						SELECT textValue FROM document.DocumentAttrValue V
						JOIN dictionary.DocumentField F ON F.id = V.documentFieldId AND F.name = ''''Attribute_SupplierDocumentNumber''''
						WHERE V.commercialDocumentHeaderId = CD.id
					) AS supplierDocumentNumber
				FROM 
					finance.Payment P
					LEFT JOIN document.commercialDocumentHeader AS CD ON CD.id = P.commercialDocumentHeaderId
					LEFT JOIN document.FinancialDocumentHeader AS FD ON FD.id = P.financialDocumentHeaderId
					--LEFT JOIN finance.PaymentSettlement PS ON PS.incomePaymentId = P.id OR PS.outcomePaymentId = P.id
					LEFT JOIN contractor.Contractor C ON C.id = P.contractorId
				WHERE
					P.direction <> 0 '' + @where + '' 
					AND (''''true'''' = '''''' + @isHeadquarter +'''''' 
																OR ( 
																	(  
																		 ( ISNULL(CD.branchId,FD.branchId) = ''''''+CAST(@branchId AS char(36))+'''''')
																	  OR ( ''''''+@showNonLocalPayments+'''''' = ''''true'''' AND ISNULL(p.commercialDocumentHeaderId,p.financialDocumentHeaderId) IS NOT NULL AND ISNULL(CD.id,FD.id) IS NULL ) 
																	  OR ( ''''''+@showExternalPayments+'''''' = ''''true'''' AND ISNULL(p.commercialDocumentHeaderId,p.financialDocumentHeaderId) IS NULL )
																	 )
																	)
																)														
				GROUP BY
					P.unsettledAmount,P.id, P.date, P.dueDate, P.contractorId, P.paymentMethodId,P.requireSettlement, P.paymentCurrencyId, P.isSettled, P.amount, P.sysAmount, P.ordinalNumber, P.exchangeRate, P.exchangeScale,
					CD.fullNumber, CD.id, FD.fullNumber, FD.id, P.documentInfo, P.direction, C.shortName
			) X
			'' + @where2 + ''
			ORDER BY date, ordinalNumber, documentNumber
			FOR XML PATH(''''payment''''), TYPE
		)
		FOR XML PATH(''''payments''''), TYPE ''

	PRINT @query
	EXECUTE(@query)
	
	/*
	Procedure by gdereck - co zlego to nie Czarek ;-)
	*/
END
' 
END
GO
