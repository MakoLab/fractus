/*
name=[repository].[p_getFileDescriptor]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
pL8jJXDDAAqt7CpNY9bErg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[repository].[p_getFileDescriptor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [repository].[p_getFileDescriptor]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[repository].[p_getFileDescriptor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [repository].[p_getFileDescriptor] @id UNIQUEIDENTIFIER
AS 

	/*Budowanie XML z danymi o plikach*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    *
                                      FROM      repository.FileDescriptor
                                      WHERE     id = @id
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''fileDescriptor''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO
