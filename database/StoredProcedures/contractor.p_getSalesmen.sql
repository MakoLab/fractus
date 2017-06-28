/*
name=[contractor].[p_getSalesmen]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
SYaulZ7/VnNxM98RaKBXRw==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getSalesmen]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getSalesmen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getSalesmen]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [contractor].[p_getSalesmen]  --''<labels><label lang="pl">Sprzedawca</label></labels>''
	@xmlVar xml
AS
IF EXISTS (SELECT * FROM sys.procedures where SCHEMA_NAME(schema_id) = ''custom'' AND name = ''p_getSalesmen'')
	EXEC custom.[p_getSalesmen] @xmlVar
ELSE
	BEGIN
	DECLARE @job uniqueidentifier, @salesmanFieldId uniqueidentifier
	SELECT @salesmanFieldId = id FROM dictionary.ContractorField WHERE name like ''Attribute_IsSalesman''
	
	SELECT @job = id 
	FROM [dictionary].[JobPosition] 
	WHERE xmlLabels.value(''(labels/label[@lang="pl"])[1]'' ,''varchar(50)'') = ''Sprzedawca''

	SELECT (
		SELECT x.id as ''@id'', x.fullName  as ''@label''
		FROM (
			SELECT c.id , c.fullName
			FROM contractor.Contractor c 
				JOIN contractor.ContractorAttrValue v ON c.id = v.contractorId  AND v.contractorFieldId = @salesmanFieldId
				JOIN contractor.Employee e ON c.id = e.contractorId
			WHERE e.jobPositionId = @job --and c.isReceiver = 0
		) x


	ORDER BY x.fullName 
	FOR XML PATH(''salesmen''),TYPE
) FOR XML PATH(''root''),TYPE

	END
' 
END
GO
