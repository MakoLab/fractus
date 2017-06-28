/*
name=[custom].[p_getCommercialDocuments]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
4sUm9NJbUs84E+1dt4SYIg==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getCommercialDocuments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_getCommercialDocuments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getCommercialDocuments]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE procedure [custom].[p_getCommercialDocuments]
	@xmlVar xml = NULL
as
declare @dateFrom datetime, @dateTo datetime

SELECT  
        @dateFrom = NULLIF(x.query(''dateFrom'').value(''.'', ''datetime''),''''),
        @dateTo = NULLIF(x.query(''dateTo'').value(''.'', ''datetime''),'''')
FROM    @xmlVar.nodes(''/*'') a(x)

select fullNumber [Numer], issueDate [Data], netValue [Wart. netto], grossValue [Wart. brutto], id
from document.commercialdocumentheader
where issuedate >= ''2011-01-01'' and issuedate >= isnull(@dateFrom, issuedate) and issuedate <= isnull(@dateTo, issueDate)

select NULL, NULL, sum(netValue) [Wart. netto], sum(grossValue) [Wart. brutto], NULL
from document.commercialdocumentheader
where issuedate >= ''2011-01-01'' and issuedate >= isnull(@dateFrom, issuedate) and issuedate <= isnull(@dateTo, issueDate)
' 
END
GO
