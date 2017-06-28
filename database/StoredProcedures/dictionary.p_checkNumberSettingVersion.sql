/*
name=[dictionary].[p_checkNumberSettingVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
y9T6HJMXZyUqxKq7p8dC4Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_checkNumberSettingVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_checkNumberSettingVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_checkNumberSettingVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_checkNumberSettingVersion]
    @version UNIQUEIDENTIFIER
AS 
    BEGIN
		
		/*Walidacja wersji ustawien numeracji*/
        IF NOT EXISTS ( SELECT  id
                        FROM    dictionary.NumberSetting
                        WHERE   NumberSetting.version = @version ) 
            RAISERROR ( 50012, 16, 1 )

    END
' 
END
GO
