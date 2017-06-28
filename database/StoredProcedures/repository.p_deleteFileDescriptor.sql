/*
name=[repository].[p_deleteFileDescriptor]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
BS6IkTPXRXYb6ktagQjqig==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[repository].[p_deleteFileDescriptor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [repository].[p_deleteFileDescriptor]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[repository].[p_deleteFileDescriptor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [repository].[p_deleteFileDescriptor]
@id UNIQUEIDENTIFIER
AS
DECLARE @errorMsg VARCHAR(2000),
        @rowcount INT

    
    
    /*Kasowanie danych o opisie plików*/
    DELETE  FROM repository.FileDescriptor
    WHERE   id = @id

	/*Pobranie liczby wierszy*/
    SET @rowcount = @@ROWCOUNT
    
    /*Obsługa błędów i wyjątków*/
    IF @@ERROR <> 0 
        BEGIN
            
            SET @errorMsg = ''Błąd kasowania danych:FileDescriptor; error:''
                + CAST(@@error AS VARCHAR(50)) + ''; ''
            RAISERROR ( @errorMsg, 16, 1 )
        END
    ELSE 
        BEGIN
            
            IF @rowcount = 0 
                RAISERROR ( 50012, 16, 1 ) ;
        END
' 
END
GO
