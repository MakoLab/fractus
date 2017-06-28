/*
name=[item].[p_setPriceListData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
SJ2vWkXMxY91zKkIeFvfiA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_setPriceListData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_setPriceListData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_setPriceListData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [item].[p_setPriceListData]
 @xmlVar XML

AS
BEGIN
/*
BEGIN TRAN
DECLARE @xmlVar XML
select @xmlVar = ''<root>
　<priceListHeader>
　　<entry>
　　　<label>testowy</label>
　　</entry>
　</priceListHeader>
　<priceListLine>
　　<entry>
　　　<itemId>8969CE55-D729-41D3-99D2-7644777BE10F</itemId>
　　　<itemName>coolik 6.1</itemName>
　　　<price>1000</price>
　　</entry>
　　<entry>
　　　<itemId>58D5853E-D3A3-41AF-9AE6-451C1EE0AD76</itemId>
　　　<itemName>coolik 6.2</itemName>
　　　<price>1200</price>
　　</entry>
　</priceListLine>
</root> ''
EXEC [item].[p_setPriceListData] @xmlVar
select * from  item.PriceListHeader 
ROLLBACK TRAN
*/
	/*Procedura to opakowanie dla tymczasowego rozwiązania problemu cenników*/
 	DECLARE @PriceListHeaderId UNIQUEIDENTIFIER,
 			@xmlHeader XML,
 			@xmlLine XML,
 			@isNew bit
 			

 	SELECT @PriceListHeaderId = NULLIF(@xmlVar.query(''root/priceListHeader/entry/id'').value(''.'',''char(36)''),'''')
 	
 	IF @priceListHeaderId IS NULL SET @isNew = 1
 	ELSE SET @isNew = 0
 	
 	
 	/* Warunek na istnienie nazwy */
 	IF EXISTS (	SELECT id 
 				FROM item.PriceListHeader 
 				WHERE label in (	
 									SELECT x.value(''(label)[1]'',''varchar(500)'') 
 									FROM @xmlVar.nodes(''root/priceListHeader/entry'') AS a(x) 
 									WHERE NULLIF(x.value(''(label)[1]'',''varchar(500)''),'''') IS NOT  NULL 
 								)
 					AND (id <> @PriceListHeaderId OR @PriceListHeaderId IS NULL)		
 				)
 		BEGIN
 			SELECT CAST(''<root>Podana nazwa jest już wykorzystana</root>'' as xml) xml
 			RETURN 0;
 		END
  	
  	IF @isNew = 1 SELECT @priceListHeaderId = newid()
 	
	SELECT @xmlHeader = (
	SELECT (
		SELECT (
			SELECT @priceListHeaderId as id, 
				   x.query(''name'').value(''.'',''nvarchar(200)'') name,
				   CAST(ISNULL(x.query(''xmlLabels/*'') ,''<root/>'') AS XML) xmlLabels, 
				   x.query(''description'').value(''.'',''nvarchar(500)'') description,
				   ISNULL(NULLIF(x.query(''creationApplicationUserId'').value(''.'',''char(36)''),'''') , (SELECT TOP 1 contractorId FROM contractor.ApplicationUser)) creationApplicationUserId ,  
				   ISNULL(NULLIF(x.query(''creationDate'').value(''.'',''datetime'') ,''''),getdate()) creationDate,  
				   x.query(''modificationDate'').value(''.'',''datetime'') modificationDate,
				   NULLIF(x.query(''modificationApplicationUserId'').value(''.'',''char(36)'') ,'''') modificationApplicationUserId,
				   ISNULL(x.query(''priceType'').value(''.'',''int''), 0) priceType, 
				   ISNULL(NULLIF(x.query(''version'').value(''.'',''char(36)'') ,''''), newid()) version,
				   ISNULL(NULLIF(x.query(''label'').value(''.'',''nvarchar(500)'') ,''''), newid()) label
			FROM @xmlVar.nodes(''root/priceListHeader/entry'') AS a(x)
			FOR XML PATH(''entry''), TYPE )
		FOR XML PATH(''priceListHeader''), TYPE)
	FOR XML PATH(''root''), TYPE )	
	
	SELECT @xmlLine = (
	SELECT (
		SELECT (
			SELECT ISNULL(NULLIF(x.query(''id'').value(''.'',''char(36)''),''''),newid()) id,
				   @priceListHeaderId as priceListHeaderId, 
				   x.query(''ordinalNumber'').value(''.'',''int'') ordinalNumber,
				   NULLIF(x.query(''itemId'').value(''.'',''char(36)''),'''')  itemId ,  
				   ISNULL(x.query(''price'').value(''.'',''numeric(18,2)''),0.0 ) price,
				   ISNULL(NULLIF(x.query(''version'').value(''.'',''char(36)'') ,''''), newid()) version
			FROM @xmlVar.nodes(''/root/priceListLine/entry'') AS a(x)
			FOR XML PATH(''entry''), TYPE )
		FOR XML PATH(''priceListLine''), TYPE)
	FOR XML PATH(''root''), TYPE )	
	
	IF @isNew = 1 	
 		BEGIN
			EXEC item.p_insertPriceListHeader @xmlHeader	
			IF @xmlLine.exist(''/root/priceListLine/entry/id'') = 1 
 				EXEC item.p_insertPriceListLine @xmlLine
 		END	
 	ELSE
 		BEGIN
 			
 			DELETE FROM item.PriceListLine WHERE priceListHeaderId = @PriceListHeaderId
		 	
 			DELETE FROM item.PriceListHeader WHERE id = @PriceListHeaderId
		 	
 			EXEC item.p_insertPriceListHeader @xmlHeader
		 	IF @xmlLine.exist(''/root/priceListLine/entry/id'') = 1 
 				EXEC item.p_insertPriceListLine @xmlLine
 		END
 		
	SELECT CAST(''<root/>'' as xml) xml
END
' 
END
GO
