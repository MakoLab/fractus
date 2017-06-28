/*
name=[contractor].[p_getApplicationUsers]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
v8fl2t95rtpZMy/37Bd+Qg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getApplicationUsers]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getApplicationUsers]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getApplicationUsers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_getApplicationUsers]
@xmlVar XML
AS

	/*Budowa XML z danymi o uzytkownikach*/
	
		    SELECT  ( SELECT    (   SELECT	*
									FROM contractor.v_applicationUsers  WITH ( NOLOCK )
									ORDER BY shortName
                        FOR XML PATH(''entry''),  TYPE
                        )
            FOR XML PATH(''applicationUsers''), TYPE
	
            ) AS returnsXML
	
	
	    --SELECT  ( SELECT    ( SELECT	id,
     --                               login,
					--				code,
					--				shortName,
					--				permissionProfile,
					--				ISNULL(REPLACE([password],[password],1),0) isActive
     --                     FROM      contractor.ApplicationUser au WITH ( NOLOCK )
					--		JOIN contractor.Contractor c WITH ( NOLOCK ) ON au.contractorId = c.id
     --                   FOR
     --                     XML PATH(''entry''),
     --                         TYPE
     --                   )
     --       FOR
     --         XML PATH(''applicationUsers''),
     --             TYPE
	
     --       ) AS returnsXML
            
    /*Zoptymalizowane stage 1 :)*/        
    --SELECT  ( SELECT    ( SELECT	id,
    --                                login,
				--					code,
				--					shortName,
				--					permissionProfile,
				--					CASE WHEN password IS NULL THEN 0 ELSE 1 END isActive
    --                      FROM      contractor.ApplicationUser au WITH ( NOLOCK )
				--			JOIN contractor.Contractor c WITH ( NOLOCK ) ON au.contractorId = c.id
    --                    FOR
    --                      XML PATH(''entry''),
    --                          TYPE
    --                    )
    --        FOR
    --          XML PATH(''applicationUsers''),
    --              TYPE

    --        ) AS returnsXML
' 
END
GO
