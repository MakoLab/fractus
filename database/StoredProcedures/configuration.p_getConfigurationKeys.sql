/*
name=[configuration].[p_getConfigurationKeys]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
lOXAIypK1fIEGd18asO7tg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_getConfigurationKeys]') AND type in (N'P', N'PC'))
DROP PROCEDURE [configuration].[p_getConfigurationKeys]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[configuration].[p_getConfigurationKeys]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE configuration.p_getConfigurationKeys
AS
BEGIN
	SELECT (SELECT (

				SELECT	id, [key], companyContractorId, branchId, userProfileId, workstationId, applicationUserId, textValue, [version]
				  FROM	configuration.Configuration
						
				  ORDER BY ISNULL( CAST(companyContractorId AS char(36)) ,''1''),
						   ISNULL( CAST(branchId AS char(36)) ,''1''),
						   ISNULL( CAST(userProfileId AS char(36)) ,''1''),
						   ISNULL( CAST(workstationId AS char(36)) ,''1''),
						   ISNULL( CAST(applicationUserId AS char(36)) ,''1'')
				FOR XML PATH(''entry''), TYPE)

			FOR
			  XML PATH(''configuration''),
				  TYPE
			)
	FOR     XML PATH(''root''),
				TYPE
END
' 
END
GO
