/*
name=[dbo].[p_createDokFile]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
801tZzIJKbQ3T8NEGrjzCA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[p_createDokFile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[p_createDokFile]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[p_createDokFile]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE p_createDokFile
@lines XML,
@file varchar(200),
@katalog varchar(500)
AS

BEGIN


DECLARE 
	@count INT,
	@i INT,
	@a NVARCHAR(4000)

	SELECT	@count = @lines.query(''<a>{ count( */*) }</a>'').value(''a[1]'',''int''),
			@i = 1

	WHILE @i <= @count
		BEGIN
			SELECT @a = ''echo '' + @lines.query(''/*[sql:variable("@i")]/*'').value(''.'',''NVARCHAR(4000)'') + '' D:\a.txt''
			EXEC xp_cmdshell  @a

			SELECT @i = @i + 1
		END
END' 
END
GO
