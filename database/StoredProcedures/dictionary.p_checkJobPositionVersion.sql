/*
name=[dictionary].[p_checkJobPositionVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
YOvWnIVh0Y5NW+lhPeBttQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_checkJobPositionVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_checkJobPositionVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_checkJobPositionVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_checkJobPositionVersion]
    @version UNIQUEIDENTIFIER
AS 
    BEGIN

		/*Walidacja wersji*/
        IF NOT EXISTS ( SELECT  id
                        FROM    dictionary.JobPosition
                        WHERE   JobPosition.version = @version ) 
            RAISERROR ( 50012, 16, 1 )

    END
' 
END
GO
