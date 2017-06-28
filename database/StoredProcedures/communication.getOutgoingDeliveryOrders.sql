/*
name=[communication].[getOutgoingDeliveryOrders]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
i0rOnD47eWnbAE00DxUJ0g==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[getOutgoingDeliveryOrders]') AND type in (N'P', N'PC'))
DROP PROCEDURE [communication].[getOutgoingDeliveryOrders]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[communication].[getOutgoingDeliveryOrders]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [communication].[getOutgoingDeliveryOrders] @xmlVar xml = null
as
BEGIN
DECLARE @orderStatus varchar(500), @orderNumber varchar(50), @fromDate varchar(50), @toDate varchar(50), @contractorId uniqueidentifier, @undelivered int

SELECT @orderStatus = NULLIF( @xmlVar.value(''(searchParams/orderStatus)[1]'',''varchar(500)''),'''')
SELECT @orderNumber = NULLIF( @xmlVar.value(''(searchParams/orderNumber)[1]'',''varchar(50)''),'''')
SELECT @fromDate = NULLIF( @xmlVar.value(''(searchParams/fromDate)[1]'',''varchar(50)''),'''')
SELECT @toDate = NULLIF( @xmlVar.value(''(searchParams/toDate)[1]'',''varchar(50)''),'''')
SELECT @contractorId = NULLIF( @xmlVar.value(''(searchParams/contractorId)[1]'',''char(36)''),'''')
SELECT @undelivered = NULLIF( @xmlVar.value(''(searchParams/undelivered)[1]'',''char(36)''),'''')

	SELECT 
		(
		SELECT h.id, h.fullNumber, s.orderNumber,s.creationDate, s.orderStatus, h.documentTypeId,h.branchId,h.status
		FROM communication.OutgoingDeliveryOrders s WITH(nolock)
			JOIN document.CommercialDocumentHeader h  WITH(nolock) ON s.commercialDocumentHeaderId = h.id
		WHERE 
			(s.orderStatus in ( @orderStatus ) OR @orderStatus IS NULL)
			AND (s.orderNumber = @orderNumber OR @orderNumber IS NULL)
			AND (s.creationDate >= @fromDate OR @fromDate IS NULL)
			AND (s.creationDate <= @toDate OR @toDate IS NULL)
			AND (h.contractorId = @contractorId OR @contractorId IS NULL)
			AND (@undelivered = 1 AND s.orderStatus <> ''Wysłana'')
		FOR XML PATH(''deliveryOrder''), TYPE
		)
	FOR XML PATH(''deliveryOrders''), TYPE
END
' 
END
GO
