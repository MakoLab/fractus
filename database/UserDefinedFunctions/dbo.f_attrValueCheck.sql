/*
name=[dbo].[f_attrValueCheck]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
AZUIXkJf6/D4DEHxPHgqCg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_attrValueCheck]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[f_attrValueCheck]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_attrValueCheck]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[f_attrValueCheck] ( @value varchar(1000),@nominal varchar(1000),@string nvarchar(1000), @period1 numeric(18,6) , @period2 numeric(18,6))
RETURNS int
AS
BEGIN
DECLARE @i int

IF @string = ''V''
	BEGIN
		SELECT @value = REPLACE(@value, '','',''.'')
		SELECT @i = CASE WHEN CAST(@value AS numeric(18,6)) <= @period1 THEN 3 WHEN (CAST(@value AS numeric(18,6)) >@period1 ) AND (CAST(@value AS numeric(18,6)) <= @period2) THEN 2 WHEN (CAST(@value AS numeric(18,6)) > @period2 ) THEN 1  ELSE 3 END 
	END
ELSE IF @string = ''A''
	BEGIN
		IF NULLIF(@nominal,'''') IS NULL 
			SELECT @i = -1
		ELSE
		SELECT @i = CASE WHEN (CAST(@value AS numeric(18,6)) / CAST(@nominal as numeric(18,6)) <= @period1) THEN 3 WHEN ((CAST(@value AS numeric(18,6)) / CAST(@nominal as numeric(18,6)) > @period1)) AND ((CAST(@value AS numeric(18,6)) / CAST(@nominal as numeric(18,6))) <= @period2) THEN 2 WHEN ( (CAST(@value AS numeric(18,6)) / CAST(@nominal as numeric(18,6))) > @period2 ) THEN 1 ELSE 3 END
	END
ELSE IF @string = ''T''
	BEGIN
		SELECT  @i = CASE WHEN DATEDIFF(dd, CAST(@value AS DATETIME), GETDATE()) >= CAST(@period1 AS INT) THEN 3 WHEN ( DATEDIFF(dd, CAST(@value AS DATETIME), GETDATE()) < CAST(@period1  AS INT)) AND ( DATEDIFF(dd, CAST(@value AS DATETIME), GETDATE()) >= CAST(@period2 AS INT) ) THEN 2 WHEN DATEDIFF(dd, CAST(@value AS DATETIME), GETDATE()) < CAST(@period2 AS INT) THEN 1 ELSE 3 END
	END
ELSE IF @string IS NULL
	BEGIN
		SELECT @i = -1
	END

	
RETURN @i
END
' 
END

GO
