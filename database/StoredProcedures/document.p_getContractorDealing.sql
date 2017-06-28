/*
name=[document].[p_getContractorDealing]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
JMMlb5cZ/USlF3kjzwt7Jg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getContractorDealing]') AND type in (N'P', N'PC'))
DROP PROCEDURE [document].[p_getContractorDealing]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[document].[p_getContractorDealing]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [document].[p_getContractorDealing]
@xmlVar XML
AS
BEGIN

DECLARE 
@contractorId UNIQUEIDENTIFIER,
@date DATETIME,
@value numeric(18,2)


SELECT 
	@contractorId = x.query(''contractorId'').value(''.'',''char(36)''),
	@date = x.query(''date'').value(''.'',''datetime'')
FROM @xmlVar.nodes(''root'') AS a( x )


SELECT @value = SUM(ch.netValue)  
FROM document.CommercialDocumentHeader ch WITH (NOLOCK)
	JOIN dictionary.DocumentType dt WITH(NOLOCK) ON ch.documentTypeId = dt.id
WHERE dt.documentCategory = 0 AND ch.contractorId = @contractorId AND ch.issueDate >= @date AND ch.status >= 40

SELECT ISNULL(@value,0)
FOR XML PATH(''root''), TYPE

END
' 
END
GO
