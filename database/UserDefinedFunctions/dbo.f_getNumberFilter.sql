/*
name=[dbo].[f_getNumberFilter]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
R7EVPmc9Y/UHyc1nRNcGIA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_getNumberFilter]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[f_getNumberFilter]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_getNumberFilter]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[f_getNumberFilter] ( @query nvarchar(4000) ,@replaceConf varchar(8000), @join varchar(500) ,@select varchar(500), @view nvarchar(500) )
RETURNS varchar(max)
AS
BEGIN
DECLARE @string nvarchar(max), @i int
DECLARE @tmp_word TABLE
	(
	  id INT IDENTITY(1, 1),
	  word NVARCHAR(100)
	)

	SELECT  @string = '' JOIN ( '', @i = 0
		
	
	/*Dzielenie wyrażenia query na słowa*/	
	INSERT  INTO @tmp_word ( word )
	SELECT DISTINCT  word
	FROM    xp_split(dbo.f_replace2(@query,@replaceConf),  '','')
	WHERE RTRIM(word) <> ''''
		
	
	WHILE @@rowcount > 0
		BEGIN
			SET @i = @i + 1
			
			SELECT  @string = @string + CASE WHEN @i > 1 THEN '' UNION '' ELSE '''' END +
					
					 ''  SELECT DISTINCT '' + @select + ''
						FROM '' + @view + '' WITH(NOLOCK) WHERE number like '''''' +  word  + ''%'''' '' 
			FROM    @tmp_word
			WHERE   id = @i
		END  
			
		SELECT  @string = @string + '' ) zn  ON '' + @join + '' = zn.'' + @select 			
	RETURN @string
END
' 
END

GO
