/*
name=[dbo].[f_replace]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
8h+4KGhBxrnU58wXVwJpeQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_replace]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[f_replace]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_replace]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[f_replace]
( @string varchar(1000) )
RETURNS varchar(1000)
AS
BEGIN
DECLARE @position int

SET @position = 1

WHILE @position <= DATALENGTH(@string)
   BEGIN

		IF (SELECT ASCII(SUBSTRING(@string, @position, 1)) ) NOT BETWEEN 48 AND 57 
			AND (SELECT ASCII(SUBSTRING(@string, @position, 1)) ) NOT BETWEEN 65 AND 90 
			AND (SELECT ASCII(SUBSTRING(@string, @position, 1)) ) NOT BETWEEN 97 AND 122 
			AND (SELECT ASCII(SUBSTRING(@string, @position, 1)) ) NOT IN (140,143, 156, 159, 163,165, 175,179,181, 185,191, 198,202,209,210,211,230, 234, 241, 243, 46)

				SELECT @string = REPLACE(@string, SUBSTRING(@string, @position, 1), '' '')

   SET @position = @position + 1
   END 

RETURN @string
END
' 
END

GO
