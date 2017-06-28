/*
name=[translation].[p_synchronizeContractorAkronim]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
e8jecr4OteSH0V5da8qC+w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_synchronizeContractorAkronim]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_synchronizeContractorAkronim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_synchronizeContractorAkronim]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [translation].[p_synchronizeContractorAkronim]
@LinkSerwerKropkaBaza varchar(100)
AS
BEGIN
	DECLARE @sql varchar(max)

	SELECT @sql = ''

	SET NOCOUNT OFF

	BEGIN TRAN
	DECLARE @tmp TABLE (idMM varchar(50),id uniqueidentifier, akronimf1 varchar(50),  akronimf2 varchar(50))
	DECLARE @externalSystemName varchar(10), @mess varchar(4000) ,@x XML, @row INT
	  
	INSERT INTO @tmp
	SELECT  sk.idMM,  c.id, sk.akronim, ex.externalId
	FROM contractor.Contractor c 
		JOIN [translation].[Kontrahent] k ON c.id = k.fractus2Id
		JOIN '' + @LinkSerwerKropkaBaza + ''.dbo.Kontrahent sk ON k.megaId = sk.idMM
		LEFT JOIN accounting.ExternalMapping ex ON ex.id = c.id
	WHERE ISNULL(sk.akronim,'''''''') <> ISNULL(ex.externalId,'''''''')
	
	IF @@rowcount > 0 
		BEGIN
			SELECT TOP 1 @externalSystemName = externalSystemName
			FROM accounting.ExternalMapping 

			INSERT INTO  accounting.ExternalMapping( id,externalId, exportDate, externalSystemName, objectType)
			SELECT id,  akronimf1, getdate(), ISNULL(@externalSystemName, ''''test'''') ,4
			FROM @tmp 
			WHERE akronimf2 IS NULL
			SELECT @row = @@rowcount
			IF @@error <> 0 
				BEGIN
				PRINT ''''Jakiś błąd przy wstawianiu akronimów w f2''''
				ROLLBACK TRAN	
				END
			
			SELECT @mess = ''''Wstawiono :'''' + cast(@row as varchar(50)) + '''' akronimów w f2 ''''

			PRINT @mess

			SELECT @x = (
			   SELECT 
			   (
				   SELECT  t.akronimf2 AS ''''@akronim'''' , idMM AS ''''@idMM''''
				   FROM @tmp t 
				   WHERE NULLIF(RTRIM(t.akronimf1),'''''''') IS NULL      
				   FOR XML PATH(''''line''''), TYPE      
				  )
				FOR XML PATH(''''root''''),TYPE
				)
				SELECT @x   

			IF @@error <> 0 
			BEGIN
			PRINT ''''Jakiś błąd przy wstawianiu akronimów w f1''''
			ROLLBACK TRAN	
			END
			
			SELECT @mess = ''''Wstawiono :'''' + cast(@@rowcount as varchar(50)) + '''' akronimów w f1 ''''
			PRINT @mess
			
		END
		
		IF @@error <> 0
		ROLLBACK TRAN
		ELSE
		COMMIT TRAN
		
		''
		--select @sql
	EXEC(@sql)
	
	

END
' 
END
GO
