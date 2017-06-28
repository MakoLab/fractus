/*
name=[repository].[p_checkFileDescriptorVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
iE6/D3Z31OtIEX6m+BUECg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[repository].[p_checkFileDescriptorVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [repository].[p_checkFileDescriptorVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[repository].[p_checkFileDescriptorVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [repository].[p_checkFileDescriptorVersion]
    @version UNIQUEIDENTIFIER
AS 
    BEGIN

		/*Walidacja wersji*/
        IF NOT EXISTS ( SELECT  id
                        FROM    repository.FileDescriptor
                        WHERE   FileDescriptor.version = @version ) 
            RAISERROR ( 50012, 16, 1 )

    END
' 
END
GO
