/*
name=[warehouse].[p_getShiftsById]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
nR4YzMH+USvosH/9/YREnQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getShiftsById]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_getShiftsById]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getShiftsById]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE  PROCEDURE [warehouse].[p_getShiftsById]
@xmlVar XML
AS
BEGIN
DECLARE @tmp_ TABLE (id uniqueidentifier )

	INSERT INTO @tmp_ (id)
	SELECT x.value(''.'',''char(36)'')
	FROM @xmlVar.nodes(''/root/id'') as a(x)

SELECT (
	SELECT (
		SELECT s.* 
		FROM warehouse.Shift s
		JOIN @tmp_ t ON s.id = t.id	
		FOR XML PATH(''entry''),TYPE
	) 	FOR XML PATH(''shift''),TYPE
) 	FOR XML PATH(''root''),TYPE

END
' 
END
GO
