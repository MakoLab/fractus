/*
name=[tools].[p_createBranchConf]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
TPQd8iw1lIfnwPja4UneEg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_createBranchConf]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_createBranchConf]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_createBranchConf]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [tools].[p_createBranchConf]
	@issuePlace_name nvarchar(100),
	@branch_Label nvarchar(500),
	@branch_Symbol nvarchar(50),
	@warehouse_Label nvarchar(500),
	@warehouse_Symbol nvarchar(50),
	@warehouse_Label_2 nvarchar(500),
	@warehouse_Symbol_2 nvarchar(50),
	@warehouse_Label_3 nvarchar(500),
	@warehouse_Symbol_3 nvarchar(50),
	@warehouse_Label_4 nvarchar(500),
	@warehouse_Symbol_4 nvarchar(50),
	@financialRegister_LabelPL_Kasa nvarchar(500),
	@financialRegister_LabelEN_Kasa nvarchar(500),
	@financialRegister_Symbol_Kasa nvarchar(50),
	@financialRegister_LabelPL_BANK nvarchar(500),
	@financialRegister_LabelEN_BANK nvarchar(500),
	@financialRegister_Symbol_Bank nvarchar(50),
	@financialRegister_LabelPL_Karta nvarchar(500),
	@financialRegister_LabelEN_Karta nvarchar(500),
	@financialRegister_Symbol_Karta nvarchar(50)
AS
BEGIN

	DECLARE @databaseIdO1 uniqueidentifier,
			@branchIdO1 uniqueidentifier,
			@warehouseId uniqueidentifier,
			@companyId uniqueidentifier,
			@financialRegisterId uniqueidentifier,
			@valuationMethod int,
			@issuePlace uniqueidentifier,
			@sql nvarchar(500),
			@tmpXml XML,
			@version uniqueidentifier,
			@skrypt nvarchar(max),
			@skryptOddzialowy nvarchar(max)

	SET NOCOUNT ON
	
	SELECT @valuationMethod = 0, @skrypt = '''', @skryptOddzialowy = ''''

	SELECT @companyId = contractorId FROM dictionary.Company

/*Dość niebezpieczne*/
SELECT @skryptOddzialowy = ''
	EXEC tools.p_czyscBazeDlaTestow '' + char(10)

SELECT @issuePlace = id FROM dictionary.IssuePlace WHERE name = @issuePlace_name
/*IssuePlace*/
IF @issuePlace IS NULL
	BEGIN
	SELECT @issuePlace = newid(), @version = newid()
	SELECT @tmpXml = 
		(SELECT (
			SELECT (
				SELECT  @issuePlace as id,
						@issuePlace_name name,   
						@version [version], 
						(select ISNULL(count(id),0) + 1 from dictionary.IssuePlace ) [order]
				FOR XML PATH(''entry''), TYPE )
			FOR XML PATH(''issuePlace''), TYPE )
		FOR XML PATH(''root''), TYPE )
	SELECT @skrypt = @skrypt + ''	EXEC dictionary.p_insertIssuePlace '''''' + CAST(@tmpXml AS varchar(max)) +'''''' '' + char(10)
	END


/*Branch*/
	SELECT @branchIdO1 = newid(), @databaseIdO1 = newid(), @version = newid()
	SELECT @tmpXml = 
		(SELECT (
			SELECT (
				SELECT  @branchIdO1 as id,
						@companyId AS companyId,
						@databaseIdO1 AS databaseId, 
						@branch_Symbol AS symbol, 
						CAST(''<xmlLabels><labels><label lang="pl">''+@branch_Label+''</label></labels></xmlLabels>'' AS XML) xmlLabels,   
						@version [version], 
						(select ISNULL(count(id),0) + 1 from dictionary.Branch ) [order]
				FOR XML PATH(''entry''), TYPE )
			FOR XML PATH(''branch''), TYPE )
		FOR XML PATH(''root''), TYPE)

	SELECT @skrypt = @skrypt + ''	EXEC  dictionary.p_insertBranch  '''''' + CAST(@tmpXml AS varchar(max)) + '''''' '' + char(10)
	--EXEC  Fractus2_oddzial1.dictionary.p_insertBranch @tmpXml


/*Warehouse*/
	SELECT @warehouseId = newid(), @version = newid()
	SELECT @tmpXml = 
		(SELECT (
			SELECT (
				SELECT  @warehouseId as id, 
						@branchIdO1 AS branchId,
						@warehouse_Symbol AS symbol, 
						1 as isActive,
						CAST(''<xmlLabels><labels><label lang="pl">''+@warehouse_Label+''</label></labels></xmlLabels>'' AS XML) xmlLabels,   
						@version [version], 
						(select ISNULL(count(id),0) + 1 from dictionary.Warehouse ) [order],
						@valuationMethod AS valuationMethod,
						@issuePlace AS issuePlaceId /*Miejsce gdzie jest magazyn, był może ktoż będzie chciał inaczej*/
				FOR XML PATH(''entry''), TYPE )
			FOR XML PATH(''warehouse''), TYPE )
		FOR XML PATH(''root''), TYPE)

SELECT @skrypt = @skrypt + ''	EXEC  dictionary.p_insertWarehouse   '''''' + CAST(@tmpXml AS varchar(max)) + '''''' '' + char(10)
--	EXEC  Fractus2_oddzial1.dictionary.p_insertWarehouse @tmpXml

/*Warehouse 2*/
IF @warehouse_Symbol_2 IS NOT NULL
	BEGIN
	SELECT @warehouseId = newid(), @version = newid()
	SELECT @tmpXml = 
		(SELECT (
			SELECT (
				SELECT  @warehouseId as id, 
						@branchIdO1 AS branchId,
						@warehouse_Symbol_2 AS symbol, 
						1 as isActive,
						CAST(''<xmlLabels><labels><label lang="pl">''+@warehouse_Label_2+''</label></labels></xmlLabels>'' AS XML) xmlLabels,   
						@version [version], 
						(select ISNULL(count(id),0) + 1 from dictionary.Warehouse ) [order],
						@valuationMethod AS valuationMethod,
						@issuePlace AS issuePlaceId /*Miejsce gdzie jest magazyn, był może ktoż będzie chciał inaczej*/
				FOR XML PATH(''entry''), TYPE )
			FOR XML PATH(''warehouse''), TYPE )
		FOR XML PATH(''root''), TYPE)

	SELECT @skrypt = @skrypt + ''	EXEC  dictionary.p_insertWarehouse   '''''' + CAST(@tmpXml AS varchar(max)) + '''''' '' + char(10)
	END	
/*Warehouse 3*/
IF @warehouse_Symbol_3 IS NOT NULL
	BEGIN
	SELECT @warehouseId = newid(), @version = newid()
	SELECT @tmpXml = 
		(SELECT (
			SELECT (
				SELECT  @warehouseId as id, 
						@branchIdO1 AS branchId,
						@warehouse_Symbol_3 AS symbol, 
						1 as isActive,
						CAST(''<xmlLabels><labels><label lang="pl">''+@warehouse_Label_3+''</label></labels></xmlLabels>'' AS XML) xmlLabels,   
						@version [version], 
						(select ISNULL(count(id),0) + 1 from dictionary.Warehouse ) [order],
						@valuationMethod AS valuationMethod,
						@issuePlace AS issuePlaceId /*Miejsce gdzie jest magazyn, był może ktoż będzie chciał inaczej*/
				FOR XML PATH(''entry''), TYPE )
			FOR XML PATH(''warehouse''), TYPE )
		FOR XML PATH(''root''), TYPE)

	SELECT @skrypt = @skrypt + ''	EXEC  dictionary.p_insertWarehouse   '''''' + CAST(@tmpXml AS varchar(max)) + '''''' '' + char(10)
	END		
	
/*Warehouse 4*/
IF @warehouse_Symbol_4 IS NOT NULL
	BEGIN
	SELECT @warehouseId = newid(), @version = newid()
	SELECT @tmpXml = 
		(SELECT (
			SELECT (
				SELECT  @warehouseId as id, 
						@branchIdO1 AS branchId,
						@warehouse_Symbol_4 AS symbol, 
						1 as isActive,
						CAST(''<xmlLabels><labels><label lang="pl">''+@warehouse_Label_4+''</label></labels><xmlLabels>'' AS XML) xmlLabels,   
						@version [version], 
						(select ISNULL(count(id),0) + 1 from dictionary.Warehouse ) [order],
						@valuationMethod AS valuationMethod,
						@issuePlace AS issuePlaceId /*Miejsce gdzie jest magazyn, był może ktoż będzie chciał inaczej*/
				FOR XML PATH(''entry''), TYPE )
			FOR XML PATH(''warehouse''), TYPE )
		FOR XML PATH(''root''), TYPE)

	SELECT @skrypt = @skrypt + ''	EXEC  dictionary.p_insertWarehouse   '''''' + CAST(@tmpXml AS varchar(max)) + '''''' '' + char(10)
	END		
	
	
	
	
/*FinancialRegister - bankowy*/
	SELECT @financialRegisterId = newid(), @version = newid()
	SELECT @tmpXml = 
		(
			SELECT (
				SELECT (
					SELECT  @financialRegisterId as id,
							@version [version],
							@financialRegister_Symbol_Bank AS symbol, 
							CAST(''<xmlLabels><labels><label lang="pl">''+@financialRegister_LabelPL_BANK+''</label><label lang="en">''+@financialRegister_LabelEN_BANK+''</label></labels></xmlLabels>'' AS XML) xmlLabels,
							(SELECT id FROM dictionary.Currency WHERE symbol = ''PLN'')  as currencyId,
							110 accountingAccount,  -- pojęcia nie mam
							1 AS registerCategory, -- 1 - bankowy; 0 - kasowy
							''<xmlOptions><root>
							   <register defaultPrintProfile="defaultBankReportPdf">
								<incomeDocument>
								  <documentTypeId>6BC5A3E8-3EF4-451A-B5C3-2B281F15F624</documentTypeId>
								  <numberSettingId>126D9893-EE7C-4FCD-ABEB-A8FDE07E8888</numberSettingId>
								</incomeDocument>
								<outcomeDocument>
								  <documentTypeId>7FD9DB2D-D1D0-4C46-A310-FEEE17CF1CF5</documentTypeId>
								  <numberSettingId>126D9893-EE7C-4FCD-ABEB-A8FDE07E8888</numberSettingId>
								</outcomeDocument>
								<financialReport>
								  <numberSettingId>126D9893-EE7C-4FCD-ABEB-A8FDE07E8888</numberSettingId>
								</financialReport>
								<paymentMethods />
							  </register>
							</root></xmlOptions>'' xmlOptions,
							(select ISNULL(count(id),0) + 1 from dictionary.Branch ) [order],
							 @branchIdO1 AS branchId
					FOR XML PATH(''entry''), TYPE )
				FOR XML PATH(''financialRegister''), TYPE )
			FOR XML PATH(''root''), TYPE )

SELECT @skrypt = @skrypt + ''	EXEC  dictionary.p_insertFinancialRegister   '''''' + CAST(@tmpXml AS varchar(max)) + '''''' '' + char(10)
	--EXEC  Fractus2_oddzial1.dictionary.p_insertFinancialRegister @tmpXml
--select  ''	EXEC  dictionary.p_insertFinancialRegister   '''''' + CAST(@tmpXml AS varchar(max)) + '''''' '' + char(10)

/*FinancialRegister - kasowy*/
	SELECT @financialRegisterId = newid(), @version = newid()
	SELECT @tmpXml = 
		(
			SELECT (
				SELECT (
					SELECT  @financialRegisterId as id,
							@version [version],
							@financialRegister_Symbol_Kasa AS symbol, 
							CAST(''<xmlLabels><labels><label lang="pl">''+@financialRegister_LabelPL_Kasa+''</label><label lang="en">''+@financialRegister_LabelEN_Kasa+''</label></labels></xmlLabels>'' AS XML) xmlLabels,
							(SELECT id FROM dictionary.Currency WHERE symbol = ''PLN'')  as currencyId,
							110 accountingAccount, -- pojęcia nie mam
							0 AS registerCategory, -- 1 - bankowy; 0 - kasowy, 2 - kartowy
							''<xmlOptions><root>
							   <register defaultPrintProfile="defaultBankReportPdf">
								<incomeDocument>
								  <documentTypeId>6BC5A3E8-3EF4-451A-B5C3-2B281F15F624</documentTypeId>
								  <numberSettingId>126D9893-EE7C-4FCD-ABEB-A8FDE07E8888</numberSettingId>
								</incomeDocument>
								<outcomeDocument>
								  <documentTypeId>7FD9DB2D-D1D0-4C46-A310-FEEE17CF1CF5</documentTypeId>
								  <numberSettingId>126D9893-EE7C-4FCD-ABEB-A8FDE07E8888</numberSettingId>
								</outcomeDocument>
								<financialReport>
								  <numberSettingId>126D9893-EE7C-4FCD-ABEB-A8FDE07E8888</numberSettingId>
								</financialReport>
								<paymentMethods />
							  </register>
							</root></xmlOptions>'' xmlOptions,
							(select ISNULL(count(id),0) + 1 from dictionary.Branch ) [order],
							 @branchIdO1 AS branchId
					FOR XML PATH(''entry''), TYPE )
				FOR XML PATH(''financialRegister''), TYPE )
			FOR XML PATH(''root''), TYPE )

SELECT @skrypt = @skrypt + ''	EXEC  dictionary.p_insertFinancialRegister   '''''' + CAST(@tmpXml AS varchar(max)) + '''''' '' + char(10)
	--EXEC  Fractus2_oddzial1.dictionary.p_insertFinancialRegister @tmpXml
		
		
/*FinancialRegister - kartowy*/
IF @financialRegister_Symbol_Karta IS NOT NULL
	BEGIN
	SELECT @financialRegisterId = newid(), @version = newid()
	SELECT @tmpXml = 
		(
			SELECT (
				SELECT (
					SELECT  @financialRegisterId as id,
							@version [version],
							@financialRegister_Symbol_Karta AS symbol, 
							CAST(''<xmlLabels><labels><label lang="pl">''+@financialRegister_LabelPL_Karta+''</label><label lang="en">''+@financialRegister_LabelEN_Karta+''</label></labels></xmlLabels>'' AS XML) xmlLabels,
							(SELECT id FROM dictionary.Currency WHERE symbol = ''PLN'')  as currencyId,
							0 accountingAccount, -- pojęcia nie mam
							2 AS registerCategory, -- 1 - bankowy; 0 - kasowy, 2 - kartowy
							CAST(''<xmlOptions><root>
							   <register defaultPrintProfile="defaultBankReportPdf">
								<incomeDocument>
								  <documentTypeId>6BC5A3E8-3EF4-451A-B5C3-2B281F15F624</documentTypeId>
								  <numberSettingId>126D9893-EE7C-4FCD-ABEB-A8FDE07E8888</numberSettingId>
								</incomeDocument>
								<outcomeDocument>
								  <documentTypeId>7FD9DB2D-D1D0-4C46-A310-FEEE17CF1CF5</documentTypeId>
								  <numberSettingId>126D9893-EE7C-4FCD-ABEB-A8FDE07E8888</numberSettingId>
								</outcomeDocument>
								<financialReport>
								  <numberSettingId>126D9893-EE7C-4FCD-ABEB-A8FDE07E8888</numberSettingId>
								</financialReport>
								<paymentMethods />
							  </register>
							</root></xmlOptions>'' AS XML) xmlOptions,
							(select ISNULL(count(id),0) + 1 from dictionary.Branch ) [order],
							 @branchIdO1 AS branchId
					FOR XML PATH(''entry''), TYPE )
				FOR XML PATH(''financialRegister''), TYPE )
			FOR XML PATH(''root''), TYPE )

	SELECT @skrypt = @skrypt + ''	EXEC  dictionary.p_insertFinancialRegister   '''''' + CAST(@tmpXml AS varchar(max)) + '''''' '' + char(10)
	--EXEC  Fractus2_oddzial1.dictionary.p_insertFinancialRegister @tmpXml
	END			
	
/*Zmiana domyślnej wartości databaseId w oddziale, taka prowizora - już nawet nie pami?tam komu się ni chciało że tak zostało*/
	--USE Fractus2_oddzial1
		
		SELECT @skryptOddzialowy = @skryptOddzialowy + '' GO
		ALTER TABLE communication.OutgoingXmlQueue
			DROP CONSTRAINT DF_OutgoingXmlQueue_databaseId
		GO '' + char(10)

		SELECT @skryptOddzialowy = @skryptOddzialowy + '' GO
		ALTER TABLE communication.OutgoingXmlQueue ADD CONSTRAINT
			DF_OutgoingXmlQueue_databaseId DEFAULT ('''''' + CAST(@databaseIdO1 AS varchar(50)) + '''''') FOR databaseId '' + char(10)
		

		/*Zmiana bazy danych w konfiguracji*/
		SELECT @skryptOddzialowy = @skryptOddzialowy + '' GO
		UPDATE configuration.configuration SET textValue='''''' + CAST(@databaseIdO1 AS char(36)) +'''''' WHERE [key]=''''communication.databaseId'''''' + char(10)

		/*Nie wiem co to ale trzeba wstawić*/
		SELECT @skrypt = @skrypt + '' INSERT INTO communication.[Statistics] (departmentId) SELECT '''''' + CAST(@branchIdO1 AS char(36)) +''''''''	
	



/*Oddział ustawiamy by nie był centralą*/
SELECT @skryptOddzialowy = @skryptOddzialowy + '' UPDATE configuration.Configuration SET textValue=''''false'''' WHERE [key]=''''system.isHeadquarter'''''' + char(10)

/*Wyłączenie WMS*/
SELECT @skryptOddzialowy = @skryptOddzialowy + '' UPDATE configuration.Configuration SET textValue=''''false'''' WHERE [key]=''''warehouse.isWmsEnabled'''''' + char(10)

DECLARE @komunikat nvarchar(500)

--PRINT @skrypt
EXEC (@skrypt)



SELECT @komunikat = ''----------------------- Odpalić na oddziale: '' + symbol + ''---------------------------------------''
FROM dictionary.Branch WHERE id = @branchIdO1

PRINT @komunikat

PRINT @skryptOddzialowy
PRINT ''------------------------------------------------------------------------------------------------------------------------------------'' 
----ustawienie repozytorium
--INSERT INTO Fractus2_centrala.dictionary.repository SELECT newid(), ''http://svn_serv/Repository/Repository.svc'', newid()
--INSERT INTO Fractus2_oddzial1.dictionary.repository SELECT * FROM Fractus2_centrala.dictionary.repository
--INSERT INTO Fractus2_oddzial2.dictionary.repository SELECT * FROM Fractus2_centrala.dictionary.repository

END' 
END
GO
