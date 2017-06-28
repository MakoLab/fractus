/*
name=[contractor].[p_getBankByNumber]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
0iOdnlrbWIB3PXtYPjo6GA==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getBankByNumber]') AND type in (N'P', N'PC'))
DROP PROCEDURE [contractor].[p_getBankByNumber]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[contractor].[p_getBankByNumber]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [contractor].[p_getBankByNumber] --''<root>123</root>''
@xmlVar XML
AS
SELECT (
	SELECT c.id , c.fullName, c.shortName , bankNumber
	FROM contractor.Contractor  c WITH (NOLOCK)
		LEFT JOIN contractor.Bank b WITH (NOLOCK) on c.id = b.contractorId
	WHERE c.isBank = 1 AND b.bankNumber LIKE @xmlVar.query(''root'').value(''.'',''varchar(50)'') + ''%''
	FOR XML PATH(''bank''), TYPE
) FOR XML PATH(''root''), TYPE
' 
END
GO
