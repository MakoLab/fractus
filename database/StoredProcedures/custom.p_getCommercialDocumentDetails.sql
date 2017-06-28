/*
name=[custom].[p_getCommercialDocumentDetails]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
Gqq+qZPegq72qluHQYoV6A==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getCommercialDocumentDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [custom].[p_getCommercialDocumentDetails]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[custom].[p_getCommercialDocumentDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'create procedure custom.p_getCommercialDocumentDetails
	@id uniqueidentifier
as
select
	t.xmlLabels.value(''(//label)[1]'', ''varchar(500)'') [Typ dokumentu],
	fullNumber [Numer],
	issueDate [Data wystawienia],
	netValue [Wartość netto],
	vatValue [Wartość VAT],
	grossValue [Wartość brutto],
	c.shortName [Kontrahent]
from
	document.commercialdocumentheader h
	join dictionary.documenttype t on t.id = h.documenttypeid
	left join contractor.contractor c on c.id = h.contractorid
where h.id = @id
' 
END
GO
