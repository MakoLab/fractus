/*
name=[document].[f_getOutcomeLineAfterCostCorrection]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
OmAtR1Wi6GIN0y4D02XUyA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[f_getOutcomeLineAfterCostCorrection]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [document].[f_getOutcomeLineAfterCostCorrection]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[f_getOutcomeLineAfterCostCorrection]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [document].[f_getOutcomeLineAfterCostCorrection] (@warehouseDocumentLineId UNIQUEIDENTIFIER) 
RETURNS uniqueidentifier
AS
BEGIN

/*
Funkcja poszukuje ostatniej korekty wartościowej dla danej pozycji rozchodowej.
Wykorzystane w algorytmie wystawiania korekt wartościowo-ilościowych PZ
*/

DECLARE 
	@correctDocumentLineId UNIQUEIDENTIFIER,
	@x XML,
	@stat INT

		SELECT @stat = 1, @correctDocumentLineId = @warehouseDocumentLineId

		WHILE @stat > 0
			BEGIN
				IF EXISTS(	SELECT id 
							FROM document.WarehouseDocumentLine l 
							WHERE l.correctedWarehouseDocumentLineId  = @correctDocumentLineId AND lineType = -3 AND quantity > 0)
					SELECT  @correctDocumentLineId = id
					FROM document.WarehouseDocumentLine l 
					WHERE l.correctedWarehouseDocumentLineId  = @correctDocumentLineId 
						AND lineType = -3 AND quantity > 0
				ELSE SET @stat = 0		
				
			END
RETURN @correctDocumentLineId

END
' 
END

GO
