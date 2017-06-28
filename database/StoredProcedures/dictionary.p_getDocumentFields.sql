/*
name=[dictionary].[p_getDocumentFields]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
YhJGsIpsWQ/aExRXKbT5LQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getDocumentFields]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getDocumentFields]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getDocumentFields]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getDocumentFields]
AS 
	/*Budowa XML z polami dodatkowymi dokumentów*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.DocumentField
                                      ORDER BY  [order]
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''documentField''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO
