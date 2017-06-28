/*
name=[tools].[p_contractorImport]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
RunXIfLTnc+oeW3vgW1xyg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_contractorImport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_contractorImport]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_contractorImport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tools].[p_contractorImport]
@xmlVar XML
AS
BEGIN

 DECLARE @snap XML,
         @errorMsg VARCHAR(2000),
         @rowcount INT,
		 @id UNIQUEIDENTIFIER,
		 @name NVARCHAR(500)

	/*pobranie contractorId*/
	SELECT @id = con.query(''id'').value(''.'', ''char(36)''),
		   @name = con.query(''fullName'').value(''.'', ''nvarchar(500)'')
	FROM    @xmlVar.nodes(''/root/contractors/entry/contractor'') AS C ( con )


	/*Wstawienie danych o kontrachencie*/
    INSERT  INTO contractor.Contractor ( id,code,isSupplier,isReceiver, isBusinessEntity,isBank,fullName, shortName,nip, strippedNip, nipPrefixCountryId,isOwnCompany, version )
            SELECT  con.query(''id'').value(''.'', ''char(36)''),
                    con.query(''code'').value(''.'', ''varchar(50)''),
                    con.query(''isSupplier'').value(''.'', ''bit''),
                    con.query(''isReceiver'').value(''.'', ''bit''),
                    con.query(''isBusinessEntity'').value(''.'', ''bit''),
                    con.query(''isBank'').value(''.'', ''bit''),
                    con.query(''fullName'').value(''.'', ''varchar(500)''),
                    con.query(''shortName'').value(''.'', ''varchar(40)''),
                    NULLIF(con.query(''nip'').value(''.'', ''nvarchar(40)''), ''''),
                    REPLACE(REPLACE(NULLIF(con.query(''nip'').value(''.'', ''nvarchar(40)''),''''), ''-'', ''''), '' '', ''''),
                    co.id,
                    con.query(''isOwnCompany'').value(''.'', ''char(36)''),
                    newid()
            FROM    @xmlVar.nodes(''/root/contractors/entry/contractor'') AS C ( con )
				JOIN dictionary.Country co ON co.symbol = con.query(''nipPrefixCountry'').value(''.'', ''varchar(50)'')
		IF @@rowcount = 0
			RAISERROR ( 50011, 16, 1 );


	/*Wstawienie danych o adresach kontrahenta*/
   INSERT  INTO contractor.ContractorAddress (id,contractorId, contractorFieldId,address,city,postCode,postOffice,countryId,version, [order] )
            SELECT  NEWID(),
                    @id,
                    f.id,
                    con.query(''address'').value(''.'', ''nvarchar(300)''),
                    con.query(''city'').value(''.'', ''nvarchar(50)''),
                    con.query(''postCode'').value(''.'', ''nvarchar(30)''),
                    con.query(''postOffice'').value(''.'', ''nvarchar(50)''),
                    co.id,
                    newid(),
                    1
            FROM    @xmlVar.nodes(''/root/contractors/entry/contractorAddress'') AS C ( con )
			 JOIN   dictionary.ContractorField f ON f.name = con.query(''contractorField'').value(''.'', ''varchar(50)'')
			 JOIN dictionary.Country co ON co.symbol = con.query(''country'').value(''.'', ''varchar(50)'')
		IF @@rowcount = 0
			PRINT ''Kontrachent :'' + @name + '' błąd wstawienia adresu, lub brak adresu'';

    /*Wstawienie danych o atrybutach kontrahenta*/
    INSERT  INTO contractor.ContractorAttrValue ( id,contractorId,contractorFieldId,decimalValue,dateValue,textValue,xmlValue,version,[order] )
            SELECT  NEWID(),
                    @id,
                    f.id,
                    CASE WHEN   (con.value(''(@type)[1]'', ''char(36)'') = ''integer'') OR (con.value(''(@type)[1]'', ''char(36)'') = ''boolean'')  THEN   NULLIF(con.value(''.'', ''varchar(500)''),'''') END ,
					CASE WHEN   con.value(''(@type)[1]'', ''char(36)'') = ''date'' THEN   NULLIF(con.value(''.'', ''varchar(500)''),'''') END ,
                    CASE WHEN   con.value(''(@type)[1]'', ''char(36)'') = ''string'' THEN  NULLIF(con.value(''.'', ''varchar(500)''),'''') END ,
					CASE WHEN   con.value(''(@type)[1]'', ''char(36)'') = ''xml'' THEN   con.query(''contractorAttribute/*'') END ,
                    NEWID(),
                    con.query(''order'').value(''.'', ''int'')
            FROM    @xmlVar.nodes(''/root/contractors/entry/contractorAttribute'') AS C ( con )
				JOIN dictionary.ContractorField f ON f.name = con.value(''(@name)[1]'', ''varchar(50)'')
		IF @@rowcount = 0
			PRINT ''Kontrachent :'' + @name + '' błąd wstawienia atrybutu, lub brak atrybutu'';



        SELECT  @snap = ( SELECT   
                                    ( SELECT    ( SELECT DISTINCT
                                                            c.*
                                                  FROM      contractor.Contractor c
                                                  WHERE     c.id = @id
                                                FOR XML PATH(''entry''), TYPE
                                                )
                                    FOR XML PATH(''contractor''), TYPE
                                    ),
                                    ( SELECT    ( SELECT    *
                                                  FROM      contractor.Employee
                                                  WHERE     contractorId = @id
                                                FOR XML PATH(''entry''),  TYPE
                                                )
                                    FOR XML PATH(''employee''), TYPE
                                    ),
                                    ( SELECT    ( SELECT    *
                                                  FROM      contractor.Bank
                                                  WHERE     contractorId = @id
                                                FOR XML PATH(''entry''), TYPE
                                                )
                                    FOR XML PATH(''bank''), TYPE
                                    ),
                                    ( SELECT    ( SELECT    *
                                                  FROM      contractor.ContractorAddress
                                                  WHERE     contractorId = @id
                                                FOR XML PATH(''entry''), TYPE
                                                )
                                    FOR XML PATH(''contractorAddress''), TYPE
                                    ),
                                    ( SELECT    ( SELECT    *
                                                  FROM      contractor.ContractorAccount
                                                  WHERE     contractorId = @id
                                                FOR XML PATH(''entry''), TYPE
                                                )
                                    FOR XML PATH(''contractorAccount''),  TYPE
                                    ),
                                    ( SELECT    ( SELECT    *
                                                  FROM      contractor.ContractorAttrValue
                                                  WHERE     contractorId = @id
                                                FOR XML PATH(''entry''),  TYPE
                                                )
                                    FOR XML PATH(''contractorAttrValue''), TYPE
                                    )
                        FOR XML PATH(''root''), TYPE
                        )

	EXEC contractor.p_insertContractorDictionary @snap

END


--
--EXEC contractor.p_insertContractorDictionary @xmlVar
--select * from dictionary.ContractorField
' 
END
GO
