/*
name=[tools].[p_dodajBANK]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
MEh6vbKoNjDoj8Dj2cmrLw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_dodajBANK]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_dodajBANK]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_dodajBANK]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE procedure [tools].[p_dodajBANK]
@nroddzialu int
AS
 

BEGIN

DECLARE @xVar XML,@contractorId uniqueidentifier, @dictionaryId uniqueidentifier, @counter int,@version uniqueidentifier, @countryId uniqueidentifier,
		@defaultAddres uniqueidentifier , @Attribute_BankNumber uniqueidentifier

/*Pobranie sBowników*/
	/*countryId dla PL*/
	SELECT @countryId = id FROM dictionary.Country WHERE symbol = ''PL''
	IF @countryId IS NULL
		RAISERROR ( ''Brak kraju'', 16, 1 ) ; 
	
	SELECT @defaultAddres = id FROM dictionary.ContractorField WHERE name = ''Address_Default''
	SELECT @Attribute_BankNumber = id FROM dictionary.ContractorField WHERE [name] = ''Attribute_BankNumber''


	IF @defaultAddres IS NULL
		RAISERROR ( ''Brak domyślnego adresu'', 16, 1 ) ; 


		SELECT @contractorId = newid(),@version = newid()

		SELECT @xVar = (
		SELECT (
			SELECT (
				SELECT  cast(@contractorId as char(36)) id, o.id_banku  code, 0 isSupplier , 0 isReceiver,1 isBusinessEntity, 1 isBank, 
					RTRIM(b.NAZWA_BA1) + char(13) + o.nazwa_jed1 fullName,  o.nazwa_jed1 shortName, 1 isShortNameAutoUpdateEnabled, @countryId  nipPrefixCountryId
					,0 isNipValidationEnabled,0 isInactive, @version version
				FROM BANKI b 
				JOIN ODDZIALY o ON b.nrbanku = o.nrbanku
				--JOIN  BIC bc ON o.NRODDZIALU = bc.NRODDZIALU
				where o.NRODDZIALU = @nroddzialu

				FOR XML PATH(''entry'') ,TYPE
			)  FOR XML PATH(''contractor'') ,TYPE
		)  FOR XML PATH(''root'') ,TYPE )




/*Wstawienie kontrahenta*/
EXEC contractor.p_insertContractor @xVar
 

/*Adresy kontrahentów*/
		SELECT @version = newid()

		SELECT @xVar = (
		SELECT (
			SELECT (
				SELECT  cast(newid() as char(36)) id, cast(@contractorId as char(36)) contractorId, @defaultAddres contractorFieldId ,
					ISNULL(ulica,'''') [address], miasto city, kod postCode,@countryId countryId, @version version
				FROM ODDZIALY o 
				where o.NRODDZIALU = @nroddzialu
				FOR XML PATH(''entry'') ,TYPE
			)  FOR XML PATH(''contractorAddress'') ,TYPE
		)  FOR XML PATH(''root'') ,TYPE)



	IF @xVar.exist(''/root/contractorAddress/entry'') = 1
			BEGIN
				EXEC contractor.p_insertContractorAddress @xVar			
			END

		INSERT INTO contractor.Bank (contractorId, bankNumber, swiftNumber, version )
		SELECT @contractorId,  o.NRODDZIALU,
			 NULLIF(( SELECT top 1 bc.NRBIC FROM BIC bc WHERE o.NRODDZIALU = bc.NRODDZIALU),'''') xmlValue, newid()
		FROM ODDZIALY o  
		where o.NRODDZIALU = @nroddzialu


--
--		SELECT @version = newid()
--		SELECT @xVar = (
--		SELECT (
--			SELECT (
--				SELECT  cast(newid() as char(36)) id, cast(@contractorId as char(36)) contractorId, @Attribute_BankNumber contractorFieldId , @version version,
--					 NULLIF(( SELECT top 1 bc.NRBIC FROM BIC bc WHERE o.NRODDZIALU = bc.NRODDZIALU),'''') xmlValue
--				FROM ODDZIALY o  
--				where o.NRODDZIALU = @nroddzialu
--				FOR XML PATH(''entry'') ,TYPE
--			)  FOR XML PATH(''contractorAttrValue'') ,TYPE
--		)  FOR XML PATH(''root'') ,TYPE
--		)
--
--	IF @xVar.exist(''/root/contractorAttrValue/entry'') = 1
--			EXEC contractor.p_insertContractorAttrValue @xVar
--

END
' 
END
GO
