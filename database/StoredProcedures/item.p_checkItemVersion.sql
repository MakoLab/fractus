/*
name=[item].[p_checkItemVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
W0TbGe2ucViQnp8zH3L+yw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_checkItemVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [item].[p_checkItemVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[item].[p_checkItemVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [item].[p_checkItemVersion]
    @version UNIQUEIDENTIFIER
AS 
    BEGIN

		/*Walidacja danych*/
        IF NOT EXISTS ( SELECT  id
                        FROM    item.Item
                        WHERE   Item.version = @version ) 
            RAISERROR ( 50012, 16, 1 )

    END
' 
END
GO
