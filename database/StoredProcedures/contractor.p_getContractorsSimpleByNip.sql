/*
name=[contractor].[p_getContractorsSimpleByNip]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
dY2OAE+AHUezfaQjLxWS/g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorsSimpleByNip]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getContractorsSimpleByNip]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorsSimpleByNip]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [contractor].[p_getContractorsSimpleByNip] -- ''<root><nip>8790172313</nip></root>''
@xmlVar XML
AS
BEGIN
DECLARE 
	@nip varchar(50),
	@contractorId uniqueidentifier

SELECT  @nip = x.query(''nip'').value(''.'',''varchar(50)'')
FROM @xmlVar.nodes(''root'') as a ( x ) 
SELECT (
	SELECT (
	SELECT id,nip, shortName
	FROM contractor.Contractor c
	WHERE c.strippedNip = REPLACE(@nip,''-'','''')
	FOR XML PATH(''entry''), TYPE
	) FOR XML PATH(''contractor''),  TYPE
) FOR XML PATH(''root''),TYPE

END
' 
END
GO
