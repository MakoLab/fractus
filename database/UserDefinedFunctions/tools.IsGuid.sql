/*
name=[tools].[IsGuid]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
7ZghnjtJvdgoCTyuzRinrg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[IsGuid]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [tools].[IsGuid]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[IsGuid]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE   FUNCTION tools.IsGuid (@@TEXT varchar(256))
RETURNS bit AS  
BEGIN 
 RETURN 
   CASE 
     WHEN @@TEXT
          LIKE replicate(''[0-9abcdefABCDEF]'', 8) + ''-'' +
               replicate(''[0-9abcdefABCDEF]'', 4) + ''-'' +
               replicate(''[0-9abcdefABCDEF]'', 4) + ''-'' +
               replicate(''[0-9abcdefABCDEF]'', 4) + ''-'' +
               replicate(''[0-9abcdefABCDEF]'', 12)
     THEN 1
     ELSE 0
   END
END' 
END

GO
