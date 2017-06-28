/*
name=[tools].[p_importItem]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
uiTgVS3O3DjEGMADgTf+zw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_importItem]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_importItem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_importItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [tools].[p_importItem]

AS
begin
declare @itemId uniqueidentifier , @i int
declare op cursor for
 
SELECT  tt.id 
FROM MegaManage_LAK_SP_JAWNA.dbo.Towary tt 
LEFT JOIN [translation].Towary  t ON tt.idmm = t.megaId
LEFT JOIN item.Item i ON t.fractus2Id = i.id
WHERE  i.id IS NULL



OPEN op
FETCH NEXT FROM op INTO @i
WHILE @@FETCH_STATUS = 0
       BEGIN
             exec tools.p_dodajTowar  @i, @itemId OUTPUT
 
             FETCH NEXT FROM op INTO @i
       END
CLOSE op DEALLOCATE op
end
' 
END
GO
