/*
name=[contractor].[p_getEmployees]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
T7+MgzzVdi0v5yTykA7TsQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getEmployees]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getEmployees]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getEmployees]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_getEmployees] --''<root><jobPositionId>6A541B99-DAAE-4526-A92C-1B7FFB8CBBA1</jobPositionId></root>''
@xmlVar XML
AS
BEGIN
DECLARE @jobPosition uniqueidentifier
SELECT @jobPosition = NULLIF(@xmlVar.query(''root/jobPositionId'').value(''.'',''char(36)''),'''')

SELECT (
	SELECT c.id, fullName, shortName, code, jobPositionId
	FROM contractor.Employee e 
		JOIN contractor.Contractor c ON e.contractorId = c.id
	WHERE (@jobPosition IS NOT NULL AND  e.jobPositionId = @jobPosition) OR (@jobPosition IS NULL)	
	FOR XML PATH(''entry''), TYPE )
FOR XML PATH(''employee''), TYPE		
END
' 
END
GO
