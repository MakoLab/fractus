/*
name=[custom].[p_getCommercialDocumentXML]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
h7FtQC/GxHLjjuMqRxlzpg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getCommercialDocumentXML]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_getCommercialDocumentXML]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getCommercialDocumentXML]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'---- [custom].[p_getCommercialDocumentXML] ''<root>95835</root>''




CREATE  PROCEDURE [custom].[p_getCommercialDocumentXML]
   @xmlVar XML 

AS 

    BEGIN
    DECLARE @commercialDocumentHeaderId uniqueidentifier, @pz uniqueidentifier, @fz uniqueidentifier,@orderNumber varchar(500)




	SELECT @orderNumber = @xmlVar.value(''(*)[1]'',''varchar(500)'')
	SELECT @commercialDocumentHeaderId = commercialDocumentHeaderId
	FROM document.DocumentAttrValue 
	WHERE documentFieldId = (SELECT id FROM dictionary.DocumentField WHERE name = ''Attribute_InternetOrderNumber'') 
		AND commercialDocumentHeaderId IS NOT NULL 
		AND textValue IS NOT NULL
		AND textValue like @orderNumber
		 

		/*Budowanie XML z kompletem informacji o dokumencie*/
	SELECT (
        SELECT  ( SELECT    
						(  
								SELECT	CDL.fullNumber [NumerDokumentu]
										,CDL.issueDate [DataWystawienia]
										,CDL.eventDate [DataSprzedazy]
										,CDL.grossValue [WartoscBrutto]
										, dbo.KwotaSlownie(CAST(CDL.grossValue AS int)) + '' złotych '' +  dbo.KwotaSlownie(CAST(CDL.grossValue*100 AS int)%100) + '' grosze'' [Slownie]
										,@orderNumber [NumerZamowieniaInternetowego]
									    ,c.fullName [Kontrahent]
										,c.nip [Nip]
										,(SELECT  a.address [Adres], a.addressNumber [Numer], a.city [Miasto], a.postCode [KodPocztowy], a.postOffice [Poczta]
                                          FROM      [contractor].ContractorAddress  a WITH(NOLOCK)
                                          WHERE     a.id = CDL.contractorAddressId
										 FOR XML PATH(''adresKontrahenta''), TYPE)
										 ,ci.fullName [Sprzedawca]
										 ,ci.nip [NipSprzedawcy]
										,(SELECT  a.address [Adres], a.addressNumber [Numer], a.city [Miasto], a.postCode [KodPocztowy], a.postOffice [Poczta]
                                          FROM      [contractor].ContractorAddress  a WITH(NOLOCK)
                                          WHERE     a.id = CDL.issuerContractorAddressId
										 FOR XML PATH(''adresSprzedawcy''), TYPE)

								FROM      [document].CommercialDocumentHeader CDL  WITH(NOLOCK)
									LEFT JOIN contractor.Contractor c WITH(NOLOCK)  ON CDL.contractorId = c.id
									LEFT JOIN contractor.Contractor ci WITH(NOLOCK)  ON CDL.issuerContractorId = ci.id
								WHERE     CDL.id = @commercialDocumentHeaderId
								FOR XML PATH(''naglowek''), TYPE
                            ),
                            (   
								SELECT (
								SELECT  l.ordinalNumber [NumerPozycji], Item.Name [Nazwa], Item.code [KodTowaru],l.quantity [Ilosc], 
										u.xmlLabels.value(''(labels/label[@lang="pl"]/@symbol)[1]'',''varchar(10)'') [Jednostka], 
										l.netPrice [CenaNetto], l.netValue [WartoscNetto], v.symbol [StawkaVat],
										l.discountRate [Rabat]
								FROM      [document].CommercialDocumentLine l
								JOIN item.Item WITH(NOLOCK) ON l.itemId = item.id
								JOIN dictionary.Unit u  WITH(NOLOCK) ON l.unitId = u.id
								join dictionary.VatRate v  WITH(NOLOCK) ON v.id = l.vatRateId
								WHERE     commercialDocumentHeaderId = @commercialDocumentHeaderId
								FOR  XML PATH(''linia''), TYPE )
								FOR  XML PATH(''linie''), TYPE
                            ),
                            ( 
								SELECT (
								SELECT      v.symbol [Stawka], t.vatValue [WartoscVat]
                                FROM      [document].CommercialDocumentVatTable t WITH(NOLOCK)
									JOIN dictionary.VatRate v  WITH(NOLOCK) ON t.vatRateId = v.id
                                WHERE     commercialDocumentHeaderId = @commercialDocumentHeaderId
								FOR XML PATH(''vat''), TYPE )
								FOR XML PATH(''tabelaVat''), TYPE
                            ),
                            ( 

								SELECT (
								SELECT   p.dueDate [TerminZaplaty], p.amount [Kwota], m.xmlLabels.value(''(labels/label[@lang="pl"])[1]'',''varchar(50)'') [FormaPlatnosci]
                                FROM      [finance].Payment p WITH(NOLOCK)
									JOIN dictionary.PaymentMethod m WITH(NOLOCK) ON p.paymentMethodId = m.id
                                WHERE     p.commercialDocumentHeaderId = @commercialDocumentHeaderId
                                FOR XML PATH(''platnosc''), TYPE  )
								FOR XML PATH(''platnosci''), TYPE
                            )
                FOR XML PATH(''fakturaSprzedazy''), TYPE
                ) ,
				(
				 SELECT f.fullNumber [NumerDokumentu], f.issueDate [DataWystawienia], f.amount [Kwota],  dbo.KwotaSlownie(CAST( f.amount AS int)) + '' złotych '' +  dbo.KwotaSlownie(CAST( f.amount*100 AS int)%100) + '' grosze'' [Slownie]
				 FROM finance.Payment p WITH(NOLOCK)
					 JOIN finance.PaymentSettlement s WITH(NOLOCK) ON p.id = s.outcomePaymentId
					 JOIN finance.Payment fp WITH(NOLOCK) ON s.incomePaymentId = fp.id
					 JOIN document.FinancialDocumentHeader f WITH(NOLOCK) ON f.id = fp.financialDocumentHeaderId
				 WHERE p.commercialDocumentHeaderId = @commercialDocumentHeaderId
				 FOR XML PATH(''kp''), TYPE
				),
				(
					SELECT (
					 SELECT pzh.fullNumber [NumerDokumentu], pzh.issueDate [DataDokumentu] , 
							pzl.ordinalNumber [NumerPozycji], i.Name [Nazwa], i.code [KodTowaru],pzl.quantity [Ilosc], 
							u.xmlLabels.value(''(labels/label[@lang="pl"]/@symbol)[1]'',''varchar(10)'') [Jednostka],
							pzl.price [CenaNetto], pzl.value [WartoscNetto],  dbo.KwotaSlownie(CAST( pzl.value AS int)) + '' złotych '' +  dbo.KwotaSlownie(CAST( pzl.value * 100 AS int)%100) + '' grosze'' [Slownie],
							c.fullName [Kontrahent]
										,c.nip [Nip]
										,(SELECT  a.address [Adres], a.addressNumber [Numer], a.city [Miasto], a.postCode [KodPocztowy], a.postOffice [Poczta]
                                          FROM      [contractor].ContractorAddress  a WITH(NOLOCK)
                                          WHERE     a.contractorId = c.id
										 FOR XML PATH(''adresKontrahenta''), TYPE)
					 FROM document.CommercialDocumentLine l WITH(NOLOCK) 
						JOIN document.CommercialWarehouseRelation r WITH(NOLOCK) ON l.id = r.commercialDocumentLineId
						JOIN document.WarehouseDocumentLine wl WITH(NOLOCK) ON wl.id = r.warehouseDocumentLineId
						JOIN document.IncomeOutcomeRelation ir WITH(NOLOCK) ON wl.id = ir.outcomeWarehouseDocumentLineId
						JOIN document.WarehouseDocumentLine pzl WITH(NOLOCK) ON ir.incomeWarehouseDocumentLineId = pzl.id
						JOIN document.WarehouseDocumentHeader pzh  WITH(NOLOCK) ON pzl.warehouseDocumentHeaderId = pzh.id
						JOIN contractor.Contractor c WITH(NOLOCK) ON pzh.contractorId = c.id
						JOIN item.Item i  WITH(NOLOCK) ON pzl.itemId = i.id
						JOIN dictionary.Unit u  WITH(NOLOCK) ON l.unitId = u.id
					 WHERE l.commercialDocumentHeaderId = @commercialDocumentHeaderId
					 
					 FOR XML PATH(''linie''), TYPE )
				 FOR XML PATH(''pz''), TYPE
				)
				,
				(
					SELECT (
					 SELECT fh.fullNumber [NumerDokumentu], fh.issueDate [DataDokumentu] , 
							fl.ordinalNumber [NumerPozycji], i.Name [Nazwa], i.code [KodTowaru],pzl.quantity [Ilosc], 
							u.xmlLabels.value(''(labels/label[@lang="pl"]/@symbol)[1]'',''varchar(10)'') [Jednostka],
							fl.netPrice [CenaNetto], fl.netValue [WartoscNetto], fl.vatValue [WartoscVat],   dbo.KwotaSlownie(CAST( fl.netValue AS int)) + '' złotych '' +  dbo.KwotaSlownie(CAST( fl.netValue * 100 AS int)%100) + '' grosze'' [Slownie],
							c.fullName [Kontrahent]
										,c.nip [Nip]
										,(SELECT  a.address [Adres], a.addressNumber [Numer], a.city [Miasto], a.postCode [KodPocztowy], a.postOffice [Poczta]
                                          FROM      [contractor].ContractorAddress  a WITH(NOLOCK)
                                          WHERE     a.id = fh.contractorAddressId
										 FOR XML PATH(''adresKontrahenta''), TYPE)
					FROM document.CommercialDocumentLine l WITH(NOLOCK) 
						JOIN document.CommercialWarehouseRelation r WITH(NOLOCK) ON l.id = r.commercialDocumentLineId
						JOIN document.WarehouseDocumentLine wl WITH(NOLOCK) ON wl.id = r.warehouseDocumentLineId
						JOIN document.IncomeOutcomeRelation ir WITH(NOLOCK) ON wl.id = ir.outcomeWarehouseDocumentLineId
						JOIN document.WarehouseDocumentLine pzl WITH(NOLOCK) ON ir.incomeWarehouseDocumentLineId = pzl.id
						JOIN document.CommercialWarehouseRelation cwr WITH(NOLOCK) ON pzl.id = cwr.warehouseDocumentLineId
						JOIN document.CommercialDocumentLine fl WITH(NOLOCK) ON cwr.commercialDocumentLineId  = fl.id
						JOIN document.CommercialDocumentHeader fh WITH(NOLOCK) ON fl.commercialDocumentHeaderId = fh.id
						JOIN contractor.Contractor c WITH(NOLOCK) ON fh.contractorId = c.id
						JOIN item.Item i WITH(NOLOCK) ON fl.itemId = i.id
						JOIN dictionary.Unit u  WITH(NOLOCK) ON fl.unitId = u.id
					 WHERE l.commercialDocumentHeaderId = @commercialDocumentHeaderId
					 
					 FOR XML PATH(''linie''), TYPE )
				 FOR XML PATH(''fz''), TYPE
				),
								(
					SELECT (
					 SELECT pzh.fullNumber [NumerDokumentu], pzh.issueDate [DataDokumentu] , 
							r.ordinalNumber [NumerPozycji], i.Name [Nazwa], i.code [KodTowaru],r.quantity [Ilosc], 
							u.xmlLabels.value(''(labels/label[@lang="pl"]/@symbol)[1]'',''varchar(10)'') [Jednostka],
							r.netPrice [CenaNetto], r.netValue [WartoscNetto],  dbo.KwotaSlownie(CAST( r.netValue AS int)) + '' złotych '' +  dbo.KwotaSlownie(CAST( r.netValue * 100 AS int)%100) + '' grosze'' [Slownie],
							c.fullName [Kontrahent]
										,c.nip [Nip]
										,(SELECT  a.address [Adres], a.addressNumber [Numer], a.city [Miasto], a.postCode [KodPocztowy], a.postOffice [Poczta]
                                          FROM      [contractor].ContractorAddress  a WITH(NOLOCK)
                                          WHERE     a.contractorId = c.id
										 FOR XML PATH(''adresKontrahenta''), TYPE)
					 FROM document.CommercialDocumentLine l WITH(NOLOCK) 
						JOIN document.CommercialDocumentLine r WITH(NOLOCK) ON l.id = r.correctedCommercialDocumentLineId
						JOIN document.CommercialDocumentHeader pzh  WITH(NOLOCK) ON r.CommercialDocumentHeaderId = pzh.id
						JOIN contractor.Contractor c WITH(NOLOCK) ON pzh.contractorId = c.id
						JOIN item.Item i  WITH(NOLOCK) ON r.itemId = i.id
						JOIN dictionary.Unit u  WITH(NOLOCK) ON l.unitId = u.id
					 WHERE l.commercialDocumentHeaderId = @commercialDocumentHeaderId
					 
					 FOR XML PATH(''linie''), TYPE )
				 FOR XML PATH(''korekty''), TYPE
				)

			FOR XML PATH(''root''), TYPE
			)
				
				as returnXML
			
    END
' 
END
GO
