package com.makolab.fractus.model.document.quickSales
{
	import com.makolab.components.util.ComponentExportManager;
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.commands.CreateBusinessObjectCommand;
	import com.makolab.fractus.commands.SaveBusinessObjectCommand;
	import com.makolab.fractus.commands.SearchCommand;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.CommercialDocumentLine;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.view.documents.plugins.CommercialDocumentCalculationPlugin;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.utils.UIDUtil;
	import com.makolab.fractus.commands.GetItemsDetailsCommand;
	import com.makolab.fractus.commands.GetItemsDetailsForDocumentCommand;
	
	public class ClientSideProxy implements IQuickSalesProxy
	{
		public function ClientSideProxy()
		{
		}

		private var documentObject:DocumentObject;
		
		private var openDocumentCallback:Function;
		
		private var calcPlugin:CommercialDocumentCalculationPlugin = new CommercialDocumentCalculationPlugin();
		
		public function openDocument(callback:Function):void
		{
			var cmd:CreateBusinessObjectCommand = new CreateBusinessObjectCommand();
			cmd.addEventListener(ResultEvent.RESULT, handleDocumentLoad);
			cmd.execute({ type : "CommercialDocument", template : "bill"});
			openDocumentCallback = callback;
		}
		
		protected function handleDocumentLoad(event:ResultEvent):void
		{
			documentObject = new DocumentObject(XML(event.result));
			
			calcPlugin.documentObject = documentObject;
			
			var result:OpenDocumentResult = new OpenDocumentResult();
			result.availablePaymentForms = [
				'66B4A96A-511D-49F8-ABAB-6DEE34AC3D0D',	// gotowka
				'D3847280-4701-4C59-AD23-0A1955F4A473'	// przelew
			];
			result.currencyId = documentObject.xml.documentCurrencyId;
			result.documentTypeId = documentObject.xml.documentTypeId;
			result.fullNumber = documentObject.xml.number.fullNumber;
			result.id = documentObject.xml.id;
			result.paymentFormId = '66B4A96A-511D-49F8-ABAB-6DEE34AC3D0D';
			openDocumentCallback(result);
		}
		
		public function addAttribute(attributeName:String, attributeValue:Object):void
		{
			var documentFieldId:String = DictionaryManager.getInstance().getByName(attributeName, "documentAttributes").id;
			
			this.documentObject.attributes.addItem(<attribute><documentFieldId>{documentFieldId}</documentFieldId><value>{attributeValue}</value></attribute>);
		}
		
		protected var addItemByCodeCallback:Function;
		
		private var itemsSet:XML = ModelLocator.getInstance().configManager.getXML("itemsSet.set1");
		 
		public function addItemByCode(code:String, quantity:Number, callback:Function):void
		{
			var foundIS:XMLList = this.itemsSet..itemsSet.(valueOf().code == code);
			var cmd:SearchCommand;
			addItemByCodeCallback = callback;
			
			if(foundIS.length() > 0)
			{
				for each(var line:XML in foundIS[0].lines.line)
				{
					cmd = new SearchCommand(SearchCommand.ITEMS);
					cmd.searchParams =
							<searchParams>
								<pageSize>5</pageSize>
								<page>1</page>
								<columns>
									<column field="code" sortOrder="1" sortType="ASC" labelKey="common.code" label="Kod"/>
									<column field="name" sortOrder="2" sortType="ASC" labelKey="common.shortName" label="Nazwa"/>
									<column field="defaultPrice" sortOrder="3" sortType="ASC" label="Cena"/>
									<column field="version" label="Wersja"/>
									<column field="unitId" label="Jm"/>
								</columns>
								<filters>
									<column field="id">{String(line.itemId)}</column>
								</filters>
							</searchParams>;
					cmd.addEventListener(ResultEvent.RESULT, handleItemSearch);
					
					if(line.netPrice.length() > 0)
						cmd.targetObject =  { netPrice : parseFloat(line.netPrice.*), quantity : quantity, multiple : true };
					else if(line.grossPrice.length() > 0)
						cmd.targetObject =  { grossPrice : parseFloat(line.grossPrice.*), quantity : quantity, multiple : true };
					else
						cmd.targetObject = { quantity : quantity, multiple : true };
						
					cmd.execute({});
				}
			}
			else
			{
				/* zmiana mechanizmu na pobieranie detali z procedury
				cmd = new SearchCommand(SearchCommand.ITEMS);
				cmd.searchParams =
						<searchParams>
							<pageSize>5</pageSize>
							<page>1</page>
							<columns>
								<column field="code" sortOrder="1" sortType="ASC" labelKey="common.code" label="Kod"/>
								<column field="name" sortOrder="2" sortType="ASC" labelKey="common.shortName" label="Nazwa"/>
								<column field="defaultPrice" sortOrder="3" sortType="ASC" label="Cena"/>
								<column field="version" label="Wersja"/>
								<column field="unitId" label="Jm"/>
							</columns>
							<filters>
								<column field="barcode">{code}</column>
							</filters>
						</searchParams>;
				cmd.addEventListener(ResultEvent.RESULT, handleItemSearch);
				cmd.targetObject = { quantity : quantity, multiple : false };
				cmd.execute({});
				*/
				var detailsCmd:GetItemsDetailsForDocumentCommand = new GetItemsDetailsForDocumentCommand();
				detailsCmd.documentTypeId = this.documentObject.typeDescriptor.typeId;
				detailsCmd.barcode = code;
				detailsCmd.addEventListener(ResultEvent.RESULT, handleItemSearch);
				detailsCmd.targetObject = { quantity : quantity, multiple : false };
				detailsCmd.execute({});
			}
		}
		
		protected function handleItemSearch(event:ResultEvent):void
		{
			if (event.target is GetItemsDetailsForDocumentCommand)
			{
				handleItemDetails(event);
				return;
			}
			var searchResults:XMLList = XML(event.result).*;
			trace("SR: " + XML(event.result));
			var result:AddItemByCodeResult = new AddItemByCodeResult();
			if (searchResults.length() == 0)	// item not found
			{
				result.message = "Nie znaleziono towaru o wprowadzonym kodzie.";
				result.operationResult = AddItemByCodeResult.CODE_NOT_FOUND;
				
			}
			else if (searchResults.length() == 1)	// found one item
			{
				var itemData:XML = searchResults[0];
				var line:CommercialDocumentLine = new CommercialDocumentLine();
				line.itemId = itemData.@id;
				line.itemCode = itemData.@code;
				line.itemName = itemData.@name;
				line.itemVersion = itemData.@version;
				line.netPrice = itemData.@defaultPrice;
				
				line.vatRateId = 'F8D50E4D-066E-4F0A-BD58-C2BC708BEB0F';
				line.unitId = itemData.@unitId;
				line.quantity = event.target.targetObject.quantity;
				
				if(event.target.targetObject.multiple == true)
				{
					if(event.target.targetObject.netPrice || event.target.targetObject.netPrice == 0) //na wszelki wypadek, bo nie ma czasu testowac ;)
					{
						line.netPrice = event.target.targetObject.netPrice;
						calcPlugin.calculateLine(line, "netPrice");
					}
					else if (event.target.targetObject.grossPrice || event.target.targetObject.grossPrice == 0) //na wszelki wypadek, bo nie ma czasu testowac ;)
					{
						line.grossPrice = event.target.targetObject.grossPrice;
						calcPlugin.calculateLine(line, "grossPrice");
					}
				}
				
				documentObject.lines.addItem(line);
				result.name = line.itemName;
				result.code = line.itemCode;
				result.unitGrossPrice = line.grossPrice;
				result.vatRateId = line.vatRateId;
				result.unitId = line.unitId;
				result.operationResult = AddItemByCodeResult.ITEM_COMMITED;
				result.lineId = UIDUtil.getUID(line);
			}
			else	// found more than one
			{
				result.message = "Niejednoznaczne kryterium wyszukiwania (znaleziono więcej niż jeden artykuł).";
				result.operationResult = AddItemByCodeResult.ITEM_ERROR;
			}
			addItemByCodeCallback(result);
		}
		
		protected function handleItemDetails(event:ResultEvent):void
		{
			var resultXML:XML = XML(event.result);
			var result:AddItemByCodeResult = new AddItemByCodeResult();
			if (resultXML.item.length() == 0)	// item not found
			{
				result.message = "Nie znaleziono towaru o wprowadzonym kodzie.";
				result.operationResult = AddItemByCodeResult.CODE_NOT_FOUND;
			}
			else
			{
				var itemData:XML = resultXML.item[0];
				var line:CommercialDocumentLine = new CommercialDocumentLine();
				line.itemId = itemData.@id;
				line.itemCode = itemData.@code;
				line.itemName = itemData.@name;
				line.itemVersion = itemData.@version;
				line.documentObject = documentObject;

				var field:String = null;
				var fields:Array = ['discountRate', 'initialNetPrice', 'initialGrossPrice', 'netPrice', 'grossPrice'];
				for each (var currentField:String in fields)
				{
					if (itemData['@' + currentField].length() > 0)
					{
						field = currentField;
						line[currentField] = parseFloat(itemData['@' + currentField]);
					}
				}
				
				calcPlugin.calculateLine(line, field);
				
				line.vatRateId = itemData.@vatRateId;
				line.unitId = itemData.@unitId;
				line.quantity = event.target.targetObject.quantity;
				
				documentObject.lines.addItem(line);
				result.name = line.itemName;
				result.code = line.itemCode;
				result.unitGrossPrice = line.grossPrice;
				result.vatRateId = line.vatRateId;
				result.unitId = line.unitId;
				result.operationResult = AddItemByCodeResult.ITEM_COMMITED;
				result.lineId = UIDUtil.getUID(line);
			}
			addItemByCodeCallback(result);
		}
		
		public function getDocumentValue():Number
		{
			calcPlugin.calculateTotal(documentObject);
			return parseFloat(documentObject.xml.grossValue);
		}
		
		public function calculateDiscount(discountValue:Number):ArrayCollection
		{
			calcPlugin.calculateTotal(documentObject);
			if(discountValue > (parseFloat(documentObject.xml.grossValue) + documentObject.lines.length * 0.01)) //jak rabatu sie nie bedzie dalo wstawic to zwracamy null
				return null;
				
			var discountPerLine:Number = discountValue / documentObject.lines.length;
			var discountLeft:Number = discountValue;
			
			if(discountPerLine < 0.01)
				discountPerLine = 0;
			else
				discountPerLine = Math.floor(discountPerLine * 100) / 100;
			
			var line:CommercialDocumentLine;
			for each(line in documentObject.lines)
			{
				if(line.grossValue > discountPerLine) //czyli wieksze chocby o 1 grosz
				{
					line.grossValue -= discountPerLine;
					line.grossValue = Tools.round(line.grossValue, 2);
					discountLeft -= discountPerLine;
					discountLeft = Tools.round(discountLeft, 2);
				}
			}
			
			if(discountLeft > 0) //zdejmujemy z pierwszej z brzegu
			{
				for each(line in documentObject.lines)
				{
					if(line.grossValue > 0.01)
					{
						var difference:Number = 0;
						
						if(line.grossValue >= discountLeft + 0.01)
							difference = discountLeft;
						else
							difference = line.grossValue - 0.01;
							
						line.grossValue -= difference;
						line.grossValue = Tools.round(line.grossValue, 2);
						discountLeft -= difference;
						discountLeft = Tools.round(discountLeft, 2);
						
						if(discountLeft <= 0)
							break;
					}
				}
			}
			
			for each(line in documentObject.lines)
			{
				calcPlugin.calculateLine(line, "grossValue");		
			}
			
			return documentObject.lines;
		}
		
		public function removeLineById(lineId:String, callback:Function):void
		{
			for (var i:int = 0; i < documentObject.lines.length; i++)
			{
				if (lineId == UIDUtil.getUID(documentObject.lines[i]))
				{
					documentObject.lines.removeItemAt(i);
					callback(true);
					return;
				}
			}
			callback(false);
		}
		
		protected var closeDocumentCallback:Function;
		
		public function closeDocument(paymentFormId:String, documentId:String, callback:Function):void
		{
			closeDocumentCallback = callback;
			calcPlugin.calculateTotal(documentObject);
			documentObject.paymentsXML =
				<payments>
					<payment>
						<date>{String(documentObject.xml.issueDate)}</date>
						<dueDate>{String(documentObject.xml.issueDate)}</dueDate>
						<paymentMethodId>{paymentFormId}</paymentMethodId>
						<amount>{String(documentObject.xml.grossValue)}</amount>
						<paymentCurrencyId>{String(documentObject.xml.documentCurrencyId)}</paymentCurrencyId>
						<systemCurrencyId>{String(documentObject.xml.systemCurrencyId)}</systemCurrencyId>
						<exchangeDate>{String(documentObject.xml.exchangeDate)}</exchangeDate>
						<exchangeScale>{String(documentObject.xml.exchangeScale)}</exchangeScale>
						<exchangeRate>{String(documentObject.xml.exchangeRate)}</exchangeRate>
						<isSettled>0</isSettled>
					</payment>
				</payments>;
			var cmd:SaveBusinessObjectCommand = new SaveBusinessObjectCommand();
			cmd.addEventListener(ResultEvent.RESULT, handleCloseDocument);
			cmd.execute(<root>{documentObject.getFullXML()}{documentObject.getOptionsXML()}</root>);
		}
		
		protected function handleCloseDocument(event:ResultEvent):void
		{
			var result:CloseDocumentResult = new CloseDocumentResult();
			result.operationResult = CloseDocumentResult.DOCUMENT_SAVED;
			//ComponentExportManager.getInstance().exportObject('defaultCommercialDocumentPdf', XML(event.result).id.*, 'content');
			ComponentExportManager.getInstance().exportObjectFiscal(XML(event.result).id.*, 'defaultCommercialDocumentFiscal');
			closeDocumentCallback(result);
		}
		
	}
}