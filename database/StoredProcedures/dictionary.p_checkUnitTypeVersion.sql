/*
name=[dictionary].[p_checkUnitTypeVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
YVlKzVvOMePpRHSwpsdYqw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_checkUnitTypeVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_checkUnitTypeVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_checkUnitTypeVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_checkUnitTypeVersion]
    @version UNIQUEIDENTIFIER
AS 
    BEGIN

		/*Walidacja wersji*/
        IF NOT EXISTS ( SELECT  id
                        FROM    dictionary.UnitType
                        WHERE   UnitType.version = @version ) 
            RAISERROR ( 50012, 16, 1 )

    END
' 
END
GO
