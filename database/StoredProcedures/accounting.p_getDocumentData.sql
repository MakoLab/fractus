/*
name=[accounting].[p_getDocumentData]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Wq8ESz6IKBbsNiwpXci2Ow==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_getDocumentData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [accounting].[p_getDocumentData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[accounting].[p_getDocumentData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [accounting].[p_getDocumentData]
@xmlVar XML
AS

DECLARE 
@commercialDocumentId UNIQUEIDENTIFIER,
@warehouseDocumentId UNIQUEIDENTIFIER,
@financialDocumentId UNIQUEIDENTIFIER


SELECT @warehouseDocumentId = NULLIF(x.query(''warehouseDocumentId'').value(''.'',''char(36)''),''''),
@commercialDocumentId = NULLIF(x.query(''commercialDocumentId'').value(''.'',''char(36)''),''''),
@financialDocumentId = NULLIF(x.query(''financialDocumentId'').value(''.'',''char(36)''),'''')
FROM @xmlVar.nodes(''*'') AS a(x)

	/*Pobranie danych o bankach*/
    SELECT  ( SELECT    ( SELECT    *
                          FROM     accounting.DocumentData
						  WHERE (@warehouseDocumentId IS NOT NULL AND warehouseDocumentId = @warehouseDocumentId)
							OR (@commercialDocumentId IS NOT NULL AND commercialDocumentId = @commercialDocumentId)
							OR (@financialDocumentId IS NOT NULL AND financialDocumentId = @financialDocumentId)
                        FOR XML PATH(''documentData''),TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnXML




/****** Object:  StoredProcedure [accounting].[p_getFinancialReport]    Script Date: 11/19/2009 11:16:51 ******/
SET ANSI_NULLS ON



set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
' 
END
GO
