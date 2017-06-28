/*
name=[custom].[p_getCommercialDocumentData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
aK0Bj0K89kkKi7KjQFxSBg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getCommercialDocumentData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_getCommercialDocumentData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getCommercialDocumentData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [custom].[p_getCommercialDocumentData]  --''330D0544-2151-4A1B-89D4-A7754CF04A6D''
   @commercialDocumentHeaderId UNIQUEIDENTIFIER -- = ''330D0544-2151-4A1B-89D4-A7754CF04A6D''

AS 
 BEGIN

 

 DECLARE @techID UNIQUEIDENTIFIER, @technologyField  UNIQUEIDENTIFIER, @productionOrder UNIQUEIDENTIFIER,  @returnXml varchar(max),
		@mainItem UNIQUEIDENTIFIER, @materialItem UNIQUEIDENTIFIER, @packageItem UNIQUEIDENTIFIER,
		@mainQty numeric(16,4), @materialQty numeric(16,4), @packageQty numeric(16,4),
		@mainName nvarchar(500),@materialName nvarchar(500),@packageName nvarchar(500),
		@mainCode nvarchar(500),@materialCode nvarchar(500), @packageCode nvarchar(500),
		@mainUnit UNIQUEIDENTIFIER, @materialUnit UNIQUEIDENTIFIER, @packageUnit UNIQUEIDENTIFIER


	 IF EXISTS( SELECT itemId FROM custom.TechnologyRequests WHERE technologyId = @commercialDocumentHeaderId)
		BEGIN

			 SELECT @technologyField = id FROM dictionary.DocumentField  WITH(NOLOCK) WHERE name = ''LineAttribute_ProductionTechnologyName''
			 SELECT @mainItem = itemId FROM custom.TechnologyRequests  WITH(NOLOCK) WHERE technologyId = @commercialDocumentHeaderId
			
			 /*Pobranie info o zleceniu produkcyjnym jeśli została użyta */
			 SELECT @productionOrder = (SELECT TOP 1 commercialDocumentHeaderId FROM document.CommercialDocumentLine  WITH(NOLOCK) WHERE id =  v.commercialDocumentLineId )
			 FROM document.DocumentLineAttrValue v WITH(NOLOCK)
			 WHERE v.documentFieldId = @technologyField AND  v.textValue = CAST(@commercialDocumentHeaderId as varchar(500))
			 

			 /*Pobranie info o opakowaniu*/
			 SELECT @packageItem = id, @packageName = name , @packageCode = code, @packageUnit = unitId
			 FROM item.Item  WITH(NOLOCK)
			 WHERE code = (SELECT textValue FROM item.ItemAttrValue  WITH(NOLOCK) WHERE itemId = @mainItem AND itemFieldId = (SELECT id FROM dictionary.ItemField  WITH(NOLOCK) WHERE name = ''Attribute_ItemPackageType''))

			 /*Pobranie info o produkcie*/
			 SELECT @mainQty = l.quantity ,@mainName = i.name , @mainCode = i.code, @mainUnit = i.unitId
			 FROM document.CommercialDocumentLine l 
				JOIN item.Item i  WITH(NOLOCK) ON l.itemId = i.id
				LEFT JOIN document.DocumentLineAttrValue v WITH(NOLOCK) ON l.id = v.commercialDocumentLineId --AND v.documentFieldId = ''v''
			 WHERE l.commercialDocumentHeaderId = @productionOrder 
				AND v.textValue = CAST(@commercialDocumentHeaderId as varchar(36))
				AND i.id = @mainItem


			SELECT @materialItem = i.id, @materialName = i.name, @materialCode = i.code , @materialUnit = i.unitId
				, @materialQty = CAST( REPLACE(RIGHT(v.textValue,2),''/'','''')  as float) /	CAST(REPLACE(LEFT(v.textValue,2) ,''/'','''') as float)
			FROM item.ItemRelation r WITH(NOLOCK)
				LEFT JOIN item.Item i  WITH(NOLOCK) ON r.itemId = i.id
				LEFT JOIN item.ItemAttrValue v  WITH(NOLOCK) ON r.relatedObjectId = v.itemId 
			WHERE r.itemRelationTypeId = ''7D55BC8E-7BAD-4166-9E32-A64D1C0E3A91''
				AND r.relatedObjectId = @mainItem
				AND v.itemFieldId = (SELECT id FROM dictionary.ItemField WHERE name = ''Attribute_ConversionRate'')
	

			
			SELECT  @returnXml =  ''<root>
			  <commercialDocumentHeader>
				<entry>
				  <id>''+ CAST(@commercialDocumentHeaderId as varchar(36)) +''</id>
				  <documentTypeId>D4772749-656C-4BC6-A790-C36D85729DBF</documentTypeId>
				  <companyId>26F958D1-06D7-4CDB-8002-9205F5871BE3</companyId>
				  <branchId>1225C626-C6CD-4CED-A6AC-FA3439E66963</branchId>
				  <issuingPersonContractorId>08E5B4A8-C430-47CB-BEEA-76AD1DD443F7</issuingPersonContractorId>
				  <issuerContractorId>26F958D1-06D7-4CDB-8002-9205F5871BE3</issuerContractorId>
				  <issuerContractorAddressId>D41FB439-D5D8-426F-B273-FD2EEA53A0F8</issuerContractorAddressId>
				  <documentCurrencyId>F01007BF-1ADA-4218-AE77-52C106DA4105</documentCurrencyId>
				  <systemCurrencyId>F01007BF-1ADA-4218-AE77-52C106DA4105</systemCurrencyId>
				  <exchangeDate>2013-11-25T13:08:46.843</exchangeDate>
				  <exchangeScale>1</exchangeScale>
				  <exchangeRate>1.000000</exchangeRate>
				  <number>1</number>
				  <fullNumber>Numer</fullNumber>
				  <issuePlaceId>D70BBE12-6E80-48E5-8123-77B5FC1A20A3</issuePlaceId>
				  <issueDate>2013-11-26T13:24:33.033</issueDate>
				  <eventDate>2013-11-26T13:24:33.033</eventDate>
				  <netValue>0.00</netValue>
				  <grossValue>0.00</grossValue>
				  <vatValue>0.00</vatValue>
				  <xmlConstantData>
					<constant>
					  <issuer>
						<shortName>Firma</shortName>
						<fullName>Firma</fullName>
						<version>272B1641-91BF-4969-87A7-2A2F1B6A6AA8</version>
						<nip>123123123</nip>
						<nipPrefixCountrySymbol>PL</nipPrefixCountrySymbol>
						<addresses>
						  <address>
							<version>B47C09AB-36C6-4D2A-9987-73E954B977DF</version>
							<id>D41FB439-D5D8-426F-B273-FD2EEA53A0F8</id>
							<countryId>8C67F218-903D-4A1D-8D21-E8040E7DCBCC</countryId>
							<postOffice>Warszawa</postOffice>
							<postCode>11-111</postCode>
							<city>Warszawa</city>
							<address>Kowalsa</address>
							<contractorFieldId>36BF2FB3-9D77-43F1-93B9-519CD389DC14</contractorFieldId>
							<order>1</order>
						  </address>
						</addresses> ''
						SELECT @returnXml = @returnXml + ''
						<accounts>
						  <account>
							<version>00681DA7-74D6-401C-870E-0CC3D0FBBDAB</version>
							<id>46C0CD3A-3C5A-44E9-B9CC-E08B0DC5E7E0</id>
							<accountNumber>07175010930000000001380777</accountNumber>
							<order>1</order>
						  </account>
						</accounts>
						<attributes>
						  <attribute>
							<version>DCA81D2C-BCD0-440B-8242-763686AF452A</version>
							<id>EA37792D-2607-4C97-97F5-B05C93AB7B3F</id>
							<value>+48 42-617-23-22</value>
							<contractorFieldId>D950E01D-5221-4711-96F2-A84F20435581</contractorFieldId>
							<order>1</order>
						  </attribute>
						  <attribute>
							<version>90263754-5FF3-45CC-A559-121CCC4EB3BB</version>
							<id>00B930A3-37BD-4DF9-B5ED-76EA4E070661</id>
							<value>adres</value>
							<contractorFieldId>356AFECD-99E6-4D0B-9F27-D802AE116C1C</contractorFieldId>
							<order>2</order>
						  </attribute>
						</attributes>
					  </issuer>
					  <issuingPerson>
						<shortName>Makolab Administrator</shortName>
						<fullName>Makolab Administrator</fullName>
						<version>61A23B03-9DBC-43E4-B67C-97797ED5CA31</version>
						<addresses />
					  </issuingPerson>
					</constant>
				  </xmlConstantData>
				  <isExportedForAccounting>0</isExportedForAccounting>
				  <netCalculationType>1</netCalculationType>
				  <vatRatesSummationType>1</vatRatesSummationType>
				  <creationDate>2013-11-26T13:24:31.973</creationDate>
				  <modificationApplicationUserId>08E5B4A8-C430-47CB-BEEA-76AD1DD443F7</modificationApplicationUserId>
				  <version>0334E09B-B657-4B3E-A844-6431A2FDF4A1</version>
				  <seriesId>C2B5942D-FDE5-4902-82E8-BE74A092F340</seriesId>
				  <status>40</status>
				  <sysNetValue>0.00</sysNetValue>
				  <sysGrossValue>0.00</sysGrossValue>
				  <sysVatValue>0.00</sysVatValue>
				  <numberSettingId>781EF7B3-2DAF-41F0-83F0-8D0699E4216E</numberSettingId>
				</entry>
			  </commercialDocumentHeader>
			  <commercialDocumentLine>
				<entry>
				  <id>E174A67F-92B6-42EF-A4C2-3DAEB0653CCB</id>
				  <commercialDocumentHeaderId>''+ CAST(@commercialDocumentHeaderId as varchar(36)) +''</commercialDocumentHeaderId>
				  <ordinalNumber>2</ordinalNumber>
				  <commercialDirection>0</commercialDirection>
				  <orderDirection>0</orderDirection>
				  <unitId>''+CAST(@mainUnit as varchar(36))+''</unitId>
				  <itemId>''+CAST(@mainItem as varchar(36))+''</itemId>
				  <warehouseId>92EB83AD-E84C-4DA9-A025-3BB8F6F04AEF</warehouseId>
				  <itemVersion>A8A97C8F-B618-40DE-A398-54EF6DB3E4CE</itemVersion>
				  <quantity>1.000000</quantity>
				  <netPrice>0.00</netPrice>
				  <grossPrice>0.00</grossPrice>
				  <initialNetPrice>417.91</initialNetPrice>
				  <initialGrossPrice>0.00</initialGrossPrice>
				  ''
				  SELECT @returnXml = @returnXml + ''
				  <discountRate>0.00</discountRate>
				  <discountNetValue>0.00</discountNetValue>
				  <discountGrossValue>0.00</discountGrossValue>
				  <initialNetValue>0.00</initialNetValue>
				  <initialGrossValue>0.00</initialGrossValue>
				  <netValue>0.00</netValue>
				  <grossValue>0.00</grossValue>
				  <vatValue>0.00</vatValue>
				  <vatRateId>390E10FC-82C5-41CB-9BD0-29059CB4872D</vatRateId>
				  <version>F3334591-6B0A-441C-BC33-35AE164FF04F</version>
				  <itemName>''+@mainName+''</itemName>
				  <sysNetValue>0.00</sysNetValue>
				  <sysGrossValue>0.00</sysGrossValue>
				  <sysVatValue>0.00</sysVatValue>
				  <itemCode>''+ @mainCode +''</itemCode>
				  <itemTypeId>DD659840-E90E-4C28-8774-4D07B307909A</itemTypeId>
				</entry>
				<entry>
				  <id>E48540C9-393E-40C9-8D99-C050CEAAD6B6</id>
				  <commercialDocumentHeaderId>''+ CAST(@commercialDocumentHeaderId as varchar(36)) +''</commercialDocumentHeaderId>
				  <ordinalNumber>3</ordinalNumber>
				  <commercialDirection>0</commercialDirection>
				  <orderDirection>0</orderDirection>
				  <unitId>''+CAST(@packageUnit as varchar(36))+''</unitId>
				  <itemId>''+ CAST(@packageItem as varchar(36)) + ''</itemId>
				  <warehouseId>92EB83AD-E84C-4DA9-A025-3BB8F6F04AEF</warehouseId>
				  <itemVersion>591D0083-4C0A-4D54-892A-5584FAF0B470</itemVersion>
				  <quantity>1.000000</quantity>
				  <netPrice>0.00</netPrice>
				  <grossPrice>0.00</grossPrice>
				  <initialNetPrice>1.00</initialNetPrice>
				  <initialGrossPrice>0.00</initialGrossPrice>
				  <discountRate>0.00</discountRate>
				  <discountNetValue>0.00</discountNetValue>
				  <discountGrossValue>0.00</discountGrossValue>
				  <initialNetValue>0.00</initialNetValue>
				  <initialGrossValue>0.00</initialGrossValue>
				  <netValue>0.00</netValue>
				  <grossValue>0.00</grossValue>
				  <vatValue>0.00</vatValue>
				  <vatRateId>390E10FC-82C5-41CB-9BD0-29059CB4872D</vatRateId>
				  <version>6A04274C-172D-4311-936F-0FABF075FCA2</version>
				  <itemName>''+ @packageName +''</itemName>
				  <sysNetValue>0.00</sysNetValue>
				  <sysGrossValue>0.00</sysGrossValue>
				  <sysVatValue>0.00</sysVatValue>
				  <itemCode>'' + @packageCode + ''</itemCode>
				  <itemTypeId>DD659840-E90E-4C28-8774-4D07B307909A</itemTypeId>
				</entry>
				<entry>
				  <id>92CB2B1D-092A-46AA-AAB1-C77A798512CA</id>
				  <commercialDocumentHeaderId>''+ CAST(@commercialDocumentHeaderId as varchar(36)) +''</commercialDocumentHeaderId>
				  <ordinalNumber>1</ordinalNumber>
				  <commercialDirection>0</commercialDirection>
				  <orderDirection>0</orderDirection>
				  <unitId>''+CAST(@materialUnit as varchar(36))+''</unitId>
				  <itemId>''+CAST(@materialItem as varchar(36))+''</itemId>
				  <warehouseId>92EB83AD-E84C-4DA9-A025-3BB8F6F04AEF</warehouseId>
				  <itemVersion>80107BA9-A3A1-4AD6-B576-D73172F19A09</itemVersion>
				  <quantity>''+CAST(@materialQty as varchar(50))+''</quantity>
				  <netPrice>0.00</netPrice>
				  <grossPrice>0.00</grossPrice>
				  ''
				  SELECT @returnXml = @returnXml + ''
				  <initialNetPrice>25.00</initialNetPrice>
				  <initialGrossPrice>0.00</initialGrossPrice>
				  <discountRate>0.00</discountRate>
				  <discountNetValue>0.00</discountNetValue>
				  <discountGrossValue>0.00</discountGrossValue>
				  <initialNetValue>0.00</initialNetValue>
				  <initialGrossValue>0.00</initialGrossValue>
				  <netValue>0.00</netValue>
				  <grossValue>0.00</grossValue>
				  <vatValue>0.00</vatValue>
				  <vatRateId>390E10FC-82C5-41CB-9BD0-29059CB4872D</vatRateId>
				  <version>5EBAC8C9-EB7A-4603-AFDD-C17C636A09BC</version>
				  <itemName>''+@materialName+''</itemName>
				  <sysNetValue>0.00</sysNetValue>
				  <sysGrossValue>0.00</sysGrossValue>
				  <sysVatValue>0.00</sysVatValue>
				  <itemCode>''+@materialCode+''</itemCode>
				  <itemTypeId>DD659840-E90E-4C28-8774-4D07B307909A</itemTypeId>
				</entry>
			  </commercialDocumentLine>
			  <commercialDocumentVatTable />
			  <documentAttrValue>
				<entry>
				  <id>C6E86134-3097-4294-A2F2-60AA50569083</id>
				  <commercialDocumentHeaderId>''+ CAST(@commercialDocumentHeaderId as varchar(36)) +''</commercialDocumentHeaderId>
				  <documentFieldId>1B4229FC-684B-420C-973C-466EA01CFC2D</documentFieldId>
				  <textValue>''+@packageName+''</textValue>
				  <version>B9B58F2A-C7F3-4DB3-B0AA-7EA218813D99</version>
				  <order>1</order>
				</entry>
			  </documentAttrValue>
			  <documentLineAttrValue>
				<entry>
				  <id>7850ACA3-A8C7-4668-8521-7358E71EFA22</id>
				  <commercialDocumentLineId>E48540C9-393E-40C9-8D99-C050CEAAD6B6</commercialDocumentLineId>
				  <documentFieldId>FE937FDC-F862-482E-BF06-0171FB1B0FE7</documentFieldId>
				  <textValue>material</textValue>
				  <version>EB6D02D9-CC8E-4EAB-B9FB-1355B27B004B</version>
				  <order>1</order>
				</entry>
				<entry>
				  <id>0BB47553-F559-4505-B72A-8BEEE3BF2ADD</id>
				  <commercialDocumentLineId>E174A67F-92B6-42EF-A4C2-3DAEB0653CCB</commercialDocumentLineId>
				  <documentFieldId>FE937FDC-F862-482E-BF06-0171FB1B0FE7</documentFieldId>
				  <textValue>product</textValue>
				  <version>70AEBAC8-E2B5-4730-9624-7C7FE8097645</version>
				  <order>1</order>
				</entry>
				''
				SELECT @returnXml = @returnXml + ''
				<entry>
				  <id>7B2F2293-70A1-4929-8B62-DDAB03772360</id>
				  <commercialDocumentLineId>92CB2B1D-092A-46AA-AAB1-C77A798512CA</commercialDocumentLineId>
				  <documentFieldId>FE937FDC-F862-482E-BF06-0171FB1B0FE7</documentFieldId>
				  <textValue>material</textValue>
				  <version>96F250E0-A2FF-44B8-987B-95EE0B6201F3</version>
				  <order>1</order>
				</entry>
			  </documentLineAttrValue>
			  <payment />
			  <commercialWarehouseValuation />
			  <documentRelation />
			  <commercialWarehouseRelation />
			  <contractor>
				<entry>
				  <id>08E5B4A8-C430-47CB-BEEA-76AD1DD443F7</id>
				  <code />
				  <isSupplier>1</isSupplier>
				  <isReceiver>1</isReceiver>
				  <isBusinessEntity>1</isBusinessEntity>
				  <isBank>0</isBank>
				  <isEmployee>0</isEmployee>
				  <isOwnCompany>0</isOwnCompany>
				  <fullName>Makolab Administrator</fullName>
				  <shortName>Makolab Administrator</shortName>
				  <nipPrefixCountryId>8C67F218-903D-4A1D-8D21-E8040E7DCBCC</nipPrefixCountryId>
				  <version>61A23B03-9DBC-43E4-B67C-97797ED5CA31</version>
				</entry>
				<entry>
				  <id>26F958D1-06D7-4CDB-8002-9205F5871BE3</id>
				  <code>0001</code>
				  <isSupplier>1</isSupplier>
				  <isReceiver>1</isReceiver>
				  <isBusinessEntity>1</isBusinessEntity>
				  <isBank>0</isBank>
				  <isEmployee>0</isEmployee>
				  <isOwnCompany>1</isOwnCompany>
				  <fullName>Firma</fullName>
				  <shortName>Firma</shortName>
				  <nip>111111111</nip>
				  <strippedNip>11111111</strippedNip>
				  <nipPrefixCountryId>8C67F218-903D-4A1D-8D21-E8040E7DCBCC</nipPrefixCountryId>
				  <version>272B1641-91BF-4969-87A7-2A2F1B6A6AA8</version>
				  <creationDate>2011-08-31T10:44:00</creationDate>
				  <modificationDate>2013-11-20T15:50:11.333</modificationDate>
				  <modificationUserId>08E5B4A8-C430-47CB-BEEA-76AD1DD443F7</modificationUserId>
				</entry>
			  </contractor>
			  <contractorAccount>
				<entry>
				  <id>46C0CD3A-3C5A-44E9-B9CC-E08B0DC5E7E0</id>
				  <contractorId>26F958D1-06D7-4CDB-8002-9205F5871BE3</contractorId>
				  <accountNumber>07175010930000000001380777</accountNumber>
				  <version>00681DA7-74D6-401C-870E-0CC3D0FBBDAB</version>
				  <order>1</order>
				</entry>
			  </contractorAccount>
			  <contractorRelation />
			  <contractorAddress>
				<entry>
				  <id>D41FB439-D5D8-426F-B273-FD2EEA53A0F8</id>
				  <contractorId>26F958D1-06D7-4CDB-8002-9205F5871BE3</contractorId>
				  <contractorFieldId>36BF2FB3-9D77-43F1-93B9-519CD389DC14</contractorFieldId>
				  <countryId>8C67F218-903D-4A1D-8D21-E8040E7DCBCC</countryId>
				  <city>Warszawa</city>
				  <postCode>91-726</postCode>
				  <postOffice>Warszawa</postOffice>
				  <address>adres</address>
				  <version>B47C09AB-36C6-4D2A-9987-73E954B977DF</version>
				  <order>1</order>
				</entry>
			  </contractorAddress>
			  <contractorAttrValue />
			  <paymentSettlement />
			</root>'' 

			SELECT CAST(@returnXml as xml)
		END
	ELSE
		/*Budowanie XML z kompletem informacji o dokumencie*/
        SELECT  ( SELECT    ( SELECT    ( SELECT    CDL.*,  s.[numberSettingId]
                                          FROM      [document].CommercialDocumentHeader CDL 
											LEFT JOIN document.Series s ON CDL.seriesId = s.id
                                          WHERE     CDL.id = @commercialDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''commercialDocumentHeader''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT   CommercialDocumentLine.*, Item.code itemCode, Item.itemTypeId itemTypeId
                                          FROM      [document].CommercialDocumentLine 
											JOIN item.Item ON CommercialDocumentLine.itemId = item.id
                                          WHERE     commercialDocumentHeaderId = @commercialDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''commercialDocumentLine''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [document].CommercialDocumentVatTable
                                          WHERE     commercialDocumentHeaderId = @commercialDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''commercialDocumentVatTable''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [document].DocumentAttrValue
                                          WHERE     commercialDocumentHeaderId = @commercialDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''documentAttrValue''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [document].DocumentLineAttrValue
                                          WHERE     commercialDocumentLineId IN (SELECT id FROM document.CommercialDocumentLine WHERE commercialDocumentHeaderId = @commercialDocumentHeaderId )
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''documentLineAttrValue''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [finance].Payment
                                          WHERE     commercialDocumentHeaderId = @commercialDocumentHeaderId
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''payment''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [document].CommercialWarehouseValuation
                                          WHERE     commercialDocumentLineId IN (
																		SELECT id 
																		FROM document.CommercialDocumentLine 
																		WHERE CommercialDocumentHeaderId = @commercialDocumentHeaderId
																				)
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''commercialWarehouseValuation''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [document].DocumentRelation
                                          WHERE     @commercialDocumentHeaderId IN (firstCommercialDocumentHeaderId, secondCommercialDocumentHeaderId)
												
	                                      FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR XML PATH(''documentRelation''), TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [document].CommercialWarehouseRelation
                                          WHERE     commercialDocumentLineId IN (
																		SELECT id 
																		FROM document.CommercialDocumentLine 
																		WHERE CommercialDocumentHeaderId = @commercialDocumentHeaderId
																				)
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''commercialWarehouseRelation''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [contractor].Contractor
                                          WHERE     id = ( SELECT   contractorId
                                                           FROM     [document].CommercialDocumentHeader
                                                           WHERE    id = @commercialDocumentHeaderId
                                                         )
                                                    OR id = ( SELECT    receivingPersonContractorId
                                                              FROM      [document].CommercialDocumentHeader
                                                              WHERE     id = @commercialDocumentHeaderId
                                                            )
                                                    OR id = ( SELECT    issuingPersonContractorId
                                                              FROM      [document].CommercialDocumentHeader
                                                              WHERE     id = @commercialDocumentHeaderId
                                                            )
                                                    OR id = ( SELECT    issuerContractorId
                                                              FROM      [document].CommercialDocumentHeader
                                                              WHERE     id = @commercialDocumentHeaderId
                                                            )
                                                    OR id IN ( SELECT  contractorId
															   FROM    [finance].Payment
															   WHERE   commercialDocumentHeaderId = @commercialDocumentHeaderId 
															)
                                                    OR id IN ( SELECT  relatedContractorId
															   FROM    contractor.ContractorRelation
															   WHERE   ContractorId = ( SELECT   contractorId
																						FROM     [document].CommercialDocumentHeader
																						WHERE    id = @commercialDocumentHeaderId
																					)
															)
		
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''contractor''),
                                  TYPE
                            ), 
						( SELECT ( 
								SELECT * 
								FROM contractor.ContractorAccount
								WHERE contractorId = (
															  SELECT    issuerContractorId
                                                              FROM      [document].CommercialDocumentHeader
                                                              WHERE     id = @commercialDocumentHeaderId
													)
								FOR XML PATH(''entry''), TYPE
										 )
                            FOR XML PATH(''contractorAccount''), TYPE                    
						),
						( SELECT    (  SELECT    *
									   FROM    contractor.ContractorRelation
									   WHERE   ContractorId = ( SELECT   contractorId
																FROM     [document].CommercialDocumentHeader
																WHERE    id = @commercialDocumentHeaderId
															)
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''contractorRelation''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [contractor].ContractorAddress
                                          WHERE     id = ( SELECT   contractorAddressId
                                                           FROM     [document].CommercialDocumentHeader
                                                           WHERE    id = @commercialDocumentHeaderId
                                                         )
                                                    OR id = ( SELECT    issuerContractorAddressId
                                                              FROM      [document].CommercialDocumentHeader
                                                              WHERE     id = @commercialDocumentHeaderId
                                                            )
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''contractorAddress''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [contractor].ContractorAttrValue
                                          WHERE     contractorid IN ( 
															SELECT   contractorId
															FROM     [document].CommercialDocumentHeader
															WHERE    id = @commercialDocumentHeaderId
                                                         UNION
                                                            SELECT    issuerContractorAddressId
                                                            FROM      [document].CommercialDocumentHeader
                                                            WHERE     id = @commercialDocumentHeaderId
                                                            )
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''contractorAttrValue''),
                                  TYPE
                            ),
                            ( SELECT    ( SELECT    *
                                          FROM      [finance].PaymentSettlement
                                          WHERE     incomePaymentId IN (
                                                    SELECT  id
                                                    FROM    [finance].Payment
                                                    WHERE   commercialDocumentHeaderId = @commercialDocumentHeaderId )
                                                    OR outcomePaymentId IN (
                                                    SELECT  id
                                                    FROM    [finance].Payment
                                                    WHERE   commercialDocumentHeaderId = @commercialDocumentHeaderId )
                                        FOR
                                          XML PATH(''entry''),
                                              TYPE
                                        )
                            FOR
                              XML PATH(''paymentSettlement''),
                                  TYPE
                            )
                FOR
                  XML PATH(''root''),
                      TYPE
                ) AS returnsXML
    END
' 
END
GO
