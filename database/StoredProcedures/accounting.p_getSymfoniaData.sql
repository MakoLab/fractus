/*
name=[accounting].[p_getSymfoniaData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
UUq+q4vl/0RpbA3gTBYIkw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_getSymfoniaData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [accounting].[p_getSymfoniaData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_getSymfoniaData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [accounting].[p_getSymfoniaData]
	@xmlVar xml
AS
BEGIN
	SET NOCOUNT ON;
	



	DECLARE @line			TABLE
							( 
								id int identity(1,1),
								line varchar(MAX) 
							)
	DECLARE @list			TABLE
							(
								i int identity(1,1),
								id uniqueidentifier
							)			
	DECLARE @subList		TABLE
							(
								i int,
								IdDlaRozliczen int,
								id uniqueidentifier
							)							
	DECLARE @xmlDocType		XML
	DECLARE @dateFrom		DATETIME
	DECLARE @dateTo			DATETIME
	DECLARE @detContractor  VARCHAR(10)
	DECLARE @minContractor	VARCHAR(10)
	
	DECLARE @rule			XML
	DECLARE @fullName		VARCHAR(300)
	DECLARE @shortName		VARCHAR(40)
	DECLARE @nip			VARCHAR(40)
	DECLARE @city			VARCHAR(50)
	DECLARE @postCode		VARCHAR(30)
	DECLARE @postOffice		VARCHAR(50)
	DECLARE @address		VARCHAR(300)
	DECLARE @countryCode	VARCHAR(3)
	DECLARE @countryName	VARCHAR(50)
	DECLARE @phone			VARCHAR(100)
	DECLARE @fax			VARCHAR(100)
	DECLARE @email			VARCHAR(100)
	DECLARE @www			VARCHAR(100)
	DECLARE @code			VARCHAR(50)
	DECLARE @mappingCode	INT
	DECLARE @id				UNIQUEIDENTIFIER
	DECLARE @idS			UNIQUEIDENTIFIER
	DECLARE @version		UNIQUEIDENTIFIER
	DECLARE @noDoc			VARCHAR(100)
	DECLARE @typeDocSym		VARCHAR(10)
	DECLARE @nameDoc		VARCHAR(200)
	DECLARE @netto			NUMERIC(18,2)
	DECLARE @vat			NUMERIC(18,2)
	DECLARE @gross			NUMERIC(18,2)
	DECLARE @vatRegister	VARCHAR(100)
	DECLARE @supported		VARCHAR(100)
	DECLARE @typeDoc		VARCHAR(100)
	DECLARE @formPayment	VARCHAR(100)
	DECLARE @description	VARCHAR(200)
	DECLARE @issueDate		DATETIME
	DECLARE @eventDate		DATETIME
	DECLARE @dueDate		DATETIME
	DECLARE @rate			INT
	DECLARE @pozycja		VARCHAR(10)
	
	DECLARE @symbolFK		VARCHAR(50)
	DECLARE @creatinDate	DATETIME
	DECLARE @closureDate	DATETIME
	DECLARE @regAccounting	VARCHAR(50)
	DECLARE @initialBalance	NUMERIC(18,2)
	DECLARE @incomeAmount	NUMERIC(18,2)
	DECLARE @outcomeAmount	NUMERIC(18,2)
	
	DECLARE @i				INT
	DECLARE @k				INT
	DECLARE @j				INT
	DECLARE @n				INT
	DECLARE @rowcount		INT
	DECLARE @orderCurrent   VARCHAR(36)
	DECLARE @orderPrevious	VARCHAR(36)
	
	DECLARE @IdDlaRozliczen	INT

	
	SELECT @xmlDocType=CAST(codeSql AS XML) FROM accounting.Pattern WHERE namePattern=''DATA.ACCOUNTING''
	SET @minContractor = ''50''
	SET @detContractor = ''50''
		

	SELECT	
		@dateFrom = con.query(''dateFrom'').value(''.'',''DATETIME''),
		@dateTo = con.query(''dateTo'').value(''.'',''DATETIME'')
	FROM  @XmlVar.nodes(''root'') AS C ( con )
	

----------------------
--	SEKCJA NAGŁÓWKA --
----------------------

	INSERT INTO @line SELECT ''INFO{''
	INSERT INTO @line SELECT ''  Nazwa programu =''''Sage Symfonia Handel 2011.a'''' Symfonia Handel 2011.a''
	INSERT INTO @line SELECT ''  Wersja_programu =90''
	INSERT INTO @line SELECT ''  Wersja szablonu =3.1''
	INSERT INTO @line SELECT ''  Kontrahent{''
	INSERT INTO @line SELECT ''    id =-1199895893''
	INSERT INTO @line SELECT ''    kod =DEMO_HM''
	INSERT INTO @line SELECT ''    nazwa =Firma Demonstracyjna''
	INSERT INTO @line SELECT ''    miejscowosc =Zamość''
	INSERT INTO @line SELECT ''    ulica =Bazyliańska''
	INSERT INTO @line SELECT ''    dom =19''
	INSERT INTO @line SELECT ''    lokal =5''
	INSERT INTO @line SELECT ''    kodpocz =22-400''
	INSERT INTO @line SELECT ''    rejon =zamojskie''
	INSERT INTO @line SELECT ''    nip =000-000-00-00''
	INSERT INTO @line SELECT ''    tel1 =3321075''
	INSERT INTO @line SELECT ''    tel2 =1844748''
	INSERT INTO @line SELECT ''    fax =3321076''
	INSERT INTO @line SELECT ''    email =demo@demo.com.pl''
	INSERT INTO @line SELECT ''    www =''
	INSERT INTO @line SELECT ''  }''
	INSERT INTO @line SELECT ''}''

--------------------------
--	SEKCJA KONTRAHENTÓW --
--------------------------

	SELECT @mappingCode = ISNULL(MAX(CAST(ISNULL(externalId,''0'') AS INT)),0) FROM accounting.externalMapping WHERE objectType = 4
	IF (CAST(@mappingCode AS INT) < CAST(@minContractor AS INT))
		SET @mappingCode = @minContractor
	
	INSERT INTO @list
	SELECT DISTINCT h.contractorId FROM document.CommercialDocumentHeader h
	JOIN dictionary.DocumentType t ON h.documentTypeId = t.id
    JOIN (SELECT con.query(''localSymbol'').value(''.'',''VARCHAR(50)'') localsymbol
		  FROM  @xmlDocType.nodes(''root/entry'') AS C (con)) e ON e.localsymbol = t.symbol 
    LEFT JOIN accounting.ExternalMapping m ON m.id = h.contractorId
	WHERE (h.contractorId IS NOT NULL) AND 
		  (m.externalId IS NULL) AND
		  (h.issueDate >= @dateFrom) AND (h.issueDate <= @dateTo)
	UNION ALL
		SELECT DISTINCT h.contractorId FROM document.FinancialDocumentHeader h
		JOIN dictionary.DocumentType t ON h.documentTypeId = t.id
		JOIN (SELECT con.query(''localSymbol'').value(''.'',''VARCHAR(50)'') localsymbol
		      FROM  @xmlDocType.nodes(''root/entry'') AS C (con)) e ON e.localsymbol = t.symbol 
		LEFT JOIN accounting.ExternalMapping m ON m.id = h.contractorId
		WHERE (h.contractorId IS NOT NULL) AND 
			  (m.externalId IS NULL) AND
			  (h.issueDate >= @dateFrom) AND (h.issueDate <= @dateTo)
	
		  
	SELECT @rowcount = @@ROWCOUNT
	
	SET @i = 0
	WHILE (@i < @rowcount)
    BEGIN
		SET @i = @i + 1 
		SELECT TOP 1
			@id = c.id,
			@version = c.version,
			@fullName = c.fullName,
			@shortName = c.shortName,
			@nip = c.nip,
			@city = a.city,
			@postCode = a.postCode,
			@postOffice = a.postOffice,
			@address = a.address,
			@countryCode = co.symbol,
			@countryName = (SELECT con.value(''.'',''VARCHAR(50)'') FROM co.xmlLabels.nodes(''labels/label'') AS C (con) 
							WHERE con.value(''@lang'',''VARCHAR(2)'') = ''pl''),
			@phone = (SELECT top 1 textValue FROM contractor.contractorAttrValue v 
					  JOIN dictionary.ContractorField f ON f.id= v.contractorFieldId  
					  WHERE (v.contractorId = h.id) and (f.name=''Contact_Phone'')),
			@email = (SELECT top 1 textValue FROM contractor.contractorAttrValue v 
					  JOIN dictionary.ContractorField f ON f.id= v.contractorFieldId  
					  WHERE (v.contractorId = h.id) and (f.name=''Contact_Email'')),
			@www = (SELECT top 1 textValue FROM contractor.contractorAttrValue v 
			        JOIN dictionary.ContractorField f ON f.id= v.contractorFieldId  
			        WHERE (v.contractorId = h.id) and (f.name=''Contact_WWW'')),
			@fax = (SELECT top 1 textValue FROM contractor.contractorAttrValue v 
					JOIN dictionary.ContractorField f ON f.id= v.contractorFieldId  
					WHERE (v.contractorId = h.id) and (f.name=''Contact_Fax'')),
			@code = (SELECT top 1 textValue FROM contractor.contractorAttrValue v 
					 JOIN dictionary.ContractorField f ON f.id= v.contractorFieldId  
					 WHERE (v.contractorId = h.id) and (f.name=''Attribute_Code''))
		FROM @list h
		LEFT JOIN contractor.Contractor c ON h.id = c.id 
		LEFT JOIN contractor.ContractorAddress a ON a.ContractorId = c.id
		LEFT JOIN dictionary.Country co ON co.id = a.countryId
		WHERE h.i = @i

		SET @mappingCode = @mappingCode + 1
			
		INSERT INTO accounting.ExternalMapping
		SELECT @id, CAST(@mappingCode AS VARCHAR), 4, GETDATE(), ''SYMFONIA'', @version
			
		INSERT INTO @line SELECT ''Kontrahent{''
		INSERT INTO @line SELECT ''  id =''+CAST(@mappingCode AS VARCHAR)
		INSERT INTO @line SELECT ''  flag =0''
		INSERT INTO @line SELECT ''  subtyp =0''
		INSERT INTO @line SELECT ''  znacznik =0''
		INSERT INTO @line SELECT ''  info =N''
		INSERT INTO @line SELECT ''  osoba =''
		INSERT INTO @line SELECT ''  kod ='' + ISNULL(@shortName,'''')
		INSERT INTO @line SELECT ''  nazwa ='' + ISNULL(@fullName,'''')
		INSERT INTO @line SELECT ''  miejscowosc ='' + ISNULL(@city,'''')
		INSERT INTO @line SELECT ''  ulica ='' + ISNULL(@address,'''')
		INSERT INTO @line SELECT ''  dom =''
		INSERT INTO @line SELECT ''  lokal =''
		INSERT INTO @line SELECT ''  kodpocz ='' + ISNULL(@postCode,'''')
		INSERT INTO @line SELECT ''  rejon =''
		INSERT INTO @line SELECT ''  nip ='' + ISNULL(@nip,'''')
		INSERT INTO @line SELECT ''  statusUE =0''
		INSERT INTO @line SELECT ''  regon =''
		INSERT INTO @line SELECT ''  pesel =''
		INSERT INTO @line SELECT ''  osfiz =0''
		INSERT INTO @line SELECT ''  tel1 ='' + ISNULL(@phone,'''')
		INSERT INTO @line SELECT ''  tel2 =''
		INSERT INTO @line SELECT ''  fax ='' + ISNULL(@fax,'''')
		INSERT INTO @line SELECT ''  email ='' + ISNULL(@email,'''')
		INSERT INTO @line SELECT ''  www ='' + ISNULL(@www,'''')
		INSERT INTO @line SELECT ''  naglowek =''
		INSERT INTO @line SELECT ''  nazwisko =''
		INSERT INTO @line SELECT ''  imie =''
		INSERT INTO @line SELECT ''  bnazwa =''
		INSERT INTO @line SELECT ''  bkonto =''
		INSERT INTO @line SELECT ''  negoc =T''
		INSERT INTO @line SELECT ''  khfk =''+CAST(@mappingCode AS VARCHAR)
		INSERT INTO @line SELECT ''  zapas =''
		INSERT INTO @line SELECT ''  krajKod ='' + ISNULL(@countryCode,'''')
		INSERT INTO @line SELECT ''  krajNazwa ='' + ISNULL(@countryName,'''')
		INSERT INTO @line SELECT ''  aktywny =1''
		INSERT INTO @line SELECT ''  NazwaRodzaju =Kontrahenci ''
		INSERT INTO @line SELECT ''  NazwaKatalogu =\@Kontrahenci''
		INSERT INTO @line SELECT ''}''

	END 

------------------------------------
--	SEKCJA DOKUMNENÓW HANDLOWYCH  --
------------------------------------	
	
	INSERT INTO @list
	SELECT h.id FROM document.CommercialDocumentHeader h
	JOIN dictionary.Branch b ON b.id=h.branchId
	JOIN dictionary.DocumentType t ON h.documentTypeId = t.id
    LEFT JOIN accounting.ExternalMapping m ON m.id = h.id
    JOIN 
		(SELECT 
			con.query(''localSymbol'').value(''.'',''VARCHAR(50)'') localsymbol, 
			con.query(''branch'').value(''.'',''VARCHAR(50)'') branch
		 FROM  @xmlDocType.nodes(''root/entry'') AS C (con)) e ON e.localsymbol = t.symbol AND e.branch = b.symbol 
	WHERE (m.externalId IS NULL) AND
		  (h.issueDate >= @dateFrom) AND (h.issueDate <= @dateTo)
	ORDER BY h.issueDate
	
	SET @rowcount = @rowcount+@@ROWCOUNT
	
	WHILE (@i < @rowcount)
	BEGIN
		SET @i = @i + 1
		SELECT
			@id = l.id,
			@noDoc = (t.symbol+'' ''+h.fullNumber),
			@nameDoc = (SELECT con.value(''.'',''VARCHAR(200)'') FROM t.xmlLabels.nodes(''labels/label'') AS C (con) 
						WHERE con.value(''@lang'',''VARCHAR(2)'') = ''pl''),
			@typeDocSym = e.externalSymbol,
			@netto = h.netValue,
			@vat = h.vatValue,
			@gross = h.grossValue,
			@vatRegister = e.vatRegister,
			@supported = e.supported,
			@typeDoc = e.typeDoc,
			@issueDate = h.issueDate,
			@eventDate = h.eventDate,
			@formPayment = (SELECT TOP 1
								(SELECT con.value(''.'',''VARCHAR(200)'') FROM m.xmlLabels.nodes(''labels/label'') AS c (con)
								 WHERE con.value(''@lang'',''VARCHAR(2)'') = ''pl'')
							FROM finance.Payment p 
			                JOIN dictionary.PaymentMethod m ON m.id=p.paymentMethodId 
			                WHERE p.commercialDocumentHeaderId = h.id),
			@dueDate = (SELECT TOP 1 p.dueDate
						FROM finance.Payment p 
			            WHERE p.commercialDocumentHeaderId = h.id),			                
			@description = 	ISNULL((SELECT TOP 1 textValue from document.documentAttrValue dav 
									JOIN  dictionary.DocumentField df ON dav.documentFieldId=df.id
									WHERE df.name = ''Attribute_Remarks'' and dav.commercialDocumentHeaderId=h.id),''''),
			@rule = e.[rule],
			@pozycja = ISNULL(m.externalId,@detContractor)
		FROM @list l
		JOIN document.CommercialDocumentHeader h ON h.id = l.id
		JOIN dictionary.DocumentType t ON t.id = h.documentTypeId
		JOIN dictionary.Branch b ON b.id = h.branchId
		LEFT JOIN accounting.ExternalMapping m ON m.id = h.contractorId
		JOIN 		
			(SELECT 
				con.query(''rule'') [rule],
				con.query(''localSymbol'').value(''.'',''VARCHAR(50)'') localsymbol, 
				con.query(''externalSymbol'').value(''.'',''VARCHAR(50)'') externalSymbol,
				con.query(''branch'').value(''.'',''VARCHAR(50)'') branch,
				con.query(''vatRegister'').value(''.'',''VARCHAR(100)'') vatRegister,
				con.query(''supported'').value(''.'',''VARCHAR(100)'') [supported],
				con.query(''typeDoc'').value(''.'',''VARCHAR(100)'') typeDoc
			FROM  @xmlDocType.nodes(''root/entry'') AS C (con)) e ON e.localsymbol = t.symbol AND e.branch = b.symbol 
		WHERE l.i = @i
		
	
		INSERT INTO @line SELECT ''Dokument{''
		INSERT INTO @line SELECT ''  anulowany =0''
		INSERT INTO @line SELECT ''  rodzaj_dok =''+@typeDoc
		INSERT INTO @line SELECT ''  metoda_VAT =0''
		INSERT INTO @line SELECT ''  kod =''+@noDoc
		INSERT INTO @line SELECT ''  nazwa =''+@nameDoc
		INSERT INTO @line SELECT ''  data =''+CONVERT(char(10),@issueDate,21)
		INSERT INTO @line SELECT ''  datasp =''+CONVERT(char(10),@eventDate,21)
		INSERT INTO @line SELECT ''  datarej =''+CONVERT(char(10),@issueDate,21)
		INSERT INTO @line SELECT ''  datawp =''
		INSERT INTO @line SELECT ''  DataKor =''
		INSERT INTO @line SELECT ''  opis =''+@description
		INSERT INTO @line SELECT ''  plattermin =''+CONVERT(char(10),@dueDate,21)
		INSERT INTO @line SELECT ''  dozaplaty =''+CAST(@gross AS VARCHAR)
		INSERT INTO @line SELECT ''  wdozaplaty =''+CAST(@gross AS VARCHAR)
		INSERT INTO @line SELECT ''  walnetto =''+CAST(@netto AS VARCHAR)
		INSERT INTO @line SELECT ''  walbrutto =''+CAST(@gross AS VARCHAR)
		INSERT INTO @line SELECT ''  wartprzychod =''+CAST(@netto AS VARCHAR)
		INSERT INTO @line SELECT ''  netto =''+CAST(@netto AS VARCHAR)
		INSERT INTO @line SELECT ''  vat =''+CAST(@vat AS VARCHAR)
		INSERT INTO @line SELECT ''  kwota =''+CAST(@gross AS VARCHAR)
		INSERT INTO @line SELECT ''  nazwa_rejestru_vat =''+@vatRegister
		INSERT INTO @line SELECT ''  forma_platnosci =''+@formPayment
		INSERT INTO @line SELECT ''  symbol FK =''+@typeDocSym
		INSERT INTO @line SELECT ''  obsluguj jak =''+@supported
		INSERT INTO @line SELECT ''  NazwaKatalogu =\@Dokumenty sprzedaży''
		INSERT INTO @line SELECT ''  NazwaRodzaju =''+''Dokumenty sprzedaży''
		INSERT INTO @line SELECT ''  FK nazwa =''+@noDoc
		INSERT INTO @line SELECT ''  opis FK =''+@description
		
		SET @orderCurrent =''''
		SET @orderPrevious = ''''
		WHILE (@orderCurrent IS NOT NULL)
		BEGIN
			SET @orderCurrent = NULL
			SELECT TOP 1
				@orderCurrent = CAST(dvt.id AS VARCHAR(36)),
				@rate = vr.rate,
				@netto = dvt.netValue,
				@vat = dvt.vatValue,
				@gross = dvt.grossValue
			FROM document.CommercialDocumentVatTable dvt 
			JOIN dictionary.VatRate vr ON vr.id = dvt.vatRateId
			WHERE (dvt.commercialDocumentHeaderId = @id) AND 
				  (CAST(dvt.id AS VARCHAR(36)) > @orderPrevious)
			ORDER BY CAST(dvt.id AS VARCHAR(36))
			
			IF (@orderCurrent IS NOT NULL)
			BEGIN
				SET @orderPrevious = @orderCurrent
				INSERT INTO @line SELECT ''  Rejestr{''
				INSERT INTO @line SELECT ''    Skrot =rSPV''
				INSERT INTO @line SELECT ''    Nazwa =''+@vatRegister
				INSERT INTO @line SELECT ''    Rodzaj =1''
				INSERT INTO @line SELECT ''    ABC =1''
				INSERT INTO @line SELECT ''    metoda_VAT =0''
				INSERT INTO @line SELECT ''    datarej =''+CONVERT(char(10),@issueDate,21)
				INSERT INTO @line SELECT ''    okres =''+SUBSTRING(CONVERT(char(10),@eventDate,21),1,8)+''01''
				INSERT INTO @line SELECT ''    stawka =''+CAST(@rate AS VARCHAR)
				INSERT INTO @line SELECT ''    brutto =''+CAST(@gross AS VARCHar)
				INSERT INTO @line SELECT ''    netto =''++CAST(@netto AS VARCHar)
				INSERT INTO @line SELECT ''    vat =''+CAST(@vat AS VARCHar)
				INSERT INTO @line SELECT ''  }''				
			END
		END 
		
		INSERT INTO @line SELECT ''  Zapis{''
		INSERT INTO @line SELECT ''    strona =''+(SELECT con.query(''folio'').value(''.'',''VARCHAR(2)'') FROM @rule.nodes(''rule/decree1'') AS C(con))
		INSERT INTO @line SELECT ''    kwota =''+CASE (SELECT con.query(''amount'').value(''.'',''VARCHAR(10)'') FROM @rule.nodes(''rule/decree1'') AS C(con))
													WHEN ''gross'' THEN CAST(@gross AS VARCHAR) 
													WHEN ''net'' THEN CAST(@netto AS VARCHAR) 
													WHEN ''vat'' THEN CAST(@vat AS VARCHAR) 
													ELSE ''0'' 
											   END
		INSERT INTO @line SELECT ''    konto =''+(SELECT REPLACE(con.query(''accounting'').value(''.'',''VARCHAR(50)''),''*'',@pozycja)
												FROM @rule.nodes(''rule/decree1'') AS C(con))
		INSERT INTO @line SELECT ''    IdDlaRozliczen =1''
		INSERT INTO @line SELECT ''    opis =''+@noDoc
		INSERT INTO @line SELECT ''    NumerDok =''+@noDoc
		INSERT INTO @line SELECT ''    Pozycja =0''
		INSERT INTO @line SELECT ''    ZapisRownolegly =0''
		INSERT INTO @line SELECT ''  }''
		INSERT INTO @line SELECT ''  Zapis{''
		INSERT INTO @line SELECT ''    strona =''+(SELECT con.query(''folio'').value(''.'',''VARCHAR(2)'') FROM @rule.nodes(''rule/decree2'') AS C(con))
		INSERT INTO @line SELECT ''    kwota =''+CASE (SELECT con.query(''amount'').value(''.'',''VARCHAR(10)'') FROM @rule.nodes(''rule/decree2'') AS C(con))
													WHEN ''gross'' THEN CAST(@gross AS VARCHAR) 
													WHEN ''net'' THEN CAST(@netto AS VARCHAR) 
													WHEN ''vat'' THEN CAST(@vat AS VARCHAR) 
													ELSE ''0'' 
											   END
		INSERT INTO @line SELECT ''    konto =''+(SELECT REPLACE(con.query(''accounting'').value(''.'',''VARCHAR(50)''),''*'',@pozycja)
												FROM @rule.nodes(''rule/decree2'') AS C(con))
		INSERT INTO @line SELECT ''    IdDlaRozliczen =2''
		INSERT INTO @line SELECT ''    opis =''+@noDoc
		INSERT INTO @line SELECT ''    NumerDok =''+@noDoc
		INSERT INTO @line SELECT ''    Pozycja =0''
		INSERT INTO @line SELECT ''    ZapisRownolegly =0''
		INSERT INTO @line SELECT ''  }''
		INSERT INTO @line SELECT ''  Zapis{''
		INSERT INTO @line SELECT ''    strona =''+(SELECT con.query(''folio'').value(''.'',''VARCHAR(2)'') FROM @rule.nodes(''rule/decree3'') AS C(con))
		INSERT INTO @line SELECT ''    kwota =''+CASE (SELECT con.query(''amount'').value(''.'',''VARCHAR(10)'') FROM @rule.nodes(''rule/decree3'') AS C(con))
													WHEN ''gross'' THEN CAST(@gross AS VARCHAR) 
													WHEN ''net'' THEN CAST(@netto AS VARCHAR) 
													WHEN ''vat'' THEN CAST(@vat AS VARCHAR) 
													ELSE ''0'' 
											   END
		INSERT INTO @line SELECT ''    konto =''+(SELECT REPLACE(con.query(''accounting'').value(''.'',''VARCHAR(50)''),''*'',@pozycja)
												FROM @rule.nodes(''rule/decree3'') AS C(con))
		INSERT INTO @line SELECT ''    IdDlaRozliczen =3''
		INSERT INTO @line SELECT ''    opis =''+@noDoc
		INSERT INTO @line SELECT ''    NumerDok =''+@noDoc
		INSERT INTO @line SELECT ''    Pozycja =0''
		INSERT INTO @line SELECT ''    ZapisRownolegly =0''
		INSERT INTO @line SELECT ''  }''
		
		SET @orderCurrent =''''
		SET @orderPrevious = ''''
		WHILE (@orderCurrent IS NOT NULL)
		BEGIN
			SET @orderCurrent = NULL
			SELECT TOP 1
				@orderCurrent = CAST(s.id AS VARCHAR(36)),
				@idS = CASE WHEN (s.incomePaymentId = p.id) THEN s.outcomePaymentId ELSE s.incomePaymentId END,
				@gross = ABS(s.amount)
			FROM finance.PaymentSettlement s 
			JOIN finance.Payment p ON p.id IN (s.incomePaymentId,s.outcomePaymentId) 
			WHERE (p.commercialDocumentHeaderId = @id) AND
				  (CAST(s.id AS VARCHAR(36)) > @orderPrevious)
			ORDER BY CAST(s.id AS VARCHAR(36))
			
			IF (@orderCurrent IS NOT NULL)
			BEGIN			

				SET @orderPrevious = @orderCurrent
				INSERT INTO @line SELECT ''  Rozliczenie{''
				INSERT INTO @line SELECT ''    IdDlaRozliczen =-1''
				INSERT INTO @line SELECT ''    dSymbol =''+(SELECT
															CASE WHEN p.commercialDocumentHeaderId IS NOT NULL
															THEN
																(SELECT tc.symbol+'' ''+c.fullnumber
																 FROM document.CommercialDocumentHeader c
																 JOIN dictionary.DocumentType tc ON tc.id = c.documentTypeId
																 WHERE p.commercialDocumentHeaderId=c.id)
															ELSE
															    (SELECT tf.symbol+'' ''+f.fullnumber
																 FROM document.FinancialDocumentHeader f
																 JOIN dictionary.DocumentType tf ON tf.id = f.documentTypeId
																 WHERE p.financialDocumentHeaderId=f.id)
															END
														  FROM finance.payment p
														  WHERE (p.id = @idS))
				INSERT INTO @line SELECT ''    kwota =''+CAST(@gross AS VARCHAR)
				INSERT INTO @line SELECT ''  }''
			END
		END 
		
		IF (@orderPrevious = '''')
		BEGIN
			INSERT INTO @line SELECT ''  Transakcja{''
			INSERT INTO @line SELECT ''    IdDlaRozliczen =-1''
			INSERT INTO @line SELECT ''    termin =''+CONVERT(char(10),@dueDate,21)
			INSERT INTO @line SELECT ''  }''
		END
		
		INSERT INTO @line SELECT ''}''
		
	END
	
----------------------------------------
--	SEKCJA DOKUMNENÓW KASOWO-BANKOWYCH
----------------------------------------		

	INSERT INTO @list
	SELECT f.id FROM finance.FinancialReport f
	JOIN dictionary.FinancialRegister r ON f.financialRegisterId = r.id
    JOIN 
		(SELECT 
			con.query(''registerName'').value(''.'',''VARCHAR(50)'') registerName
		 FROM  @xmlDocType.nodes(''root/entry'') AS C (con)) e ON e.registerName = r.symbol 
	WHERE (f.creationDate >= @dateFrom) AND (f.closureDate <= @dateTo)
	ORDER BY f.creationDate
	
	SET @rowcount = @rowcount+@@ROWCOUNT
	
--
--	Raporty kasowe
--	
	
	WHILE (@i < @rowcount)
	BEGIN
		SET @i = @i + 1
		
		SELECT 
			@id = f.id,
			@noDoc = f.fullNumber,
			@symbolFK = e.symbolFK,
			@creatinDate = f.creationDate,
			@closureDate = f.closureDate,
			@regAccounting = e.registerAccounting,
			@initialBalance = f.initialBalance,
			@incomeAmount = f.incomeAmount,
			@outcomeAmount = f.outcomeAmount
		FROM @list l
		JOIN finance.FinancialReport f ON f.id= l.id
		JOIN dictionary.FinancialRegister r ON f.financialRegisterId = r.id
		JOIN 
			(SELECT 
				con.query(''registerName'').value(''.'',''VARCHAR(50)'') registerName,
				con.query(''registerAccounting'').value(''.'',''VARCHAR(50)'') registerAccounting,
				con.query(''symbolFK'').value(''.'',''VARCHAR(50)'') symbolFK
			 FROM  @xmlDocType.nodes(''root/entry'') AS C (con)) e ON e.registerName = r.symbol 
		WHERE l.i = @i
		
		INSERT INTO @line SELECT ''Dokument{''
		INSERT INTO @line SELECT ''  symbol FK =''+@symbolFK
		INSERT INTO @line SELECT ''  obsluguj jak =''
		INSERT INTO @line SELECT ''  kod =''+@noDoc
		INSERT INTO @line SELECT ''  opis FK =''+@noDoc+'' za dzień ''+CONVERT(VARCHAR(10),@creatinDate,102)
		INSERT INTO @line SELECT ''  dataWystawienia =''+CONVERT(VARCHAR(10),@creatinDate,102)
		INSERT INTO @line SELECT ''  dataSprzedazy =''+CONVERT(VARCHAR(10),@closureDate,102)
		INSERT INTO @line SELECT ''  kwota =''+''75.17''
		INSERT INTO @line SELECT ''  Sygnatura =''+''Admin''
		INSERT INTO @line SELECT ''  SaldoPRK ='' + CAST(@initialBalance AS VARCHAR)
		INSERT INTO @line SELECT ''  SaldoZRK ='' + CAST((@incomeAmount-@outcomeAmount) AS VARCHAR)
		INSERT INTO @line SELECT ''  KontoKasy ='' + @regAccounting
		INSERT INTO @line SELECT ''  FK nazwa ='' + @noDoc
		
		
		DELETE FROM @subList
		SET @k = 0
		
		SET @orderCurrent = ''''
		SET @orderPrevious = ''''
		
--
--		Dokumenty kasowe dla danego raportu
--		

		SET @n = 0
		DELETE FROM @subList
		
		WHILE (@orderCurrent IS NOT NULL)
		BEGIN
			SET @orderCurrent = NULL
			SELECT TOP 1
				@idS = p.id,
				@orderCurrent = CAST(f.id AS VARCHAR(36)),
				@noDoc = t.symbol + '' '' + f.fullnumber,
				@issueDate = f.issueDate,
				@rule = e.[rule],
				@gross = p.amount,
				@netto = 0,
				@vat = 0,
				@pozycja = ISNULL(m.externalId,@detContractor)
			FROM document.FinancialDocumentHeader f
			JOIN finance.Payment p ON p.financialDocumentHeaderId = f.id
			JOIN dictionary.DocumentType t ON f.documentTypeId = t.id
			JOIN accounting.ExternalMapping m ON m.id = f.contractorId
			JOIN (SELECT 
					con.query(''localSymbol'').value(''.'',''VARCHAR(50)'') [localsymbol],
					con.query(''rule'') [rule]
		          FROM  @xmlDocType.nodes(''root/entry'') AS C (con)) e ON e.localsymbol = t.symbol
			WHERE (f.financialReportId = @id) AND (CAST(f.id AS VARCHAR(36)) > @orderPrevious)
			ORDER BY CAST(f.id AS VARCHAR(36))
			
			IF (@orderCurrent IS NOT NULL)
			BEGIN	
				SET @orderPrevious = @orderCurrent
				SET @k = @k + 1

				INSERT INTO @line SELECT ''  Zapis{''
				INSERT INTO @line SELECT ''    strona =''+(SELECT con.query(''folio'').value(''.'',''VARCHAR(2)'') FROM @rule.nodes(''rule/decree1'') AS C(con))
				INSERT INTO @line SELECT ''    kwota =''+CASE (SELECT con.query(''amount'').value(''.'',''VARCHAR(10)'') FROM @rule.nodes(''rule/decree1'') AS C(con))
														WHEN ''gross'' THEN CAST(@gross AS VARCHAR) 
														WHEN ''net'' THEN CAST(@netto AS VARCHAR) 
														WHEN ''vat'' THEN CAST(@vat AS VARCHAR) 
														ELSE ''0'' 
											           END
				INSERT INTO @line SELECT ''    konto =''+(SELECT REPLACE(con.query(''accounting'').value(''.'',''VARCHAR(50)''),''*'',@pozycja)
												        FROM @rule.nodes(''rule/decree1'') AS C(con))
				INSERT INTO @line SELECT ''    IdDlaRozliczen ='' + CAST(@k AS VARCHAR)
				INSERT INTO @line SELECT ''    opis =''+@noDoc
				INSERT INTO @line SELECT ''    NumerDok =''+@noDoc
				INSERT INTO @line SELECT ''    Pozycja =0''
				INSERT INTO @line SELECT ''    ZapisRownolegly =0''
				INSERT INTO @line SELECT ''  }''
				
				IF EXISTS(SELECT * FROM @rule.nodes(''rule/decree1'') AS C(con) 
				          WHERE con.query(''accounting'').value(''.'',''VARCHAR(50)'') LIKE ''%*%'')
				BEGIN
					SET @n = @n + 1
					INSERT INTO @subList
					SELECT @n, @k, @idS	
				END
					
				SET @k = @k + 1
				
				INSERT INTO @line SELECT ''  Zapis{''
				INSERT INTO @line SELECT ''    strona =''+(SELECT con.query(''folio'').value(''.'',''VARCHAR(2)'') FROM @rule.nodes(''rule/decree2'') AS C(con))
				INSERT INTO @line SELECT ''    kwota =''+CASE (SELECT con.query(''amount'').value(''.'',''VARCHAR(10)'') FROM @rule.nodes(''rule/decree2'') AS C(con))
														WHEN ''gross'' THEN CAST(@gross AS VARCHAR) 
														WHEN ''net'' THEN CAST(@netto AS VARCHAR) 
														WHEN ''vat'' THEN CAST(@vat AS VARCHAR) 
														ELSE ''0'' 
											           END
				INSERT INTO @line SELECT ''    konto =''+(SELECT REPLACE(con.query(''accounting'').value(''.'',''VARCHAR(50)''),''*'',@pozycja)
												        FROM @rule.nodes(''rule/decree2'') AS C(con))
				INSERT INTO @line SELECT ''    IdDlaRozliczen ='' + CAST(@k AS VARCHAR)
				INSERT INTO @line SELECT ''    opis =''+@noDoc
				INSERT INTO @line SELECT ''    NumerDok =''+@noDoc
				INSERT INTO @line SELECT ''    Pozycja =0''
				INSERT INTO @line SELECT ''    ZapisRownolegly =0''
				INSERT INTO @line SELECT ''  }''
				
				IF EXISTS(SELECT * FROM @rule.nodes(''rule/decree2'') AS C(con) 
				          WHERE con.query(''accounting'').value(''.'',''VARCHAR(50)'') LIKE ''%*%'')
				BEGIN
					SET @n = @n + 1
					INSERT INTO @subList
					SELECT @n, @k, @idS	
				END
			END
		
		END 
		
		
		SET @k = 0
		WHILE (@k < @n)
		BEGIN
		
			SET @k = @k + 1
			SELECT @id = t.id, @IdDlaRozliczen = IdDlaRozliczen FROM @subList t WHERE t.i = @k
--
--			Rozliczenia dla platnosci @id
--		
			SET @orderCurrent = ''''
			SET @orderPrevious = ''''
		
			WHILE (@orderCurrent IS NOT NULL)
			BEGIN
				SET @orderCurrent = NULL
				SET @idS = NULL
				SELECT TOP 1
					@orderCurrent = CAST(s.id AS VARCHAR(36)),
					@gross = s.amount,
					@ids = CASE WHEN @id = s.incomePaymentId 
						   THEN  s.outcomePaymentId
						   ELSE  s.incomePaymentId
						   END
				FROM finance.PaymentSettlement s
				WHERE (CAST(s.id AS VARCHAR(36)) > @orderPrevious)AND
					  (@id IN (s.incomePaymentId,s.outcomePaymentId))
				ORDER BY CAST(s.id AS VARCHAR(36))

				
				IF (@orderCurrent IS NOT NULL)
				BEGIN
					SET @orderPrevious = @orderCurrent
					IF( @idS IS NULL )
					BEGIN
						INSERT INTO @line SELECT ''  Transakcja{''
						INSERT INTO @line SELECT ''    IdDlaRozliczen =''+CAST(@IdDlaRozliczen AS VARCHAR)
						INSERT INTO @line SELECT ''    termin =''
						INSERT INTO @line SELECT ''  }''
					END
					ELSE
					BEGIN
						SELECT 
							@noDoc = CASE WHEN p.commercialDocumentHeaderId IS NOT NULL THEN
										(SELECT t.symbol+'' ''+h.fullNumber FROM document.CommercialDocumentHeader h
										 JOIN dictionary.DocumentType t ON t.id = h.documentTypeId
										 WHERE h.id = p.commercialDocumentHeaderId)
									 WHEN p.financialDocumentHeaderId IS NOT NULL THEN
										(SELECT t.symbol+'' ''+f.fullNumber FROM document.FinancialDocumentHeader f
										 JOIN dictionary.DocumentType t ON t.id = f.documentTypeId
										 WHERE f.id = p.financialDocumentHeaderId)
									 ELSE
										p.documentInfo
									 END
						FROM finance.Payment p 
						WHERE p.id = @idS 
					
						INSERT INTO @line SELECT ''  Rozliczenie{''
						INSERT INTO @line SELECT ''    IdDlaRozliczen =''+CAST(@IdDlaRozliczen AS VARCHAR)
						INSERT INTO @line SELECT ''    dSymbol ='' + @noDoc
						INSERT INTO @line SELECT ''    kwota =''+CAST(@gross AS VARCHAR)
						INSERT INTO @line SELECT ''  }''
					END
				END
				ELSE
					IF(@orderPrevious = '''') 
					BEGIN
						INSERT INTO @line SELECT ''  Transakcja{''
						INSERT INTO @line SELECT ''    IdDlaRozliczen =''+CAST(@IdDlaRozliczen AS VARCHAR)
						INSERT INTO @line SELECT ''    termin =''
						INSERT INTO @line SELECT ''  }''
					END
				
			END
		
		END

		INSERT INTO @line SELECT ''}''
		
	END 		

	select (
		select line from @line for xml raw, type
	) for xml path(''root''), type
 
END
' 
END
GO
