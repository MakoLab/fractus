/*
name=[reports].[p_getContractorsPaymentStructureDetails]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
m2k9E5+Ho3gV8fZbtsGk7w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getContractorsPaymentStructureDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getContractorsPaymentStructureDetails]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getContractorsPaymentStructureDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [reports].[p_getContractorsPaymentStructureDetails]
--DECLARE 
@xmlVar XML  
AS  
BEGIN   
--select @xmlVar = ''<searchParams type="CommercialDocument">
--  <filters>
--    <column field="payments">0</column>
--    <column field="debt">1</column>
--    <column field="showExternalPayments">0</column>
--    <column field="showCommercialDocumentPayment">1</column>
--    <column field="contractorId">73A390A9-C057-41F2-B58A-901DA4565158</column>
--  </filters>
--  <contractorId>73A390A9-C057-41F2-B58A-901DA4565158</contractorId>
--  <range>period_5</range>
--  <period1>15</period1>
--  <period2>45</period2>
--  <period3>60</period3>
--  <period4>90</period4>
--</searchParams>''

--create table params(x xml)
--insert into params(x)
--select @xmlVar 

DECLARE @contact_Phone_field UNIQUEIDENTIFIER,     
		@contractor_Remark UNIQUEIDENTIFIER,     
		@today DATETIME,     
		@period1 INT,     
		@period2 INT,     
		@period3 INT,     
		@period4 INT,     
		@dateFrom varchar(50),     
		@dateTo varchar(50),     
		@query nvarchar(500),     
		@replaceConf nvarchar(500),    
		@branchId varchar(8000),     
		@includeUnassignedContractor bit,     
		@contractorGroups varchar(8000),
		@paymentMethod nvarchar(4000),      
		@groups NVARCHAR(MAX),              
		@includeUnassignedcontractors CHAR(1), 
		@idoc int,             
		@contractorId UNIQUEIDENTIFIER,              
		@debt int,              
		@payment int,
		@range varchar(50),
		@supplierDocumentDate UNIQUEIDENTIFIER,
		@supplierDocumentNumber UNIQUEIDENTIFIER,
		@cdId char(36), 
		@fullName nvarchar(500),
		@shortName nvarchar(500), 
		@code nvarchar(500), 
		@contractorPhone nvarchar(500),  
		@contractorRemark nvarchar(4000),
		@branchId_ uniqueidentifier,
		@branchSymbol char(10),
		@showExternalPayments varchar(50),
		@showNonLocalPayments varchar(50),
		@isHeadquarter varchar(50),
		@showCommercialDocumentPayment CHAR(10),
		@contractorAddress nvarchar(1000),
		@contractorCity nvarchar(100),
		@contractorPostCode nvarchar(100),
		@contractorPostOffice nvarchar(100),
		@factoring int
		
		
		DECLARE @range_tmp TABLE (id uniqueidentifier)
		DECLARE @tmp_branch TABLE (id uniqueidentifier)
		DECLARE @mp_paymentMethods TABLE (id uniqueidentifier, label nvarchar(500))
		DECLARE @payments TABLE (id uniqueidentifier, [date] dateTime, dueDate dateTime, contractorId uniqueidentifier, contractorAddressId uniqueidentifier, paymentMethodId uniqueidentifier, commercialDocumentHeaderId uniqueidentifier, financialDocumentHeaderId uniqueidentifier, amount numeric(18,2), paymentCurrencyId uniqueidentifier, systemCurrencyId uniqueidentifier, exchangeDate dateTime, description nvarchar(500), documentInfo nvarchar(100), direction int, unsettledAmount numeric(18,2) ,exchangeScale numeric(18,0), exchangeRate numeric(18,6) ,unsettledSysAmount numeric(18,2), waluta varchar(5), branchId  uniqueidentifier )
		
		/*Tabela pomocnicza do pobrania konfiguracji*/
		DECLARE @configuration TABLE (key_ nvarchar(500), value nvarchar(max))        
		
		SELECT @contact_Phone_field = id    
		FROM dictionary.ContractorField    
		WHERE name = ''Contact_Phone''     
		
		SELECT @contractor_Remark = id   
		FROM dictionary.ContractorField    
		WHERE name = ''Attribute_Remark''    
		
		SELECT @supplierDocumentDate = id
		FROM dictionary.DocumentField
		WHERE name = ''Attribute_SupplierDocumentDate''
		
		SELECT @supplierDocumentNumber = id
		FROM dictionary.DocumentField
		WHERE name = ''Attribute_SupplierDocumentNumber''
	
		SELECT @branchSymbol = symbol , @branchId_ = id
		FROM dictionary.Branch 
		WHERE databaseId = (
			SELECT TOP 1 CAST(textValue AS UNIQUEIDENTIFIER )
			FROM configuration.Configuration 
			WHERE [key] = ''communication.databaseId''
			)	
	
		
		/*Pobranie konfiguracji*/
		SELECT @showExternalPayments = textValue FROM configuration.Configuration WITH(NOLOCK) WHERE [key] = ''finance.showExternalPayments''
		SELECT @showNonLocalPayments = textValue FROM configuration.Configuration WITH(NOLOCK) WHERE [key] = ''finance.showNonLocalPayments''
		SELECT @isHeadquarter = textValue FROM configuration.Configuration WITH(NOLOCK) WHERE [key] = ''system.isHeadquarter''

		/*Jeśli nie ma konfiguracji*/
		/* gdereck - zmienilem wartości domyślne na true (patrz niżej) */
		SELECT @showExternalPayments = ISNULL(@showExternalPayments, ''true''), @showNonLocalPayments = ISNULL(@showNonLocalPayments, ''true''), @isHeadquarter = ISNULL(@isHeadquarter, ''false'')

		/*Pobranie konfiguracji replace*/   
		--SELECT @replaceConf = xmlValue.query(''root/indexing/contractor/replaceConfiguration'').value(''.'', ''varchar(8000)'')   FROM    configuration.Configuration c  WHERE   c.[key] = ''Dictionary''      


	/*XQuery nie jest za wolne wiec.... pobieram parametry wejsciowe*/
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

			SELECT
				@period1 = period1,
				@period2 = period2,
				@period3 = period3,
				@period4 = period4,
				@dateFrom = dateFrom,
				@dateTo = dateTo,
				@query = query,
				@range = range,
				@contractorId = NULLIF(contractorId	,'''')	
			FROM OPENXML(@idoc, ''/searchParams'')
							WITH(
								period1 int ''period1'',
								period2 int ''period2'',
								period3 int ''period3'',
								period4 int ''period4'',
								dateFrom varchar(50) ''dateFrom'',
								dateTo varchar(50) ''dateTo'',
								query nvarchar(500) ''query'',
								range varchar(100) ''range'',
								contractorId char(36) ''contractorId''
						)

			INSERT INTO @configuration
			SELECT field, [column]
			FROM OPENXML(@idoc, ''/searchParams/filters/column'')
							WITH(
								field nvarchar(max) ''@field'',
								[column] nvarchar(max) ''.''
						)
		EXEC sp_xml_removedocument @idoc

		/*Pobranie reszty parametrów*/
		--SELECT @contractorId  = value FROM @configuration WHERE [key_] = ''contractorId''    
		SELECT @paymentMethod  = value FROM @configuration WHERE [key_] = ''paymentMethodId''
		SELECT @branchId  = value FROM @configuration WHERE [key_] = ''branchId''
		SELECT @payment  = value FROM @configuration WHERE [key_] = ''payments''
		SELECT @debt  = value FROM @configuration WHERE [key_] = ''debt''
		SELECT @factoring = value FROM @configuration WHERE [key_] = ''factoring''

		/*TO było wielokrotnie zmieniane zgodnie z najnowszymi odkryciami klienta*/
		/* gdereck - zmiana warunku by parametr nie był wymuszany na false jeżeli nie zdefiniowano tego w konfiguracji
			założenie jest takie, że jeżeli w konfiguracji zablokowane jest wyświetlanie płatności obcych to nie mogą się wyświetlić niezależnie od filtrów
			jednak jeżeli nie jest zablokowane w konfiguracji, to steruje tym filtr płatności obcych dostępny dla użytkownika
		*/
		IF (ISNULL(@showExternalPayments, '''') <> ''false'')
			SELECT @showExternalPayments = CASE WHEN ISNULL(value, '''') IN (''1'', ''true'') THEN ''true'' ELSE ''false'' END
			FROM @configuration WHERE [key_] = ''showExternalPayments''

		SELECT @showCommercialDocumentPayment  =  REPLACE(REPLACE(NULLIF(value ,'''') ,''0'',''false''),''1'',''true'') FROM @configuration WHERE [key_] = ''showCommercialDocumentPayment''
		--SELECT @today = CAST( CONVERT(char(10), GETDATE(),120) as datetime)
		SELECT @today = ISNULL(@dateFrom,CAST( CONVERT(char(10), GETDATE(),120) as datetime))
		SELECT @dateFrom = NULL, @dateTo = NULL
/*Pobranie danych kontrahenta*/
IF @contractorId IS NOT NULL

		SELECT TOP 1 @cdId = cd.id ,@fullName = cd.fullName , @shortName = cd.shortName , @code = cd.code,
				@contractorAddress = ca.address, @contractorPostCode = ca.postCode, @contractorPostOffice = ca.postOffice, @contractorCity = ca.city,
				@contractorPhone = (SELECT STUFF(        
						(SELECT phone.textValue + char(10)        
						FROM  contractor.ContractorAttrValue phone WITH(NOLOCK)         
						WHERE phone.contractorFieldId = @contact_Phone_field 
							AND cd.id = phone.contractorId        
						FOR XML PATH('''')) , 1, 0, '''' )       
					) ,               
				@contractorRemark = (SELECT STUFF(         
						(SELECT Remark.textValue + char(10) as ''data()''        
						FROM  contractor.ContractorAttrValue Remark WITH(NOLOCK)         
						WHERE Remark.contractorFieldId = @contractor_Remark 
							AND cd.id = Remark.contractorId        
						FOR XML PATH('''')),1,0,'''')       
					)
			FROM contractor.Contractor cd
			LEFT JOIN contractor.ContractorAddress ca ON ca.contractorId = cd.id
			LEFT JOIN dictionary.ContractorField cf ON cf.id = ca.contractorFieldId
			WHERE cd.id = @contractorId AND ca.id IS NOT NULL
			ORDER BY CASE WHEN cf.name = ''Address_Default'' THEN 1 ELSE 2 END


IF @branchId IS NOT NULL
	BEGIN
		INSERT INTO @tmp_branch(id)
		SELECT CAST( NULLIF(word ,'''') AS char(36) ) 
		FROM dbo.xp_split(@branchId, '','') 
	END

	INSERT INTO @mp_paymentMethods
	SELECT  pm.id, pm.xmlLabels.value(''(labels/label)[1]'',''varchar(50)'')
	FROM dictionary.PaymentMethod pm  WITH(NOLOCK)


/*To wywaliłem poza kwerendę gdyż silnik pomimo warunków próbował to wykonywać*/
IF @range = ''paymentLeft'' 
	BEGIN
		INSERT INTO @range_tmp(id)
        SELECT DISTINCT px.id
		FROM finance.payment px WITH(NOLOCK) 
			LEFT JOIN document.FinancialDocumentHeader hx WITH(NOLOCK) ON px.financialDocumentHeaderId = hx.id
			LEFT JOIN document.CommercialDocumentHeader cx WITH(NOLOCK) ON px.CommercialDocumentHeaderId = cx.id
			LEFT JOIN accounting.ExternalMapping em WITH(NOLOCK) ON px.id = em.id
			-- gdereck - wykomentowalem moim zdaniem niepotrzebnego joina
			-- LEFT JOIN finance.PaymentSettlement psx WITH(NOLOCK) ON px.id IN (psx.incomePaymentId, psx.outcomePaymentId )
		WHERE ((@debt = 1 AND (px.direction * px.amount) > 0) OR (@payment = 1 AND (px.direction * px.amount) < 0  ))  AND ISNULL(requireSettlement,1) <> 0
			AND( NULLIF(@showCommercialDocumentPayment,''false'') IS NULL OR (@showCommercialDocumentPayment = ''true'' AND (px.financialDocumentHeaderId IS NOT NULL OR externalId like ''784:%'')))											
			AND ISNULL(px.contractorId, cx.contractorId) = @contractorId
			AND ( @isHeadquarter = ''true'' 
				OR ( 
					(  
					   ( px.branchId = @branchId_)
					  OR ( @showNonLocalPayments = ''true'' AND ISNULL(px.commercialDocumentHeaderId,px.financialDocumentHeaderId) IS NOT NULL AND ISNULL(hx.id,cx.id) IS NULL ) 
					  OR ( @showExternalPayments = ''true'' AND ISNULL(px.commercialDocumentHeaderId,px.financialDocumentHeaderId) IS NULL )
					 )
					)
				)
			AND px.unsettledAmount <> 0
										 
	END		


	INSERT INTO @payments (id , [date] , dueDate , contractorId , contractorAddressId , paymentMethodId , commercialDocumentHeaderId , financialDocumentHeaderId , amount , paymentCurrencyId , systemCurrencyId , exchangeDate , [description] , documentInfo , direction , unsettledAmount ,exchangeRate,exchangeScale , unsettledSysAmount , waluta, branchId)
	SELECT p.id , p.[date] , p.dueDate , p.contractorId , p.contractorAddressId , p.paymentMethodId , p.commercialDocumentHeaderId , p.financialDocumentHeaderId , p.sysAmount , p.paymentCurrencyId , p.systemCurrencyId , p.exchangeDate , p.[description] , p.documentInfo , p.direction , (p.unsettledAmount * p.exchangeRate) / p.exchangeScale, p.exchangeRate,p.exchangeScale,p.unsettledAmount,c.symbol, p.branchId
	FROM finance.payment p WITH(NOLOCK)
		 LEFT JOIN dictionary.Currency c  WITH(NOLOCK) ON  p.paymentCurrencyId = c.id
	WHERE  p.direction <> 0 AND  p.unsettledAmount <> 0  AND ISNULL(requireSettlement,1) <> 0
							AND ( p.contractorId = @contractorId OR (@contractorId IS NULL AND p.contractorId IS NULL) )
							AND (  (@showCommercialDocumentPayment IS NULL OR @showCommercialDocumentPayment = ''false'') OR (@showCommercialDocumentPayment = ''true''  AND p.commercialDocumentHeaderId IS NOT NULL ))
	
SELECT 	@cdId ''@contractorId'', 
		@fullName ''@fullName'' ,
		@shortName ''@shortName'',
		@code ''@code'' , 
		@contractorPhone ''@contractorPhone'',
		@contractorRemark  ''@contractorRemark'',
		@contractorAddress ''@contractorAddress'',
		@contractorCity ''@contractorCity'',
		@contractorPostCode ''@contractorPostCode'',
		@contractorPostOffice ''@contractorPostOffice'',
						(
						SELECT  DISTINCT 
								ISNULL(ISNULL(cdh.fullNumber,fdh.fullNumber), p.documentInfo) ''@fullNumber'',            
								dt.symbol ''@documentType'',
								ABS(ISNULL(cdh.sysGrossValue ,((fdh.amount * p.exchangeRate)/  p.exchangeScale))) ''@documentValue'',
--Dodałam wartosc w walucie dokumentu (Agnieszka):
								ABS(cdh.grossValue) ''@documentAmount'',
								ABS(p.unsettledAmount) ''@unsettled'',
								p.dueDate ''@dueDate'',
								DATEDIFF(dd, p.date, p.dueDate) ''@dueDays'',
								DATEDIFF(dd, p.dueDate, GETDATE()) ''@delay'',
								ISNULL(cdh.issueDate,fdh.issueDate) ''@issueDate'',       
								ABS(paymentLeft) ''@paymentLeft'',
								pmx.label ''@paymentMethod'',
								pmx.id ''@paymentMethodId'',
								cdh.id ''@commercialDocumentHeaderId'',
								fdh.id ''@financialDocumentHeaderId'',
								p.documentInfo ''@documentInfo'' ,
								(SELECT dateValue FROM document.DocumentAttrValue  WITH(NOLOCK) WHERE documentFieldId = @supplierDocumentDate AND (commercialDocumentHeaderId = cdh.id OR financialDocumentHeaderId = fdh.id)) ''@supplierDocumentDate'',
								--dav1.dateValue ''@supplierDocumentDate'',
								--dav2.textValue ''@supplierDocumentNumber''   
								CASE WHEN CAST(dav.decimalValue AS int) = 1 THEN ''[faktoring]'' ELSE (SELECT textValue FROM document.DocumentAttrValue  WITH(NOLOCK) WHERE documentFieldId = @supplierDocumentNumber AND (commercialDocumentHeaderId = cdh.id OR financialDocumentHeaderId = fdh.id)) END ''@supplierDocumentNumber'',
								CAST(dav.decimalValue AS int) ''@factoring'',
								p.unsettledSysAmount ''@unsettledDocumentAmount'',
								p.waluta ''@currency''
						FROM @payments p
							LEFT JOIN @mp_paymentMethods pmx  ON p.paymentMethodId =  pmx.id  
							LEFT JOIN contractor.Contractor cc WITH(NOLOCK) ON p.contractorId = cc.id       
							LEFT JOIN document.CommercialDocumentHeader cdh WITH(NOLOCK) ON p.commercialDocumentHeaderId = cdh.id       
							LEFT JOIN document.FinancialDocumentHeader fdh WITH(NOLOCK) ON p.financialDocumentHeaderId = fdh.id
							LEFT JOIN dictionary.Branch b WITH(NOLOCK) ON b.id  = p.branchId 
							LEFT JOIN dictionary.DocumentType dt WITH(NOLOCK) ON dt.id = cdh.documentTypeId OR dt.id = fdh.documentTypeId        
							LEFT JOIN ( SELECT SUM(ABS(px.unsettledAmount)) paymentLeft, contractorId 
										FROM finance.payment px WITH(NOLOCK)
											LEFT JOIN accounting.ExternalMapping em WITH(NOLOCK) ON px.id = em.id
										WHERE px.contractorId = @contractorId AND ((@debt = 1 AND (px.direction * px.amount) > 0 ) OR (@payment = 1 AND (px.direction * px.amount) < 0  ))
											AND( NULLIF(@showCommercialDocumentPayment,''false'') IS NULL OR (@showCommercialDocumentPayment = ''true'' AND px.financialDocumentHeaderId IS NOT NULL OR externalId like ''784:%''))
										GROUP BY  px.contractorId						
										) wplaty ON cc.id = wplaty.contractorId
							-- gdereck - pobranie cechy faktoring
							LEFT JOIN document.DocumentAttrValue dav ON dav.commercialDocumentHeaderId = p.commercialDocumentHeaderId AND dav.documentFieldId = (SELECT id FROM dictionary.DocumentField df WHERE df.name = ''DocumentFeature_Factoring'')
						WHERE 
							
							(
								/* gdereck - reorganizacja warunków */
								-- LOKALNE - zawsze pokazuj
								--ISNULL(cdh.branchId, fdh.branchId) = @branchId_
								( p.branchId= @branchId_)
								-- NIELOKALNE - jak jesteśmy w centrali lub dozwolone jest wyswietlanie nielokalnych to pokaż
								-- (nie ma warunku na fdh.id i cdh.id bo jak jest branchId to jest i id czyli zalatwia to warunek na lokalne)
								OR ((@isHeadquarter = ''true'' OR @showNonLocalPayments = ''true'') AND ISNULL(p.commercialDocumentHeaderId, p.financialDocumentHeaderId) IS NOT NULL)
								-- OBCE - jezeli włączone jest wyświetlanie płatności obcych to pokaż
								OR (@showExternalPayments = ''true'' AND ISNULL(p.commercialDocumentHeaderId, p.financialDocumentHeaderId) IS NULL)
							) 
							AND  
							( NULLIF(@branchId, '''') IS NULL OR b.id IN (SELECT id FROM @tmp_branch))
							--AND  (p.paymentMethodId IS NULL OR   ( ( @paymentMethod IS NOT NULL AND p.paymentMethodId IN (SELECT word FROM xp_split(@paymentMethod,'','') WHERE word <> '' '' ))  OR  @paymentMethod IS NULL OR p.paymentMethodId IS NULL ) )
							AND  (( ( @dateFrom IS NOT NULL AND ISNULL(p.date,GETDATE()) >= @dateFrom) OR @dateFrom IS NULL) 
							AND ( ( @dateTo IS NOT NULL AND p.date < DATEADD(dd,1, CAST(CONVERT(char(10),@dateTo,120) as datetime)) ) OR @dateTo IS NULL)              
								AND  ( 
										(@range = ''total''  )
										OR (@range = ''period_1'' AND (  DATEDIFF(dd,dueDate, @today) <= @period1 AND DATEDIFF(dd,dueDate, @today) > 0  ) )
										OR (@range = ''period_2'' AND (  DATEDIFF(dd,dueDate, @today) > @period1 AND DATEDIFF(dd,dueDate, @today) <= @period2 ) )
										OR (@range = ''period_3'' AND (  DATEDIFF(dd,dueDate, @today) > @period2 AND DATEDIFF(dd,dueDate, @today) <= @period3 ) )
										OR (@range = ''period_4'' AND (  DATEDIFF(dd,dueDate, @today) > @period3 AND DATEDIFF(dd,dueDate, @today) <= @period4 ) )
										OR (@range = ''period_5'' AND (  DATEDIFF(dd,dueDate, @today) > @period4 ) )
										OR (@range = ''unterm'' AND (    DATEDIFF(dd,dueDate, @today) > 0) )
										OR (@range = ''interm'' AND (   DATEDIFF(dd,dueDate, @today) <= 0) ) 
									) 
								AND ( (@debt = 1 AND (p.amount * p.direction) < 0) OR (@payment = 1 AND (p.amount * p.direction) > 0) )
							 ) 
							AND (CAST(dav.decimalValue AS int) =  @factoring OR @factoring IS NULL)--factoring
						/*Wyświetlenie kolumny paymentLeft powoduje zmianę w filtrach, gdyż kwota dotyczy całości nierozliczonych należności/zobowiązania */							
						OR ( @range = ''paymentLeft'' 
							AND  p.id IN ( SELECT id FROM @range_tmp ) 
							)
							
					ORDER BY p.dueDate		
				FOR XML PATH(''documents''), TYPE )  
			FOR XML PATH(''root''), TYPE   
			    
		END
' 
END
GO
