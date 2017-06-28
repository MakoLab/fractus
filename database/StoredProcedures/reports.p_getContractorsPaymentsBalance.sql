/*
name=[reports].[p_getContractorsPaymentsBalance]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
vdpq54ANgTyphY1/ywWXtg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getContractorsPaymentsBalance]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getContractorsPaymentsBalance]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getContractorsPaymentsBalance]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [reports].[p_getContractorsPaymentsBalance]
@xmlVar XML
AS
BEGIN
        DECLARE 
			@max INT,
            @i INT,
            @column NVARCHAR(255),
            @select NVARCHAR(max),
            @from NVARCHAR(max),
            @where NVARCHAR(max),
            @sub_where NVARCHAR(max),
            @opakowanie NVARCHAR(max),
            @dataColumn NVARCHAR(255),
            @exec NVARCHAR(max),
            @dateFrom DATETIME,
            @dateTo DATETIME,
            @filtrDat VARCHAR(200),
			@filter XML,
			@field_name NVARCHAR(255),
			@field_value NVARCHAR(MAX),
			@contractorGroups XML,
            @includeUnassignedContractors CHAR(1),
			@itemGroups XML,
            @includeUnassignedItems CHAR(1),
			@filter_count INT,
			@flag_filter NVARCHAR(max),
			@paymentMethod varchar(1000),
			@branchSymbol char(10),
			@branchId uniqueidentifier,
			@showExternalPayments varchar(50),
			@showNonLocalPayments varchar(50),
			@isHeadquarter varchar(50)

        SELECT  
                @dateFrom = NULLIF(x.query(''dateFrom'').value(''.'', ''datetime''),''''),
                @dateTo = NULLIF(x.query(''dateTo'').value(''.'', ''datetime''),''''),
				@contractorGroups = @xmlVar.query(''*/contractorGroups'').value(''.'', ''varchar(max)''),
				@filter = x.query(''filters/*'')
        FROM    @xmlVar.nodes(''/*'') a(x)


		/*Pobranie konfiguracji*/
		SELECT @showExternalPayments = textValue FROM configuration.Configuration WITH(NOLOCK) WHERE [key] like ''finance.showExternalPayments''
		SELECT @showNonLocalPayments = textValue FROM configuration.Configuration WITH(NOLOCK) WHERE [key] like ''finance.showNonLocalPayments''
		SELECT @isHeadquarter = textValue FROM configuration.Configuration WITH(NOLOCK) WHERE [key] = ''system.isHeadquarter''

		/*Jeśli nie ma konfiguracji*/
		SELECT @showExternalPayments = ISNULL(@showExternalPayments,''false''), @showNonLocalPayments = ISNULL(@showNonLocalPayments,''false''), @isHeadquarter = ISNULL(@isHeadquarter,''false'')
					

		SELECT @includeUnassignedContractors = x.value(''@includeUnassigned'', ''char(1)'')
		FROM @xmlVar.nodes(''/searchParams/contractorGroups'') AS a (x)

		SELECT @branchSymbol = symbol , @branchId = id
		FROM dictionary.Branch 
		WHERE databaseId = (
			SELECT TOP 1 CAST( textValue AS UNIQUEIDENTIFIER )
			FROM configuration.Configuration 
			WHERE [key] = ''communication.databaseId''
			)
		
		/*Wymagania w bugu 915, stą taki nietypwy wygląd kwerendy, np. filtrowana ma być tylko pierwsza wartość....*/
        SELECT  @opakowanie = ''	DECLARE @return XML '' + char(10),
                @select = ''SELECT @return = ( ''+ char(10) + 
						''		SELECT * FROM (''+ char(10) + 
						''			
									SELECT c. id , c.fullName, paj.amount balance, 
										ISNULL(rozl.amount,0) settledIncome,
										ISNULL(rozl.amount_,0) settledOutcome ,
										ISNULL(nrozl.amount,0) unsettledIncome,
										ISNULL(nrozl.amount_,0) unsettledOutcome , 
										ISNULL(nrozl.amountNT,0) dueUnsettledIncome,  
										ISNULL(nrozl.amountNT_,0) dueUnsettledOutcome,
										ISNULL(nrozl.amount_,0) - ISNULL(nrozl.amountNT,0) overdueUnsettledIncome,  
										ISNULL(nrozl.amount_,0) - ISNULL(nrozl.amountNT_,0) overdueUnsettledOutcome '',
			   @where = '''',
			   @sub_where = ''''						
		/*mechanizm filtrów, tu trzeba dopisywać kolejne filtry*/
		/*Filtry - filters*/	
		DECLARE @tmp_filters TABLE (id int identity(1,1), field nvarchar(255), [value] nvarchar(max))

		INSERT INTO @tmp_filters (field, [value] )
		SELECT  x.value(''@field'',''nvarchar(50)''),
				x.value(''.'',''nvarchar(max)'')
		FROM @filter.nodes(''column'') AS a(x)

		SELECT @filter_count = @@ROWCOUNT , @i = 1

		WHILE @i <= @filter_count
			BEGIN
				SELECT @field_name = field, @field_value = [value]
				FROM @tmp_filters WHERE id = @i

				IF @field_name IN (''isSupplier'',''isReceiver'',''isBusinessEntity'',''isBank'',''isEmployee'', ''isOwnCompany'')
					SELECT  @flag_filter = ISNULL(@flag_filter + '' OR '' , '' '') + @field_name + '' = '' +  @field_value
				ELSE
				IF @field_name = ''paymentMethodId''
						SELECT	@paymentMethod =  '' (p_.paymentMethodId IS NULL OR ( p_.paymentMethodId = '''''' + REPLACE(@field_value,'','','''''' OR  p_.paymentMethodId = '''''') + '''''' )) ''
				ELSE
				IF @field_name = ''contractorId''
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  + ''( c.id = '''''' + REPLACE(@field_value,'','','''''' ,'''''') + '''''' ) '',
								@sub_where =  ISNULL( @sub_where + '' AND '','' '' )  + ''( p_.contractorId = '''''' + REPLACE(@field_value,'','','''''' ,'''''') + '''''' ) ''
				ELSE		
				IF @field_name = ''branchId''
					BEGIN
						SELECT	@where = ISNULL( @where + '' AND '','' '' )  +  '' ( b.id IN ('''''' + REPLACE(@field_value,'','','''''','''''') + '''''') AND b.id IS NOT NULL)'',
								@sub_where = ISNULL( @sub_where + '' AND '','' '' )  +  '' ( b.id IN ('''''' + REPLACE(@field_value,'','','''''','''''') + '''''') AND b.id IS NOT NULL)''
					END
				IF @field_name = ''showExternalPayments''
					BEGIN
						SELECT	@showExternalPayments = REPLACE(REPLACE(ISNULL(@field_value,''false''),''1'',''true''),''0'',''false'')
					END
				SELECT @i = @i + 1
			END			


							 
					SELECT @from = ''	FROM contractor.Contractor c WITH(NOLOCK)
										/*rozliczone należności*/
										LEFT JOIN (		SELECT 
															(ABS(SUM(ps.amount))) amount,
															(ABS(SUM(ps_.amount))) amount_ , 
															p_.contractorId 
														FROM finance.Payment p_  WITH(NOLOCK)
															LEFT JOIN finance.PaymentSettlement  ps  WITH(NOLOCK) ON p_.id = ps.outcomePaymentId AND (p_.direction * p_.amount) < 0 
															LEFT JOIN finance.PaymentSettlement  ps_  WITH(NOLOCK) ON p_.id = ps_.incomePaymentId AND (p_.direction * p_.amount) > 0

															/*To jest fragment niebezpieczny, dodany na żądanie klineta*/
															LEFT JOIN document.commercialDocumentHeader  CD WITH(NOLOCK) ON CD.id = p_.commercialDocumentHeaderId
															LEFT JOIN document.FinancialDocumentHeader FD WITH(NOLOCK) ON FD.id = p_.financialDocumentHeaderId 
															LEFT JOIN dictionary.Branch b ON b.id = ISNULL( CD.branchId, FD.branchId ) 
														WHERE ISNULL(requireSettlement,1) <> 0
														'' + ISNULL( ISNULL(''AND  p_.date >= '''''' + CAST(@dateFrom AS VARCHAR(20)) + '''''''', '' '') + '' '' + ISNULL('' AND p_.date <= '''''' + CAST(@dateTo AS VARCHAR(20)) + '''''''', '' ''),'''') + ''
														'' + ISNULL('' AND '' + @paymentMethod,'' '') + ''
															AND (''''true'''' = '''''' + @isHeadquarter + '''''' 
																	OR ( 
																		(  
																			 ( ISNULL(CD.branchId,FD.branchId) = ''''''+CAST(@branchId AS char(36))+'''''')
																		  OR ( ''''''+@showNonLocalPayments+'''''' = ''''true'''' AND ISNULL(p_.commercialDocumentHeaderId,p_.financialDocumentHeaderId) IS NOT NULL AND ISNULL(CD.id,FD.id) IS NULL ) 
																		  OR ( ''''''+@showExternalPayments+'''''' = ''''true'''' AND ISNULL(p_.commercialDocumentHeaderId,p_.financialDocumentHeaderId) IS NULL )
																		 )
																		)
																	) 
														
														''+ @sub_where + ''
													GROUP BY p_.contractorId
													HAVING (ABS(SUM(ps.amount))) <> 0  OR (ABS(SUM(ps_.amount))) <> 0
												  )	rozl ON c.id = rozl.contractorId
										LEFT JOIN (
													SELECT * 
													FROM (	
														SELECT
															ABS(SUM(CASE WHEN ps.id IS NULL AND p_.dueDate > getdate() AND SIGN(p_.direction * p_.amount) < 0 THEN (p_.direction * p_.amount) ELSE 0 END)) amountNT ,
															ABS(SUM(CASE WHEN ps_.id IS NULL AND p_.dueDate > getdate() AND SIGN(p_.direction * p_.amount) > 0 THEN (p_.direction * p_.amount) ELSE 0 END)) amountNT_ ,
															ABS(SUM(CASE WHEN ps.id IS NULL AND SIGN(p_.direction * p_.amount) < 0 THEN (p_.direction * p_.amount) ELSE 0 END)) amount , 
															ABS(SUM(CASE WHEN ps_.id IS NULL AND SIGN(p_.direction * p_.amount) > 0 THEN (p_.direction * p_.amount) ELSE 0 END)) amount_ ,
															p_.contractorId 
														FROM finance.Payment p_  WITH(NOLOCK)
															LEFT JOIN finance.PaymentSettlement  ps  WITH(NOLOCK) ON p_.id = ps.outcomePaymentId AND (p_.direction * p_.amount) < 0
															LEFT JOIN finance.PaymentSettlement  ps_  WITH(NOLOCK) ON p_.id = ps_.outcomePaymentId AND (p_.direction * p_.amount) > 0
															
															/*To jest fragment niebezpieczny, dodany na żądanie klineta*/
															LEFT JOIN document.commercialDocumentHeader  CD WITH(NOLOCK) ON CD.id = p_.commercialDocumentHeaderId
															LEFT JOIN document.FinancialDocumentHeader FD WITH(NOLOCK) ON FD.id = p_.financialDocumentHeaderId 
															LEFT JOIN dictionary.Branch b ON b.id = ISNULL( CD.branchId, FD.branchId ) 
														WHERE 
															ps_.id IS NULL AND ps.id IS NULL 
															AND (''''true'''' = '''''' + @isHeadquarter +'''''' 
																	OR ( 
																		(  
																			 ( ISNULL(CD.branchId,FD.branchId) = ''''''+CAST(@branchId AS char(36))+'''''')
																		  OR ( ''''''+@showNonLocalPayments+'''''' = ''''true'''' AND ISNULL(p_.commercialDocumentHeaderId,p_.financialDocumentHeaderId) IS NOT NULL AND ISNULL(CD.id,FD.id) IS NULL ) 
																		  OR ( ''''''+@showExternalPayments+'''''' = ''''true'''' AND ISNULL(p_.commercialDocumentHeaderId,p_.financialDocumentHeaderId) IS NULL )
																		 )
																		)
																	) 
														
														'' + ISNULL( '' AND '' + @paymentMethod,'' '') + ''  '' +  @sub_where + '' 
														GROUP BY p_.contractorId
														) x
														
												  )	nrozl ON c.id = nrozl.contractorId
										LEFT JOIN ( SELECT SUM(p_.direction * p_.amount) amount, p_.contractorId 
													FROM finance.Payment p_
														/*To jest fragment niebezpieczny, dodany na żądanie klineta*/
														LEFT JOIN document.commercialDocumentHeader  CD WITH(NOLOCK) ON CD.id = p_.commercialDocumentHeaderId
														LEFT JOIN document.FinancialDocumentHeader FD WITH(NOLOCK) ON FD.id = p_.financialDocumentHeaderId 
														LEFT JOIN dictionary.Branch b ON b.id = ISNULL( CD.branchId, FD.branchId ) 
													WHERE 1 = 1	
														'' + ISNULL( ISNULL(''AND  p_.date >= '''''' + CAST(@dateFrom AS VARCHAR(20)) + '''''''', '' '') + '' '' + ISNULL('' AND p_.date <= '''''' + CAST(@dateTo AS VARCHAR(20)) + '''''''', '' ''),'''') + ''
														'' + ISNULL('' AND '' + @paymentMethod,'' '') +''
														
															
															AND (''''true'''' = '''''' + @isHeadquarter +'''''' 
																OR ( 
																	(  
																		 ( ISNULL(CD.branchId,FD.branchId) = ''''''+CAST(@branchId AS char(36))+'''''')
																	  OR ( ''''''+@showNonLocalPayments+'''''' = ''''true'''' AND ISNULL(p_.commercialDocumentHeaderId,p_.financialDocumentHeaderId) IS NOT NULL AND ISNULL(CD.id,FD.id) IS NULL ) 
																	  OR ( ''''''+@showExternalPayments+'''''' = ''''true'''' AND ISNULL(p_.commercialDocumentHeaderId,p_.financialDocumentHeaderId) IS NULL )
																	 )
																	)
																) 
														
														''+ @sub_where + ''

													GROUP BY p_.contractorId 
													HAVING SUM(p_.direction * p_.amount) IS NOT NULL ) paj ON c.id = paj.contractorId		   
										WHERE ISNULL(rozl.amount,0) <> 0 OR ISNULL(rozl.amount_,0) <> 0 OR ISNULL(nrozl.amount,0) <> 0 OR ISNULL(nrozl.amount_,0) <> 0	
												  ''
	/* AND REVERSE(LEFT(REVERSE(p_.documentInfo), CHARINDEX('''';'''',REVERSE(p_.documentInfo),1)-1)) <> '''''' + @branchSymbol + '''''' */					


		SELECT @where = ''''
                              
		/*Filtr dla kontrahenta*/
		IF @flag_filter IS NOT NULL
			SELECT @where = ISNULL(NULLIF(@where,'''') + '' AND '' ,'' '' ) +  ISNULL( ''( '' + @flag_filter + '' ) '', '' '' ) 

		/*Warunki dla grup kontrahentów*/
        IF NULLIF(@includeUnassignedContractors, '''') IS NOT NULL 
				IF @includeUnassignedContractors = 1
					SELECT @where = ISNULL( @where + '' AND '','' '') + '' ( c.id IS NULL OR c.id NOT IN ( SELECT contractorId FROM contractor.ContractorGroupMembership CGM WITH(NOLOCK) ) ''
				ELSE
					SELECT @where = ISNULL( @where + '' AND '','' '') + '' ( c.id IN ( SELECT c.id FROM contractor.ContractorGroupMembership CGM WITH(NOLOCK) ) ''
		

        IF NULLIF((SELECT @contractorGroups.value(''.'',''varchar(8000)'') ),'''') IS NOT NULL
                    SELECT  @where = ISNULL( @where + CASE WHEN NULLIF(@includeUnassignedContractors, '''') IS NOT NULL THEN '' OR '' ELSE '' AND '' END, '''') +
                             '' c.id IN (SELECT CGM2.contractorId FROM contractor.ContractorGroupMembership CGM2 WITH(NOLOCK) WHERE CGM2.contractorGroupId in ('''''' + REPLACE(@contractorGroups.value(''.'',''varchar(8000)'') ,'','','''''','''''') + '''''') ) '' 

		/*Uzupełnienie nawiasu po @includeUnassignedContractor*/
        IF NULLIF(@includeUnassignedContractors, '''') IS NOT NULL 
            SELECT  @where = @where + '')''

    

		SELECT @exec = @opakowanie + @select + @from + ISNULL( '' '' + @where ,'''') + '' ) line  FOR XML AUTO);
				 SELECT  @return FOR XML PATH(''''root''''),TYPE ''
--
        EXECUTE ( @exec ) 
		select  @exec 
    END
' 
END
GO
