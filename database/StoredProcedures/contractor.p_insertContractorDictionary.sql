/*
name=[contractor].[p_insertContractorDictionary]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
i6ERgnLXJBsWRV05PZv29A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertContractorDictionary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_insertContractorDictionary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertContractorDictionary]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [contractor].[p_insertContractorDictionary] @xmlVar XML
AS 

-- DECLARE @xmlVar XML

--SET @xmlVar = ''<root>
--  <contractor>
--    <entry>
--      <id>58EE4E77-7E4A-48D0-BDBF-1659D49C4986</id>
--      <code>cccp</code>
--      <isSupplier>1</isSupplier>
--      <isReceiver>1</isReceiver>
--      <isBusinessEntity>0</isBusinessEntity>
--      <isBank>0</isBank>
--      <isEmployee>0</isEmployee>
--      <isOwnCompany>0</isOwnCompany>
--      <fullName>Czarek Woźniak</fullName>
--      <shortName>Czarek Woźniak</shortName>
--      <nipPrefixCountryId>8C67F218-903D-4A1D-8D21-E8040E7DCBCC</nipPrefixCountryId>
--      <version>07533376-DCCD-4CED-95A4-FC6BD35BE5E9</version>
--    </entry>
--    <entry>
--      <id>C5832AAD-A549-4B73-93B3-268B0646B086</id>
--      <code />
--      <isSupplier>0</isSupplier>
--      <isReceiver>0</isReceiver>
--      <isBusinessEntity>0</isBusinessEntity>
--      <isBank>0</isBank>
--      <isEmployee>0</isEmployee>
--      <isOwnCompany>0</isOwnCompany>
--      <fullName>czarek</fullName>
--      <shortName>czarek</shortName>
--      <nipPrefixCountryId>8C67F218-903D-4A1D-8D21-E8040E7DCBCC</nipPrefixCountryId>
--      <version>70C9E8B1-CF24-415C-BABB-DD48CB772783</version>
--    </entry>
--    <entry>
--      <id>92475E28-23CD-46F6-909E-6AE8F5FCCFFF</id>
--      <code />
--      <isSupplier>0</isSupplier>
--      <isReceiver>0</isReceiver>
--      <isBusinessEntity>0</isBusinessEntity>
--      <isBank>0</isBank>
--      <isEmployee>0</isEmployee>
--      <isOwnCompany>0</isOwnCompany>
--      <fullName>jacek placek</fullName>
--      <shortName>jacek placek</shortName>
--      <nipPrefixCountryId>8C67F218-903D-4A1D-8D21-E8040E7DCBCC</nipPrefixCountryId>
--      <version>64320B7C-B74C-450D-B5E8-4DE5AC38DCBD</version>
--    </entry>
--  </contractor>
--  <employee />
--  <bank />
--  <applicationUser />
--  <contractorAddress>
--    <entry>
--      <id>D450CA79-9A23-46C5-B6EE-E9AFDC5450ED</id>
--      <contractorId>58EE4E77-7E4A-48D0-BDBF-1659D49C4986</contractorId>
--      <contractorFieldId>1C991154-00BA-4668-A359-43F726E98DDF</contractorFieldId>
--      <countryId>8C67F218-903D-4A1D-8D21-E8040E7DCBCC</countryId>
--      <city>Łódź</city>
--      <postCode>93-121</postCode>
--      <postOffice>Łódź</postOffice>
--      <address>Demokratyczna 46</address>
--      <version>7646D5C4-6F79-44BC-AD31-D9A7FF2081B2</version>
--      <order>1</order>
--    </entry>
--  </contractorAddress>
--  <contractorRelation>
--    <entry>
--      <id>85BA1DC1-3308-42E3-9E4E-1D44586BFB9A</id>
--      <contractorId>58EE4E77-7E4A-48D0-BDBF-1659D49C4986</contractorId>
--      <contractorRelationTypeId>9197E1CF-C601-483A-A367-B26D5E378ED4</contractorRelationTypeId>
--      <relatedContractorId>C5832AAD-A549-4B73-93B3-268B0646B086</relatedContractorId>
--      <version>7F89520B-1C20-4FEC-B18F-BDF32F25FA4F</version>
--      <order>1</order>
--      <relatedContractorOrder>0</relatedContractorOrder>
--    </entry>
--    <entry>
--      <id>3B390AFB-6AF7-465E-B265-58D8748CBE95</id>
--      <contractorId>58EE4E77-7E4A-48D0-BDBF-1659D49C4986</contractorId>
--      <contractorRelationTypeId>9197E1CF-C601-483A-A367-B26D5E378ED4</contractorRelationTypeId>
--      <relatedContractorId>92475E28-23CD-46F6-909E-6AE8F5FCCFFF</relatedContractorId>
--      <version>346D98E7-3FEC-4759-8D71-69FB3DD739B5</version>
--      <order>2</order>
--      <relatedContractorOrder>0</relatedContractorOrder>
--    </entry>
--  </contractorRelation>
--  <contractorGroupMembership />
--  <contractorAccount />
--  <contractorAttrValue>
--    <entry>
--      <id>FB345FB9-DD53-42B8-8397-26F3130C672F</id>
--      <contractorId>58EE4E77-7E4A-48D0-BDBF-1659D49C4986</contractorId>
--      <contractorFieldId>4A3E3275-2549-4BE1-945B-8FE8DC75D8E5</contractorFieldId>
--      <textValue>dupa</textValue>
--      <version>3D92A07D-0EBC-40EB-8FAC-5D31566B66AF</version>
--      <order>2</order>
--    </entry>
--    <entry>
--      <id>4E18EC92-B051-451D-AB19-D29943CE2332</id>
--      <contractorId>58EE4E77-7E4A-48D0-BDBF-1659D49C4986</contractorId>
--      <contractorFieldId>4A3E3275-2549-4BE1-945B-8FE8DC75D8E5</contractorFieldId>
--      <textValue>To ja d</textValue>
--      <version>3618A2E5-F854-44FA-82DD-22CE39F3235F</version>
--      <order>1</order>
--    </entry>
--  </contractorAttrValue>
--</root>''

    DECLARE @configuration XML,
        @value VARCHAR(1000),
        @id UNIQUEIDENTIFIER,
        @count INT,
        @i INT,
		@replaceConf VARCHAR(8000),
		@idoc int
declare @configuration2 xml


	/*Tabela do agregacji słów kluczowych*/	
	DECLARE @tmp_ TABLE (id UNIQUEIDENTIFIER, word NVARCHAR(1000))

	/*Tabela do wstawienia słów kluczowych*/	
	DECLARE @tmp_key TABLE (id UNIQUEIDENTIFIER, word NVARCHAR(1000), field NVARCHAR(1000), id_dictionary UNIQUEIDENTIFIER, id_dictionary_new UNIQUEIDENTIFIER, id_relation UNIQUEIDENTIFIER)


	/*Tabele indeksowane*/
	DECLARE @tmp_configuration TABLE ( i int identity(1,1), tableName varchar(100), columnName varchar(100),attributeName varchar(500), attributeFieldId char(36) )


	/*Dane indeksowane*/
	DECLARE @tmp_dane TABLE (  i int identity(1,1), columnName varchar(500), value nvarchar(max))
	
	DECLARE @tmp_dataXml TABLE (id int , parentId int,localname varchar(100), [text] nvarchar(max))

	
	/*Pobranie konfiguracji*/
    SELECT  @configuration2 = xmlValue
    FROM    configuration.Configuration c
    WHERE   c.[key] = ''Dictionary.configuration''
    

/*Fragment parsujący konfiguracje*/
	/*Przepisanie do tabeli całej konfiguracji*/
	EXEC sp_xml_preparedocument @idoc OUTPUT, @configuration2
	
		/*Pobranie listy tabel z konfiguracji*/
		INSERT INTO @tmp_configuration (  tableName ,columnName, attributeName )
		SELECT tableName, columnName, attributeName
		FROM OPENXML (@idoc, ''/root/indexing/object/table/column'', 1)
			WITH ( 
					objectName varchar(100)  ''../../@name'',
					tableName varchar(100)  ''../@name'',
					columnName varchar(100) ''@name'',
					attributeName varchar(500) ''../@attributeName''
					
				)
		WHERE objectName = ''contractor''
		
		
		SELECT @replaceConf = replaceConfiguration
		FROM OPENXML (@idoc, ''/root/indexing/object'')
		WITH (  replaceConfiguration varchar(8000) ''replaceConfiguration'',
				objectName varchar(100) ''@name'' 
			)
		WHERE objectName = ''contractor''
				
	EXEC sp_xml_removedocument @idoc
	
	UPDATE x
		SET x.attributeFieldId = cf.id
	FROM @tmp_configuration x
		JOIN dictionary.ContractorField cf ON x.attributeName = cf.name

/*Fragment parsujący dane indeksowane*/
	/*Przepisanie do tabeli danych*/
	


		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar
		
		SELECT @id = id
		FROM OPENXML (@idoc, N''/root/contractor/entry/id'')
			WITH( id uniqueidentifier ''.'')

 
		INSERT INTO @tmp_dataXml 
		SELECT id, parentId, localname, [text]
		FROM OPENXML (@idoc, N''/root/'', 1)
		
		INSERT INTO @tmp_dane( value )
		SELECT DISTINCT ISNULL(textValue,CAST(decimalValue AS varchar(50)))
		FROM OPENXML (@idoc, N''/root/contractorAttrValue/entry'', 1)
		WITH(
				contractorFieldId char(36) ''contractorFieldId'',
				textValue nvarchar(500) ''textValue'',
				decimalValue decimal(18,6) ''decimalValue''
			)
		WHERE contractorFieldId IN (SELECT attributeFieldId FROM @tmp_configuration WHERE attributeFieldId IS NOT NULL)
			

		EXEC sp_xml_removedocument @idoc
	
	INSERT INTO @tmp_dane( value )
	SELECT distinct x4.text 
	FROM @tmp_dataXml x1
		JOIN @tmp_configuration tab ON x1.localname = tab.tableName
		JOIN @tmp_dataXml x2 ON x1.id = x2.parentId
		JOIN @tmp_dataXml x3 ON x2.id = x3.parentId AND tab.columnName = x3.localname AND tab.attributeFieldId IS NULL
		JOIN @tmp_dataXml x4 ON x3.id = x4.parentId
	
		SELECT @count = COUNT(i), @i = 1 FROM @tmp_dane
		
		WHILE @i <= @count
			BEGIN
				SELECT @value = ISNULL(value ,'''')
				FROM @tmp_dane
				WHERE i = @i
				
				/*Wstawienie słownika*/
				INSERT INTO @tmp_ (id, word) 
				SELECT @id, ISNULL(word,'''') 
				FROM xp_split( [dbo].[f_replace2]( @value , @replaceConf) , '' '')
				WHERE ISNULL(word,'''') NOT IN ( SELECT word FROM @tmp_)
				
				SELECT @i = @i + 1
			END
--select @replaceConf
		/*Uproszczony sposób wstawiania dictionary*/

		/*Wybranie słów kluczowych i utworzenie kluczy dla tabel relacji*/
		INSERT INTO @tmp_key ( id,  word, field, id_dictionary,id_dictionary_new, id_relation)
		SELECT x.id, x.word, x.field, idField, newid(), newid() 
		FROM (
			SELECT  t.id, t.word, d.field, d.id idField
			FROM @tmp_ t 
				LEFT JOIN contractor.v_contractorDictionary d WITH(noexpand) ON t.word like d.field
			GROUP BY  t.id, t.word, d.field, d.id
			) x
			

		/*Wstawienie słów kluczowych*/
		INSERT INTO contractor.ContractorDictionary (id, field)
		SELECT DISTINCT id_dictionary_new, word 
		FROM @tmp_key 
		WHERE field IS NULL

		/*Wstawienie relacji do słów kluczowych*/
		INSERT INTO contractor.ContractorDictionaryRelation (id, contractorId, contractorDictionaryId)
		SELECT DISTINCT id_relation, id, ISNULL(id_dictionary,id_dictionary_new)  FROM @tmp_key
' 
END
GO
