/*
name=[contractor].[p_updateContractorRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
PcDbVxczhx1gLQzVu+LTNw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_updateContractorRelation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_updateContractorRelation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_updateContractorRelation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_updateContractorRelation]
@xmlVar XML
AS
BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT,
			@error int 
    
	BEGIN TRY
        
        /*Aktualizacja danych o Powiązaniach kontrahenta*/
        UPDATE  contractor.ContractorRelation
        SET     contractorId = con.value(''(contractorId)[1]'', ''char(36)''),
                contractorRelationTypeId = con.value(''(contractorRelationTypeId)[1]'', ''char(36)''),
                relatedContractorId = con.value(''(relatedContractorId)[1]'', ''char(36)''),
                xmlAttributes = con.query(''xmlAttributes/*''),
                [version] = ISNULL(con.value(''(_version)[1]'', ''char(36)''),con.value(''(version)[1]'', ''char(36)'')),
                [order] = con.value(''(order)[1]'', ''int''),
                [relatedContractorOrder] = con.value(''(relatedContractorOrder)[1]'', ''int'')
        FROM    @xmlVar.nodes(''/root/contractorRelation/entry'') AS C ( con )
        WHERE   ContractorRelation.id = con.value(''(id)[1]'', ''char(36)'')
                AND ContractorRelation.version = con.value(''(version)[1]'', ''char(36)'')

		/*Pobranie danych o kontrahentach*/
        SET @rowcount = @@ROWCOUNT
        
     END TRY
	 BEGIN CATCH
			SELECT @errorMsg = ''Błąd wstawiania danych tabela:ContractorRelation; error:''
				+ CAST(@@ERROR AS VARCHAR(50)) + '';Procedura:'' + ERROR_PROCEDURE() + '';Linia:'' + CAST(ERROR_LINE() as varchar(50))+ '';Opis:'' + ERROR_MESSAGE() 
            RAISERROR ( @errorMsg, 16, 1)
    END CATCH        
	IF @rowcount = 0 
		BEGIN
			EXEC [contractor].[p_insertContractorRelation] @xmlVar
		END
    END
' 
END
GO
