/*
name=[contractor].[p_getContractorByFullNameAndPostCode]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
FxrZJL4qQHdVJMPmakw7jQ==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorByFullNameAndPostCode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getContractorByFullNameAndPostCode]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorByFullNameAndPostCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_getContractorByFullNameAndPostCode] 
@xmlVar XML
AS
BEGIN
DECLARE 
	@code varchar(50),
	@fullName nvarchar(500),
	@contractorId uniqueidentifier

SELECT  @code = x.query(''postCode'').value(''.'',''varchar(50)''),
		@fullName = x.query(''fullName'').value(''.'',''varchar(50)'')
FROM @xmlVar.nodes(''root'') as a ( x ) 

SELECT TOP 1 @contractorId = id 
FROM contractor.Contractor c
WHERE c.fullName = @fullName 
	AND c.id IN (
				SELECT contractorId 
				FROM contractor.ContractorAddress ca
				WHERE REPLACE(RTRIM(ca.postCode),''-'','''') = REPLACE(RTRIM(@code),''-'','''')
				)

IF @contractorId IS NOT NULL
	EXEC contractor.p_getContractorData @contractorId	
ELSE
	SELECT CAST(''<root></root>'' AS XML )

END
' 
END
GO
