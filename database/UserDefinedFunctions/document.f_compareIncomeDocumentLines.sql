/*
name=[document].[f_compareIncomeDocumentLines]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
fZrh8l5QAziQFJpEswN7Ng==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[f_compareIncomeDocumentLines]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [document].[f_compareIncomeDocumentLines]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[f_compareIncomeDocumentLines]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [document].[f_compareIncomeDocumentLines] 
(@incomeDocumentLineId UNIQUEIDENTIFIER,
@previousIncomeDocumentLineId UNIQUEIDENTIFIER) 
RETURNS uniqueidentifier
AS
BEGIN

/*
Funkcja sprawdza, czy linia @previousIncomeDocumentLineId stanowi przychód dla @incomeDocumentLineId.
Uwzgledniane są również wcześniejsze przychody, tzn. przychody dla korekt.
*/

DECLARE @previous UNIQUEIDENTIFIER

SELECT @previous = @incomeDocumentLineId

WHILE @previous <> @previousIncomeDocumentLineId AND @previous IS NOT NULL
BEGIN
	SELECT @previous = previousIncomeWarehouseDocumentLineId
	FROM document.WarehouseDocumentLine
	WHERE id = @previous	
END
RETURN @previous

END
' 
END

GO
