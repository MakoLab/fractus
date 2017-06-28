/*
name=[translation].[p_insertOrSelectKontrahentFromFractus2]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
PcA+fxP9ixDEj2ed/bYCFw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertOrSelectKontrahentFromFractus2]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_insertOrSelectKontrahentFromFractus2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_insertOrSelectKontrahentFromFractus2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [translation].[p_insertOrSelectKontrahentFromFractus2]
@fractus2Id UNIQUEIDENTIFIER, @branchSymbol VARCHAR (20)
AS
BEGIN
	DECLARE @megaId VARCHAR(50)
	DECLARE @megaGID NUMERIC(18, 0)

	SELECT @megaId = megaId, @megaGID = megaGID 
		FROM [translation].[Kontrahent] 
		WHERE fractus2Id = @fractus2Id

	IF @megaId IS NULL
		BEGIN
			DECLARE @assignedId NUMERIC(18, 0)
			DECLARE @prefix int
			
				INSERT INTO [translation].[Kontrahent](fractus2Id) VALUES(@fractus2Id)

				SELECT @assignedId = scope_identity()

				SET @megaId = @branchSymbol + CAST(@assignedId AS VARCHAR(18))

				SELECT @prefix = prefix 
					FROM translation.BranchAttributes ba 
					INNER JOIN dictionary.Branch db 
					ON ba.branchId = db.id 
					WHERE db.symbol = @branchSymbol

				SET @megaGID = (@prefix * 1000000000000000) + @assignedId

				UPDATE [translation].[Kontrahent] 
					SET megaId = @megaId, megaGID = @megaGID 
					WHERE id=@assignedId
			
		END	

SELECT @megaId AS megaId, @megaGID AS megaGID

END
' 
END
GO
