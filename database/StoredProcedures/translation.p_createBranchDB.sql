/*
name=[translation].[p_createBranchDB]
version=1.0.1
lastUpdate=2017-01-24 10:37:21
QdF4aZhacbk9VqrZeBXT0w==
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_createBranchDB]') AND type in (N'P', N'PC'))
DROP PROCEDURE [translation].[p_createBranchDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[translation].[p_createBranchDB]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [translation].[p_createBranchDB] @order numeric
AS
BEGIN
	DECLARE @databaseIdBranch varchar(50), 
			@sql nvarchar(500),
			@issuePlaceId varchar(50)
			
	SELECT @databaseIdBranch = databaseId FROM dictionary.Branch WHERE [order] = @order
	SELECT @issuePlaceId = textValue FROM configuration.Configuration WHERE [key] = ''document.defaults.issuePlaceId''
	
	BACKUP DATABASE F2 TO DISK = ''D:\F2.Bak'' WITH INIT
	RESTORE FILELISTONLY FROM DISK = ''D:\F2.Bak''
	IF EXISTS(SELECT name FROM sys.databases WHERE name = ''F2Branch'')
	    DROP DATABASE F2Branch
	RESTORE DATABASE F2Branch FROM DISK = ''D:\F2.Bak'' WITH 
	MOVE ''Fraktusek2'' TO ''D:\Databases\F2Branch2_Data.mdf'', 
	MOVE ''Fraktusek2_Log'' TO ''D:\Databases\F2Branch2_Log.ldf''

	UPDATE F2Branch.configuration.Configuration SET textValue = ''false'' WHERE [key] = ''system.isHeadquarter''
	UPDATE F2Branch.configuration.Configuration SET textValue = ''true'' WHERE [key] = ''warehouse.isWMSenabled''
	UPDATE F2Branch.configuration.Configuration SET textValue = (SELECT id FROM dictionary.IssuePlace WHERE [order] = @order) WHERE [key] = ''document.defaults.issuePlaceId''
	UPDATE F2Branch.configuration.Configuration SET textValue = @databaseIdBranch WHERE [key] = ''communication.databaseId''

	UPDATE F2Branch.configuration.Configuration SET xmlValue.modify(''delete //issuePlaceId'') WHERE [key] = ''templates.CommercialDocument.correctiveSalesInvoice''
	UPDATE F2Branch.configuration.Configuration SET xmlValue.modify(''insert <issuePlaceId>{xs:string(sql:variable("@issuePlaceId"))}</issuePlaceId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.correctiveSalesInvoice''
	UPDATE F2Branch.configuration.Configuration SET xmlValue.modify(''delete //issuePlaceId'') WHERE [key] = ''templates.CommercialDocument.correctivePurchaseInvoice''
	UPDATE F2Branch.configuration.Configuration SET xmlValue.modify(''insert <issuePlaceId>{xs:string(sql:variable("@issuePlaceId"))}</issuePlaceId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.correctivePurchaseInvoice''
	UPDATE F2Branch.configuration.Configuration SET xmlValue.modify(''delete //issuePlaceId'') WHERE [key] = ''templates.CommercialDocument.invoice''
	UPDATE F2Branch.configuration.Configuration SET xmlValue.modify(''insert <issuePlaceId>{xs:string(sql:variable("@issuePlaceId"))}</issuePlaceId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.invoice''
	UPDATE F2Branch.configuration.Configuration SET xmlValue.modify(''delete //issuePlaceId'') WHERE [key] = ''templates.CommercialDocument.order''
	UPDATE F2Branch.configuration.Configuration SET xmlValue.modify(''insert <issuePlaceId>{xs:string(sql:variable("@issuePlaceId"))}</issuePlaceId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.order''
	UPDATE F2Branch.configuration.Configuration SET xmlValue.modify(''delete //issuePlaceId'') WHERE [key] = ''templates.CommercialDocument.correctiveBill''
	UPDATE F2Branch.configuration.Configuration SET xmlValue.modify(''insert <issuePlaceId>{xs:string(sql:variable("@issuePlaceId"))}</issuePlaceId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.correctiveBill''
	UPDATE F2Branch.configuration.Configuration SET xmlValue.modify(''delete //issuePlaceId'') WHERE [key] = ''templates.CommercialDocument.purchaseInvoice''
	UPDATE F2Branch.configuration.Configuration SET xmlValue.modify(''insert <issuePlaceId>{xs:string(sql:variable("@issuePlaceId"))}</issuePlaceId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.purchaseInvoice''
	UPDATE F2Branch.configuration.Configuration SET xmlValue.modify(''delete //issuePlaceId'') WHERE [key] = ''templates.CommercialDocument.reservation''
	UPDATE F2Branch.configuration.Configuration SET xmlValue.modify(''insert <issuePlaceId>{xs:string(sql:variable("@issuePlaceId"))}</issuePlaceId> as first into /root[1]/commercialDocument[1]'') WHERE [key] = ''templates.CommercialDocument.reservation''
	
	
	IF (EXISTS(SELECT * FROM F2Branch.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ''OutgoingXmlQueue'' AND COLUMN_NAME = ''databaseId'' AND COLUMN_DEFAULT IS NOT NULL))
	ALTER TABLE F2Branch.communication.OutgoingXmlQueue	DROP CONSTRAINT DF_OutgoingXmlQueue_databaseId
	SELECT @sql = N''ALTER TABLE F2Branch.communication.OutgoingXmlQueue ADD CONSTRAINT
	DF_OutgoingXmlQueue_databaseId DEFAULT ('''''' + CAST(@databaseIdBranch AS varchar(50)) + '''''') FOR databaseId''
	EXEC(@sql)

END
' 
END
GO
