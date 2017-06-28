/*
name=[communication].[p_createCommercialWarehouseValuationPackage]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
xnaoo0M64iZ7HZbyQJXz6A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createCommercialWarehouseValuationPackage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[p_createCommercialWarehouseValuationPackage]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[p_createCommercialWarehouseValuationPackage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [communication].[p_createCommercialWarehouseValuationPackage]
@xmlVar XML
AS
BEGIN

		/*Deklaracja zmiennych*/
        DECLARE @snap XML,
            @errorMsg VARCHAR(2000),
            @rowcount INT,
            @localTransactionId UNIQUEIDENTIFIER,
            @deferredTransactionId UNIQUEIDENTIFIER,
			@databaseId UNIQUEIDENTIFIER

		/*Pobranie danych o transakcji*/
        SELECT  @localTransactionId = x.value(''@localTransactionId'',''char(36)''),
                @deferredTransactionId = x.value(''@deferredTransactionId'',''char(36)''),
				@databaseId = x.value(''@databaseId'',''char(36)'')
        FROM    @xmlVar.nodes(''root'') AS a ( x )
		/*Budowa obrazu danych*/
        SELECT  @snap = ( SELECT   
								( SELECT
									 ( SELECT    x.value(''@previousVersion'',''char(36)'') AS ''@previousVersion'',
                                                x.value(''@action'',''varchar(10)'') AS ''@action'',
                                                x.value(''@id'', ''char(36)'') ''id'',
                                                commercialDocumentLineId ''commercialDocumentLineId'',
                                                warehouseDocumentLineId ''warehouseDocumentLineId'',
                                                quantity ''quantity'',
												[value] ''value'',
												price ''price'',
                                                x.value(''@_object1from'',''char(36)'') ''_object1from'',
                                                x.value(''@_object1to'',''char(36)'') ''_object1to'',
                                                x.value(''@_object2from'',''char(36)'') ''_object2from'',
                                                x.value(''@_object2to'',''char(36)'') ''_object2to'',
												ISNULL(version, x.value(''@version'',''char(36)'')) ''version''
                                      FROM      @xmlVar.nodes(''root/entry'') AS a ( x )
                                                LEFT JOIN document.CommercialWarehouseValuation i ON i.id = x.value(''@id'', ''char(36)'')
                                    FOR XML PATH(''entry''), TYPE
									)
                               FOR XML PATH(''commercialWarehouseValuation''), TYPE
                               )

                        FOR XML PATH(''root''), TYPE
                        )  

        
        /*Wstawienie danych*/
        INSERT  INTO communication.OutgoingXmlQueue
                (
                  id,
                  localTransactionId,
                  deferredTransactionId,
				  databaseId,
                  [type],
                  [xml],
                  creationDate
                )
                SELECT  NEWID(),
                        @localTransactionId,
                        @deferredTransactionId,
						@databaseId,
                        ''CommercialWarehouseValuation'',
                        @snap,
                        GETDATE()
                        
        /*Pobranie liczby wierszy*/                
        SET @rowcount = @@ROWCOUNT

        /*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                
                SET @errorMsg = ''Błąd wstawiania danych table: OutgoingXmlQueue; error:''
                    + CAST(@@ERROR AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        ELSE 
            BEGIN
                
                IF @rowcount = 0 
                    RAISERROR ( 50011, 16, 1 ) ;
            END

    END
' 
END
GO
