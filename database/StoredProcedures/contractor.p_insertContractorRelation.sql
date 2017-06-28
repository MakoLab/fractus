/*
name=[contractor].[p_insertContractorRelation]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
gfkPUWLA85XTIZ/ZOaqTNg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertContractorRelation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_insertContractorRelation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_insertContractorRelation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_insertContractorRelation]
@xmlVar XML
AS
BEGIN
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT,
		@error int 
    
	BEGIN TRY

	/*Wstawienie danych o powiązaniach kontrahenta*/
    INSERT  INTO contractor.ContractorRelation
            (
              id,
              contractorId,
              contractorRelationTypeId,
              relatedContractorId,
              xmlAttributes,
              version,
              [order],
              relatedContractorOrder
            )
            SELECT  con.value(''(id)[1]'', ''char(36)''),
                    con.value(''(contractorId)[1]'', ''char(36)''),
                    con.value(''(contractorRelationTypeId)[1]'', ''char(36)''),
                    con.value(''(relatedContractorId)[1]'', ''char(36)''),
                    con.query(''xmlAttributes/*''),
                    ISNULL(con.value(''(_version)[1]'', ''char(36)''), con.value(''(version)[1]'', ''char(36)'')),
                    con.value(''(order)[1]'', ''int''),
                    con.value(''(relatedContractorOrder)[1]'', ''int'')
            FROM    @xmlVar.nodes(''/root/contractorRelation/entry'') AS C ( con )
			WHERE con.value(''(id)[1]'', ''char(36)'') NOT IN (SELECT id FROM contractor.ContractorRelation)

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT

     END TRY
	 BEGIN CATCH
			SELECT @errorMsg = ''Błąd wstawiania danych tabela:Configuration; error:''
				+ CAST(@@ERROR AS VARCHAR(50)) + '';Procedura:'' + ERROR_PROCEDURE() + '';Linia:'' + CAST(ERROR_LINE() as varchar(50))+ '';Opis:'' + ERROR_MESSAGE() 
            RAISERROR ( @errorMsg, 16, 1)
    END CATCH        
	IF @rowcount = 0 
		BEGIN
			EXEC [contractor].[p_updateContractorRelation] @xmlVar

		END
END
' 
END
GO
