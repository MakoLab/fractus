/*
name=[tools].[p_dodajTowar]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
OvovhPfcfTPtaT9LCFP3gw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_dodajTowar]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_dodajTowar]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_dodajTowar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N' 

CREATE PROCEDURE [tools].[p_dodajTowar] 
@idTow int,
@itemId uniqueidentifier OUTPUT

AS
BEGIN 

	DECLARE 
	@itemType_service UNIQUEIDENTIFIER, 
	@itemType_good UNIQUEIDENTIFIER, 
	@Attribute_Manufacturer  UNIQUEIDENTIFIER, 
	@Attribute_Description UNIQUEIDENTIFIER,
	@Attribute_ManufacturerCode UNIQUEIDENTIFIER,
	@Attribute_FiscalName UNIQUEIDENTIFIER,
	@Attribute_SWW UNIQUEIDENTIFIER,
	@Attribute_pkwiu UNIQUEIDENTIFIER,
	@Attribute_remarks UNIQUEIDENTIFIER,
	@x XML


	SELECT @itemType_service = id  FROM dictionary.ItemType WHERE name = ''Service''
	SELECT @itemType_good = id   FROM dictionary.ItemType WHERE name = ''Good''
	SELECT @Attribute_Manufacturer = id  FROM dictionary.ItemField WHERE name = ''Attribute_Manufacturer''--
	SELECT @Attribute_Description = id   FROM dictionary.ItemField WHERE name = ''Attribute_Description''--
	SELECT @Attribute_ManufacturerCode = id   FROM dictionary.ItemField WHERE name = ''Attribute_ManufacturerCode''--
	SELECT @Attribute_FiscalName = id  FROM dictionary.ItemField WHERE name = ''Attribute_FiscalName''--
	SELECT @Attribute_SWW = id  FROM dictionary.ItemField WHERE name = ''Attribute_SWW''
	SELECT @Attribute_pkwiu = id   FROM dictionary.ItemField WHERE name = ''Attribute_pkwiu''
	SELECT @Attribute_remarks = id   FROM dictionary.ItemField WHERE name = ''Attribute_remarks''
	
	declare @unit table ( id uniqueidentifier, symbol varchar(50))

	INSERT INTO @unit 
	SELECT id, xmlLabels.value(''(labels/label[@lang = "pl"]/@symbol)[1]'',''varchar(50)'') symbol
	FROM  dictionary.Unit


	SELECT @itemId = NEWID()

	INSERT INTO [item].Item (id, code, vatRateId, itemTypeId, name, defaultPrice, unitId, version, creationDate)
	SELECT 
		@itemId, 
		REPLACE(REPLACE(kod, ''&amp;'',''''), ''&quot;'',''''), 
		vr.id,
		CASE WHEN typ = ''U'' THEN @itemType_service  ELSE @itemType_good  END, 
		REPLACE(REPLACE(t.nazwa, ''&amp;'',''''), ''&quot;'',''''), 
		ISNULL(cena,0) ,x.id, 
		NEWID()
		,GETDATE()
	FROM MegaManage_LAK_SP_JAWNA.dbo.[Towary] t 
		JOIN MegaManage_LAK_SP_JAWNA.dbo.Slow_Jm jm ON t.id_jm = jm.id
		LEFT JOIN ( SELECT MAX(wartosc) cena, id_towaru FROM MegaManage_LAK_SP_JAWNA.dbo.[Tow_ceny] GROUP BY id_towaru) tc ON t.id = tc.id_towaru
		LEFT JOIN @unit x ON REPLACE(jm.skrot,''.'','''') = REPLACE(x.symbol, ''.'','''')
		JOIN dictionary.VatRate vr ON REPLACE(t.vat,''.00'','''') = vr.symbol
	WHERE t.id = @idTow

	INSERT INTO [translation].Towary (megaId,fractus2Id,megaGID)
	SELECT idMM, @itemId, gid FROM MegaManage_LAK_SP_JAWNA.dbo.[Towary] WHERE id = @idTow
	 
	/*Producent*/
	INSERT INTO item.ItemAttrValue ( id,itemId, itemFieldId, textValue, [version], [order]  )
	SELECT newid() id, @itemId itemId,@Attribute_Manufacturer itemFieldId,producent textValue, newid() version, 1 number
	FROM MegaManage_LAK_SP_JAWNA.dbo.towary t 
	WHERE t.id = @idTow AND NULLIF(RTRIM(t.producent), '''') IS NOT NULL


	/*Kod producenta*/
	INSERT INTO item.ItemAttrValue ( id,itemId, itemFieldId, textValue, [version], [order]  )
	SELECT newid() id, @itemId itemId,@Attribute_ManufacturerCode itemFieldId,kod_producenta textValue, newid() , 1 number
	FROM MegaManage_LAK_SP_JAWNA.dbo.towary t 
	WHERE t.id = @idTow  AND NULLIF(RTRIM(t.kod_producenta), '''') IS NOT NULL

		
	/* SWW */
	INSERT INTO item.ItemAttrValue ( id,itemId, itemFieldId, textValue, [version], [order] )
	SELECT newid() id, @itemId itemId,@Attribute_SWW itemFieldId,sww textValue, newid() , 1 number
	FROM MegaManage_LAK_SP_JAWNA.dbo.towary t 
	WHERE t.id = @idTow  AND  NULLIF(RTRIM(t.sww), '''') IS NOT NULL

	

	/* Opis */
	INSERT INTO item.ItemAttrValue ( id,itemId, itemFieldId, textValue, [version], [order] )
	SELECT newid() id, @itemId itemId,@Attribute_Description itemFieldId,opis textValue, newid() , 1 number
	FROM MegaManage_LAK_SP_JAWNA.dbo.towary t 
	WHERE t.id = @idTow  AND NULLIF(RTRIM(t.opis), '''') IS NOT NULL


	/* PKWiU */
	INSERT INTO item.ItemAttrValue ( id,itemId, itemFieldId, textValue, [version], [order] )
	SELECT newid() id, @itemId itemId,@Attribute_pkwiu itemFieldId,pkwiu textValue, newid() , 1 number
	FROM MegaManage_LAK_SP_JAWNA.dbo.towary t 
	WHERE t.id = @idTow AND NULLIF(RTRIM(t.pkwiu), '''') IS NOT NULL

	/* Uwagi */
	INSERT INTO item.ItemAttrValue ( id,itemId, itemFieldId, textValue, [version], [order] )
	SELECT newid() id, @itemId itemId,@Attribute_Remarks itemFieldId,uwagi textValue, newid() , 2 number
	FROM MegaManage_LAK_SP_JAWNA.dbo.towary t 
	WHERE t.id = @idTow AND NULLIF(RTRIM(t.uwagi), '''') IS NOT NULL
 

	/* Nazwa Fiskalna */
	INSERT INTO item.ItemAttrValue ( id,itemId, itemFieldId, textValue, [version], [order] )
	SELECT newid() id, @itemId itemId,@Attribute_FiscalName itemFieldId,nazwa_fiskalna textValue, newid() , 2 number
	FROM MegaManage_LAK_SP_JAWNA.dbo.towary t 
	WHERE t.id = @idTow AND NULLIF(RTRIM(t.nazwa_fiskalna), '''') IS NOT NULL

	  
	SELECT @x = CAST( ''<root businessObjectId="'' + CAST( @itemId AS char(36)) + ''" mode="insert" />'' AS XML)

/*Indeksowanie towaru*/
	EXEC [item].[p_updateItemDictionary] @x

END' 
END
GO
