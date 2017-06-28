/*
name=[translation].[p_insertContractorGroupMembership]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
SlTmytE9hWs9e9KswYbA2Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertContractorGroupMembership]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_insertContractorGroupMembership]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertContractorGroupMembership]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [translation].[p_insertContractorGroupMembership]
@serverName VARCHAR (50), @dbName VARCHAR (50), @translationServer VARCHAR (50), @dbTranslation VARCHAR (50)
AS
BEGIN
	DECLARE @query NVARCHAR(1500)
	DELETE FROM contractor.ContractorGroupMembership
	SELECT @query = ''INSERT INTO contractor.ContractorGroupMembership (id, contractorId, contractorGroupId, version)
		SELECT newid(), fractus2Id, groupId, newid()
		FROM 
		[''+@serverName+''].''+@dbName+''.dbo.Grupy G
		INNER JOIN [''+@serverName+''].''+@dbName+''.dbo.GrupyDef GD ON GD.id = G.id_grupy AND GD.wsk = ''''K''''
		INNER JOIN [''+@translationServer+''].''+@dbTranslation+''.dbo.ContractorGroup IG ON IG.megaId = GD.id
		INNER JOIN translation.Kontrahent TT ON G.id_tabeli = (SELECT id FROM [''+@serverName+''].''+@dbName+''.dbo.Kontrahent WHERE idMM = TT.megaId)''
	EXEC(@query)
END
' 
END
GO
