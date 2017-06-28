/*
name=[reports].[p_getContractorsPaymentStructure]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
6XUlTN7UGRiEfxGvcjpOpA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getContractorsPaymentStructure]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getContractorsPaymentStructure]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getContractorsPaymentStructure]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [reports].[p_getContractorsPaymentStructure]  
@xmlVar XML 
AS
BEGIN   


/*Tabela słów kluczowych kontrahentów*/
DECLARE @tmp TABLE (i int identity(1,1) , word nvarchar(500))
DECLARE @contractors TABLE (i int identity,id UNIQUEIDENTIFIER)
DECLARE @configuration TABLE (key_ nvarchar(500), value nvarchar(max))      

DECLARE @returnXml XML,
		@contact_Phone_field UNIQUEIDENTIFIER,     
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
		@replaceXml XML,    
		@branchId varchar(8000),
		@paymentMethod nvarchar(4000),     
		@includeUnassignedContractor bit,     
		@contractorGroups varchar(8000),     
		@groups NVARCHAR(MAX),              
		@includeUnassignedcontractors CHAR(1),              
		@contractorId CHAR(36),              
		@debt int,              
		@payment int,
		@i int ,
		@idoc int,
		@branchSymbol char(10),
		@branchId_ uniqueidentifier,
		@showExternalPayments varchar(50),
		@showNonLocalPayments varchar(50),
		@isHeadquarter varchar(50),
		@showCommercialDocumentPayment char(10),
		@factoring int,
		@applicationUsers varchar(max)
		
	DECLARE @tmpApplicationUser TABLE( id uniqueidentifier)

		
		
		
		SELECT @contact_Phone_field = id    
		FROM dictionary.ContractorField    
		WHERE name = ''Contact_Phone''     
		
		SELECT @contractor_Remark = id   
		FROM dictionary.ContractorField    
		WHERE name = ''Attribute_Annotation''      
		
		SELECT @branchSymbol = symbol , @branchId_ = id
		FROM dictionary.Branch 
		WHERE databaseId = (
			SELECT TOP 1 CAST(textValue AS UNIQUEIDENTIFIER )
			FROM configuration.Configuration 
			WHERE [key] = ''communication.databaseId''
			)
		
		/*Pobranie konfiguracji replace*/   
		SELECT  @replaceXml = xmlValue
		FROM    configuration.Configuration c  
		WHERE   c.[key] = ''Dictionary.configuration''      

		SELECT @replaceConf = @replaceXml.value(''(root/indexing/object[@name="contractor"]/replaceConfiguration)[1]'', ''varchar(8000)'')   

		/*Pobranie konfiguracji*/
		SELECT @showExternalPayments = textValue FROM configuration.Configuration WITH(NOLOCK) WHERE [key] like ''finance.showExternalPayments''
		SELECT @showNonLocalPayments = textValue FROM configuration.Configuration WITH(NOLOCK) WHERE [key] like ''finance.showNonLocalPayments''
		SELECT @isHeadquarter = textValue FROM configuration.Configuration WITH(NOLOCK) WHERE [key] = ''system.isHeadquarter''

		/*Jeśli nie ma konfiguracji*/
		/* gdereck - zmienilem wartości domyślne na true (patrz niżej) */
		SELECT @showExternalPayments = ISNULL(@showExternalPayments, ''true''), @showNonLocalPayments = ISNULL(@showNonLocalPayments, ''true''), @isHeadquarter = ISNULL(@isHeadquarter, ''false'')

		
	/*XQuery nie jest za wolne więc.... pobieram parametry wejściowe*/
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar

			SELECT
				@period1 = period1,
				@period2 = period2,
				@period3 = period3,
				@period4 = period4,
				@dateFrom = dateFrom,
				@dateTo = dateTo,
				@query = query,
				@contractorGroups = contractorGroups
			FROM OPENXML(@idoc, ''/searchParams'')
							WITH(
								period1 int ''period1'',
								period2 int ''period2'',
								period3 int ''period3'',
								period4 int ''period4'',
								dateFrom varchar(50) ''dateFrom'',
								dateTo varchar(50) ''dateTo'',
								query nvarchar(500) ''query'',
								contractorGroups nvarchar(max) ''contractorGroups''
								
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
		SELECT @contractorId  = value FROM @configuration WHERE [key_] = ''contractorId''    
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
		
		SELECT @showCommercialDocumentPayment  = REPLACE(REPLACE(NULLIF(value ,''''),''0'',''false''),''1'',''true'') FROM @configuration WHERE [key_] = ''showCommercialDocumentPayment''
		SELECT @today = ISNULL(@dateTo,CAST( CONVERT(char(10), GETDATE(),120) as datetime))
		--SELECT @dateFrom = NULL, @dateTo = NULL
            
		--select @showExternalPayments, @showNonLocalPayments
		/*Pobranie wartości z atrybutu z root*/      	
		SELECT  @includeUnassignedcontractors = @xmlVar.value(''(searchParams/contractorGroups/@includeUnassigned)[1]'', ''char(1)'')                 
	
		/*Ten fragment wyszuka kontrahentów na podstawie słów kluczowych przekazanych w query*/
		IF (NULLIF(@query,'''') IS NOT NULL)
			BEGIN
				SET @i = 0
				
				INSERT INTO @tmp (word)
				SELECT word 
				FROM xp_split(ISNULL(dbo.f_replace2(@query,@replaceConf),''''),  '' '')
				
				WHILE @@rowcount > 0
					BEGIN 
						SET @i = @i + 1
						
						INSERT INTO @contractors (id)
						SELECT DISTINCT contractorId            
						FROM contractor.v_contractorDictionary cd WITH(NOLOCK)             
							JOIN @tmp xp ON cd.field LIKE xp.word + ''%''             
						WHERE cd.field <> '' '' AND xp.i = @i
					END
					
				DELETE 
				FROM @contractors 
				WHERE  id IN (	SELECT id 
								FROM @contractors
								GROUP BY id 
								HAVING COUNT(i) < (@i-1) 
								)
			END	
				
	SELECT @applicationUsers =  NULLIF(@xmlVar.query(''/searchParams/filters/column[@field="applicationUsers"]'').value(''.'',''varchar(max)''),'''') 

	IF @applicationUsers IS NOT NULL
		BEGIN
			INSERT INTO @tmpApplicationUser
			SELECT CAST( word  as uniqueidentifier) 
			FROM dbo.xp_split(@applicationUsers,'','')
		END



 SELECT @returnXml = (
		SELECT (    
			SELECT	c.id AS ''@id'', 
					contractorName AS ''@contractorName'',  
					ABS(ISNULL((paymentLeft),0)) AS ''@paymentLeft'',    
					ABS(SUM(termN * @debt) + SUM(termP * @payment) + SUM(untermN *@debt) + SUM(untermP * @payment )) - ABS(ISNULL(paymentLeft,0))  AS ''@balance'',     
					ABS( ABS(SUM(termN * @debt)) + ABS(SUM(termP * @payment)) + ABS(SUM(untermN *@debt)) + ABS(SUM(untermP * @payment ))) AS ''@total'',
					ISNULL( NULLIF(ABS(SUM(termN * @debt) + SUM(termP * @payment)) ,0) / NULLIF(ABS( ABS(SUM(termN * @debt)) + ABS(SUM(termP * @payment)) + ABS(SUM(untermN *@debt)) + ABS(SUM(untermP * @payment ))) ,0) ,0) as ''@untermPercent'',     
					ABS(SUM(termN * @debt) + SUM(termP * @payment))  AS ''@interm'',      
					ABS(SUM(untermN *@debt) + SUM(untermP * @payment )) AS ''@unterm'',     
					ABS(SUM(( period1N *@debt) + (period1P *@payment))) AS ''@period_1'',      
					ABS(SUM(( period2N *@debt) + (period2P *@payment))) AS ''@period_2'',    
					ABS(SUM(( period3N *@debt) + (period3P *@payment))) AS ''@period_3'',     
					ABS(SUM(( period4N *@debt) + (period4P *@payment))) AS ''@period_4'',     
					ABS(SUM(( period5N *@debt) + (period5P *@payment))) AS ''@period_5'',     
					(SELECT STUFF(        
						(SELECT phone.textValue + char(10)        
						FROM  contractor.ContractorAttrValue phone WITH(NOLOCK)         
						WHERE phone.contractorFieldId = @contact_Phone_field 
							AND c.id = phone.contractorId        
						FOR XML PATH('''')) , 1, 0, '''' )       
					) AS ''@contractorPhone'',               
					(SELECT STUFF(         
						(SELECT Remark.xmlValue.value(''(note/data)[1]'',''nvarchar(4000)'')  as ''data()''        
						FROM  contractor.ContractorAttrValue Remark WITH(NOLOCK)         
						WHERE Remark.contractorFieldId = @contractor_Remark 
							AND c.id = Remark.contractorId        
						FOR XML PATH('''')),1,0,'''')       
					) AS ''@contractorRemark'', 
					ISNULL(NULLIF(RTRIM(c.code),'''') ,c.strippedNip) AS ''@contractorCode''    
					FROM (      
						SELECT                
							    SUM( ISNULL(NULLIF( SIGN(ISNULL(NULLIF(dateDif,0),-1)),1) * (ISNULL( NULLIF(  SIGN(y.direction * y.amount), 1),0) * ((y.direction * y.amount) + ISNULL(psc_amount,0))),0)) termN ,
								SUM( ISNULL(NULLIF( SIGN(ISNULL(NULLIF(dateDif,0),1)),1),0) * (ISNULL( NULLIF(  SIGN(y.direction * y.amount), -1),0) * ((y.direction * y.amount) - ISNULL(psc_amount,0))) )   termP,
								SUM( ISNULL(NULLIF( SIGN(dateDif), -1),0) * ( ISNULL( NULLIF(  SIGN(y.direction * y.amount), 1),0) * ((y.direction * y.amount) + ISNULL(psc_amount,0))) ) * -1 untermN,        
								SUM( ISNULL(NULLIF( SIGN(dateDif), -1),0) * ( ISNULL( NULLIF(  SIGN(y.direction * y.amount), -1),0) * ((y.direction * y.amount) - ISNULL(psc_amount,0))) ) untermP,        
								SUM( ISNULL( NULLIF(SIGN(dateDif - @period1 - 1)  ,1) *    NULLIF(SIGN( dateDif),-1) * ( ISNULL( NULLIF( SIGN(y.direction * y.amount), 1),0) * ((y.direction * y.amount) + ISNULL(psc_amount,0)))  ,0)) period1N,      
								SUM( ISNULL( NULLIF(SIGN(dateDif - @period1 - 1)  ,1) * NULLIF(SIGN( dateDif),-1) * ( ISNULL( NULLIF( SIGN(y.direction * y.amount),-1),0) * ((y.direction * y.amount) - ISNULL(psc_amount,0)))  ,0)) period1P,        
								SUM( ISNULL( NULLIF(SIGN(dateDif - @period1 ) , -1) * NULLIF(SIGN( dateDif - @period2 - 1),1) * ( ISNULL( NULLIF( SIGN(y.direction * y.amount), 1),0) * ((y.direction * y.amount) + ISNULL(psc_amount,0) )) ,0))  period2N,        
								SUM( ISNULL( NULLIF(SIGN(dateDif - @period1 ) , -1) * NULLIF(SIGN( dateDif - @period2 - 1),1) * ( ISNULL( NULLIF( SIGN(y.direction * y.amount), -1),0) * ((y.direction * y.amount) - ISNULL(psc_amount,0) ))  ,0)) period2P,        
								SUM( ISNULL( NULLIF(SIGN(dateDif - @period2 ) , -1) * NULLIF(SIGN( dateDif - @period3 - 1),1) * ( ISNULL( NULLIF( SIGN(y.direction * y.amount), 1),0) * ((y.direction * y.amount) + ISNULL(psc_amount,0) ))  ,0))  period3N,        
								SUM( ISNULL( NULLIF(SIGN(dateDif - @period2 ) , -1) * NULLIF(SIGN( dateDif - @period3 - 1),1) * ( ISNULL( NULLIF( SIGN(y.direction * y.amount), -1),0) * ((y.direction * y.amount) - ISNULL(psc_amount,0) )) ,0)) period3P,        
								SUM( ISNULL( NULLIF(SIGN(dateDif - @period3 ) , -1) * NULLIF(SIGN( dateDif - @period4 - 1),1) * ( ISNULL( NULLIF( SIGN(y.direction * y.amount), 1),0) * ((y.direction * y.amount) + ISNULL(psc_amount,0) ))  ,0)) period4N,        
								SUM( ISNULL( NULLIF(SIGN(dateDif - @period3 ) , -1) * NULLIF(SIGN( dateDif - @period4 - 1),1) * ( ISNULL( NULLIF( SIGN(y.direction * y.amount), -1),0) * ((y.direction * y.amount) - ISNULL(psc_amount,0) ))  ,0)) period4P,
								SUM( ISNULL( NULLIF(SIGN(dateDif - @period4 ) , -1) * ( ISNULL( NULLIF( SIGN(y.direction * y.amount), 1),0) * ((y.direction * y.amount) + ISNULL(psc_amount,0))) ,0))  * -1 period5N,        
								SUM( ISNULL( NULLIF(SIGN(dateDif - @period4 ) , -1) * ( ISNULL( NULLIF( SIGN(y.direction * y.amount), -1),0) * ((y.direction * y.amount) - ISNULL(psc_amount,0))) ,0)) period5P ,
								(paymentLeft) paymentLeft,
								dueDate,        
								y.contractorId,        
								ISNULL(cc.fullName, ''?'') contractorName--,        
								--p.id   
						
						
						FROM (	
								SELECT DATEDIFF(dd,p.dueDate, @today) dateDif ,p.dueDate, p.direction, p.sysAmount amount,p.contractorId,p.commercialDocumentHeaderId, p.financialDocumentHeaderId,  ABS(p.sysAmount) - ABS(( p.unsettledAmount * p.exchangeRate )/p.exchangeScale ) psc_amount, p.branchId
								FROM finance.payment p WITH(NOLOCK)
								WHERE p.direction <> 0 AND p.sysAmount <> 0 AND p.unsettledAmount <> 0 AND ISNULL(requireSettlement,1) <> 0
									AND ((@debt = 1 AND (p.direction * p.amount) < 0 ) OR (@payment = 1 AND (p.direction * p.amount) > 0  ))
									AND ( ( @dateFrom IS NOT NULL AND p.date >= @dateFrom) OR @dateFrom IS NULL)       
									AND ( ( @dateTo IS NOT NULL AND p.date < DATEADD(dd,1, CAST(CONVERT(char(10),@dateTo,120) as datetime)) ) OR @dateTo IS NULL) 
									AND ( (@contractorId IS NOT NULL AND p.contractorId  = @contractorId) OR  (@contractorId IS NULL))   
									AND (  p.paymentMethodId IS NULL OR ( ( @paymentMethod IS NOT NULL AND p.paymentMethodId IN (SELECT CAST( REPLACE(word,'','','''') AS uniqueidentifier) FROM xp_split(@paymentMethod,'','') WHERE word <> '' '' AND word <> ''''))  OR  @paymentMethod IS NULL  ) )    
							) y 
							LEFT JOIN contractor.Contractor cc WITH(NOLOCK) ON y.contractorId = cc.id       
							LEFT JOIN document.CommercialDocumentHeader cdh WITH(NOLOCK) ON y.commercialDocumentHeaderId = cdh.id       
							LEFT JOIN document.FinancialDocumentHeader fdh WITH(NOLOCK) ON y.financialDocumentHeaderId = fdh.id       
							LEFT JOIN dictionary.Branch b WITH(NOLOCK) ON b.id  = cdh.branchId OR b.id = fdh.branchId       
							LEFT JOIN (  SELECT SUM(ABS(px.unsettledAmount)) paymentLeft, contractorId 
										FROM finance.payment px WITH(NOLOCK)
											LEFT JOIN accounting.ExternalMapping em WITH(NOLOCK) ON px.id = em.id
										WHERE ((@debt = 1 AND (px.direction * px.amount) > 0 ) OR (@payment = 1 AND (px.direction * px.amount) < 0  ))
											AND( NULLIF(@showCommercialDocumentPayment,''false'') IS NULL OR (@showCommercialDocumentPayment = ''true'' AND px.financialDocumentHeaderId IS NOT NULL OR externalId like ''784:%''))
										GROUP BY  px.contractorId						
										) wplaty ON cc.id = wplaty.contractorId
-- gdereck - pobranie cechy faktoring
							LEFT JOIN document.DocumentAttrValue dav ON dav.commercialDocumentHeaderId = cdh.Id AND dav.documentFieldId = (SELECT id FROM dictionary.DocumentField df WHERE df.name = ''DocumentFeature_Factoring'')										
						WHERE   
							(  (@showCommercialDocumentPayment IS NULL OR @showCommercialDocumentPayment = ''false'') OR (@showCommercialDocumentPayment = ''true''  AND y.commercialDocumentHeaderId IS NOT NULL ))
			AND
			(
				/* gdereck - reorganizacja warunków */
				-- LOKALNE - zawsze pokazuj  ISNULL(ISNULL(y.branchId,cdh.branchId), fdh.branchId)
				( ISNULL(ISNULL(y.branchId,cdh.branchId), fdh.branchId) = @branchId_)
				-- NIELOKALNE - jak jesteśmy w centrali lub dozwolone jest wyswietlanie nielokalnych to pokaż
				-- (nie ma warunku na fdh.id i cdh.id bo jak jest branchId to jest i id czyli zalatwia to warunek na lokalne)
				OR ((@isHeadquarter = ''true'' OR @showNonLocalPayments = ''true'') AND ISNULL(y.commercialDocumentHeaderId, y.financialDocumentHeaderId) IS NOT NULL)
				-- OBCE - jezeli włączone jest wyświetlanie płatności obcych to pokaż
				OR (@showExternalPayments = ''true'' AND ISNULL(y.commercialDocumentHeaderId, y.financialDocumentHeaderId) IS NULL)
			)
							AND ( ( @query IS NOT NULL  AND cc.id IN (SELECT id FROM @contractors) ) OR @query IS NULL)
							AND ( NULLIF(@branchId, '''') IS NULL OR y.branchId IN (SELECT CAST(NULLIF(word, '''') AS char(36)) FROM dbo.xp_split(ISNULL(@branchId,''''), '','')))
							AND (CAST(dav.decimalValue AS int) =  @factoring OR @factoring IS NULL)--factoring  
							AND ( ISNULL(fdh.issuingPersonContractorId, cdh.issuingPersonContractorId)  IN (SELECT id FROM @tmpApplicationUser) OR @applicationUsers IS NULL)
							
						GROUP BY y.contractorId, dueDate, cc.fullName , paymentLeft     
						) py     --,p.id
					LEFT JOIN contractor.Contractor c WITH(NOLOCK) ON py.contractorId = c.id
				WHERE 
					( NULLIF(@contractorGroups,'''') is null or ((c.id IS NOT NULL 
						AND ( NULLIF(@contractorGroups,'''') IS NULL 
							OR ( c.id IN ( 	SELECT contractorId          
											FROM contractor.contractorGroupMembership  WITH( NOLOCK )         
											WHERE contractorGroupId IN (
														SELECT CAST(NULLIF(word ,'''') AS char(36)) 
														FROM dbo.xp_split(@contractorGroups, '','') )         
														)        
											) 
									)   
						)  ))
					OR  ( (@includeUnassignedcontractors = 1   and 
							(c.id IS not NULL  
							AND c.id IN (
								SELECT itm.id          
								FROM contractor.contractor itm WITH( NOLOCK )            
									LEFT JOIN contractor.contractorGroupMembership igm WITH( NOLOCK ) ON itm.id = igm.contractorId          
								WHERE igm.contractorId IS NULL 
										)
							) ) or isnull(@includeUnassignedcontractors,0) = 0
						)
				GROUP BY contractorName, c.id, c.code,c.strippedNip, paymentLeft
				HAVING ABS(SUM(ISNULL(untermN,0) *@debt) + SUM(ISNULL(untermP,0) * @payment )) <> 0 
					OR ABS(SUM(ISNULL(termN,0) * @debt) + SUM(ISNULL(termP,0) * @payment)) <> 0
					--OR ABS(ISNULL((paymentLeft),0)) <> 0
				ORDER BY ''@unterm'' DESC, ''@total'' DESC--c.code, contractorName
				FOR XML PATH(''contractor''), TYPE )    
			FOR XML PATH(''root''), TYPE     
)

	SELECT @returnXml		
END
' 
END
GO
