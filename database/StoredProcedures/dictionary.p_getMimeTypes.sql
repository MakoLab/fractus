/*
name=[dictionary].[p_getMimeTypes]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
KZzpuPUEazas0F48qVmqcg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getMimeTypes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getMimeTypes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getMimeTypes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getMimeTypes]
AS 
	/*Budowa XML z MimeType*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    id,
                                                name,
                                                extensions,
                                                version
                                      FROM      dictionary.MimeType
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''mimeType''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO
