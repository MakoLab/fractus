/*
name=[tools].[p_getUserMessages]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
HohJHg5PIW0aWLLE811lEg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_getUserMessages]') AND type in (N'P', N'PC'))
DROP PROCEDURE [tools].[p_getUserMessages]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tools].[p_getUserMessages]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tools].[p_getUserMessages] @xmlVar xml
AS
BEGIN
	DECLARE @applicationUserId uniqueidentifier,@branchId uniqueidentifier,  @fromDate datetime, @showAll int, @currentBranch  uniqueidentifier

	SELECT @applicationUserId = NULLIF(x.value(''(applicationUserId)[1]'',''char(36)''),''''),
		   @fromDate = NULLIF(x.value(''(fromDate)[1]'',''varchar(50)''),''''),
		   @showAll =  x.value(''(showAll)[1]'',''int'')
	FROM @xmlVar.nodes(''root'') as a(x)

	SELECT @currentBranch = id 
	FROM dictionary.Branch WITH(NOLOCK) 
	WHERE databaseId in (
				SELECT CAST(textValue as uniqueidentifier) 
				FROM configuration.Configuration WITH(NOLOCK) 
				WHERE [key] = ''communication.DatabaseId''
					)

	SELECT (
			SELECT (
				SELECT (
					SELECT x.*
					FROM tools.UserMessage x
					WHERE 
							( (x.receiverId = @applicationUserId OR x.applicationUserId = @applicationUserId) OR @applicationUserId IS NULL)
							AND (x.receiverBranchId = @currentBranch OR x.receiverBranchId IS NULL)
							AND ((x.[date] >= @fromDate OR (@fromDate IS NULL AND x.receiveDate IS NULL AND @showAll = 0  )) OR @showAll = 1 )
					ORDER BY x.[date]	
					FOR XML PATH(''entry''),TYPE
				) FOR XML PATH(''message''),TYPE
			) FOR XML PATH(''root''),TYPE
			)
END
' 
END
GO
