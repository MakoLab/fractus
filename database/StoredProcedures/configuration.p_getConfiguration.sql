/*
name=[configuration].[p_getConfiguration]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
VRrlUgWv+NQ0qde/0fPgqQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_getConfiguration]') AND type in (N'P', N'PC'))
DROP PROCEDURE [configuration].[p_getConfiguration]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_getConfiguration]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [configuration].[p_getConfiguration] @xmlVar XML
AS 


	/*Deklaracja zmiennych*/	
    DECLARE @confCount INT,
        @returnXML XML,
        @applicationUserId char(36),
        @workstationId char(36),
        @userProfileId char(36),
        @branchId char(36),
        @companyContractorId char(36),
        @idoc int
	
	
	DECLARE @tmp_ TABLE ( key_ varchar(100))
	
	
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlVar
	
	INSERT INTO @tmp_
	SELECT
		[entry]
	FROM OPENXML(@idoc, ''root/entry'')
					WITH(
						[entry] varchar(100) ''.''
						)

	EXEC sp_xml_removedocument @idoc
	
	
	/*Pobranie liczby wpisów z XML*/
    SELECT  @confCount = COUNT(DISTINCT CK.[key])
    FROM    configuration.Configuration CK
            JOIN @tmp_ x ON CK.[key] LIKE REPLACE(x.key_, ''*'', ''%'')
   -- GROUP BY CK.[key]
	
	/*Pobranie liczby wpisów z XML*/
    --SELECT  @confCount = COUNT(*)
    --FROM    @xmlVar.nodes(''root/entry'') a ( x ) 
	
	
	SELECT 
		@applicationUserId = NULLIF(x.value(''(@applicationUserId)[1]'', ''char(36)''), ''''),
		@workstationId = NULLIF(x.value(''(@workstationId)[1]'', ''char(36)''), ''''),
		@userProfileId = NULLIF(x.value(''(@userProfileId)[1]'', ''char(36)''), ''''),
		@branchId = NULLIF(x.value(''(@branchId)[1]'', ''char(36)''), ''''),
		@companyContractorId = NULLIF(x.value(''(@companyContractorId)[1]'', ''char(36)''), '''')		
	FROM @xmlVar.nodes(''root'') AS a ( x )
	
	--select @applicationUserId
	/*Warunek na istnienie wpisów*/
    IF @confCount IS NOT NULL 
        BEGIN
			/*Budowa XML z danymi o konfiguracji z zachowaniem hierarchii*/
            SELECT  @returnXML = ( SELECT   ( SELECT TOP ( @confCount )
                                                        entry.*
                                              FROM      configuration.Configuration entry
                                                        JOIN @tmp_ x ON [entry].[key] LIKE REPLACE(x.key_, ''*'', ''%'')
                                              WHERE  ( (@applicationUserId IS NOT NULL) AND ( ISNULL(applicationUserId, @applicationUserId) = @applicationUserId)  OR @applicationUserId IS NULL) 
													AND ( (@companyContractorId IS NOT NULL) AND ( ISNULL(companyContractorId, @companyContractorId) = @companyContractorId)  OR @companyContractorId IS NULL) 
													AND ( (@branchId IS NOT NULL) AND ( ISNULL(branchId, @branchId) = @branchId)  OR @branchId IS NULL) 
													AND ( (@userProfileId IS NOT NULL) AND ( ISNULL(userProfileId, @userProfileId) = @userProfileId)  OR @userProfileId IS NULL) 
													AND ( (@workstationId IS NOT NULL) AND ( ISNULL(workstationId, @workstationId) = @workstationId)  OR @workstationId IS NULL)
													
                                              ORDER BY  ISNULL( NULLIF( ISNULL( CAST(companyContractorId AS char(36)) ,''1'') ,@companyContractorId),''0''),
                                                        ISNULL( NULLIF( ISNULL( CAST(branchId AS char(36)) ,''1'') ,@branchId),''0''),
                                                        ISNULL( NULLIF( ISNULL( CAST(userProfileId AS char(36)) ,''1'') ,@userProfileId),''0''),
                                                        ISNULL( NULLIF( ISNULL( CAST(workstationId AS char(36)) ,''1'') ,@workstationId),''0''),
                                                        ISNULL( NULLIF( ISNULL( CAST(applicationUserId AS char(36)) ,''1'') ,@applicationUserId),''0'')
                                            FOR XML PATH(''entry''), TYPE
                                            )
                                 )
--select @confCount
			/*Zwrócenie wyników*/
            SELECT  ( SELECT    @returnXML
                    FOR
                      XML PATH(''configuration''),
                          TYPE
                    )
            FOR     XML PATH(''root''),
                        TYPE
        END
    ELSE
		/*Zwrócenie wyniku pustej konfiguracji*/ 
        SELECT  CAST(''<root><configuration></configuration></root>'' AS XML)
' 
END
GO
