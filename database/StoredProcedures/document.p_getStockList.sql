/*
name=[document].[p_getStockList]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
1LmFfBRR4SJB3mqbori5Kw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getStockList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getStockList]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getStockList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getStockList]
@xmlVar XML
AS
BEGIN

	DECLARE 
		@replaceConf_item varchar(8000),
		@query NVARCHAR(max),
		@select NVARCHAR(max),
		@from NVARCHAR(max),
		@where NVARCHAR(max)

		/*Pobranie konfiguracji*/
		SELECT	@replaceConf_item = xmlValue.query(''root/indexing/object[@name="item"]/replaceConfiguration'').value(''.'', ''varchar(8000)'')
		FROM    configuration.Configuration c
		WHERE   c.[key] = ''Dictionary.configuration''

		SELECT @query = ISNULL(REPLACE(REPLACE(RTRIM(NULLIF(@xmlVar.query(''*/query'').value(''.'', ''nvarchar(1000)''),'''')), ''*'', ''%''),'''''''',''''''''''''),'''') + ''%''
		

		SELECT @select = char(9) + ''SELECT ( '' + char(10) + 
			        char(9) + char(9) + ''SELECT ws.itemId, i.[version] itemVersion, i.name itemName, ws.quantity, 0 realQuantity, (SELECT TOP 1 netPrice FROM document.CommercialDocumentLine WHERE itemId = ws.itemId ) price '' + char(10),
			@from = char(9) + char(9) + ''FROM document.WarehouseStock ws '' + char(10) +
					char(9) + char(9) + char(9) +  ''JOIN item.Item i ON ws.itemId = i.id'' + char(10),
			@where = ''''		 


		/*filtrowanie po query */
		IF @query <> ''%''
			BEGIN
				/*Funkcja składa widoki do query*/
				SELECT @from = @from  + char(9) + char(9) + char(9) + dbo.f_getQueryFilter(@query ,@replaceConf_item , '' ws.itemId '', ''itemId '',''item.v_itemDictionary'', null, null ,null ) + char(10)
			END    


		SELECT @select = @select + @from + @where +
			char(9) + char(9) +''FOR XML PATH(''''line''''),TYPE ) '' + char(10) +
			char(9) + ''FOR XML PATH(''''root''''),TYPE ''

		/*Odpalamy, a co tam*/
		EXEC (@select)
--		print @select 	
END
' 
END
GO
