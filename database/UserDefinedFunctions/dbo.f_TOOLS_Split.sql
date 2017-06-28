/*
name=[dbo].[f_TOOLS_Split]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
ZCRhxnyPONJoXuoEIn8uXQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_TOOLS_Split]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[f_TOOLS_Split]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_TOOLS_Split]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[f_TOOLS_Split]
( 
	@split_text varchar(max),
	@split_char char(1)
)
RETURNS 
	@param TABLE 
	(
		idP VARCHAR(8000)
	)
AS
BEGIN
	DECLARE @a int, @b int, @l int
	SELECT @a = 0, @l = len(@split_text)

	WHILE @a <= @l
	BEGIN
		DECLARE @ci int
		SET @ci = CHARINDEX(@split_char, @split_text, @a + 1)
		SELECT @b = CASE WHEN @ci = 0 THEN @l + 1 ELSE @ci END

		INSERT INTO @param (idp)
		SELECT NULLIF(SUBSTRING(@split_text, @a + 1, @b - @a - 1), '''')
		SET @a = @b
	END
RETURN
END
' 
END

GO
