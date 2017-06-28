/*
name=[warehouse].[p_getShiftTransactionByShiftId]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Pj7mqWc+pP6HSWXN3mJ7rQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getShiftTransactionByShiftId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [warehouse].[p_getShiftTransactionByShiftId]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[warehouse].[p_getShiftTransactionByShiftId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [warehouse].[p_getShiftTransactionByShiftId] 
@shiftId UNIQUEIDENTIFIER
AS
BEGIN
DECLARE @shiftTransactionId UNIQUEIDENTIFIER

SELECT @shiftTransactionId = shiftTransactionId 
FROM warehouse.Shift 
WHERE id = @shiftId


EXEC [warehouse].[p_getShiftTransactionData] @shiftTransactionId
END
' 
END
GO
