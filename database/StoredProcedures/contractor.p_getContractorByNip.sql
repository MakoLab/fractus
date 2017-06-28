/*
name=[contractor].[p_getContractorByNip]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
lbFkr0nLvz4SsNPM1WJr2Q==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorByNip]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getContractorByNip]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getContractorByNip]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_getContractorByNip] 
@xmlVar XML
AS
BEGIN
DECLARE 
	@nip varchar(50),
	@contractorId uniqueidentifier

SELECT  @nip = x.query(''nip'').value(''.'',''varchar(50)'')
FROM @xmlVar.nodes(''root'') as a ( x ) 

SELECT TOP 1 @contractorId = id 
FROM contractor.Contractor c
WHERE c.strippedNip = REPLACE(@nip,''-'','''')


IF @contractorId IS NOT NULL
	EXEC contractor.p_getContractorData @contractorId	
ELSE
	SELECT CAST(''<root></root>'' AS XML )

END
' 
END
GO
