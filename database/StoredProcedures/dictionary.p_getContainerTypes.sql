/*
name=[dictionary].[p_getContainerTypes]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
uyCCp09bp3AgtyLah+aVNQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getContainerTypes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dictionary].[p_getContainerTypes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dictionary].[p_getContainerTypes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dictionary].[p_getContainerTypes]
AS 
	/*Budowa XML z kontenerami*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    id,
                                                isSlot,
												isItemContainer,
                                                xmlLabels,
												xmlMetadata,
                                                version,
												[order],
												availability
                                      FROM      dictionary.ContainerType
                                      ORDER BY  [order]
                                    FOR XML PATH(''entry''), TYPE
                                    )
                        FOR XML PATH(''containerType''), TYPE
                        )
            FOR XML PATH(''root''), TYPE
            ) AS returnsXML
' 
END
GO
