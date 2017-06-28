/*
name=[item].[p_getItemsSetByItemId]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
6fp4U2w3h3kaRv820U4MCw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsSetByItemId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_getItemsSetByItemId]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_getItemsSetByItemId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


CREATE PROCEDURE [item].[p_getItemsSetByItemId]
@xmlVar XML
--set @xmlVar = ''<root><itemId>BE4BF2C1-DD84-4F42-9D87-D341C8BEC622</itemId></root>''
AS
BEGIN

DECLARE @itemId UNIQUEIDENTIFIER,
		@configuration XML,
		@iDoc INT,
		@x XML



	SELECT @itemId = @xmlVar.value(''(root/itemId)[1]'',''char(36)'')

	SELECT @configuration = xmlValue 
	FROM configuration.Configuration 
	WHERE [key] = ''itemsSet.set1''


	EXEC sp_xml_preparedocument @idoc OUTPUT, @configuration

			SELECT TOP 1 @x =  x
			FROM OPENXML(@idoc, ''itemsSets/itemsSet/lines/line'')
				WITH(
					itemId uniqueidentifier ''itemId'',
					x xml ''../../.''
					)
			WHERE itemId = @itemId
	EXEC sp_xml_removedocument @idoc
	
	SELECT ISNULL(@x,CAST(''<root/>'' as XML)) returnXml
END
' 
END
GO
