package com.makolab.fractus.view.diagnostics
{
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.commands.CreateBusinessObjectCommand;
	import com.makolab.fractus.commands.LoadBusinessObjectCommand;
	import com.makolab.fractus.commands.SaveBusinessObjectCommand;
	import com.makolab.fractus.commands.SearchCommand;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.document.CommercialDocumentLine;
	import com.makolab.fractus.model.document.CorrectiveCommercialDocumentLine;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.model.document.WarehouseDocumentLine;
	import com.makolab.fractus.view.documents.plugins.CommercialDocumentCalculationPlugin;
	import com.makolab.fractus.view.documents.plugins.WarehouseDocumentCalculationPlugin;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;		
						
	public class DocumentIssueTestProcedures
	{
		
		[Bindable] public var searchContractorParams:XML;
		[Bindable] public var searchItemParams:XML;
		[Bindable] public var searchDocumentParams:XML;
		[Bindable] public var payments:XML;
		
		[Bindable] public var contractorResult:XMLList;
		[Bindable] public var itemsResult:Array = new Array();
		
		[Bindable] public var documentData:Object;
		[Bindable] public var correctedDocumentData:Object;
		[Bindable] public var itemsTable:Array = new Array();
		[Bindable] public var contractorReady:Boolean = false;
		[Bindable] public var itemsReady:Boolean = false;
		[Bindable] public var itemsLoaded:int = 0;
		
		
		[Bindable] public var correctiveDocumentData:Object;
		
		
		
		
		public var options:XML;
		
		private var dictionary:DictionaryManager = DictionaryManager.getInstance();
		
		[Bindable] public var flag:Boolean = false;


		public function DocumentIssueTestProcedures(searchContractorParams:XML, searchItemParams:XML, searchDocumentParams:XML, payments:XML)
		{
			this.searchContractorParams = searchContractorParams;
			this.searchItemParams = searchItemParams;
			this.searchDocumentParams = searchDocumentParams;
			this.payments = payments;
		}
		
		public function issueDocument(document:Object):void
		{
			var createCmd:CreateBusinessObjectCommand ;
			
			var searchContractorCmd:SearchCommand; 
			var loadContractorCmd:LoadBusinessObjectCommand;
					
			var searchItemCmd:SearchCommand;
			var loadItemCmd:LoadBusinessObjectCommand;
			
			var itemData:XML;
			var contractorData:XML;
									
			
			createCmd = new CreateBusinessObjectCommand();
			trace("createCmd: " + createCmd);
			createCmd.addEventListener(ResultEvent.RESULT, createResult);
					
			
			for(var i:int=0; i<(document.linesTable).length; i++)
			{
				searchItemCmd = new SearchCommand("items");
				searchItemCmd.addEventListener(ResultEvent.RESULT, searchItemResult);
				
				searchItemParams.filters.column = (document.linesTable[i]).itemCode;
				searchItemCmd.searchParams = searchItemParams;
				
				var item:Object = {itemIndex: i, searchItemCmd: searchItemCmd, loadItemCmd: loadItemCmd, itemData: XML, price: (document.linesTable[i]).price, quantity: (document.linesTable[i]).quantity, discountRate: (document.linesTable[i]).discountRate, vatRate: (document.linesTable[i]).vatRate };
				itemsTable.push(item);
				
				item.searchItemCmd.execute();
			} 
						
						
			if(document.contractorCode == "" || document.contractorCode == null){
				
				documentData = {template: document.template, type: document.type, paymentType: document.payment, sourceType: document.sourceType, correctedDocumentId: document.correctedDocumentId, createCmd: createCmd, warehouseSymbol: document.warehouseSymbol, issueFinancial: document.issueFinancial, issueWarehouse: document.issueWarehouse, searchContractorCmd: null, loadContractorCmd: null, contractorData: null, itemsTable: itemsTable};
				contractorReady = true;
			}	
			else{
				searchContractorCmd = new SearchCommand("contractors");
				searchContractorParams.query = document.contractorCode;
				searchContractorCmd.searchParams = searchContractorParams;
				searchContractorCmd.searchParams.sqlConditions.condition = "code=" + document.contractorCode;
				searchContractorCmd.addEventListener(ResultEvent.RESULT, searchContractorResult);
					
				documentData = {template: document.template, type: document.type, paymentType: document.payment, sourceType: document.sourceType, correctedDocumentId: document.correctedDocumentId, createCmd: createCmd, warehouseSymbol: document.warehouseSymbol, issueFinancial: document.issueFinancial, issueWarehouse: document.issueWarehouse, searchContractorCmd: searchContractorCmd, loadContractorCmd: loadContractorCmd, contractorData: XML, itemsTable: itemsTable};
			
				documentData.searchContractorCmd.execute();
				
			}		
		}
		
		private function searchContractorResult(event:ResultEvent):void
		{
			var xml:XML = XML(event.result);
						
			documentData.loadContractorCmd = new LoadBusinessObjectCommand(LoadBusinessObjectCommand.TYPE_CONTRACTOR, xml.contractor.@id[0]);
			documentData.loadContractorCmd.addEventListener(ResultEvent.RESULT, loadContractorResult);
						
			documentData.loadContractorCmd.execute();
		}
			
		private function loadContractorResult(event:ResultEvent):void
		{
			documentData.contractorData = XML(event.result);
				
			contractorReady = true;
			if(itemsReady){
				createDocument();
			}
		}
		
		private function createDocument():void
		{
			
			documentData.createCmd.execute({type : documentData.type, template : documentData.template});	
			
		/*	<source type="correction">
    <correctedDocumentId>B3E260E1-614F-47CE-A659-CBFB445BC19F</correctedDocumentId>
  </source>
			*/
			
	
		}
				
		private function searchItemResult(event:ResultEvent):void
		{
			for each(var item:Object in documentData.itemsTable)
			{
				if(item.searchItemCmd == event.target){
					var xml:XML = XML(event.result);
					
					item.loadItemCmd = new LoadBusinessObjectCommand(LoadBusinessObjectCommand.TYPE_ITEM, xml.item.@id[0]);
					item.loadItemCmd.addEventListener(ResultEvent.RESULT, loadItemResult);
																				
					item.loadItemCmd.execute();
				}
			}
		}
	
		private function loadItemResult(event:ResultEvent):void
		{
			var itemXML:XML = XML(event.result);
			
			for each(var item:Object in documentData.itemsTable)
			{
				if(item.loadItemCmd == event.target){
					item.itemData = itemXML;
					itemsLoaded++;
				}
			}
				
				
			if(itemsLoaded == documentData.itemsTable.length){
				itemsReady = true;
				if(contractorReady)
				createDocument();
			}
			else {
				itemsReady = false;
			}
					
		}
		
		private function createResult(event:ResultEvent):void
		{
			// get current date
			trace("result wchodzący do createResult: " + XML(event.result));
			var nowDate:String = Tools.dateToIso(new Date()) ;
			var dueDate:String = Tools.dateToString(new Date());
				
			var document:DocumentObject = new DocumentObject(XML(event.result));
				
			var calcPlugin:CommercialDocumentCalculationPlugin = new CommercialDocumentCalculationPlugin();
			var warehouseCalcPlugin:WarehouseDocumentCalculationPlugin = new WarehouseDocumentCalculationPlugin();
			var temp:XML;
			var warehouseSymbol:String;
			
				
			if(documentData.type == "CommercialDocument"){
									
				for (var i:int = 0; i< documentData.itemsTable.length; i++)	{
					document.lines = new ArrayCollection();
					var cline:CommercialDocumentLine = new CommercialDocumentLine();
					
					cline.itemName = documentData.itemsTable[i].itemData.item.name;
					cline.itemId = documentData.itemsTable[i].itemData.item.id;
					cline.itemVersion = documentData.itemsTable[i].itemData.item.version;
					cline.quantity = documentData.itemsTable[i].quantity;
					cline.initialNetPrice = documentData.itemsTable[i].price == "" ? documentData.itemsTable[i].itemData.item.defaultPrice : documentData.itemsTable[i].price;
					cline.discountRate = documentData.itemsTable[i].discountRate;
					
					var vatRate:String = String(XML(dictionary.getBySymbol(documentData.itemsTable[i].vatRate)).id);
					cline.vatRateId = vatRate;
				
				
				
					document.lines.addItem(cline);
					
					calcPlugin.documentObject = document;
					calcPlugin.calculateLine(cline, "initialNetPrice");
				}
				
				
				if(documentData.searchContractorCmd != null){
					if(documentData.contractorData.code != ""){
						var addressXML: XML = <addressId>{String(documentData.contractorData.contractor.addresses[0].address.id)}</addressId>;
						
						var contractorXML: XML = <contractor>{XML(documentData.contractorData.contractor)}{addressXML}</contractor>;
						document.xml.appendChild(contractorXML);

					}
				}
					
				
				calcPlugin.calculateTotal(document);
				payments.payment.date = nowDate ;
				payments.payment.dueDate = dueDate ;
				payments.payment.exchangeDate = nowDate ;
				payments.payment.amount = document.totalForPayment;
				
				if(documentData.searchContractorCmd != null){
					if(documentData.contractorData.code != ""){
						var paymentContractorXML: XML = <contractor>{XML(documentData.contractorData.contractor)}</contractor>;
						payments.payment.appendChild(contractorXML);
					}
				}
				
				
				if(documentData.paymentType == "Gotówka"){
					payments.payment.paymentMethodId = "66B4A96A-511D-49F8-ABAB-6DEE34AC3D0D";
				}
				else if(documentData.paymentType == "Karta kredytowa"){
					payments.payment.paymentMethodId = "D3847280-4701-4C59-AD23-0A1955F4A473";
				}
				else if(documentData.paymentType == "Przelew"){
					payments.payment.paymentMethodId = "0B9D516E-BCAD-4702-AA17-11AAAED12845";
				}
				
				document.paymentsXML = payments;
				
			
				
			}
			else if(documentData.type == "WarehouseDocument"){
				
				for (var j:int = 0; j< documentData.itemsTable.length; j++)	{
					
				var wline:WarehouseDocumentLine = new WarehouseDocumentLine();
				wline.itemName = documentData.itemsTable[j].itemData.item.name;
				wline.itemId = documentData.itemsTable[j].itemData.item.id;
				wline.itemVersion = documentData.itemsTable[j].itemData.item.version;
				wline.quantity = documentData.itemsTable[j].quantity;
				wline.price = documentData.itemsTable[j].price == "" ? documentData.itemsTable[j].itemData.item.defaultPrice : documentData.itemsTable[j].price ;
							
				document.lines.addItem(wline);
							
							
				warehouseCalcPlugin.documentObject = document;
				warehouseCalcPlugin.calculateLine(wline, "itemName" );
				
				}
				
				if(documentData.contractorData.code != ""){
					temp = document.getFullXML();
					temp.contractor.contractor = documentData.contractorData.contractor;
					
				}	
				
				
				
				var warXML:XML = XML(dictionary.getBySymbol(documentData.warehouseSymbol));
				document.xml = temp;
				document.xml.warehouseId = String(warXML.id);
				warehouseCalcPlugin.calculateTotal(document);
				
				
							
				
			}
			
			
			if(documentData.template == "purchaseInvoice"){
				if((documentData.issueWarehouse == 1) && (documentData.issueFinancial == 1)) {
				
					options = <options>
    							<generateDocument method="incomeFromPurchase" labelKey="documents.options.incomeFromPurchase"/>
    							<generateDocument method="financialFromCommercial" labelKey="documents.options.financialFromCommercial"/>
  							  </options>;
  					}
  				
				else if(documentData.issueFinancial == 1) {
					options = <options>
    							<generateDocument method="financialFromCommercial" labelKey="documents.options.financialFromCommercial"/>
  							  </options>;
					}
				else if(documentData.issueWarehouse == 1) {
					options = <options>
    					<generateDocument method="incomeFromPurchase" labelKey="documents.options.incomeFromPurchase"/>
    				</options>;
					}
			}
			else if (documentData.template == "bill" || documentData.template == "invoice"){
				
				if((documentData.issueWarehouse == 1) && (documentData.issueFinancial == 1)) {
				
					options = <options>
    							<generateDocument method="outcomeFromSales" labelKey="documents.options.outcomeFromSales"/>
    							<generateDocument method="financialFromCommercial" labelKey="documents.options.financialFromCommercial"/>
  							  </options>;
  					}
  				
				else if(documentData.issueFinancial == 1) {
					options = <options>
    							<generateDocument method="financialFromCommercial" labelKey="documents.options.financialFromCommercial"/>
  							  </options>;
					}
				else if(documentData.issueWarehouse == 1) {
					options = <options>
    					<generateDocument method="outcomeFromSales" labelKey="documents.options.outcomeFromSales"/>
    				</options>;
					}
					
			}
			
			
			
			
			
					//if(saveCreatedDocumentsCB.selected == true)
				
					var cmd:SaveBusinessObjectCommand = new SaveBusinessObjectCommand();
					
					
					
					var finalXml:XML = 
					<root>
					{document.getFullXML()}
					{options}
					</root>;
  			
			//		cmd.execute(<root>{document.getFullXML()}</root>);
					cmd.execute(finalXml);
				
				flag = true;
				
				
		
			} 


		
		public function issueCorrectiveDocument(document:Object):void
		{
			var createCmd:CreateBusinessObjectCommand ;
			var correctedDocumentId:String = document.correctedDocumentId;
			
			var searchDocumentCmd:SearchCommand; 
			var loadDocumentCmd:LoadBusinessObjectCommand;
			
			createCmd = new CreateBusinessObjectCommand();
			createCmd.addEventListener(ResultEvent.RESULT, createCorrectiveResult);
											
			
			searchDocumentCmd = new SearchCommand("documents");
			
			
			for each (var x:XML in searchDocumentParams.filters.*){
				
				if(x.@field == "number") {
					searchDocumentParams.filters.column[0] = document.correctedDocumentNumber;
				}
				
			}
			
			
			for(var i:int=0; i<(document.linesTable).length; i++)
			{
				var item:Object = {itemIndex: i, itemData: XML, price: (document.linesTable[i]).price, quantity: (document.linesTable[i]).quantity, discountRate: (document.linesTable[i]).discountRate, vatRate: (document.linesTable[i]).vatRate };
				itemsTable.push(item);
			} 
			
			
			
				searchDocumentCmd.searchParams = this.searchDocumentParams;
								
				searchDocumentCmd.addEventListener(ResultEvent.RESULT, searchDocumentResult);
					
				correctiveDocumentData = {template: document.template, type: document.type, paymentType: document.payment, sourceType: document.sourceType, correctedDocumentNumber: document.correctedDocumentNumber, correctedDocumentId: null, createCmd: createCmd, warehouseSymbol: document.warehouseSymbol, issueFinancial: document.issueFinancial, issueWarehouse: document.issueWarehouse, searchDocumentCmd: searchDocumentCmd, loadDocumentCmd: loadDocumentCmd, contractorData: XML, itemsTable: itemsTable};
			
				correctiveDocumentData.searchDocumentCmd.execute();
		}
	
		
		private function searchDocumentResult(event:ResultEvent):void
		{
			var xml:XML = XML(event.result);
			
			correctiveDocumentData.correctedDocumentId = xml.commercialDocumentHeader.@id[0];
			correctiveDocumentData.loadDocumentCmd = new LoadBusinessObjectCommand(LoadBusinessObjectCommand.TYPE_COMMERCIAL_DOCUMENT, xml.commercialDocumentHeader.@id[0]);
			correctiveDocumentData.loadDocumentCmd.addEventListener(ResultEvent.RESULT, loadDocumentResult);
			correctiveDocumentData.loadDocumentCmd.execute();
		}
			
		private function loadDocumentResult(event:ResultEvent):void
		{
			correctiveDocumentData.originalDocumentData = XML(event.result);
				
			createCorrectiveDocument();
		}
		
		
		private function createCorrectiveDocument():void
		{
				var source:XML = 
					<source type={correctiveDocumentData.sourceType}>
					<correctedDocumentId>{correctiveDocumentData.correctedDocumentId}</correctedDocumentId>
					</source>;
				var object:Object = {type : correctiveDocumentData.type, template : correctiveDocumentData.template, source: source};
				
				correctiveDocumentData.createCmd.execute(object);
		}

			
		
		private function createCorrectiveResult(event:ResultEvent):void
		{
			
			trace("result wchodzący do createResult: " + XML(event.result));
			var nowDate:String = Tools.dateToIso(new Date()) ;
			var dueDate:String = Tools.dateToString(new Date());
				
			var document:DocumentObject = new DocumentObject(XML(event.result));
				
				
			var calcPlugin:CommercialDocumentCalculationPlugin = new CommercialDocumentCalculationPlugin();
			
			var temp:XML;
			var warehouseSymbol:String;
				
				for (var i:int = 0; i< document.lines.length; i++)	{
					
					
					var correctiveCline:CorrectiveCommercialDocumentLine = document.lines[i];
					correctiveCline.quantity = correctiveDocumentData.itemsTable[i].quantity;
					trace("mi");
					
					
					
					document.lines[i] = correctiveCline;
					calcPlugin.documentObject = document;
					
					calcPlugin.calculateLine(correctiveCline, "quantity");
					
					
				
					
					//document.lines = new ArrayCollection();
				/*	for(var j:int = 0; j<documentData.itemsTable.item[i].attributes.length; j++){
						trace("J");
					}*/
					//var cline:CorrectiveCommercialDocumentLine = new CorrectiveCommercialDocumentLine(null ,document);
	//				var correctiveCline:CorrectiveCommercialDocumentLine = CorrectiveCommercialDocumentLineine();
					
				/*	if(correctiveDocumentData.itemsTable[i].quantity == document.lines.getItemAt(i).quantity){
						
					}		
					*/
					//cline.itemName = document.lines[i].itemNameBeforeCorrection;
				//	cline.itemId = document.lines[i].itemData.item.id;
				//	cline.itemVersion = document.lines[i].itemData.item.version;
										
					
				//	cline.quantity = correctiveDocumentData.itemsTable[i].quantity;
				//	cline.initialNetPrice = correctiveDocumentData.itemsTable[i].price == "" ? correctiveDocumentData.itemsTable[i].itemData.item.defaultPrice : correctiveDocumentData.itemsTable[i].price;
				//	cline.discountRate = correctiveDocumentData.itemsTable[i].discountRate;
					
				//	var vatRate:String = String(XML(dictionary.getBySymbol(correctiveDocumentData.itemsTable[i].vatRate)).id);
				//	cline.vatRateId = vatRate;
				
				
				
				//	document.lines.addItem(cline);
					
				//	calcPlugin.documentObject = document;
				//	calcPlugin.calculateLine(cline, "quantity");
				//	calcPlugin.calculateLine(cline, "initialNetPrice");
				//	calcPlugin.calculateLine(cline, "discountRate");
					
					
				}
				
								
				//calcPlugin.calculateTotal(document);
					
				calcPlugin.calculateTotal(document);
				payments.payment.date = nowDate ;
				payments.payment.dueDate = dueDate ;
				payments.payment.exchangeDate = nowDate ;
				payments.payment.amount = Tools.round(document.totalForPayment, 2);
				
						
							
				if(correctiveDocumentData.paymentType == "Gotówka"){
					payments.payment.paymentMethodId = "66B4A96A-511D-49F8-ABAB-6DEE34AC3D0D";
				}
				else if(correctiveDocumentData.paymentType == "Karta kredytowa"){
					payments.payment.paymentMethodId = "D3847280-4701-4C59-AD23-0A1955F4A473";
				}
				else if(correctiveDocumentData.paymentType == "Przelew"){
					payments.payment.paymentMethodId = "0B9D516E-BCAD-4702-AA17-11AAAED12845";
				}
				
				document.paymentsXML = payments;
				
			
			
			if(correctiveDocumentData.template == "correctivePurchaseInvoice"){
				if((correctiveDocumentData.issueWarehouse == 1) && (correctiveDocumentData.issueFinancial == 1)) {
				
					options = <options>
    							<generateDocument method="correctiveIncomeFromCorrectivePurchase" labelKey="documents.options.correctiveOutcomeFromCorrectiveSales"/>
    							<generateDocument method="financialFromCommercial" labelKey="documents.options.financialFromCommercial"/>
  							  </options>;
  					}
  				
				else if(correctiveDocumentData.issueFinancial == 1) {
					options = <options>
    							<generateDocument method="financialFromCommercial" labelKey="documents.options.financialFromCommercial"/>
  							  </options>;
					}
				else if(correctiveDocumentData.issueWarehouse == 1) {
					options = <options>
    					<generateDocument method="correctiveIncomeFromCorrectivePurchase" labelKey="documents.options.correctiveOutcomeFromCorrectiveSales"/>
    				</options>;
					}
			}
			else if (correctiveDocumentData.template == "correctiveBill" || correctiveDocumentData.template == "invoice"){
				
				if((correctiveDocumentData.issueWarehouse == 1) && (correctiveDocumentData.issueFinancial == 1)) {
				
					options = <options>
    							<generateDocument method="correctiveOutcomeFromCorrectiveSales" labelKey="documents.options.correctiveOutcomeFromCorrectiveSales"/>
    							<generateDocument method="financialFromCommercial" labelKey="documents.options.financialFromCommercial"/>
  							  </options>;
  					}
  				
				else if(correctiveDocumentData.issueFinancial == 1) {
					options = <options>
    							<generateDocument method="financialFromCommercial" labelKey="documents.options.financialFromCommercial"/>
  							  </options>;
					}
				else if(correctiveDocumentData.issueWarehouse == 1) {
					options = <options>
    					<generateDocument method="correctiveOutcomeFromCorrectiveSales" labelKey="documents.options.correctiveOutcomeFromCorrectiveSales"/>
    				</options>;
					}
					
			}
			
			
					//if(saveCreatedDocumentsCB.selected == true)
				
					var cmd:SaveBusinessObjectCommand = new SaveBusinessObjectCommand();
					
					
					
					var finalXml:XML = 
					<root>
					{document.getFullXML()}
					{options}
					</root>;
  			
			//		cmd.execute(<root>{document.getFullXML()}</root>);
					cmd.execute(finalXml);
				
				flag = true;
				
				
		
			} 
		
		
		

	}
}