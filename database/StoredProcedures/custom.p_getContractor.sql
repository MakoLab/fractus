/*
name=[custom].[p_getContractor]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
7VmmsKwpMsjVXj5aSZo5Wg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getContractor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_getContractor]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getContractor]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [custom].[p_getContractor] @contractorId UNIQUEIDENTIFIER
AS
SELECT  TOP 1 c.id, c.code, c.fullName,c.shortName, c.nip, ca.city, ca.postCode, ca.postOffice, ca.address
FROM    contractor.Contractor c
	LEFT JOIN contractor.ContractorAddress ca ON c.id = ca.contractorId
WHERE c.id = @contractorId
ORDER BY ca.[order]
' 
END
GO
