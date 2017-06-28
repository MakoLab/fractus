/*
name=[document].[p_getStockHistory]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
a7jgib+AITGXQVoFu/KNDg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getStockHistory]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getStockHistory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getStockHistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getStockHistory] 
@xmlVar XML
AS

BEGIN
	DECLARE 
		@warehouseId char(36),
		@itemId char(36),
		@dateFrom VARCHAR(50),
		@dateTo VARCHAR(50),
		@select NVARCHAR(max),
		@where NVARCHAR(max),
		@date NVARCHAR(max),
		@stan NVARCHAR(max)

	SELECT 
		@warehouseId = x.query(''warehouseId'').value(''.'',''char(36)''),
		@itemId = x.query(''itemId'').value(''.'',''char(36)''),
		@dateFrom = NULLIF(x.query(''dateFrom'').value(''.'',''VARCHAR(50)''),''''),
		@dateTo = NULLIF(x.query(''dateTo'').value(''.'',''VARCHAR(50)''),'''')
	FROM @xmlVar.nodes(''params'') AS a(x)
	

	SELECT @where = '' WHERE l.warehouseId = '''''' + @warehouseId + ''''''
			AND l.itemId = '''''' + @itemId + '''''' 
			AND l.direction <> 0 ''  

	/* Fragment dotyczy filtra daty dokumentu, filtry występują razaem zgodnie z zamówieniem */
	IF @dateFrom IS NOT NULL 
		BEGIN
			SELECT @date = '' AND ( issueDate >= '''''' + @dateFrom + '''''' AND issueDate <= '''''' + @dateTo + '''''' ) ''



			SELECT @stan = '' 
			SELECT @stan_przed =  SUM(direction * quantity) 
			FROM document.WarehouseDocumentHeader h WITH(NOLOCK)
				JOIN document.WarehouseDocumentLine l WITH(NOLOCK) ON h.id = l.warehouseDocumentHeaderId ''  + @where + ''
					AND issueDate < '''''' + @dateFrom + '''''' ''

		END

	SELECT @select = ''
	DECLARE @tmp_table TABLE ( direction INT, quantity NUMERIC(18,6), id UNIQUEIDENTIFIER, documentId UNIQUEIDENTIFIER, 
								fullNumber NVARCHAR(50), ordinalNumber INT, contractor NVARCHAR(200), price NUMERIC(18,2), [value] NUMERIC(18,2),
								issuedate DATETIME, rowNumber INT IDENTITY(1,1), incomeDate DATETIME , documentTypeId UNIQUEIDENTIFIER, status INT)

	DECLARE @stan_przed NUMERIC(18,6) , @stan_po NUMERIC(18,6); '' + ISNULL( @stan, '''' ) + ''   
	
	INSERT INTO @tmp_table (direction, quantity, id, documentId, fullNumber, ordinalNumber, contractor, price, [value], issuedate, incomeDate, documentTypeId, status)
			SELECT  direction , quantity , l.id , h.id , fullNumber , ordinalNumber , c.fullName , price , l.value , issuedate ,l.incomeDate, h.documentTypeId, h.status
			FROM document.WarehouseDocumentHeader h WITH(NOLOCK)
				JOIN document.WarehouseDocumentLine l WITH(NOLOCK) ON h.id = l.warehouseDocumentHeaderId LEFT JOIN contractor.contractor c WITH(NOLOCK) ON h.contractorId = c.id ''  + @where + ISNULL(@date,'''') + ''
				
			ORDER BY issuedate, h.id, l.ordinalNumber, l.id

	SELECT ISNULL(@stan_przed ,0 ) AS ''''@stan_przed'''' , (
			SELECT  l.direction AS ''''@direction'''', l.quantity AS ''''@quantity'''' , l.id AS ''''@id'''',l.documentId AS ''''@documentId'''', 
			l.fullNumber AS ''''@fullNumber'''', l.ordinalNumber AS ''''@ordinalNumber'''', l.price AS ''''@price'''', l.value AS ''''@value'''', 
			l.issuedate AS ''''@date'''', l.incomeDate	AS ''''@incomeDate'''',
			(	SELECT ISNULL(@stan_przed, 0 ) + SUM(direction * quantity) 
							FROM @tmp_table t
							WHERE  t.rowNumber <= l.rowNumber
						) AS ''''@currentStock'''', 
			l.documentTypeId AS ''''@documentTypeId'''', l.status as ''''@status'''', l.contractor as ''''@contractor''''
			FROM @tmp_table l 		
			ORDER BY rowNumber 
			FOR XML PATH(''''line''''), TYPE 
		) FOR XML PATH(''''stockHistory''''), TYPE ''



--select @select
EXEC (@select)
			
	
END
' 
END
GO
