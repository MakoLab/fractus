/*
name=[crm].[p_insertOfferLine]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
zzOsDGSpGiObDCnb/AvWFw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_insertOfferLine]') AND type in (N'P', N'PC'))
DROP PROCEDURE [crm].[p_insertOfferLine]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[crm].[p_insertOfferLine]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [crm].[p_insertOfferLine] 
	@xmlVar XML
AS
BEGIN
	/*Deklaracja zmiennych*/
    DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT,
			@idoc int


	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar
	
      
INSERT INTO crm.OfferLine ([id],  [offerId],  [ordinalNumber],  [itemId],  [itemVersion], [quantity], [grossValue], [version],  [itemName])   
SELECT [id],  [offerId],  [ordinalNumber],  [itemId],  [itemVersion], [quantity], [grossValue], [version],  [itemName] 

	FROM OPENXML(@idoc, ''/root/offerLine/entry'')
				WITH(
				[id] char(36) ''id'', 
				[offerId] char(36) ''offerId'', 
				[ordinalNumber] int ''ordinalNumber'', 
				[itemId] char(36) ''itemId'', 
				[itemVersion] char(36) ''itemVersion'', 
				[version] char(36) ''version'', 
				[itemName] nvarchar(500) ''itemName'',
				[quantity] numeric(18,2) ''quantity'',
				[grossValue] numeric(18,2) ''grossValue''
			)
  
	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
 	EXEC sp_xml_removedocument @idoc
 	   
    /*Obsługa błędów i wyjątków*/
    IF @@error <> 0 
        BEGIN
            SET @errorMsg = ''Błąd wstawiania danych table:OfferLine ; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
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
