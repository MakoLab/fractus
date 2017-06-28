/*
name=[dictionary].[p_getDocumentStatuses]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
bgeyuaSjIiqN4vk1z9LctA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getDocumentStatuses]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getDocumentStatuses]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getDocumentStatuses]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getDocumentStatuses]
AS 
	/* Budowa XML z statusami dokumentów */
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      dictionary.DocumentStatus
                                     
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''documentStatus''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO
