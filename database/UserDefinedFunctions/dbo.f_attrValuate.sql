/*
name=[dbo].[f_attrValuate]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
h7AuAL8F0M8epgbRoU677Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_attrValuate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[f_attrValuate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_attrValuate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[f_attrValuate] ( @a1 int, @is1 int ,@a2 int, @is2 int ,@a3 int, @is3 int )
RETURNS int
AS
BEGIN
DECLARE @i int

IF @is1 = 1 AND NULLIF(@a1,-1) IS NULL
	SELECT @i =- 1

IF @is2 = 1 AND NULLIF(@a2,-1) IS NULL
	SELECT @i =- 1

IF @is3 = 1 AND  NULLIF(@a3,-1) IS NULL
	SELECT @i = - 1	

IF @i IS NULL
	BEGIN
		SELECT @i = MIN (y)
		FROM (
			SELECT ISNULL(@a1,-1) y UNION ALL
			SELECT ISNULL(@a2,-1) y UNION ALL
			SELECT ISNULL(@a3,-1) y
			) x
		WHERE x.y <> -1
	END

SELECT @i = ISNULL(@i, -1)	 

		
RETURN @i
END
' 
END

GO
