/*
name=[reports].[p_getItemDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
h/rSvCX3WbESETYKuYC3Qw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getItemDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [reports].[p_getItemDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[reports].[p_getItemDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [reports].[p_getItemDocuments]
@xmlVar XML
AS
BEGIN

	DECLARE 
		@x XML,
		@config NVARCHAR(4000),
		@data_od DATETIME,
		@data_do DATETIME,
		@warehouseId UNIQUEIDENTIFIER, 
		@itemId UNIQUEIDENTIFIER

		SELECT 
			@data_od = NULLIF(x.query(''data_od'').value(''.'', ''datetime''),''''),
			@data_do = NULLIF(x.query(''data_do'').value(''.'', ''datetime''),''''),
			@warehouseId = NULLIF(x.query(''warehouseId'').value(''.'', ''char(36)''),''''),
			@itemId = NULLIF(x.query(''itemId'').value(''.'', ''char(36)''),'''')
		FROM @xmlVar.nodes(''searchParams'') as a( x )
		
		SELECT @config = ''<columns>  
							<column label="Ilość" field="@quantity" /> 
							<column label="Dokument" field="@fullNumber" /> 
							<column label="Data dokumentu" field="@issueDate" /> 
						  </columns>''

	SELECT @x = ( 
	SELECT         
		(SELECT CAST( @config as XML) ),         
		(SELECT CAST( ''<summary>cos</summary>'' as XML) ),         
		(SELECT ( SELECT * FROM (				
				SELECT (quantity * direction ) as ''@quantity'' ,fullNumber as ''@fullNumber'', h.issueDate as ''@issueDate''
				FROM document.WarehouseDocumentHeader h
					JOIN document.WarehouseDocumentLine l ON h.id = l.warehouseDocumentHeaderId
				WHERE l.warehouseId = @warehouseId
						AND l.itemId = @itemId

		) element FOR XML PATH(''element''),TYPE) FOR XML PATH(''elements''),TYPE )          FOR XML PATH(''root''),TYPE ) 


	SELECT @x as xml

END

--
--SELECT (quantity * direction ) quantity, fullNumber,h.issueDate
--FROM document.WarehouseDocumentHeader h
--	JOIN document.WarehouseDocumentLine l ON h.id = l.warehouseDocumentHeaderId
--
--WHERE l.warehouseId = 
--		AND l.itemId = 
--
--
--
--
--
--
' 
END
GO
