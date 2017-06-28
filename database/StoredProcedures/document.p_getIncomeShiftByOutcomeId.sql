/*
name=[document].[p_getIncomeShiftByOutcomeId]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
8Ej5u+VfqGrMeheXXltsnw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getIncomeShiftByOutcomeId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getIncomeShiftByOutcomeId]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getIncomeShiftByOutcomeId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getIncomeShiftByOutcomeId]
@outcomeShiftId UNIQUEIDENTIFIER
AS
BEGIN

DECLARE 
@rowcount INT,
@attribute UNIQUEIDENTIFIER,
@id UNIQUEIDENTIFIER


SELECT @attribute = id 
FROM dictionary.DocumentField 
WHERE name = ''ShiftDocumentAttribute_OppositeDocumentId''

SELECT TOP 1 @id = warehouseDocumentHeaderId
FROM document.DocumentAttrValue
WHERE documentFieldId = @attribute AND CAST(textValue as UNIQUEIDENTIFIER)  = @outcomeShiftId

EXEC document.p_getWarehouseDocumentData @id

END
' 
END
GO
