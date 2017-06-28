/*
name=[dbo].[f_replace2]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
QwtgLzPsYaxMV1Ksk6QUbg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_replace2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[f_replace2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_replace2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N' 

CREATE FUNCTION [dbo].[f_replace2]
( @string varchar(1000) , @string2 varchar(8000) )
RETURNS varchar(1000)
AS
BEGIN
DECLARE @position int

/*Funkcja uwzględnia wartość z konfiguracji przekazaną drugim parametrem*/
SET @position = 1

WHILE @position <= DATALENGTH(@string)
   BEGIN

		IF (SELECT ASCII(SUBSTRING(@string, @position, 1)) ) NOT BETWEEN 48 AND 57 
			AND (SELECT ASCII(SUBSTRING(@string, @position, 1)) ) NOT BETWEEN 65 AND 90 
			AND (SELECT ASCII(SUBSTRING(@string, @position, 1)) ) NOT BETWEEN 97 AND 122 
			AND (SELECT ASCII(SUBSTRING(@string, @position, 1)) ) NOT IN ( SELECT word FROM dbo.xp_split(@string2, '','') ) -- wartości z konfiguracji
			BEGIN
				SELECT @string = REPLACE(@string, SUBSTRING(@string, @position, 1), '' '')
			END	

   SET @position = @position + 1
   END 

RETURN @string
END' 
END

GO
