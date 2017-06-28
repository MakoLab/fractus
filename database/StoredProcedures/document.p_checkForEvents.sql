/*
name=[document].[p_checkForEvents]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
a9oafMQu36C2n7f4vh/Giw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkForEvents]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_checkForEvents]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_checkForEvents]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [document].[p_checkForEvents] @xmlVar XML --= ''<root applicationUserId="24190027-F726-4215-9710-9DAE077FBC52"/>''
AS
BEGIN
	DECLARE @mmm uniqueidentifier,@mmp uniqueidentifier, @mmz uniqueidentifier, @x xml, @casheDate datetime
	/*No to jest hardcode, muszę przyjąć że symbole dokumentów przesunięć są tak właśnie nazwane
	*/

	/*CzarekW - 14-03-2013 dodałem cache 

		CREATE TABLE [tools].[EventCache](
			[cacheDate] [datetime] NULL,
			[parameter] [xml] NULL,
			[response] [xml] NULL
		) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

	*/
	 SELECT @casheDate = cacheDate FROM tools.EventCache WHERE CAST(parameter as varchar(max)) = CAST(@xmlVar as varchar(max))


	IF ((SELECT DATEDIFF(mi ,getdate() , @casheDate  ))  < -5 ) OR @casheDate IS NULL
		BEGIN
	
		SELECT @mmp = id 
		FROM dictionary.DocumentType WITH(nolock) WHERE [symbol] = ''MM+'' AND xmlOptions.value(''(root/warehouseDocument/@warehouseDirection)[1]'',''varchar(500)'')  = ''incomeShift''
		SELECT  @mmm = id 
		FROM dictionary.DocumentType WITH(nolock)  WHERE [symbol] = ''MM-'' AND xmlOptions.value(''(root/warehouseDocument/@warehouseDirection)[1]'',''varchar(500)'')  = ''outcomeShift''
		SELECT @mmz = id 
		FROM dictionary.DocumentType WITH(nolock)  WHERE [symbol] = ''ZMM-''

			SELECT @x = 
				(SELECT 	
					(SELECT (
						SELECT h.id AS ''@id'', h.fullNumber AS ''@fullNumber'' , h.issueDate ''@issueDate''
						FROM document.WarehouseDocumentHeader h WITH(nolock) 
							JOIN document.DocumentAttrValue v WITH(nolock) ON h.id = v.warehouseDocumentHeaderId 
						WHERE h.documentTypeId = @mmm AND h.status = 40 AND v.textValue = ''-20'' AND v.documentFieldId = ( SELECT id FROM dictionary.DocumentField WITH(nolock)  WHERE [name] = ''ShiftDocumentAttribute_OppositeDocumentStatus'' )
						ORDER BY  h.issueDate
						FOR XML PATH(''document''),TYPE
					) FOR XML PATH(''outcomesWaitingForCancelation''),TYPE) ,
				   (SELECT (
						SELECT h.id AS ''@id'', h.fullNumber AS ''@fullNumber'' , h.issueDate ''@issueDate''
						FROM document.CommercialDocumentHeader h WITH(nolock) 
							JOIN document.CommercialDocumentLine l WITH(nolock) ON h.id = l.commercialDocumentheaderId 
							LEFT JOIN (SELECT SUM(quantity) qty, commercialDocumentLineId FROM document.CommercialWarehouseRelation  WITH(nolock)  GROUP BY commercialDocumentLineId) r ON l.id = r.commercialDocumentLineId
						WHERE h.documentTypeId = @mmz AND h.status = 40  AND ISNULL(r.qty,0) < abs(l.quantity)
						GROUP BY h.id, h.fullNumber,  h.issueDate
						ORDER BY  h.issueDate
						FOR XML PATH(''document''),TYPE
					) FOR XML PATH(''outcomesWaitingForCommitting''),TYPE) ,
					(SELECT (
						SELECT h.id AS ''@id'', h.fullNumber AS ''@fullNumber'', h.issueDate ''@issueDate'' 
						FROM document.WarehouseDocumentHeader h WITH(nolock) 
							JOIN document.DocumentAttrValue v WITH(nolock) ON h.id = v.warehouseDocumentHeaderId 
						WHERE h.documentTypeId = @mmp AND h.status = 20 AND v.textValue = ''40'' AND v.documentFieldId = ( SELECT id FROM dictionary.DocumentField WITH(nolock) WHERE [name] = ''ShiftDocumentAttribute_OppositeDocumentStatus'' )
						ORDER BY  h.issueDate
						FOR XML PATH(''document''),TYPE
					)FOR XML PATH(''incomesWaitingForCommitting''),TYPE)
				FOR XML PATH(''root''),TYPE
				)
			PRINT ''tabele''

			UPDATE  tools.EventCache 
			SET response = @x, cacheDate = getdate()
			WHERE CAST(parameter as varchar(max)) = CAST(@xmlVar as varchar(max))

			IF @@ROWCOUNT = 0
				BEGIN
					INSERT INTO  tools.EventCache (cacheDate , parameter , response )
					SELECT getdate(), @xmlVar, @x
				END
			SELECT @x
		END
	ELSE
		BEGIN
			PRINT ''cashe''
			SELECT response FROM tools.EventCache WHERE CAST(parameter as varchar(max)) = CAST(@xmlVar as varchar(max))
		END

END
' 
END
GO
