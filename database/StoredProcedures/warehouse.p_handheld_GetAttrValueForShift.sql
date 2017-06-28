/*
name=[warehouse].[p_handheld_GetAttrValueForShift]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
v4YEonSiPE0fKgyW5Qx0Ew==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_handheld_GetAttrValueForShift]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_handheld_GetAttrValueForShift]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_handheld_GetAttrValueForShift]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_handheld_GetAttrValueForShift]
	@shiftId uniqueidentifier
AS
	
	SELECT
		ISNULL((SELECT TOP 1 CAST(CAST(decimalValue AS float) as varchar(10))
			FROM warehouse.ShiftAttrValue V
			JOIN dictionary.ShiftField F ON F.id = V.shiftFieldId
			WHERE shiftId = S.id AND F.name = ''Attribute_Voltage''
		), '''') attribute_Voltage, 
		ISNULL((SELECT TOP 1 CAST(CAST(decimalValue AS float) as varchar(10))
			FROM warehouse.ShiftAttrValue V
			JOIN dictionary.ShiftField F ON F.id = V.shiftFieldId
			WHERE shiftId = S.id AND F.name = ''Attribute_Current''
		), '''') attribute_Current 

	FROM warehouse.Shift S
	WHERE S.id = @shiftId
	FOR XML PATH(''root''), TYPE
' 
END
GO
