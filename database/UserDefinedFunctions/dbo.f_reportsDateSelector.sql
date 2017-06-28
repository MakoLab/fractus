/*
name=[dbo].[f_reportsDateSelector]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
bcxStm89y6Z9l5qb0NewoQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_reportsDateSelector]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[f_reportsDateSelector]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[f_reportsDateSelector]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[f_reportsDateSelector]
( @issueDate datetime , @eventDate datetime, @documentCategory int )
RETURNS datetime
AS
	BEGIN
		DECLARE @return datetime
		SELECT @return = CASE 
					WHEN @documentCategory IN (0) THEN @issueDate --FVS, PA
					WHEN @documentCategory IN (5) THEN @issueDate --PAK, FKS
					WHEN @documentCategory IN (2,6) THEN @issueDate --FZ, FKZ
					--WHEN @documentCategory IN (0) THEN @issueDate
					--WHEN @documentCategory IN (0) THEN @issueDate
					--WHEN @documentCategory IN (0) THEN @issueDate
					ELSE @issueDate END
					
	RETURN @return
	END
' 
END

GO
