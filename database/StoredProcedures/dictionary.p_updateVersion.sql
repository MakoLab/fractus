/*
name=[dictionary].[p_updateVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
4CES0H1hdcgAidRR7xpcng==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_updateVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_updateVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_updateVersion]
@tableName VARCHAR (255)
AS
DECLARE @rowcount INT
    BEGIN
        
        
        /*Aktualizacja wersji słowników*/
        UPDATE  dictionary.DictionaryVersion
        SET     versionNumber = versionNumber + 1,
				version = newid()
        WHERE   tableName = @tableName
        
        /*Pobranie liczby wierszy*/
        SET @rowcount = @@ROWCOUNT
        
        /*Obsługa błędów i wyjątków*/
        IF @@ERROR <> 0 
            BEGIN
                 RAISERROR ( 50012, 16, 1 )
            END
        ELSE 
            BEGIN
                
                IF @rowcount = 0 
                    RAISERROR ( 50012, 16, 1 )
            END
    END
' 
END
GO
