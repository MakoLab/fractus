IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Concatenate]') AND type = N'AF')
EXEC dbo.sp_executesql @statement =
N'CREATE AGGREGATE [dbo].[Concatenate]
(@value [nvarchar](4000))
RETURNS[nvarchar](4000)
EXTERNAL NAME [Concatenate].[Concatenate]
'
GO
