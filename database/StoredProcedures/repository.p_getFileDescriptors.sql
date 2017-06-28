/*
name=[repository].[p_getFileDescriptors]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
vLkgoyQSJ3O9cu+7kNocYw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[repository].[p_getFileDescriptors]') AND type in (N'P', N'PC'))
DROP PROCEDURE [repository].[p_getFileDescriptors]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[repository].[p_getFileDescriptors]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [repository].[p_getFileDescriptors] @xmlVar XML
AS 

	/*Budowanie XML z danymi o plikach*/
    SELECT  ( SELECT    ( SELECT    id as ''@id'',
									originalFilename as ''@originalFilename''
                          FROM      repository.FileDescriptor
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
