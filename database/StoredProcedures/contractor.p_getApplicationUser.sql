/*
name=[contractor].[p_getApplicationUser]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Zhrxxc/z1DcO57tto6rzIQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getApplicationUser]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getApplicationUser]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getApplicationUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [contractor].[p_getApplicationUser] @login NVARCHAR(50)
AS 
	/*Budowa XML z danymi o uzytkownikach*/
    SELECT  ( SELECT    ( SELECT    ( SELECT    contractorId,
                                                login,
                                                password,
                                                version,
												permissionProfile
                                      FROM      contractor.ApplicationUser
                                      WHERE     login = @login
										AND (restrictDatabaseId IS NULL OR restrictDatabaseId = (SELECT textValue FROM configuration.Configuration WHERE [key] like ''communication.DatabaseId''))
                                    FOR
                                      XML PATH(''entry''),
                                          TYPE
                                    )
                        FOR
                          XML PATH(''applicationUser''),
                              TYPE
                        )
            FOR
              XML PATH(''root''),
                  TYPE
            ) AS returnsXML
' 
END
GO
