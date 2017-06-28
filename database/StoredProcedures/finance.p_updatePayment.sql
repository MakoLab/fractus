/*
name=[finance].[p_updatePayment]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
2WABNKHsE3/YhEtnAQDYqg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_updatePayment]') AND type in (N'P', N'PC'))
DROP PROCEDURE [finance].[p_updatePayment]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[finance].[p_updatePayment]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [finance].[p_updatePayment]
@xmlVar XML
AS
BEGIN 
	DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT,
		@idoc INT,
		@error int 
    
  BEGIN TRY

    EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar
		
	DECLARE @tmp_payment TABLE(	
					[id] char(36) , 
					[date] datetime , 
					[dueDate] datetime , 
					[contractorId] char(36) , 
					[contractorAddressId] char(36), 
					[paymentMethodId] char(36), 
					[commercialDocumentHeaderId] char(36), 
					[financialDocumentHeaderId] char(36), 
					[amount] numeric(18,9), 
					[paymentCurrencyId] char(36), 
					[systemCurrencyId] char(36), 
					[exchangeDate] datetime , 
					[exchangeScale] numeric(18,9), 
					[exchangeRate] numeric(18,9), 
					[isSettled] bit, 
					[version] char(36) , 
					[ordinalNumber] int, 
					[description] nvarchar(500), 
					[documentInfo] nvarchar(100) , 
					[direction] int, 
					[requireSettlement] bit , 
					[unsettledAmount] numeric(18,9), 
					[sysAmount] numeric(18,9) , 
					[branchId] char(36) )
	--/*Wstawienie danych o płatnościach*/
    INSERT  INTO @tmp_payment
            (
              id,
              date,
              dueDate,
              contractorId,
              contractorAddressId,
              paymentMethodId,
              commercialDocumentHeaderId,
              financialDocumentHeaderId,
              amount,
              paymentCurrencyId,
              systemCurrencyId,
              exchangeDate,
              exchangeScale,
              exchangeRate,
              isSettled,
              version,
			  ordinalNumber,
			  description,
			  direction,
			  documentInfo,
			  requireSettlement,
			  unsettledAmount,
			  sysAmount,
			  branchId
            )
			
			SELECT   
			  id,
              date,
              dueDate,
              contractorId,
              contractorAddressId,
              paymentMethodId,
              commercialDocumentHeaderId,
              financialDocumentHeaderId,
              amount,
              paymentCurrencyId,
              systemCurrencyId,
              exchangeDate,
              exchangeScale,
              exchangeRate,
              isSettled,
              ISNULL([_version],[version]) [version],
			  ordinalNumber,
			  description,
			  direction,
			  documentInfo,
			  requireSettlement,
			  ISNULL(unsettledAmount,amount),
			  (amount * exchangeRate) / exchangeScale,
			  --branchId
			  ISNULL(branchId , 
								ISNULL( (SELECT c.branchId FROM document.CommercialDocumentHeader c WHERE c.id = commercialDocumentHeaderId ) 
											,(SELECT f.branchId FROM document.FinancialDocumentHeader f WHERE f.id = financialDocumentHeaderId) 
									 )
					)
			FROM OPENXML(@idoc, ''/root/payment/entry'')
				WITH(
					[id] char(36) ''id'', 
					[date] datetime ''date'', 
					[dueDate] datetime ''dueDate'', 
					[contractorId] char(36) ''contractorId'', 
					[contractorAddressId] char(36) ''contractorAddressId'', 
					[paymentMethodId] char(36) ''paymentMethodId'', 
					[commercialDocumentHeaderId] char(36) ''commercialDocumentHeaderId'', 
					[financialDocumentHeaderId] char(36) ''financialDocumentHeaderId'', 
					[amount] numeric(18,9) ''amount'', 
					[paymentCurrencyId] char(36) ''paymentCurrencyId'', 
					[systemCurrencyId] char(36) ''systemCurrencyId'', 
					[exchangeDate] datetime ''exchangeDate'', 
					[exchangeScale] numeric(18,9) ''exchangeScale'', 
					[exchangeRate] numeric(18,9) ''exchangeRate'', 
					[isSettled] bit ''isSettled'', 
					[version] char(36) ''version'', 
					[_version] char(36) ''_version'',
					[ordinalNumber] int ''ordinalNumber'', 
					[description] nvarchar(500) ''description'', 
					[documentInfo] nvarchar(100) ''documentInfo'', 
					[direction] int ''direction'', 
					[requireSettlement] bit ''requireSettlement'', 
					[unsettledAmount] numeric(18,9) ''unsettledAmount'', 
					[sysAmount] numeric(18,9) ''sysAmount'', 
					[branchId] char(36) ''branchId''
				)


    EXEC sp_xml_removedocument @idoc

		/*Aktualizacja danych o płatnościach*/
        UPDATE  [finance].[Payment]
        SET     [date] =  p.[date] ,
                dueDate = p.dueDate ,
                contractorId = p.contractorId ,
                contractorAddressId = p.contractorAddressId ,
                paymentMethodId = p.paymentMethodId ,
                commercialDocumentHeaderId = p.commercialDocumentHeaderId ,
                financialDocumentHeaderId = p.financialDocumentHeaderId,
                amount = p.amount ,
                unsettledAmount = p.unsettledAmount ,
                paymentCurrencyId = p.paymentCurrencyId ,
                systemCurrencyId = p.systemCurrencyId,
                exchangeDate = p.exchangeDate,
                exchangeScale = p.exchangeScale ,
                exchangeRate = p.exchangeRate ,
                isSettled = p.isSettled ,
                requireSettlement = p.requireSettlement ,
                [version] =p.[version],
                ordinalNumber = p.ordinalNumber ,
                [documentInfo] = p.documentInfo ,
                [description] = p.description ,
                [direction] = p.direction ,
                sysAmount = ISNULL( p.sysAmount  , (p.amount * p.exchangeRate)/p.exchangeScale) ,
                [branchId] = ISNULL( p.branchId, 
											ISNULL( (SELECT c.branchId FROM document.CommercialDocumentHeader c WHERE c.id =  p.commercialDocumentHeaderId  ) ,
													(SELECT f.branchId FROM document.FinancialDocumentHeader f WHERE f.id = p.financialDocumentHeaderId )))
        FROM    @tmp_payment p
        WHERE   Payment.id = p.id

		/*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT

    END TRY
	BEGIN CATCH
			SELECT @errorMsg = ''Błąd wstawiania danych tabela:Payment; error:''
				+ CAST(@@ERROR AS VARCHAR(50)) + '';Procedura:'' + ERROR_PROCEDURE() + '';Linia:'' + CAST(ERROR_LINE() as varchar(50))+ '';Opis:'' + ERROR_MESSAGE() 
            RAISERROR ( @errorMsg, 16, 1)
    END CATCH        
	IF @rowcount = 0 
		BEGIN

		/* 
			Aby zapobiec występowaniu przestojów w komunikacji zamieniam ten komunikat na próbę wstawienia jak się okazuje nowgo wpisu w konfiguracji.
			Może to spowodować błąd logiki systemu (jeśli ktoś celowo usunoł klucz w tym samym czasie z tego miejsca), jednak z punktu widzenia
			i tak koniecznej naprawy, lepiej jest mieć dane które może są niesłusznie niż wcale ich nie mieć i wykminiać czy słusznie 
		*/
			EXEC [finance].[p_insertPayment] @xmlVar

		END
END
' 
END
GO
