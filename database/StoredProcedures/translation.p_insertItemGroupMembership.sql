/*
name=[translation].[p_insertItemGroupMembership]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
r1ieRbClfMMie1nNA/ufDw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertItemGroupMembership]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_insertItemGroupMembership]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertItemGroupMembership]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [translation].[p_insertItemGroupMembership] @serverName VARCHAR(50), @dbName VARCHAR(50), @translationServer VARCHAR(50), @dbTranslation VARCHAR(50) AS
BEGIN
	DECLARE @query NVARCHAR(1500)
	DELETE FROM item.ItemGroupMembership
	SELECT @query = ''INSERT INTO item.ItemGroupMembership (id, itemId, itemGroupId, version)
		SELECT newid(), fractus2Id, groupId, newid()
		FROM 
		[''+@serverName+''].''+@dbName+''.dbo.Grupy G
		INNER JOIN [''+@serverName+''].''+@dbName+''.dbo.GrupyDef GD ON GD.id = G.id_grupy AND GD.wsk = ''''T''''
		INNER JOIN [''+@translationServer+''].''+@dbTranslation+''.dbo.ItemGroup IG ON IG.megaId = GD.id
		INNER JOIN translation.Towary TT ON G.id_tabeli = (SELECT id FROM [''+@serverName+''].''+@dbName+''.dbo.Towary WHERE idMM = TT.megaId)''
	EXEC(@query)
END
' 
END
GO
