/*
name=[dbo].[f_extractPattern]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
50lTkKALUTeMMrHgzEgsxA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_extractPattern]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[f_extractPattern]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_extractPattern]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- funkcja wyciaga znaki pasujace do wzorca np.
-- select dbo.f_extractPattern(''123-456-78-90 xyz'', ''%[0-9]%'') -- zwroci 1234567890
-- select dbo.f_extractPattern(''1234567890'', ''%[0-9]%'') -- zwroci 1234567890
CREATE FUNCTION [dbo].[f_extractPattern](@s nvarchar(max), @p nvarchar(100))
	RETURNS nvarchar(max)
AS
BEGIN
	DECLARE  @i      INT, 
			 @result VARCHAR(50),
			 @pos    INT

	SELECT @i = 1, @result = ''''

	SET @pos = Patindex(@p, @s)
	WHILE (@pos >= 0) 
	  BEGIN 
		SET @result = @result + Substring(@s, @pos, 1)
		SET @s = Stuff(@s, @pos, 1, '''')
		SET @pos = Patindex(@p, @s)
	  END

	RETURN @result
END
' 
END

GO
