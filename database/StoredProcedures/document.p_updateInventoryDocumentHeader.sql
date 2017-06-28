/*
name=[document].[p_updateInventoryDocumentHeader]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
EwYXf0FzTusKdeEdb+0ydg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateInventoryDocumentHeader]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_updateInventoryDocumentHeader]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_updateInventoryDocumentHeader]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_updateInventoryDocumentHeader] 
@xmlVar XML
AS 
    BEGIN
    
		/*Deklaracja zmiennych*/
        DECLARE @errorMsg VARCHAR(2000),
            @rowcount INT,
            @applicationUserId UNIQUEIDENTIFIER

		/*Pobranie uzytkownika aplikacji*/
        SELECT  @applicationUserId = a.value(''@applicationUserId'', ''char(36)'')
        FROM    @xmlVar.nodes(''root'') AS x ( a )

        /*Aktualizacja danych */
        UPDATE  document.InventoryDocumentHeader
        SET    
			--[number] =  CASE WHEN con.exist(''number'') = 1 THEN con.query(''number'').value(''.'',''int'') ELSE NULL END ,  
			--[fullNumber] =  CASE WHEN con.exist(''fullNumber'') = 1 THEN con.query(''fullNumber'').value(''.'',''nvarchar(50)'') ELSE NULL END ,  
			--[seriesId] =  CASE WHEN con.exist(''seriesId'') = 1 THEN con.query(''seriesId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[creationApplicationUserId] =  CASE WHEN con.exist(''creationApplicationUserId'') = 1 THEN con.query(''creationApplicationUserId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[creationDate] =  CASE WHEN con.exist(''creationDate'') = 1 THEN con.query(''creationDate'').value(''.'',''datetime'') ELSE NULL END ,  
			[modificationApplicationUserId] =  CASE WHEN con.exist(''modificationApplicationUserId'') = 1 THEN con.query(''modificationApplicationUserId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[modificationDate] =  CASE WHEN con.exist(''modificationDate'') = 1 THEN con.query(''modificationDate'').value(''.'',''datetime'') ELSE NULL END ,  
			[closureApplicationUserId] =  CASE WHEN con.exist(''closureApplicationUserId'') = 1 THEN con.query(''closureApplicationUserId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[closureDate] =  CASE WHEN con.exist(''closureDate'') = 1 THEN con.query(''closureDate'').value(''.'',''datetime'') ELSE NULL END ,  
			[type] =  CASE WHEN con.exist(''type'') = 1 THEN con.query(''type'').value(''.'',''nvarchar(200)'') ELSE NULL END ,  
			[warehouseId] =  CASE WHEN con.exist(''warehouseId'') = 1 THEN con.query(''warehouseId'').value(''.'',''uniqueidentifier'') ELSE NULL END ,  
			[header] =  CASE WHEN con.exist(''header'') = 1 THEN con.query(''header'').value(''.'',''nvarchar(500)'') ELSE NULL END ,  
			[footer] =  CASE WHEN con.exist(''footer'') = 1 THEN con.query(''footer'').value(''.'',''nvarchar(500)'') ELSE NULL END ,  
			[responsiblePersoncommission] =  CASE WHEN con.exist(''responsiblePersoncommission'') = 1 THEN con.query(''responsiblePersoncommission/*'') ELSE NULL END ,  
			[version] =  CASE WHEN con.exist(''_version'') = 1 THEN con.query(''_version'').value(''.'',''uniqueidentifier'') ELSE NULL END,
			[documentTypeId] =  CASE WHEN con.exist(''documentTypeId'') = 1 THEN con.query(''documentTypeId'').value(''.'',''uniqueidentifier'') ELSE NULL END,
			[status] = CASE WHEN con.exist(''status'') = 1 THEN con.query(''status'').value(''.'',''int'') ELSE NULL END,
			[issueDate] = CASE WHEN con.exist(''issueDate'') = 1 THEN con.query(''issueDate'').value(''.'',''datetime'') ELSE NULL END
        FROM    @xmlVar.nodes(''/root/inventoryDocumentHeader/entry'') AS C ( con )
        WHERE   InventoryDocumentHeader.id = con.query(''id'').value(''.'', ''char(36)'')
                AND InventoryDocumentHeader.version = con.query(''version'').value(''.'', ''char(36)'')


		/*Pobranie liczby pozycji*/
        SET @rowcount = @@ROWCOUNT
        
		/*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                SET @errorMsg = ''Błąd wstawiania danych table:InventoryDocumentHeader; error:''
                    + CAST(@@error AS VARCHAR(50)) + ''; ''
                RAISERROR ( @errorMsg, 16, 1 )
            END
        ELSE 
            BEGIN
                IF @rowcount = 0 
                    RAISERROR ( 50012, 16, 1 ) ;
            END
 END
' 
END
GO
