/*
name=[dictionary].[p_checkItemFieldVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
fzL31oIPDwu5veP0nTJb/Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_checkItemFieldVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_checkItemFieldVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_checkItemFieldVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_checkItemFieldVersion]
    @version UNIQUEIDENTIFIER
AS 
    BEGIN

		/*Walidacja wersji*/        
        IF NOT EXISTS ( SELECT  id
                        FROM    dictionary.ItemField
                        WHERE   ItemField.version = @version ) 
            RAISERROR ( 50012, 16, 1 )

    END
' 
END
GO
