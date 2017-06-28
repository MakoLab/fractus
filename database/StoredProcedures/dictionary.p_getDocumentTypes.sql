/*
name=[dictionary].[p_getDocumentTypes]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
SNGoHm/qhJu+wVRxLfJrcQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getDocumentTypes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getDocumentTypes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getDocumentTypes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getDocumentTypes]
AS 
	/*Budowanie XML z typami dokumentów*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.DocumentType
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''documentType''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO
