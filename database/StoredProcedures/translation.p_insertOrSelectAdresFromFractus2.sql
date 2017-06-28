/*
name=[translation].[p_insertOrSelectAdresFromFractus2]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
NdvHq+OBF2erAKET7ugJ5A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertOrSelectAdresFromFractus2]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_insertOrSelectAdresFromFractus2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertOrSelectAdresFromFractus2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [translation].[p_insertOrSelectAdresFromFractus2]
@fractus2Id uniqueidentifier,
@branchSymbol VARCHAR(20)
AS
BEGIN
	DECLARE @prefix int

	IF NOT EXISTS( 	SELECT megaId
				FROM [translation].[Adres] 
				WHERE fractus2Id = @fractus2Id
			)
		BEGIN

			SELECT @prefix = prefix 
			FROM translation.BranchAttributes ba 
				INNER JOIN dictionary.Branch db ON ba.branchId = db.id 
			WHERE db.symbol = @branchSymbol

			INSERT INTO [translation].[Adres](fractus2Id, megaId,megaGID ) 
			SELECT @fractus2Id,  @branchSymbol + CAST(IDENT_CURRENT(''[translation].[Adres]'') AS VARCHAR(18)), (@prefix * 1000000000000000) + IDENT_CURRENT(''[translation].[Adres]'')

		END	

	SELECT  megaId,  megaGID 
	FROM [translation].[Adres] 
	WHERE fractus2Id = @fractus2Id


END
' 
END
GO
