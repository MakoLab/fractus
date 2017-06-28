/*
name=[item].[p_savePriceRuleList]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
dE5XCHAANz7qldWLL4QD1g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_savePriceRuleList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_savePriceRuleList]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_savePriceRuleList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [item].[p_savePriceRuleList]
--declare
@xmlVar XML
AS
BEGIN
DECLARE 
	@iDoc INT,
	@dropList varchar(max)
	
	DECLARE @tmp TABLE (i int identity(1,1), id uniqueidentifier, [order] int, [status] int)
	
	--set @xmlVar = ''<root>
	--  <priceRule id="97B4AA65-6CF4-46D3-903A-13912251DA2D" name="testowa reguła" procedure="item.p_getItemPrice_97B4AA656CF446D3903A13912251DA2D" status="1" version="76866259-7C51-4D7D-82F1-3FF96A8CFBC3" order="1" />
	--  <priceRule id="25E45BFF-F582-42CB-8C01-149AC167E70D" name="reguła testowa" procedure="item.p_getItemPrice_25E45BFFF58242CB8C01149AC167E70D" status="1" version="2557C6DE-769A-45B0-82DE-1FB9E27B25D0" order="2" />
	--  <priceRule id="67A220F9-0694-47A9-B4A3-87AFF8FCB37E" name="nowa" procedure="item.p_getItemPrice_67A220F9069447A9B4A387AFF8FCB37E" status="1" version="AAE54CDC-D41E-489C-91B6-BC70165577BE" order="3" />
	--  <priceRule id="6D06E838-3D38-4845-AC24-FBEFD1A99DBA" name="reguła testowa" procedure="item.p_getItemPrice_6D06E8383D384845AC24FBEFD1A99DBA" status="1" version="B06B556B-622C-4D9E-96B9-4297A9C4E4F8" order="4"/>
	--</root>''	
	
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar
	
	INSERT INTO @tmp(id,[order], [status])
	SELECT id,[order], [status]
	FROM OPENXML(@idoc, ''/root/priceRule'')
					WITH(
						id char(36) ''@id'',
						[order] int ''@order'',
						[status] int ''@status''
						)
	
	EXEC sp_xml_removedocument @idoc
	--select * from @tmp
	
	SELECT @dropList = (
				SELECT STUFF(
							(SELECT '' DROP PROCEDURE '' + [procedure] + ''  '' 
							FROM item.PriceRule pr
								LEFT JOIN @tmp t ON pr.id = t.id
							WHERE t.id IS NULL
							FOR XML PATH('''')) , 1, 0, '''' ) 
						)

	EXECUTE (@dropList)
	
	DELETE FROM item.PriceRule 
	WHERE id NOT IN ( SELECT id FROM @tmp)
			
			
	UPDATE x
	SET x.[order] = t.[order], x.[status] = t.[status]
	FROM item.PriceRule x
		JOIN @tmp t ON x.id = t.id
				
	-- gdereck - wysylanie paczki komunikacyjnej		
	IF (SELECT ISNULL(@xmlVar.value(''(/root/@isCommunication)[1]'',''varchar(50)''), ''false'')) <> ''true''
		BEGIN
			INSERT INTO communication.OutgoingXmlQueue ( id, localTransactionId, deferredTransactionId, databaseId, [type], [xml],sendDate,creationDate)
			SELECT newid(), newid(),newid(),(SELECT textValue FROM configuration.Configuration WHERE [key] = ''communication.databaseId''), ''PriceRuleList'', @xmlVar, null, getdate()
		END


 EXEC item.p_getPriceRule ''<root/>''
END	

' 
END
GO
