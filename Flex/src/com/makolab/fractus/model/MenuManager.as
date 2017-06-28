package com.makolab.fractus.model
{
	import assets.Version;
	
	import com.makolab.components.layoutComponents.DynamicDetailRenderer;
	import com.makolab.components.layoutComponents.mdi.DragCanvas;
	import com.makolab.components.util.ErrorReport;
	import com.makolab.fractus.commands.ShowDocumentEditorCommand;
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	import com.makolab.fractus.view.ComponentWindow;
	import com.makolab.fractus.view.CsvToXmlManager;
	import com.makolab.fractus.view.Dictionary;
	import com.makolab.fractus.view.ExcelToXmlManager;
	import com.makolab.fractus.view.XlsToXmlManager;
	import com.makolab.fractus.view.administration.ChangeCurrentUserPassword;
	import com.makolab.fractus.view.administration.DatabaseBackupWindow;
	import com.makolab.fractus.view.administration.DiscountSlider;
	import com.makolab.fractus.view.administration.MinimalMarginManagement;
	import com.makolab.fractus.view.administration.OwnCompanies;
	import com.makolab.fractus.view.administration.Permissions;
	import com.makolab.fractus.view.administration.PostSalesProfitMargin.PostSalesProfitMarginConfigurator;
	import com.makolab.fractus.view.administration.ProfileChangeWindow;
	import com.makolab.fractus.view.administration.RulesList;
	import com.makolab.fractus.view.administration.SpeedTest;
	import com.makolab.fractus.view.administration.WarehouseStructure;
	import com.makolab.fractus.view.catalogue.BanksCatalogue;
	import com.makolab.fractus.view.catalogue.ContractorsCatalogue;
	import com.makolab.fractus.view.catalogue.ContractorsExportComponent;
	import com.makolab.fractus.view.catalogue.ExportToAccountingFileDialog;
	import com.makolab.fractus.view.catalogue.ItemsCatalogue;
	import com.makolab.fractus.view.catalogue.ProductionItemsCatalogue;
	import com.makolab.fractus.view.catalogue.NewsCatalogue;
	import com.makolab.fractus.view.catalogue.ObjectsCatalogue;
	import com.makolab.fractus.view.catalogue.PriceLists;
	import com.makolab.fractus.view.catalogue.ServicedObjectsCatalogue;
	import com.makolab.fractus.view.dashboard.DashboardPanel;
	import com.makolab.fractus.view.diagnostics.CommandExecutionLog;
	import com.makolab.fractus.view.diagnostics.ConfigurationEditor;
	import com.makolab.fractus.view.diagnostics.ConfigurationLittleEditor;
	import com.makolab.fractus.view.diagnostics.DocumentCommittingPerformanceTestWindow;
	import com.makolab.fractus.view.diagnostics.DocumentIssueTestWindow;
	import com.makolab.fractus.view.diagnostics.SearchPerformanceTestWindow;
	import com.makolab.fractus.view.diagnostics.SearchTest;
	import com.makolab.fractus.view.diagnostics.XmlCommunicatorQueueList;
	import com.makolab.fractus.view.documents.DocumentsExportComponent;
	import com.makolab.fractus.view.documents.SalesLockUnlockingCodeGeneratorWindow;
	import com.makolab.fractus.view.documents.documentEditors.InventoryDocumentCreator;
	import com.makolab.fractus.view.documents.documentLists.DocumentList;
	import com.makolab.fractus.view.documents.documentLists.DraftDocumentList;
	import com.makolab.fractus.view.documents.documentLists.FinancialDocumentList;
	import com.makolab.fractus.view.documents.documentLists.FinancialReportList;
	import com.makolab.fractus.view.documents.documentLists.InventoryDocumentList;
	import com.makolab.fractus.view.documents.documentLists.OrderDocumentList;
	import com.makolab.fractus.view.documents.documentLists.ProductionOrderDocumentList;
	import com.makolab.fractus.view.documents.documentLists.ProtocolComplaintList;
	import com.makolab.fractus.view.documents.documentLists.PurchaseDocumentList;
	import com.makolab.fractus.view.documents.documentLists.SalesDocumentList;
	import com.makolab.fractus.view.documents.documentLists.SalesOrderDocumentList;
	import com.makolab.fractus.view.documents.documentLists.ServiceDocumentList;
	import com.makolab.fractus.view.documents.documentLists.ShiftList;
	import com.makolab.fractus.view.documents.documentLists.TechnologyDocumentList;
	import com.makolab.fractus.view.documents.documentLists.WarehouseDocumentList;
	import com.makolab.fractus.view.documents.reports.complaintReports.ComplaintReport;
	import com.makolab.fractus.view.documents.reports.financialReports.FinancialReport;
	import com.makolab.fractus.view.documents.reports.purchaseReports.PurchaseReport;
	import com.makolab.fractus.view.documents.reports.salesOrderReport.SalesOrderReport;
	import com.makolab.fractus.view.documents.reports.salesReports.SalesReport;
	import com.makolab.fractus.view.documents.reports.serviceReports.ServiceReport;
	import com.makolab.fractus.view.documents.reports.warehouseReports.WarehouseReport;
	import com.makolab.fractus.view.documents.reports.productionReports.ProductionOrderReport;
	import com.makolab.fractus.view.finance.FinancialRegisterList;
	import com.makolab.fractus.view.finance.PaymentSettlementsExportComponent;
	import com.makolab.fractus.view.menu.MultiButtonEvent;
	import com.makolab.fractus.view.payments.PaymentList;
	import com.makolab.fractus.view.tools.JournalWindow;
	import com.makolab.fractus.view.tools.ParcelWindow;
	import com.makolab.fractus.view.tools.PivotTableTest;
	import com.makolab.fractus.view.tools.SettlementExport;
	import com.makolab.fractus.view.warehouse.ShiftTransactionEditor;
	import com.makolab.fraktus2.modules.warehouse.WarehouseMapManager;
	
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	import mx.rpc.AsyncToken;
	
	
	public class MenuManager
	{
		private var openWindows:Object = {};
		private var pivotTableTest:PivotTableTest;
		
		private function createOrRestore(property:String, cls:Object = null):Boolean
		{
			if (openWindows[property] == null)
			{
				if (cls)
				{
					addWindow(property, cls.showWindow());
				}
				return true;
			}
			else
			{
				DragCanvas.instance.windowManager.bringToFront(DragCanvas.instance, openWindows[property]);
				return false;
			}
		}
		
		private function addWindow(property:String, reference:ComponentWindow):void
		{
			openWindows[property] = reference;
			openWindows[property].addEventListener(FlexEvent.HIDE, hideHandler);
		}
		
		private function hideHandler(event:FlexEvent):void
		{
			for (var i:String in openWindows) if (openWindows[i] == event.target) delete openWindows[i];
		}
		
		public function showContractorsCatalogue():Object
		{
			createOrRestore("contractorsCatalogue", ContractorsCatalogue);
			return null;
		}
		
		public function newContractor(event:MultiButtonEvent):Object
		{
			ContractorsCatalogue.showContractorWindow(null, event.item&&event.item.@configurationKey.length()?event.item.@configurationKey:null, event.itemId);
			return null;
		}
		
		public function showItemsCatalogue():Object
		{
			createOrRestore("itemsCatalogue", ItemsCatalogue);
			return null;
		}
		
		public function showProductionItemsCatalogue():Object
		{
			createOrRestore("ProductionItemsCatalogue", ProductionItemsCatalogue);
			return null;
		}

		public function showObjectsCatalogue():Object
		{
			createOrRestore("objectsCatalogue", ObjectsCatalogue);
			return null;
		}
		
		public function showNewsCatalogue():Object
		{
			createOrRestore("newsCatalogue", NewsCatalogue);
			return null;
		}
		
		public function newItem(event:MultiButtonEvent):Object
		{
			ItemsCatalogue.showItemWindow(null, null, event.itemId);
			return null;
		}
		
		public function showBanksCatalogue():Object
		{
			createOrRestore("banksCatalogue", BanksCatalogue);
			return null;
		}
		
		public function newBank():Object
		{
			BanksCatalogue.showContractorWindow();
			return null;
		}
		
		public function showSalesDocuments():Object
		{
			if (createOrRestore("salesDocuments"))
			{
				addWindow("salesDocuments", DocumentList.showWindow(SalesDocumentList, LanguageManager.getInstance().labels.title.documents.list.sales));
			}
			return null;
		}
		
		public function newShiftTransaction():Object
		{
			ShiftTransactionEditor.showWindow();
			return null;
		}
		
		public function showShifts():Object
		{
			ShiftList.showWindow();
			return null;
		}
		
		public function showWarehouseContent():Object
		{
			MODULES::wms {
			
				var wmm:WarehouseMapManager =  WarehouseMapManager.getInstance()
					wmm.showMap( null, true, 2, "", null, true )
											
				
				//WarehouseContentInfo.showWindow();
			}
			return null;
		}

		public function showPurchaseDocuments():Object
		{
			if (createOrRestore("purchaseDocuments"))
			{
				addWindow("purchaseDocuments", DocumentList.showWindow(PurchaseDocumentList, LanguageManager.getInstance().labels.title.documents.list.purchase));
			}
			return null;
		}

		public function showOrderDocuments():Object
		{
			if (createOrRestore("orderDocuments"))
			{
				addWindow("orderDocuments", DocumentList.showWindow(OrderDocumentList, LanguageManager.getInstance().labels.title.documents.list.order));
			}
			return null;
		}
		
		public function showWarehouseDocuments():Object
		{
			if (createOrRestore("warehouseDocuments"))
			{
				addWindow("warehouseDocuments", DocumentList.showWindow(WarehouseDocumentList,LanguageManager.getInstance().labels.title.documents.list.warehouse));
			}
			return null;
		}

		public function newSalesDocumentSimple(event:MultiButtonEvent):Object
		{
			newSalesDocument(event.itemId, ShowDocumentEditorCommand.EDITOR_SIMPLE);
			return null;
		}
		
		public function newSalesDocumentAdvanced(event:MultiButtonEvent):Object
		{
			newSalesDocument(event.itemId, ShowDocumentEditorCommand.EDITOR_ADVANCED);
			return null;
		}
		
		public function newSalesDocumentQuick():Object
		{
			//createOrRestore("quickSales", QuickSalesDocumentEditor);
			newSalesDocument("bill",ShowDocumentEditorCommand.EDITOR_QUICK);
			return null;
		}
		
		private function newSalesDocument(templateName:String, editorType:int):void
		{
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(DocumentTypeDescriptor.CATEGORY_SALES);
			cmd.template = templateName;
			cmd.editorType = editorType;//advanced ? ShowDocumentEditorCommand.EDITOR_ADVANCED : ShowDocumentEditorCommand.EDITOR_SIMPLE;
			cmd.execute();			
		}
		
		public function newPurchaseDocument(event:MultiButtonEvent):Object
		{
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(DocumentTypeDescriptor.CATEGORY_PURCHASE);
			cmd.template = event.itemId;
			cmd.execute();
			return null;
		}
		
		public function newOrderDocument(event:MultiButtonEvent):Object
		{
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(DocumentTypeDescriptor.CATEGORY_WAREHOUSE_ORDER);
			cmd.template = event.itemId;
			cmd.execute();
			return null;
		}
		
		public function showServiceDocuments():Object
		{
			if (createOrRestore("serviceDocuments"))
			{
				addWindow("serviceDocuments", DocumentList.showWindow(ServiceDocumentList, LanguageManager.getInstance().labels.title.documents.list.service));
			}
			return null;
		}
		
		public function newServiceOrder(event:MultiButtonEvent):Object
		{
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(DocumentTypeDescriptor.CATEGORY_SERVICE_DOCUMENT);
			cmd.template = event.itemId;
			cmd.execute();
			return null;		
		}
		
		public function showServicedObjectsCatalogue():Object
		{
			createOrRestore("servicedObjectsCatalogue", ServicedObjectsCatalogue);
			return null;
		}

		public function showServiceReports():Object
		{
			model.configManager.requestValue("reports.serviceReports", true);
			createOrRestore("serviceReports", ServiceReport);
			return null;
		}
		
		public function showOwnCompanies():Object
		{
			createOrRestore("ownCompanies", OwnCompanies);
			return null;
		}
		
		public function showDictionaries():Object
		{
			createOrRestore("dictionaries", Dictionary);
			return null;
		}
		
		public function showDiscountSlider():Object
		{
			createOrRestore("discountSlider", DiscountSlider);
			return null;
		}
		
		public function showPermissions():Object
		{
			createOrRestore("permissions", Permissions);
			return null;
		}
		
		public function showWarehouseStructure():Object
		{
			createOrRestore("warehouseStructure", WarehouseStructure);
			return null;
		}
		
		public function documentCreationTest():Object
		{
			DocumentCommittingPerformanceTestWindow.showWindow();
			return null;
		}
		
		public function searchTest():Object
		{
			SearchPerformanceTestWindow.showWindow();
			return null;
		}

			public function showSalesReports():Object
			{
				model.configManager.requestValue("reports.salesReports", true);
				createOrRestore("reports", SalesReport);
				return null;
			}
		
		public function showProductionOrderReports():Object
		{
			model.configManager.requestValue("reports.productionOrderReports", true);
			createOrRestore("productionOrderReports", ProductionOrderReport);
			return null;
		}

		public function showPurchaseReports():Object
		{
			model.configManager.requestValue("reports.purchaseReports", true);
			createOrRestore("purchaseReports", PurchaseReport);
			return null;
		}

		public function showWarehouseReports():Object
		{
			model.configManager.requestValue("reports.salesReports", true);
			createOrRestore("warehouseReports", WarehouseReport);
			return null;
		}
		
		public function showFinanceReports():Object
		{
			model.configManager.requestValue("reports.financialReports", true);
			createOrRestore("financialReports", FinancialReport);
			return null;
		}
		
		public function newWarehouseDocument(event:MultiButtonEvent):Object
		{
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(DocumentTypeDescriptor.CATEGORY_WAREHOUSE);
			cmd.template = event.itemId;
			cmd.execute();	
			return null;
		}
		
		public function showDictionariesXML():Object
		{
			ErrorReport.showWindow("XML słowników", String(DictionaryManager.getInstance().dictionariesXML), LanguageManager.getInstance().labels.title.dictionaries.xml);
			return null;
		}
		
		public function showConfigurationEditor():Object
		{
			ConfigurationEditor.showWindow();
			return null;
		}
		
		public function newSearchUnitTest():Object
		{
			ModelLocator.getInstance().configManager.requestValue("diagnostics.searchTestParams");
			SearchTest.showWindow();
			return null;
		}
		
		public function showCommandLog():Object
		{
			CommandExecutionLog.showWindow();
			return null;
		}
		public function showCommunicatorXMLList():Object
		{
			XmlCommunicatorQueueList.showWindow();
			return null;
		}
		
		public function showDocumentIssueTest():Object
		{
			var temp:DynamicDetailRenderer = null;
		 	DocumentIssueTestWindow.showWindow();
		 	return null;
		}
				
		public function newFinancialDocument(event:MultiButtonEvent = null):Object
		{
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(DocumentTypeDescriptor.CATEGORY_FINANCIAL_DOCUMENT);
			cmd.template = event.itemId;
			cmd.execute();
			return null;
		}
		
		public function showFinancialDocuments():Object
		{
			if (createOrRestore("financialDocuments"))
			{
				addWindow("financialDocuments", DocumentList.showWindow(FinancialDocumentList, LanguageManager.getInstance().labels.title.documents.list.financialDocuments));
			}
			return null;
		}

		public function showFinancialReportsList():Object
		{
			if (createOrRestore("financialReportsList"))
			{
				addWindow("financialReportsList", DocumentList.showWindow(FinancialReportList, LanguageManager.getInstance().labels.title.documents.list.financialReports));
			}
			return null;
		}
		
		public function showFinancialRegisters():Object
		{
			FinancialRegisterList.showWindow();
			return null;
		}
		
		public function showContractorRelatedDocuments():Object
		{
			PaymentList.showWindow(null);
			return null;
		}
		
		public function versionInfo():Object
		{
			 Alert.show(
				"Release version: " + Version.releaseVersion + "\n" +
				"SWF build: " + Version.buildTime + "\n" +
				"Revision: " + Version.repositoryRevision,
				LanguageManager.getInstance().labels.menu.versionInfo
			); 
			//ApplicationInfo.showWindow();
			return null;
		}

		public function contractorAccounting():Object
		{
			ContractorsExportComponent.showWindow();
			return null;
		}

		public function documentAccounting():Object
		{
			DocumentsExportComponent.showWindow();
			return null;
		}
		
		public function salesLockUnlockingCodeGeneration():Object
		{
			SalesLockUnlockingCodeGeneratorWindow.showWindow();
			return null;
		}
		
		public function paymentSynchronization():Object
		{
			PaymentSettlementsExportComponent.showWindow();
			return null;
		}
		
		public function showProtocolDocumentList():Object
		{
			
			if (createOrRestore("complaintProtocol"))
			{
				addWindow("complaintProtocol", DocumentList.showWindow(ProtocolComplaintList, LanguageManager.getInstance().labels.complaint.protocolDocumentList));
			}
			return null;
		}
		public function showNewProtocolDocument():Object
		{
			
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(DocumentTypeDescriptor.CATEGORY_PROTOCOL_COMPLAINTS);
			cmd.template = "complaintProtocol"
			cmd.execute();
			
			return null;
		}

		public function showComplaintReports():Object
		{
			//model.configManager.requestValue("reports.complaintReports", true);
			createOrRestore("complaintReports", ComplaintReport);
			return null;
		}
		
		private function get model():ModelLocator
		{
			return ModelLocator.getInstance();
		}
		
		public function createInventoryDocument():Object
		{
			InventoryDocumentCreator.showWindow();
			return null;
		}
		
		public function showInventoryDocuments():Object
		{
			if (createOrRestore("inventoryDocuments"))
			{
				addWindow("inventoryDocuments", DocumentList.showWindow(InventoryDocumentList, LanguageManager.getInstance().labels.title.documents.list.inventoryDocument));
			}
			return null;
		}
		
		public function showPriceLists():Object
		{
			PriceLists.showWindow();
			return null;
		}
		
		public function showRulesList():Object
		{
			RulesList.showWindow();
			return null;
		} 
		
		//do zmiany na multibutton, wtedy z template bedzie ok
		public function newSalesOrder(event:MultiButtonEvent = null):Object
		{
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(DocumentTypeDescriptor.CATEGORY_SALES_ORDER_DOCUMENT);
			cmd.template = event? event.itemId : "salesOrder";
			cmd.execute();
			return null;
		}
		
		public function newTechnologyDocument(event:MultiButtonEvent = null):Object
		{
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(DocumentTypeDescriptor.CATEGORY_TECHNOLOGY_DOCUMENT);
			cmd.template = event? event.itemId : "technology";
			cmd.execute();
			return null;
		}
		
		public function newProductionOrderDocument(event:MultiButtonEvent = null):Object
		{
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(DocumentTypeDescriptor.CATEGORY_PRODUCTION_ORDER_DOCUMENT);
			cmd.template = event? event.itemId : "productionOrder";
			cmd.execute();
			return null;
		}
		
		public function showSalesDraftList():Object
		{
			DraftDocumentList.showWindow(DraftDocumentList.SALES, LanguageManager.getInstance().labels.menu.sales.salesDraftList);
			return null;
		}
		
		public function showPurchaseDraftList():Object
		{
			DraftDocumentList.showWindow(DraftDocumentList.PURCHASE, LanguageManager.getInstance().labels.menu.purchase.purchaseDraftList);
			return null;
		}
		
		public function showProfileChange():Object
		{
			ProfileChangeWindow.showWindow();
			return null;
		}
		
		public function showWarehouseDraftList():Object
		{
			DraftDocumentList.showWindow(DraftDocumentList.WAREHOUSE, LanguageManager.getInstance().labels.menu.warehouse.warehouseDraftList);
			return null;
		}
		
		public function showSalesOrderDocuments():Object
		{
			if (createOrRestore("salesOrderDocuments"))
			{
				addWindow("salesOrderDocuments", DocumentList.showWindow(SalesOrderDocumentList, LanguageManager.getInstance().labels.title.documents.list.salesOrder));
			}
			return null;
		}
		
		public function showProductionOrderDocuments():Object
		{
			if (createOrRestore("productionOrderDocuments"))
			{
				addWindow("productionOrderDocuments", DocumentList.showWindow(ProductionOrderDocumentList, LanguageManager.getInstance().labels.title.documents.list.productionOrder));
			}
			return null;
		}
		
		public function showTechnologyDocuments():Object
		{
			if (createOrRestore("technologyDocuments"))
			{
				addWindow("technologyDocuments", DocumentList.showWindow(TechnologyDocumentList, LanguageManager.getInstance().labels.title.documents.list.technology));
			}
			return null;
		}
		
		public function showMinimalMarginWindow():Object
		{
			MinimalMarginManagement.showWindow();
			return null;
		}
		
		public function showSalesOrderReportWindow():Object
		{
			//SalesOrderReport.showWindow();
			createOrRestore("salesOrderReports", SalesOrderReport);
			return null;
		}
		
		public function showDatabaseBackupWindow():Object
		{
			DatabaseBackupWindow.showWindow();
			return null;
		}
		
		public function showExportToAccountingFileDialog():Object
		{
			ExportToAccountingFileDialog.showWindow();
			return null;
		}
		
		public function showPostSalesProfitMarginConfigurator():Object
		{
			PostSalesProfitMarginConfigurator.showWindow();
			return null;
		}
		
		public function showChangePasswordWindow():Object
		{
			var temp:ChangeCurrentUserPassword = new ChangeCurrentUserPassword();
		 	return null;
		}
		
		public function newBill():Object
		{
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(DocumentTypeDescriptor.CATEGORY_SALES);
			cmd.template = "bill";
			cmd.execute();
			return null;
		}
		
		public function newInvoice():Object
		{
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(DocumentTypeDescriptor.CATEGORY_SALES);
			cmd.template = "invoice";
			cmd.execute();
			return null;
		}
		
		public function newExternalIncome():Object
		{
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(DocumentTypeDescriptor.CATEGORY_WAREHOUSE);
			cmd.template = "externalIncome";
			cmd.execute();
			return null;
		}
		
		public function newExternalOutcome():Object
		{
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(DocumentTypeDescriptor.CATEGORY_WAREHOUSE);
			cmd.template = "externalOutcome";
			cmd.execute();
			return null;
		}
		
		public function showSpeedTest():Object
		{
			SpeedTest.showWindow();
			return null;
		}
		
		public function newDocument(documentCategory:String,templateName:String):AsyncToken
		{
			var category:uint = NaN;
			if (!isNaN(Number(documentCategory)))
			{
				category = uint(Number(documentCategory));
			}else{
				category = DocumentTypeDescriptor[documentCategory];
			}
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(category);
			cmd.template = templateName;
			var token:AsyncToken = cmd.execute();
			return token;
		}
		
		public function showConfigurationLittleEditor():Object
		{
			ConfigurationLittleEditor.showWindow();
			return null;
		}
		
		public function showXlsToXmlManager():Object
		{
			XlsToXmlManager.showWindow();
			return null;
		}
		public function showCsvToXmlManager():Object
		{
			CsvToXmlManager.showWindow();
			return null;
		}
		public function showExcelToXmlManager():Object
		{
			ExcelToXmlManager.showWindow();
			return null;
		}
		
		public function settlementExport():Object
		{
			SettlementExport.showWindow();
			return null;
		}
		
		public function showJournalWindow():Object
		{
			JournalWindow.showWindow();
			//showParcelWindow();
			return null;
		}
		public function showParcelWindow():Object
		{
			ParcelWindow.showWindow();
			return null;
		}
		public function showDashboardWindow():Object
		{
			if(ModelLocator.getInstance().configManager.getXML("dashboard").panel.length()>0&& ModelLocator.getInstance().permissionManager.getPermissionLevel("dashboard")==PermissionManager.LEVEL_ENABLED)
			createOrRestore("DashboardPanel", DashboardPanel);//	DashboardPanel.showWindow("Twój panel");
			return null;
		}
	}
}