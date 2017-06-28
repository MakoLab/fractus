/*
name=[dictionary].[p_checkRepositoryVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
f9wsOy7jftMx71iPKJyWlQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_checkRepositoryVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_checkRepositoryVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_checkRepositoryVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_checkRepositoryVersion]
    @version UNIQUEIDENTIFIER
AS 
    BEGIN

		/*Walidacja wersji*/
        IF NOT EXISTS ( SELECT  id
                        FROM    dictionary.Repository
                        WHERE   Repository.version = @version ) 
            RAISERROR ( 50012, 16, 1 )

    END
' 
END
GO
