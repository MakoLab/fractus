package com.makolab.fractus.view.menu
{
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.model.ModelLocator;
	
	import mx.controls.Button;
	   
    public class MenuItemsList extends Object
	{
		public var menuItemsArray:Array;
		private static var instance:MenuItemsList;
		private var model:ModelLocator = ModelLocator.getInstance();
		
		public function MenuItemsList(){
			/*
				trace("---");
				trace(ModelLocator.getInstance().purchaseDocumentTemplates.toString());
				trace("---");
				if(model.configManager.isAvailable("menuItemsArray2"))
				{
					trace("ok")
					menuItemsArray = new Array();
					
					var menuItemsArraySource:XML = ModelLocator.getInstance().configManager.getXML("menuItemsArray");
					
					for each(var menuItem:XML in menuItemsArraySource.configValue.menuItems.*)
					{
						var o:Object = new Object;
						
						for each(var x:XML in menuItem)
						{
							var tempStr:String = XML(x.*[0]).toString();
							if(x.name() =="dataProvider")
							{
								// TODO potworna kaszana, zrobiona z powodu szybkiego terminu prezentacji dla klienta. Rzecz priorytetowa do poprawienia
															
								if(tempStr == "ModelLocator.getInstance().contractorTemplates")
								{
									o["itemDataProvider"] = ModelLocator.getInstance().contractorTemplates;
								}
								else if(tempStr == "ModelLocator.getInstance().financialDocumentTemplates")
								{
									o["itemDataProvider"] = ModelLocator.getInstance().financialDocumentTemplates;
								}
								else if(tempStr == "ModelLocator.getInstance().itemTemplates")
								{
									o["itemDataProvider"] = ModelLocator.getInstance().itemTemplates;
								}
								else if(tempStr == "ModelLocator.getInstance().orderDocumentTemplates")
								{
									o["itemDataProvider"] = ModelLocator.getInstance().orderDocumentTemplates;
								}
								else if(tempStr == "ModelLocator.getInstance().productionOrderDocumentTemplates")
								{
									o["itemDataProvider"] = ModelLocator.getInstance().productionOrderDocumentTemplates;
								}
								else if(tempStr == "ModelLocator.getInstance().salesDocumentTemplates")
								{
									o["itemDataProvider"] = ModelLocator.getInstance().salesDocumentTemplates;
								}
								else if(tempStr == "ModelLocator.getInstance().salesOrderDocumentTemplates")
								{
									o["itemDataProvider"] = ModelLocator.getInstance().salesOrderDocumentTemplates;
								}
								else if(tempStr == "ModelLocator.getInstance().serviceDocumentTemplates")
								{
									o["itemDataProvider"] = ModelLocator.getInstance().serviceDocumentTemplates;
								}
								else if(tempStr == "ModelLocator.getInstance().technologyDocumentTemplates")
								{
									o["itemDataProvider"] = ModelLocator.getInstance().technologyDocumentTemplates;
								}
								else if(tempStr == "ModelLocator.getInstance().warehouseDocumentTemplates")
								{
									o["itemDataProvider"] = ModelLocator.getInstance().warehouseDocumentTemplates;
								}
								
							}
							else if((tempStr == "true") || (tempStr == "false"))
							{
								o[x.name()] = Tools.parseBoolean(tempStr);
							}
							else
							{
								o[x.name()] = tempStr;
							}
												
						}
						menuItemsArray.push(o);
					}
				}
				else
				{
				
				trace("ok2")
				
				menuItemsArray = [
					{id:"contractorsList", type: "menuButton", itemToolTip: "contractors.contractors", itemLabelKey:"contractors.contractors", itemFunctionName:"showContractorsCatalogue", itemIconName: "contractor_catalogue", permissionKey: "catalogue.contractorsList"},
					{id:"newContractor", type: "multiButton", itemToolTip: "contractors.newContractor", itemEnabled: true, itemDataProvider: ModelLocator.getInstance().contractorTemplates, itemFunctionName:"newContractor", itemStyleName: "multiButton", itemListStyleName: "menuPopUpList", permissionKey: "catalogue.contractorsList.new"},
					{id:"itemsList", type: "menuButton", itemToolTip: "items.itemsAndServices", itemLabelKey:"items.itemsAndServices", itemFunctionName:"showItemsCatalogue", itemIconName: "item_catalogue", permissionKey: "catalogue.itemsList" },
					{id:"ProductionItemsList", type: "menuButton", itemToolTip: "items.itemsAndServices", itemLabelKey:"items.itemsAndServices", itemFunctionName:"showProductionItemsCatalogue", itemIconName: "item_catalogue", permissionKey: "catalogue.itemsList" },
					{id:"newItem", type: "multiButton", itemToolTip: "items.newItemOrService", itemEnabled: true, itemDataProvider: ModelLocator.getInstance().itemTemplates, itemFunctionName:"newItem", itemStyleName: "multiButton", itemListStyleName: "menuPopUpList", permissionKey: "catalogue.itemsList.new"},
					{id:"banksList", type: "menuButton", itemToolTip: "banks.banks", itemLabelKey:"banks.banks", itemFunctionName:"showBanksCatalogue", itemIconName: "bank_catalogue", permissionKey: "catalogue.banksList"},
					{id:"newBank", type: "menuButton", itemToolTip: "banks.newBank", itemLabelKey:"banks.newBank", itemFunctionName:"newBank", itemIconName: "bank_new", permissionKey: "catalogue.newBank"},
					{id:"priceLists", type: "menuButton", itemToolTip: "title.priceLists", itemLabelKey:"title.priceLists", itemFunctionName:"showPriceLists", itemIconName: "finance_cashReport", permissionKey: "catalogue.priceLists"},
					
					{id:"objectsList", type: "menuButton", itemToolTip: "objects.objects", itemLabelKey:"objects.objects", itemFunctionName:"showObjectsCatalogue", itemIconName: "item_catalogue", permissionKey: "catalogue.objectsList" },
					{id:"newsList", type: "menuButton", itemToolTip: "news.news", itemLabelKey:"news.news", itemFunctionName:"showNewsCatalogue", itemIconName: "item_catalogue", permissionKey: "catalogue.newsList" },
					
					{id:"companies", type: "menuButton", itemToolTip: "menu.ownCompanys", itemLabelKey:"menu.ownCompanys", itemFunctionName:"showOwnCompanies", itemIconName: "settings_ownCompanies", permissionKey: "administration.ownCompanies"},
					{id:"dictionaries", type: "menuButton", itemToolTip: "dictionaries.dictionaries", itemLabelKey:"dictionaries.dictionaries", itemFunctionName:"showDictionaries", itemIconName: "settings_dictionaries", permissionKey: "administration.dictionaries"},
					{id:"discountSlider", type: "menuButton", itemToolTip: "menu.discountSlider", itemLabelKey:"menu.discountSlider", itemFunctionName:"showDiscountSlider", itemIconName: "settings_ownCompanies", permissionKey: "administration.rebateSlider"},
					{id:"permissions", type: "menuButton", itemToolTip: "menu.permissions", itemLabelKey:"menu.permissions", itemFunctionName:"showPermissions", itemIconName: "settings_ownCompanies", permissionKey: "administration.permissions"},
					{id:"versionInfo", type: "menuButton", itemToolTip: "menu.versionInfo", itemLabelKey:"menu.versionInfo", itemFunctionName:"versionInfo", itemIconName: "settings", permissionKey: "administration"},
					{id:"warehouseStructure", type: "menuButton", itemToolTip: "menu.warehouseStructure", itemLabelKey:"menu.warehouseStructure", itemFunctionName:"showWarehouseStructure", itemIconName: "settings_ownCompanies", permissionKey: "warehouse.wms"},
					{id:"rules", type: "menuButton", itemToolTip: "title.rulesList", itemLabelKey:"title.rulesList", itemFunctionName:"showRulesList", itemIconName: "settings_ownCompanies", permissionKey: "administration.rules"},
					{id:"profileChange", type: "menuButton", itemToolTip: "title.profileChange", itemLabelKey:"title.profileChange", itemFunctionName:"showProfileChange", itemIconName: "settings_ownCompanies"},
					{id:"minimalMargin", type: "menuButton", itemToolTip: "menu.administration.minimalMargin", itemLabelKey:"menu.administration.minimalMargin", itemFunctionName:"showMinimalMarginWindow", itemIconName: "settings_ownCompanies", permissionKey: "administration.minimalMargin"},
					{id:"postSalesProfitMargin", type: "menuButton", itemToolTip: "menu.administration.postSalesProfitMargin", itemLabelKey:"menu.administration.postSalesProfitMargin", itemFunctionName:"showPostSalesProfitMarginConfigurator", itemIconName: "settings_ownCompanies", permissionKey: "administration.postSalesProfitMargin"},
					{id:"databaseBackup", type: "menuButton", itemToolTip: "menu.databaseBackup", itemLabelKey:"menu.databaseBackup", itemFunctionName:"showDatabaseBackupWindow", itemIconName: "settings"},
									
					{id:"salesDocList", type: "menuButton", itemToolTip: "menu.salesDocumentList", itemLabelKey:"menu.documentList", itemFunctionName:"showSalesDocuments", itemIconName: "sales_documentList", permissionKey: "sales.documentList"},				
					{id:"quickSale", type: "menuButton", itemToolTip: "menu.quickSalesTooltip", itemLabelKey:"menu.sales.quick", itemFunctionName:"newSalesDocumentQuick", itemIconName: "sales_quick", permissionKey: "sales.newDocumentQuick"},									
					{id:"salesSimple", type: "multiButton", itemToolTip: "menu.sales.simple", itemEnabled: true, itemDataProvider: ModelLocator.getInstance().salesDocumentTemplates, itemFunctionName:"newSalesDocumentSimple", itemStyleName: "multiButtonSimple", itemListStyleName: "menuPopUpList", permissionKey: "sales.newDocumentSimple"},
					{id:"salesAdvanced", type: "multiButton", itemToolTip: "menu.sales.advanced", itemEnabled: true, itemDataProvider: ModelLocator.getInstance().salesDocumentTemplates, itemFunctionName:"newSalesDocumentAdvanced", itemStyleName: "multiButtonAdvanced", itemListStyleName: "menuPopUpList", permissionKey: "sales.newDocumentAdvanced"},			
					{id:"salesOrderDocList", type: "menuButton", itemToolTip: "menu.sales.salesOrderList", itemLabelKey:"menu.sales.salesOrderList", itemFunctionName:"showSalesOrderDocuments", itemIconName: "sales_salesOrderList", permissionKey: "sales.documentList"},
					{id:"salesOrder", type: "multiButton", itemToolTip: "menu.sales.salesOrder", itemEnabled: true, itemDataProvider: ModelLocator.getInstance().salesOrderDocumentTemplates, itemFunctionName:"newSalesOrder", itemStyleName: "multiButton", itemListStyleName: "menuPopUpList", permissionKey: "sales.salesOrder" },
					{id:"billButton", type: "menuButton", itemToolTip: "menu.sales.bill", itemLabelKey:"menu.sales.bill", itemFunctionName:"newBill", itemIconName: "sales_salesOrderList", permissionKey: "sales.newBill"},				
					
					{id:"salesDraftList", type: "menuButton", itemToolTip: "menu.sales.salesDraftList", itemLabelKey:"menu.draftListShort", itemFunctionName:"showSalesDraftList", itemIconName: "sales_documentList", permissionKey: "sales.drafts"},
					
					{id:"warehouseDocList", type: "menuButton", itemToolTip: "menu.warehouseDocumentList", itemLabelKey:"menu.warehouseDocuments", itemFunctionName:"showWarehouseDocuments", itemIconName: "warehouse_list", permissionKey: "warehouse.documentList"},
					{id:"orderDocList", type: "menuButton", itemToolTip: "menu.orderDocumentList", itemLabelKey:"menu.orderDocuments", itemFunctionName:"showOrderDocuments", itemIconName: "warehouse_orderList", permissionKey: "warehouse.orderList"},				
					{id:"warehouseDocument", type: "multiButton", itemToolTip: "menu.warehouse.newDocument", itemEnabled: true, itemDataProvider: ModelLocator.getInstance().warehouseDocumentTemplates, itemFunctionName:"newWarehouseDocument", itemStyleName: "multiButton", itemListStyleName: "menuPopUpList", permissionKey: "warehouse.newDocument"},
					{id:"warehouseDocument", type: "multiButton", itemToolTip: "menu.warehouse.newDocument", itemEnabled: true, itemDataProvider: ModelLocator.getInstance().warehouseDocumentTemplates, itemFunctionName:"newWarehouseDocument", itemStyleName: "multiButton", itemListStyleName: "menuPopUpList", permissionKey: "warehouse.newDocument"},
					{id:"shiftTransaction", type: "menuButton", itemToolTip: "menu.newShiftTransactionTT", itemLabelKey:"menu.newShiftTransaction", itemFunctionName:"newShiftTransaction", itemIconName: "warehouse_list", permissionKey: "warehouse.shiftTransaction"},
					{id:"shiftsList", type: "menuButton", itemToolTip: "menu.shiftsListTT", itemLabelKey:"menu.shiftsList", itemFunctionName:"showShifts", itemIconName: "warehouse_list", permissionKey: "warehouse.shiftList"},
					{id:"warehouseContent", type: "menuButton", itemToolTip: "menu.warehouseContentTT", itemLabelKey:"menu.warehouseContent", itemFunctionName:"showWarehouseContent", itemIconName: "warehouse_list", permissionKey: "warehouse.content"},
					{id:"warehouseDraftList", type: "menuButton", itemToolTip: "menu.warehouse.warehouseDraftList", itemLabelKey:"menu.draftListShort", itemFunctionName:"showWarehouseDraftList", itemIconName: "warehouse_list", permissionKey: "warehouse.draftList"},
					
					{id:"purchaseDocList", type: "menuButton", itemToolTip: "menu.purchaseDocumentList", itemLabelPlacement: "bottom", itemLabelKey:"menu.documentList", itemFunctionName:"showPurchaseDocuments", itemIconName: "purchase_documentList", permissionKey: "purchase.documentList"},
					{id:"purchaseDocument", type: "multiButton", itemToolTip: "menu.purchase.newDocument", itemDataProvider: ModelLocator.getInstance().purchaseDocumentTemplates, itemFunctionName:"newPurchaseDocument", itemStyleName: "multiButton", itemListStyleName: "menuPopUpList", permissionKey: "purchase.newDocument"},
					{id:"orderDocument", type: "multiButton", itemToolTip: "menu.order.newDocument", itemEnabled: true, itemDataProvider: ModelLocator.getInstance().orderDocumentTemplates, itemFunctionName:"newOrderDocument", itemStyleName: "multiButton", itemListStyleName: "menuPopUpList", permissionKey: "warehouse.newOrder"},
					{id:"purchaseDraftList", type: "menuButton", itemToolTip: "menu.purchase.purchaseDraftList", itemLabelKey:"menu.draftListShort", itemFunctionName:"showPurchaseDraftList", itemIconName: "purchase_documentList", permissionKey: "purchase.drafts"},
					
					{id:"technologyDocument", type: "multiButton", itemToolTip: "menu.production.technologyDocument", itemEnabled: true, itemDataProvider: ModelLocator.getInstance().technologyDocumentTemplates, itemFunctionName:"newTechnologyDocument", itemStyleName: "multiButton", itemListStyleName: "menuPopUpList", permissionKey: "production.newTechnology" },
					{id:"technologyDocList", type: "menuButton", itemToolTip: "menu.production.technologyList", itemLabelKey:"menu.production.technologyList", itemFunctionName:"showTechnologyDocuments", itemIconName: "service_documentList", permissionKey: "production.technologyList"},
					{id:"productionOrderDocument", type: "multiButton", itemToolTip: "menu.production.productionOrderDocument", itemEnabled: true, itemDataProvider: ModelLocator.getInstance().productionOrderDocumentTemplates, itemFunctionName:"newProductionOrderDocument", itemStyleName: "multiButton", itemListStyleName: "menuPopUpList", permissionKey: "production.newProductionOrder" },
					{id:"productionOrderDocList", type: "menuButton", itemToolTip: "menu.production.productionOrderList", itemLabelKey:"menu.production.productionOrderList", itemFunctionName:"showProductionOrderDocuments", itemIconName: "service_documentList", permissionKey: "production.productionOrderList"},
					
					{id:"serviceDocList", type: "menuButton", itemToolTip: "menu.serviceDocumentList", itemLabelKey:"menu.serviceDocumentList", itemFunctionName:"showServiceDocuments", itemIconName: "service_documentList" },
					{id:"serviceOrder", type: "multiButton", itemToolTip: "menu.service.serviceOrder", itemEnabled: true, itemDataProvider: ModelLocator.getInstance().serviceDocumentTemplates, itemFunctionName:"newServiceOrder", itemStyleName: "multiButton", itemListStyleName: "menuPopUpList" },
					{id:"servicedObjectsList", type: "menuButton", itemToolTip: "title.servicedObjects", itemLabelKey:"menu.service.servicedObjectsList", itemFunctionName:"showServicedObjectsCatalogue", itemIconName: "servicedObject_catalogue", permissionKey: "catalogue.itemsList" },
					{id:"serviceReports", type: "menuButton", itemToolTip: "reports.serviceReports", itemLabelKey:"reports.serviceReports", itemFunctionName:"showServiceReports", itemIconName: "reports", permissionKey: "finance.reports"},
					
					{id:"documentCommittingPerformanceTest", type: "menuButton", itemToolTip: "diagnostics.performanceTest.documentCommittingPerformanceTest", itemLabelKey:"diagnostics.performanceTest.documentCommittingPerformanceTest", itemFunctionName:"documentCreationTest", itemIconName: "sales_invoice", permissionKey: "diagnostics.documentCommitingTest"},									
					{id:"searchPerformanceTest", type: "menuButton", itemToolTip: "diagnostics.performanceTest.searchPerformanceTest", itemLabelKey:"diagnostics.performanceTest.searchPerformanceTest", itemFunctionName:"searchTest", itemIconName: "item_catalogue", permissionKey: "diagnostics.searchPerformanceTest"},
					{id:"showDictionariesXML", type: "menuButton", itemToolTip: "diagnostics.showDictionaries", itemLabelKey:"diagnostics.showDictionaries", itemFunctionName:"showDictionariesXML", itemIconName: "settings_dictionaries", permissionKey: "diagnostics.dictionariesXML"},
					{id:"showConfigurationEditor", type: "menuButton", itemToolTip: "diagnostics.editConfiguration", itemLabelKey:"diagnostics.editConfiguration", itemFunctionName:"showConfigurationEditor", itemIconName: "settings", permissionKey: "diagnostics.configuration"},
					{id:"searchUnitTest", type: "menuButton", itemToolTip: "diagnostics.searchUnitTest", itemLabelKey:"diagnostics.searchUnitTest", itemFunctionName:"newSearchUnitTest", itemIconName: "item_catalogue", permissionKey: "diagnostics.searchUnitTest"},
					{id:"showCommandLog", type: "menuButton", itemToolTip: "diagnostics.commandLog", itemLabelKey:"diagnostics.commandLog", itemFunctionName:"showCommandLog", itemIconName: "settings", permissionKey: "diagnostics.commandLog"},
					{id:"showCommunicatorXMLList", type: "menuButton", itemToolTip: "diagnostics.communication.xmlCommunicatorTitle", itemLabelKey:"diagnostics.communication.xmlCommunicatorTitle", itemFunctionName:"showCommunicatorXMLList", itemIconName: "settings", permissionKey: "diagnostics.communicationXML"},
					{id:"showDocumentIssueTest", type: "menuButton", itemToolTip: "diagnostics.documentIssueTest", itemEnabled: true, itemLabelPlacement: "bottom", itemLabelKey:"diagnostics.documentIssueTest", itemFunctionName: "showDocumentIssueTest", itemIconName: "item_catalogue"},
					
					{id:"salesReports", type: "menuButton", itemToolTip: "reports.salesReports", itemLabelKey:"reports.salesReports", itemFunctionName:"showSalesReports", itemIconName: "reports", permissionKey: "sales.reports"},
					{id:"purchaseReports", type: "menuButton", itemToolTip: "reports.purchaseReports", itemLabelKey:"reports.purchaseReports", itemFunctionName:"showPurchaseReports", itemIconName: "reports", permissionKey: "purchase.reports"},
					{id:"warehouseReports", type: "menuButton", itemToolTip: "reports.warehouseReports", itemLabelKey:"reports.warehouseReports", itemFunctionName:"showWarehouseReports", itemIconName: "reports", permissionKey: "warehouse.reports"},
					{id:"financialReports", type: "menuButton", itemToolTip: "reports.financialReports", itemLabelKey:"reports.financialReports", itemFunctionName:"showFinanceReports", itemIconName: "reports", permissionKey: "finance.reports"},
					{id:"salesOrderReports", type: "menuButton", itemToolTip: "reports.salesOrderReports", itemLabelKey:"reports.salesOrderReports", itemFunctionName:"showSalesOrderReportWindow", itemIconName: "reports", permissionKey: "sales.reports"},
					
					{id:"financialDocList", type: "menuButton", itemToolTip: "menu.financialDocumentList", itemLabelKey:"menu.documentList", itemFunctionName:"showFinancialDocuments", itemIconName: "finance_documentList_cash", permissionKey: "finance.documentList"},
					{id:"financialRepList", type: "menuButton", itemToolTip: "menu.financialReportList", itemLabelKey:"menu.reportList", itemFunctionName:"showFinancialReportsList", itemIconName: "finance_documentList_bank", permissionKey: "finance.reportList"},
					{id:"financialRegisters", type: "menuButton", itemToolTip: "menu.financialRegisters", itemLabelKey:"menu.financialRegisters", itemFunctionName:"showFinancialRegisters", itemIconName: "finance_cashReport", permissionKey: "finance.reportList"},
					{id:"financialDocument", type: "multiButton", itemToolTip: "menu.financial.newDocument", itemEnabled: true, itemDataProvider: ModelLocator.getInstance().financialDocumentTemplates, itemFunctionName:"newFinancialDocument", itemStyleName: "multiButton", itemListStyleName: "menuPopUpList", permissionKey: "finance.newDocument"},
					{id:"financialRelatedDocuments", type: "menuButton", itemToolTip: "menu.payments", itemLabelKey:"menu.payments", itemFunctionName:"showContractorRelatedDocuments", itemIconName: "finance_documentList_cash", permissionKey: "finance.payments"},
					
					{id:"contractorAccounting", type: "menuButton", itemToolTip: "accounting.exportContractors", itemLabelKey:"accounting.exportContractorsShort", itemFunctionName:"contractorAccounting", itemIconName: "contractor_accounting", permissionKey: "tools.contractorExport"},
					{id:"documentAccounting", type: "menuButton", itemToolTip: "accounting.exportDocuments", itemLabelKey:"accounting.exportDocumentsShort", itemFunctionName:"documentAccounting", itemIconName: "document_accounting", permissionKey: "tools.documentExport"},
					{id:"paymentSynchronization", type: "menuButton", itemToolTip: "accounting.paymentSynchronization", itemLabelKey:"accounting.paymentSynchronization", itemFunctionName:"paymentSynchronization", itemIconName: "payment_synhronization", permissionKey: "tools.paymentSynchronization"},
					{id:"exportToAccountingFile", type: "menuButton", itemToolTip: "accounting.exportToAccountingFile", itemLabelKey:"accounting.exportToAccountingFile", itemFunctionName:"showExportToAccountingFileDialog", itemIconName: "document_accounting", permissionKey: "tools.exportToAccountingFile"},
					{id:"salesLockUnlockingCodeGeneration", type: "menuButton", itemToolTip: "title.salesLockUnlockingCodeGeneratorTitle", itemLabelKey:"title.salesLockUnlockingCodeGeneratorTitle", itemFunctionName:"salesLockUnlockingCodeGeneration", itemIconName: "payment_synhronization", permissionKey: "administration.salesLockUnlockingCodeGenerator"},
					{id:"changePassword", type: "menuButton", itemToolTip: "tools.changeUserPassword", itemLabelKey:"tools.changeUserPassword", itemFunctionName:"showChangePasswordWindow", itemIconName: "contractor_accounting", permissionKey: "tools.contractorExport"},
					
					{id:"complaintDocList", type: "menuButton", itemToolTip: "complaint.protocolDocumentList", itemLabelKey:"complaint.protocolDocumentListShort", itemFunctionName:"showProtocolDocumentList", itemIconName: "complaint_documentList", permissionKey: "complaint.protocolList"},
					{id:"newProtocolComplaint", type: "menuButton", itemToolTip: "complaint.protocolDocument", itemLabelKey:"complaint.protocolDocumentShort", itemFunctionName:"showNewProtocolDocument", itemIconName: "complaint_document", permissionKey: "complaint.protocolDocument"},
					{id:"complaintReports", type: "menuButton", itemToolTip: "complaint.complaintReports", itemLabelKey:"complaint.complaintReports", itemFunctionName:"showComplaintReports", itemIconName: "reports", permissionKey: "complaint.reports"},
					
					{id:"inventoryDocument", type: "menuButton", itemToolTip: "", itemLabelKey:"inventory.document", itemFunctionName:"createInventoryDocument", itemIconName: "inventoryDocument_new", permissionKey: "warehouse.inventory.document"},
					{id:"inventoryDocumentList", type: "menuButton", itemToolTip: "", itemLabelKey:"inventory.documentList", itemFunctionName:"showInventoryDocuments", itemIconName: "inventoryDocument_catalogue", permissionKey: "warehouse.inventory.list"},
					{id:"speedTest", type: "menuButton", itemToolTip: "", itemLabelKey:"menu.speedTest", itemFunctionName:"showSpeedTest", itemIconName: "item_catalogue", permissionKey: ""}
				];
				
			}
				
			trace("---");
			var k:* = ModelLocator.getInstance().;
			trace(k);
			
			*/
		}
		
		public static function getInstance():MenuItemsList
		{			
			if (instance == null) instance = new MenuItemsList();
			return instance;
		}
		
		public function getMenuItem(id:String,item:XML):Button {
			var menuB:Button;
			//var index:int;
			var type:String;
			var itemIconName:String;
			var itemLabelPlacement:String = "bottom";
			var itemStyleName:String = "defaultButton";
			var itemToolTip:String;
			var itemFunctionName:String;
			var itemLabelKey:String;
			var itemLabel:String;
			var permissionKey:String;
			var itemDataProvider:XMLList;
			var itemListStyleName:String;
			var itemHeight:Number = 65;
			var itemDocumentCategory:String;
			var itemTemplateName:String;
			var itemClassName:String;
			var itemFunctionParameters:Array;
			var itemLabelLang:Array;
			if (item)
			{
				if ( item.@type.length() > 0 ) type = item.@type.toString();
				if ( item.type.length() > 0 ) type = item.type.toString();
				if ( item.@iconName.length() > 0 ) itemIconName = item.@iconName.toString();
				if ( item.iconName.length() > 0 ) itemIconName = item.iconName.toString();
				if ( item.@labelPlacement.length() > 0 ) itemLabelPlacement = item.@labelPlacement.toString();
				if ( item.labelPlacement.length() > 0 ) itemLabelPlacement = item.labelPlacement.toString();
				if ( item.@styleName.length() > 0 ) itemStyleName = item.@styleName.toString();
				if ( item.styleName.length() > 0 ) itemStyleName = item.styleName.toString();
				if ( item.@toolTip.length() > 0 ) itemToolTip = item.@toolTip.toString();
				if ( item.toolTip.length() > 0 ) itemToolTip = item.toolTip.toString();
				if ( item.@functionName.length() > 0 ) itemFunctionName = item.@functionName.toString();
				if ( item.functionName.length() > 0 ) itemFunctionName = item.functionName.toString();
				if ( item.@labelKey.length() > 0 ) itemLabelKey = item.@labelKey.toString();
				if ( item.labelKey.length() > 0 ) itemLabelKey = item.labelKey.toString();
				if ( item.@label.length() > 0 ) itemLabel = item.@label.toString();
				if ( item.@labelEn.length() > 0 ) itemLabelLang = (item.@labelEn.toString()).split(";");
				if ( item.label.length() > 0 ) itemLabel = item.label.toString();
				if ( item.@permissionKey.length() > 0 ) permissionKey = item.@permissionKey.toString();
				if ( item.permissionKey.length() > 0 ) permissionKey = item.permissionKey.toString();
				if ( item.dataProvider.length() > 0 ) {
					itemDataProvider = getDataProvider(item.dataProvider[0]);
					type = "multiButton";
				} else {
					type = "menuButton";
				}
				if ( item.@listStyleName.length() > 0 ) itemListStyleName = item.@listStyleName.toString();
				if ( item.listStyleName.length() > 0 ) itemListStyleName = item.listStyleName.toString();
				if ( item.@height.length() > 0 ) itemHeight = item.@height.toString();
				if ( item.height.length() > 0 ) itemHeight = item.height.toString();
				if ( item.@documentCategory.length() > 0 ) itemDocumentCategory = item.@documentCategory.toString();
				if ( item.documentCategory.length() > 0 ) itemDocumentCategory = item.documentCategory.toString();
				if ( item.@templateName.length() > 0 ) itemTemplateName = item.@templateName.toString();
				if ( item.templateName.length() > 0 ) itemTemplateName = item.templateName.toString();
				if ( item.@className.length() > 0 ) itemClassName = item.@className.toString();
				if ( item.className.length() > 0 ) itemClassName = item.className.toString();
				if ( item.functionParameters.length() > 0 )
				{
					itemFunctionParameters = [];
					for each (var parameter:XML in item.functionParameters.parameter)
						itemFunctionParameters.push(parameter.toString());
				}
						
			}
			
			// opcja nowa full-generyczna.
			if (type)
			{
				if(type == "menuButton")
				{
					menuB = new MenuButton();
					if( itemIconName != null ) MenuButton(menuB).iconName = itemIconName;
					if( itemLabelPlacement ) menuB.labelPlacement = itemLabelPlacement;
					if( itemStyleName != null ) menuB.styleName = itemStyleName;
					else menuB.styleName="defaultButton";
					if ( itemToolTip != null ) MenuButton(menuB).toolTipKey = itemToolTip;
					if ( itemFunctionName != null )
					{
						MenuButton(menuB).functionName = itemFunctionName;
						MenuButton(menuB).functionClass = itemClassName;
						MenuButton(menuB).functionParameters = itemFunctionParameters;
					}
					else if ( itemFunctionName == null  && itemDocumentCategory != null && itemTemplateName != null)
					{
						MenuButton(menuB).functionName = "newDocument";
						MenuButton(menuB).functionParameters = [itemDocumentCategory,itemTemplateName];
					}
					if ( itemLabelKey != null ) MenuButton(menuB).labelKey = itemLabelKey;
					if ( itemLabel != null ) MenuButton(menuB).label = itemLabel;
					if ( permissionKey != null ) {
						menuB.enabled = model.permissionManager.isEnabled( permissionKey );
						if (model.permissionManager.isHidden(permissionKey))	{
							menuB.visible = false;
							menuB.includeInLayout = false;	
						}
					}
					//index = i;
				}
				else if(type == "multiButton")
				{
					menuB = new MultiButton;
					MultiButton(menuB).dataProvider = itemDataProvider;
					if ( itemToolTip != null ) MultiButton(menuB).toolTipKey = itemToolTip;
					if ( itemFunctionName != null )
					{ 
						MultiButton(menuB).functionName = itemFunctionName;
						MultiButton(menuB).functionClass = itemClassName;
					}
					if ( itemStyleName != null ) MultiButton(menuB).styleName = itemStyleName;
					if ( itemListStyleName != null ) MultiButton(menuB).listStyleName = itemListStyleName;
					if ( permissionKey != null ) {
						MultiButton(menuB).enabled = model.permissionManager.isEnabled(permissionKey);
						if(model.permissionManager.isHidden(permissionKey))	{
							MultiButton(menuB).visible = false;
							MultiButton(menuB).includeInLayout = false;
						}	
					}
					//index = i;
				}
				menuB.height = itemHeight;
			}
			
			/*
			else // opcja stara wykorzystujaca hardcode menuItemsArray.
			{
				for (var i:int = 0; i < menuItemsArray.length; ++i){
					trace(i);
					if (menuItemsArray[i].id==id){
						if(menuItemsArray[i].type == "menuButton"){
							menuB = new MenuButton();
							if(menuItemsArray[i].itemIconName!= null)MenuButton(menuB).iconName=menuItemsArray[i].itemIconName;
							if(menuItemsArray[i].itemLabelPlacement) menuB.labelPlacement=menuItemsArray[i].itemLabelPlacement;
							else menuB.labelPlacement = "bottom";
							if(menuItemsArray[i].itemStyleName != null)menuB.styleName=menuItemsArray[i].itemStyleName;
							else menuB.styleName="defaultButton";
							if(menuItemsArray[i].itemToolTip != null)MenuButton(menuB).toolTipKey=menuItemsArray[i].itemToolTip;
							if(menuItemsArray[i].itemFunctionName != null)MenuButton(menuB).functionName = menuItemsArray[i].itemFunctionName;
							if(menuItemsArray[i].itemLabelKey != null)MenuButton(menuB).labelKey = menuItemsArray[i].itemLabelKey;
							if(menuItemsArray[i].permissionKey != null) {
								menuB.enabled = model.permissionManager.isEnabled(menuItemsArray[i].permissionKey);
								if(model.permissionManager.isHidden(menuItemsArray[i].permissionKey))	{
									menuB.visible = false;
									menuB.includeInLayout = false;	
								}
							}
							index = i;
							
						}
						else if(menuItemsArray[i].type == "multiButton"){
							menuB = new MultiButton;
							MultiButton(menuB).dataProvider = menuItemsArray[i].itemDataProvider;
							if(menuItemsArray[i].itemToolTip != null)MultiButton(menuB).toolTipKey=menuItemsArray[i].itemToolTip;
							if(menuItemsArray[i].itemFunctionName != null)MultiButton(menuB).functionName = menuItemsArray[i].itemFunctionName;
							if(menuItemsArray[i].itemStyleName != null)MultiButton(menuB).styleName=menuItemsArray[i].itemStyleName;
							if(menuItemsArray[i].itemListStyleName != null)MultiButton(menuB).listStyleName=menuItemsArray[i].itemListStyleName;
							if(menuItemsArray[i].permissionKey != null) {
								MultiButton(menuB).enabled = model.permissionManager.isEnabled(menuItemsArray[i].permissionKey);
								if(model.permissionManager.isHidden(menuItemsArray[i].permissionKey))	{
									MultiButton(menuB).visible = false;
									MultiButton(menuB).includeInLayout = false;
								}	
										
							}
							index = i;
						}
					}
				}
				if(menuItemsArray[index].hasOwnProperty("buttonHeight"))
				{
					if(menuItemsArray[index].buttonHeight != null)
					{
					menuB.height = parseInt(menuItemsArray[index].buttonHeight);
					}
				}
				else
				{
					menuB.height = 65;
				}
			}
			
			*/
			return menuB;
		}
		
		private function getDataProvider(config:XML):XMLList
		{
			var result:XMLList;
			var key:String;
			if (config)
			{
				key = config.toString().replace(" ","")
				if (key.charAt() == '{' && key.charAt(key.length-1) == '}')
				{
					var propertyChain:Array = key.substring(1,key.length - 1).split(".");
					var target:Object = ModelLocator.getInstance();
					for (var i:int = 0; i < propertyChain.length; i++)
					{
						if (target.hasOwnProperty(propertyChain[i])) target = target[propertyChain[i]];
						else target = null;
					}
					if (target && target is XMLList) result = target as XMLList;
				} else {
					result = new XMLList();
					for each (var item:XML in config.*)
					{
						if (item.localName() == "template") {
							//trace("id:",item.@permissionKey.toString());
							if (item.@permissionKey && ModelLocator.getInstance().permissionManager.isEnabled(item.@permissionKey)) {
								
								if(item.@configurationKey.length())
								{
									var xmll:XMLList=XMLList(model[item.@templatesSet.toString()]).(@id.toString() == item.@templateId.toString());
									xmll.@configurationKey=item.@configurationKey;
									result = result +xmll ;
								}
								else
								result = result + XMLList(model[item.@templatesSet.toString()]).(@id.toString() == item.@templateId.toString());
							}
							
						} else {
							result = result + item;
						}
					}
				}
			}
			return result;
		}
	}
}