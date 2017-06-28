/*
name=[complaint].[p_checkComplaintDocumentVersion]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
2ti00ZRbFB5La/+jQMmUfQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_checkComplaintDocumentVersion]') AND type in (N'P', N'PC'))
DROP PROCEDURE [complaint].[p_checkComplaintDocumentVersion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[complaint].[p_checkComplaintDocumentVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [complaint].[p_checkComplaintDocumentVersion]  
    @version UNIQUEIDENTIFIER
AS 
    BEGIN
		/*Walidacja wersji*/
        IF NOT EXISTS ( SELECT  id
                        FROM    [complaint].ComplaintDocumentHeader
                        WHERE   ComplaintDocumentHeader.version = @version ) 
            RAISERROR ( 50012, 16, 1 )

    END
' 
END
GO
