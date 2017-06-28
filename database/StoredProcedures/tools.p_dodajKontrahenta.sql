/*
name=[tools].[p_dodajKontrahenta]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
WKCWYApKoTv0lMgRZYcGRQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_dodajKontrahenta]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_dodajKontrahenta]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_dodajKontrahenta]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [tools].[p_dodajKontrahenta]
@idKon INT, @contractorId UNIQUEIDENTIFIER OUTPUT, @contractorAddresId UNIQUEIDENTIFIER OUTPUT
AS
BEGIN

DECLARE @xVar XML, @dictionaryId uniqueidentifier, @counter int,@version uniqueidentifier, @countryId uniqueidentifier,
		@defaultAddres uniqueidentifier , 
		@Attribute_Remark uniqueidentifier,
		@Attribute_Annotation uniqueidentifier,
		@Attribute_AllowCashPayment uniqueidentifier,
		@SalesLockAttribute_MaxDebtAmount uniqueidentifier,
		@Contact_Phone uniqueidentifier,
		@Contact_Fax uniqueidentifier,
		@Attribute_Regon uniqueidentifier,
		@Contact_Email uniqueidentifier,
		@Contact_WWW uniqueidentifier,
		@adresId uniqueidentifier

/*Pobranie słowników*/
	/*countryId dla PL*/
	SELECT @countryId = id FROM dictionary.Country WHERE symbol = ''PL''
	IF @countryId IS NULL
		RAISERROR ( ''Brak kraju'', 16, 1 ) ; 
	
	SELECT @defaultAddres = id FROM dictionary.ContractorField WHERE name = ''Address_Default''
	SELECT @Attribute_Remark = id FROM dictionary.ContractorField WHERE [name] = ''Attribute_Remark''
	SELECT @Attribute_Annotation = id FROM dictionary.ContractorField WHERE [name] = ''Attribute_Annotation''
	SELECT @Attribute_AllowCashPayment = id FROM dictionary.ContractorField WHERE [name] = ''SalesLockAttribute_AllowCashPayment''
	SELECT @SalesLockAttribute_MaxDebtAmount = id FROM dictionary.ContractorField WHERE [name] = ''SalesLockAttribute_MaxDebtAmount''
	SELECT @Contact_Phone = id FROM dictionary.ContractorField WHERE [name] = ''Contact_Phone''
	SELECT @Contact_Fax = id FROM dictionary.ContractorField WHERE [name] = ''Contact_Fax''
	SELECT @Attribute_Regon = id FROM dictionary.ContractorField WHERE [name] = ''Attribute_Regon''
	SELECT @Contact_Email = id FROM dictionary.ContractorField WHERE [name] = ''Contact_Email''
	SELECT @Contact_WWW = id FROM dictionary.ContractorField WHERE [name] = ''Contact_WWW''

	IF @defaultAddres IS NULL
		RAISERROR ( ''Brak domyślnego adresu'', 16, 1 ) ; 


		SELECT @contractorId = newid(),@version = newid()

		SELECT @xVar = (
		SELECT (
			SELECT (
				SELECT  cast(@contractorId as char(36)) id, REPLACE(REPLACE(k.kod , ''&amp;'',''''), ''&quot;'','''') code,CASE WHEN k.typ in(''X'',''D'') THEN 1 ELSE 0 END isSupplier , CASE WHEN k.typ in(''X'',''O'') THEN 1 ELSE 0 END isReceiver,
						CASE WHEN k.fizyczna = ''T'' THEN 1 ELSE 0 END isBusinessEntity, 0 isBank, 
					REPLACE(REPLACE(k.nazwaPelna , ''&amp;'',''''), ''&quot;'','''') fullName,REPLACE(REPLACE(k.nazwa , ''&amp;'',''''), ''&quot;'','''') shortName, 1 isShortNameAutoUpdateEnabled,a.nip
					,@countryId  nipPrefixCountryId
					,0 isNipValidationEnabled,0 isInactive, @version version,
					0 isOwnCompany
				FROM MegaManage_LAK_SP_JAWNA.dbo.kontrahent k 
					JOIN MegaManage_LAK_SP_JAWNA.dbo.adres a on k.id_adres = a.id
				WHERE k.id = @idKon
				FOR XML PATH(''entry'') ,TYPE
			)  FOR XML PATH(''contractor'') ,TYPE
		)  FOR XML PATH(''root'') ,TYPE )

/*Wstawienie kontrahenta*/
EXEC contractor.p_insertContractor @xVar

INSERT INTO [translation].Kontrahent (megaId,fractus2Id)
SELECT idMM, @contractorId FROM MegaManage_LAK_SP_JAWNA.dbo.[Kontrahent] WHERE id = @idKon

 

/*Adresy kontrahentów*/
		SELECT @version = newid()
		SELECT @adresId = newid()

		SELECT @xVar = (
		SELECT (
			SELECT (
				SELECT  cast(@adresId as char(36)) id, cast(@contractorId as char(36)) contractorId, @defaultAddres contractorFieldId ,
					ISNULL(ulica,'''') + '' '' +  ISNULL(nrDomu, '''')  + '' '' +  ISNULL( nrLokalu,'''') address, miasto city, kodPocztowy postCode,@countryId countryId, @version version
				FROM MegaManage_LAK_SP_JAWNA.dbo.kontrahent k JOIN MegaManage_LAK_SP_JAWNA.dbo.adres a on k.id_adres = a.id
				WHERE k.id = @idKon
				
				FOR XML PATH(''entry'') ,TYPE
			)  FOR XML PATH(''contractorAddress'') ,TYPE
		)  FOR XML PATH(''root'') ,TYPE)

	IF @xVar.exist(''/root/contractorAddress/entry'') = 1
			BEGIN
				EXEC contractor.p_insertContractorAddress @xVar
				INSERT INTO [translation].Adres (megaId,fractus2Id,megaGID)
				SELECT idMA, @adresId, null FROM MegaManage_LAK_SP_JAWNA.dbo.[Adres] WHERE id = (SELECT id_adres FROM MegaManage_LAK_SP_JAWNA.dbo.kontrahent k where id = @idKon)
			END

	/*Regon*/
		SELECT @version = newid(), @xVar = null
		SELECT @xVar = (
		SELECT (
			SELECT (
				SELECT  cast(newid() as char(36)) id, cast(@contractorId as char(36)) contractorId, @Attribute_Regon contractorFieldId , @version version,
					 
						(SELECT STUFF(        
							(	SELECT a.regon + char(10)        
								FROM  MegaManage_LAK_SP_JAWNA.dbo.adres a  
								WHERE a.id = k.id_adres
								FOR XML PATH('''')) , 1, 0, '''' )       
					) AS textValue
				FROM MegaManage_LAK_SP_JAWNA.dbo.kontrahent k JOIN MegaManage_LAK_SP_JAWNA.dbo.adres a on k.id_adres = a.id 
				WHERE k.id = @idKon 
					AND NULLIF(rtrim(a.regon),'''') IS NOT NULL
				 	
				FOR XML PATH(''entry'') ,TYPE
			)  FOR XML PATH(''contractorAttrValue'') ,TYPE
		)  FOR XML PATH(''root'') ,TYPE
		)

	IF @xVar.exist(''/root/contractorAttrValue/entry'') = 1
			EXEC contractor.p_insertContractorAttrValue @xVar				
 

 /* Uwagi */
		SELECT @version = newid()
		SELECT @xVar = (
		SELECT (
			SELECT (
				SELECT  cast(newid() as char(36)) id, cast(@contractorId as char(36)) contractorId, @Attribute_Remark contractorFieldId , @version version,
					 NULLIF(rtrim(uwagi),'''') textValue
				FROM MegaManage_LAK_SP_JAWNA.dbo.kontrahent k --JOIN MegaManage_LAK_SP_JAWNA.dbo.adres a on k.id_adres = a.id
				WHERE k.id = @idKon AND NULLIF(rtrim(uwagi),'''') IS NOT NULL
				FOR XML PATH(''entry'') ,TYPE
			)  FOR XML PATH(''contractorAttrValue'') ,TYPE
		)  FOR XML PATH(''root'') ,TYPE
		)

	IF @xVar.exist(''/root/contractorAttrValue/entry'') = 1
			EXEC contractor.p_insertContractorAttrValue @xVar
			
 	
			
/*Adnotacje*/			
			
		SELECT @version = newid(), @xVar = null
		SELECT @xVar = (
		SELECT (
			SELECT (
				SELECT  cast(newid() as char(36)) id, cast(@contractorId as char(36)) contractorId, @Attribute_Annotation contractorFieldId , @version version,
					 (SELECT ''Makolab Administrator'' [user], ''D1F80960-EC30-48E4-979B-F7A5D33C25B3'' [userId], NULLIF(rtrim(notatki),'''') data
						FOR XML PATH(''note'') ,TYPE ) xmlValue
					 
				FROM MegaManage_LAK_SP_JAWNA.dbo.kontrahent k 
				WHERE k.id = @idKon 
					AND NULLIF(rtrim(notatki),'''') IS NOT NULL
				FOR XML PATH(''entry'') ,TYPE
			)  FOR XML PATH(''contractorAttrValue'') ,TYPE
		)  FOR XML PATH(''root'') ,TYPE
		)

	IF @xVar.exist(''/root/contractorAttrValue/entry'') = 1
			EXEC contractor.p_insertContractorAttrValue @xVar
 
/*Blokady kupieckie*/			
	/*czy pozwalać na gotówkę*/			
			
		SELECT @version = newid(), @xVar = null
		SELECT @xVar = (
		SELECT (
			SELECT (
				SELECT  cast(newid() as char(36)) id, cast(@contractorId as char(36)) contractorId, @Attribute_AllowCashPayment contractorFieldId , @version version,
					 ''true'' textValue, 1.0 decimalValue
				FROM MegaManage_LAK_SP_JAWNA.dbo.kontrahent k 
				WHERE k.id = @idKon  
				FOR XML PATH(''entry'') ,TYPE
			)  FOR XML PATH(''contractorAttrValue'') ,TYPE
		)  FOR XML PATH(''root'') ,TYPE
		)

	IF @xVar.exist(''/root/contractorAttrValue/entry'') = 1
			EXEC contractor.p_insertContractorAttrValue @xVar
 
 
	/*maksymalny kredyt*/
		SELECT @version = newid(), @xVar = null
		SELECT @xVar = (
		SELECT (
			SELECT (
				SELECT  cast(newid() as char(36)) id, cast(@contractorId as char(36)) contractorId, @SalesLockAttribute_MaxDebtAmount contractorFieldId , @version version,
					 maxWart_kred decimalValue 
				FROM MegaManage_LAK_SP_JAWNA.dbo.kontrahent k 
				WHERE k.id = @idKon 
					AND maxWart_kred IS NOT NULL
				FOR XML PATH(''entry'') ,TYPE
			)  FOR XML PATH(''contractorAttrValue'') ,TYPE
		)  FOR XML PATH(''root'') ,TYPE
		)

	IF @xVar.exist(''/root/contractorAttrValue/entry'') = 1
			EXEC contractor.p_insertContractorAttrValue @xVar
 	
	/*telefony*/
		SELECT @version = newid(), @xVar = null
		SELECT @xVar = (
		SELECT (
			SELECT (
				SELECT  cast(newid() as char(36)) id, cast(@contractorId as char(36)) contractorId, @Contact_Phone contractorFieldId , @version version,
						(SELECT STUFF(        
							(	SELECT a.telefony + char(10)        
								FROM  MegaManage_LAK_SP_JAWNA.dbo.adres a  
								WHERE a.id = k.id_adres
								FOR XML PATH('''')) , 1, 0, '''' )       
					) AS textValue
				FROM MegaManage_LAK_SP_JAWNA.dbo.kontrahent k JOIN MegaManage_LAK_SP_JAWNA.dbo.adres a on k.id_adres = a.id 
				WHERE k.id = @idKon 
					AND NULLIF(rtrim(a.telefony),'''') IS NOT NULL
				 	
				FOR XML PATH(''entry'') ,TYPE
			)  FOR XML PATH(''contractorAttrValue'') ,TYPE
		)  FOR XML PATH(''root'') ,TYPE
		)

	IF @xVar.exist(''/root/contractorAttrValue/entry'') = 1
			EXEC contractor.p_insertContractorAttrValue @xVar	
 	
			
	/*FAX*/
		SELECT @version = newid(), @xVar = null
		SELECT @xVar = (
		SELECT (
			SELECT (
				SELECT  cast(newid() as char(36)) id, cast(@contractorId as char(36)) contractorId, @Contact_Fax contractorFieldId , @version version,
					 
						(SELECT STUFF(        
							(	SELECT a.fax + char(10)        
								FROM  MegaManage_LAK_SP_JAWNA.dbo.adres a  
								WHERE a.id = k.id_adres
								FOR XML PATH('''')) , 1, 0, '''' )       
					) AS textValue
				FROM MegaManage_LAK_SP_JAWNA.dbo.kontrahent k JOIN MegaManage_LAK_SP_JAWNA.dbo.adres a on k.id_adres = a.id 
				WHERE k.id = @idKon 
					AND NULLIF(rtrim(a.fax),'''') IS NOT NULL
				 	
				FOR XML PATH(''entry'') ,TYPE
			)  FOR XML PATH(''contractorAttrValue'') ,TYPE
		)  FOR XML PATH(''root'') ,TYPE
		)

	IF @xVar.exist(''/root/contractorAttrValue/entry'') = 1
			EXEC contractor.p_insertContractorAttrValue @xVar				
 		
	/*email*/
		SELECT @version = newid(), @xVar = null
		SELECT @xVar = (
		SELECT (
			SELECT (
				SELECT  cast(newid() as char(36)) id, cast(@contractorId as char(36)) contractorId, @Contact_Email contractorFieldId , @version version,
					 
						(SELECT STUFF(        
							(	SELECT a.email + char(10)        
								FROM  MegaManage_LAK_SP_JAWNA.dbo.adres a  
								WHERE a.id = k.id_adres
								FOR XML PATH('''')) , 1, 0, '''' )       
					) AS textValue
				FROM MegaManage_LAK_SP_JAWNA.dbo.kontrahent k JOIN MegaManage_LAK_SP_JAWNA.dbo.adres a on k.id_adres = a.id 
				WHERE k.id = @idKon 
					AND NULLIF(rtrim(a.email),'''') IS NOT NULL
				 	
				FOR XML PATH(''entry'') ,TYPE
			)  FOR XML PATH(''contractorAttrValue'') ,TYPE
		)  FOR XML PATH(''root'') ,TYPE
		)

	IF @xVar.exist(''/root/contractorAttrValue/entry'') = 1
			EXEC contractor.p_insertContractorAttrValue @xVar
 		
	/*www*/
		SELECT @version = newid(), @xVar = null
		SELECT @xVar = (
		SELECT (
			SELECT (
				SELECT  cast(newid() as char(36)) id, cast(@contractorId as char(36)) contractorId, @Contact_WWW contractorFieldId , @version version,
					 
						(SELECT STUFF(        
							(	SELECT a.www + char(10)        
								FROM  MegaManage_LAK_SP_JAWNA.dbo.adres a  
								WHERE a.id = k.id_adres
								FOR XML PATH('''')) , 1, 0, '''' )       
					) AS textValue
				FROM MegaManage_LAK_SP_JAWNA.dbo.kontrahent k JOIN MegaManage_LAK_SP_JAWNA.dbo.adres a on k.id_adres = a.id 
				WHERE k.id = @idKon 
					AND NULLIF(rtrim(a.www),'''') IS NOT NULL
				 	
				FOR XML PATH(''entry'') ,TYPE
			)  FOR XML PATH(''contractorAttrValue'') ,TYPE
		)  FOR XML PATH(''root'') ,TYPE
		)

	IF @xVar.exist(''/root/contractorAttrValue/entry'') = 1
			EXEC contractor.p_insertContractorAttrValue @xVar			
 		
END
' 
END
GO
