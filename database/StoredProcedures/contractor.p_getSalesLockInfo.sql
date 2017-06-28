/*
name=[contractor].[p_getSalesLockInfo]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
N/xJJCgVWdCYL6AZi15vAA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getSalesLockInfo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getSalesLockInfo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getSalesLockInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [contractor].[p_getSalesLockInfo] @xmlVar XML
AS
BEGIN
	DECLARE @contractorId UNIQUEIDENTIFIER,
			@totalDebt decimal(18,2),
			@oldestPaymentDueDate datetime,
			@allowCashPayment varchar(50),
			@maxDebtAmount decimal(18,2),
			@maxDocumentDebtAmount decimal(18,2),
			@maxOverdueDays varchar(100),
			@maxDueDays varchar(100)
			
	--Cache na atrybuty grup kontrahenta by adam
	DECLARE @ContractorGroupsAttributes
	TABLE
	(
		groupId UNIQUEIDENTIFIER,
		name	VARCHAR(200),
		[type]	varchar(50),
		[value]	numeric(18,2)
	)

	DECLARE @x XML

	SELECT @x =xmlValue from configuration.Configuration WHERE [key] like ''contractors.group''
	SELECT @contractorId = @xmlVar.value(''(/root/contractorId)[1]'',''char(36)'')

	--Uzupełnienie cache atrybutów grup kontrahenta by adam
	INSERT INTO @ContractorGroupsAttributes
	SELECT [attr].* FROM
		(SELECT 
			x.value(''(../../@id)[1]'',''char(36)'') [groupId]
			, x.value(''(@name)[1]'',''varchar(200)'') [name]
			, x.value(''(@type)[1]'',''varchar(50)'') [type]
			, NULLIF(x.value(''.'',''varchar(200)''), ''NaN'') [value]
		FROM @x.nodes(''//group/attributes/*[contains(@name, "SalesLockAttribute")]'') as a(x)) [attr]
	JOIN [contractor].[ContractorGroupMembership] [gm] ON [attr].[groupId] = [gm].[contractorGroupId]
	WHERE [gm].[contractorId] = @contractorId

	SELECT
		@totalDebt = SUM( (p.unsettledAmount * exchangeRate )/ p.exchangeScale ),	-- suma nierozliczonych kwot platnosci
		@oldestPaymentDueDate = MIN(dueDate)								-- najstarsza platnosc spelniajaca warunki
	FROM
		finance.payment p WITH(NOLOCK)
		--LEFT JOIN (
		--	SELECT p.id, sum(( ps.amount * p.exchangeRate ) / p.exchangeScale) amount					-- suma rozliczen dla kazdej platnosci
		--	FROM finance.payment p
		--	JOIN finance.PaymentSettlement ps ON p.id IN (ps.incomePaymentId, ps.outcomePaymentId)
		--	WHERE contractorId = @contractorId					-- tak na wszelki wypadek zeby nie przegladal calej tabeli platnosci
		--	GROUP BY p.id
		--) psc ON p.id = psc.id
	WHERE
		contractorId = @contractorId							-- tylko platnosci wybranego kontrahenta
		AND p.direction * p.amount < 0							-- tylko naleznosci
		AND p.unsettledAmount <> 0	-- potrzebne by wybrac date najstarszej NIEROZLICZONEJ platnosci oraz by ew. nadrozliczone platnosci nie pomniejszaly kwoty calkowitego zadluzenia
		AND ISNULL(p.requireSettlement,1) <> 0
		
	-- gdereck - jezeli kontrahent nie posiada atrybutu, wartosc pozostanie null (wykona sie kolejne przypisanie)
	SELECT @allowCashPayment = CASE WHEN decimalValue <> 0 THEN ''true'' ELSE ''false'' END
	FROM contractor.ContractorAttrValue  cav 
		JOIN dictionary.ContractorField cf ON cav.contractorFieldId = cf.id
	WHERE cav.contractorId = @contractorId AND cf.name = ''SalesLockAttribute_AllowCashPayment''

	--linia by adam
	SELECT @allowCashPayment = ISNULL(@allowCashPayment,( SELECT (CASE MAX([value]) WHEN 1 THEN ''true'' WHEN 0 THEN ''false'' ELSE NULL END) FROM @ContractorGroupsAttributes WHERE [name] = ''SalesLockAttribute_AllowCashPayment'' ))

	SELECT @allowCashPayment = ISNULL(@allowCashPayment,( SELECT textValue FROM configuration.Configuration WHERE [key] = ''salesLock.allowCashPayment'' ))

	SELECT @maxDebtAmount = decimalValue
	FROM contractor.ContractorAttrValue  cav 
		JOIN dictionary.ContractorField cf ON cav.contractorFieldId = cf.id
	WHERE cav.contractorId = @contractorId AND cf.name = ''SalesLockAttribute_MaxDebtAmount''

	--adam
	SELECT @maxDebtAmount = ISNULL(@maxDebtAmount,( SELECT MIN([value]) FROM @ContractorGroupsAttributes WHERE [name] = ''SalesLockAttribute_MaxDebtAmount'' ))

	SELECT @maxDebtAmount = ISNULL(@maxDebtAmount,( SELECT textValue FROM configuration.Configuration WHERE [key] = ''salesLock.maxDebtAmount'' ))
 
	SELECT @maxDocumentDebtAmount = decimalValue
	FROM contractor.ContractorAttrValue  cav 
		JOIN dictionary.ContractorField cf ON cav.contractorFieldId = cf.id
	WHERE cav.contractorId = @contractorId AND cf.name = ''SalesLockAttribute_MaxDocumentDebtAmount''

	--adam
	SELECT @maxDocumentDebtAmount = ISNULL(@maxDocumentDebtAmount,( SELECT MIN([value]) FROM @ContractorGroupsAttributes WHERE [name] = ''SalesLockAttribute_MaxDocumentDebtAmount'' ))

	SELECT @maxDocumentDebtAmount = ISNULL(@maxDocumentDebtAmount,( SELECT textValue FROM configuration.Configuration WHERE [key] = ''salesLock.maxDocumentDebtAmount'' ))

	SELECT @maxOverdueDays = decimalValue
	FROM contractor.ContractorAttrValue  cav 
		JOIN dictionary.ContractorField cf ON cav.contractorFieldId = cf.id
	WHERE cav.contractorId = @contractorId AND cf.name = ''SalesLockAttribute_MaxOverdueDays''

	--adam
	SELECT @maxOverdueDays = ISNULL(@maxOverdueDays,( SELECT MIN([value]) FROM @ContractorGroupsAttributes WHERE [name] = ''SalesLockAttribute_MaxOverdueDays'' ))
	
	SELECT @maxOverdueDays = ISNULL(@maxOverdueDays,( SELECT textValue FROM configuration.Configuration WHERE [key] = ''salesLock.maxOverdueDays'' ))
	
	--select * FROM dictionary.ContractorField WHERE [name] = ''SalesLockAttribute_MaxDueDays''

	SELECT @maxDueDays = decimalValue
	FROM contractor.ContractorAttrValue  cav 
		JOIN dictionary.ContractorField cf ON cav.contractorFieldId = cf.id
	WHERE cav.contractorId = @contractorId AND cf.name = ''SalesLockAttribute_MaxDueDays''

	--adam
	SELECT @maxDueDays = ISNULL(@maxDueDays,( SELECT MIN([value]) FROM @ContractorGroupsAttributes WHERE [name] = ''SalesLockAttribute_MaxDueDays'' ))

	SELECT @maxDueDays = ISNULL(@maxDueDays,( SELECT textValue FROM configuration.Configuration WHERE [key] = ''salesLock.maxDueDays'' ))

	SELECT NULLIF(@totalDebt,0) totalDebt,
		   @oldestPaymentDueDate oldestPaymentDueDate,
		   @allowCashPayment allowCashPayment,
		   @maxDebtAmount maxDebtAmount,
		   @maxDocumentDebtAmount maxDocumentDebtAmount,
		   @maxOverdueDays maxOverdueDays,
		   @maxDueDays maxDueDays
	FOR XML PATH(''root''), TYPE	   
END
' 
END
GO
