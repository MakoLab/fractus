/*
name=[document].[p_getDate]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
dcar1cX9HTI/Um6LfyB14w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getDate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getDate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure [document].[p_getDate]
as
SELECT getDate() date
' 
END
GO
