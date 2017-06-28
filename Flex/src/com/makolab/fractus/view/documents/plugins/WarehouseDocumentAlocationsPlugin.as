package com.makolab.fractus.view.documents.plugins
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.fractus.commands.GetItemLotsCommand;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.model.document.ShiftObject;
	import com.makolab.fractus.view.documents.documentControls.IDocumentControl;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;

	public class WarehouseDocumentAlocationsPlugin implements IDocumentControl
	{
		public function WarehouseDocumentAlocationsPlugin()
		{
		}
		
		//private var editedLine:WarehouseDocumentLine;
		private var quantity:Number;
		
		private var _documentObject:DocumentObject;
		public function set documentObject(value:DocumentObject):void
		{
			_documentObject = value;
			if (ModelLocator.getInstance().isWmsEnabled)
			{
				_documentObject.addEventListener(DocumentEvent.DOCUMENT_LINE_CHANGE, handleLineChange);
				_documentObject.addEventListener(DocumentEvent.DOCUMENT_LINE_SET_ITEM, handleLineChange);
				_documentObject.addEventListener(DocumentEvent.DOCUMENT_FIELD_CHANGE,documentFieldChangeHandler);
				_documentObject.addEventListener(DocumentEvent.DOCUMENT_LINE_ADD,documentLineAddHandler);
				getAlocationsForNewLines();
			}
		}
		
		private function getAlocationsForNewLines():void
		{
			if (_documentObject)
			{
				// jesli dokumenet jest wystawiany ze schowka lub innego dok. (line.version == null)
				// i nie zostaly dla niego wczesniej wybrane alokacje (nie ma powiazan z wz, czyli commercialWarehouseRelations.length() == 0)
				// to ustawiamy domyslne alokacje. 
				for (var i:int = 0; i < _documentObject.lines.length; i++)
				{
					var line:Object = _documentObject.lines[i];
					var commercialWarehouseRelations:XMLList;
					if (line.additionalNodes != null && line.additionalNodes.(valueOf().localName() == "commercialWarehouseRelations").length() > 0)
						commercialWarehouseRelations = line.additionalNodes.(valueOf().localName() == "commercialWarehouseRelations").commercialWarehouseRelation;
					
					if (
						(line.version == null && commercialWarehouseRelations.length() == 0)
						) callCommand(line);
				}
			}
		}
		
		public function get documentObject():DocumentObject
		{
			return _documentObject;
		}
		
		private function documentLineAddHandler(event:DocumentEvent):void
		{
			callCommand(event.line,true);
		}
		
		private function documentFieldChangeHandler(event:DocumentEvent):void
		{
			if(event.fieldName == "warehouseId"){
				if(documentObject.typeDescriptor.isSalesDocument)warehouseId = event.line.warehouseId;
				else warehouseId = documentObject.xml.warehouseId.*;
			}
		}
		
		private var allowAlocations:Boolean = true;
		
		private var _warehouseId:String;
		
		[Bindable]
		public function set warehouseId(value:String):void{
			_warehouseId = value;
			if(ModelLocator.getInstance().dictionaryManager.dictionaries.allWarehouses.(id.toString() ==  _warehouseId).valuationMethod.toString() == "0"){
				allowAlocations = false;
				for(var i:int=0;i<documentObject.lines.length;i++){
					if(documentObject.lines[i].hasOwnProperty("shifts"))documentObject.lines[i].shifts = [];
				}
			}else{
				allowAlocations = true;
				commandArray = [];
				for(var j:int=0;j<documentObject.lines.length;j++){
					callCommand(documentObject.lines[j]);
				}
			}
		}
		public function get warehouseId():String
		{
			return _warehouseId;
		}
		
		private function handleLineChange(event:DocumentEvent):void
		{
			if(
				(
					(
						allowAlocations
						 && documentObject.typeDescriptor.isWarehouseOutcome 
						 && (ModelLocator.getInstance().dictionaryManager.dictionaries.allWarehouses.(id.toString() ==  documentObject.xml.warehouseId.toString()).valuationMethod.toString() == "1")
					 )
					 || documentObject.typeDescriptor.isSalesDocument
				 )
				 && (event.fieldName == "quantity" || event.fieldName == "itemName" || event.fieldName == "itemId")
			){
				if(documentObject.typeDescriptor.isSalesDocument && ModelLocator.getInstance().dictionaryManager.dictionaries.allWarehouses.(id.toString() ==  event.line.warehouseId).valuationMethod.toString() == "0"){
					event.line.shifts = [];
				}else{
					commandArray = [];
					callCommand(event.line,(event.fieldName == "quantity" || event.fieldName == "warehouseId"));
				}
			}else if(documentObject.typeDescriptor.isSalesDocument && event.fieldName == "warehouseId"){
				callCommand(event.line);//warehouseId = event.line.warehouseId;
			}else if(documentObject.typeDescriptor.isWarehouseIncome || documentObject.typeDescriptor.isPurchaseDocument){
				if(event.line.shifts && event.line.shifts.length == 1 && (event.fieldName == "quantity" || event.fieldName == "itemName")){
					event.line.shifts[0].quantity = event.line.quantity;
				}
				if(documentObject.typeDescriptor.isPurchaseDocument && ModelLocator.getInstance().dictionaryManager.dictionaries.allWarehouses.(id.toString() ==  event.line.warehouseId).valuationMethod.toString() == "0"){
					event.line.shifts = [];
				}
			}
		}
		
		private var commandArray:Array = [];
		
		private function callCommand(line:Object,quantityChanged:Boolean = false):void
		{
			if(line.itemId){
				var shiftTransactionId:String = line.documentObject.shiftsTransaction.id;
				var warehouseId:String = this.warehouseId ? this.warehouseId : line.documentObject.xml.warehouseId.toString();
				if(line.hasOwnProperty("warehouseId"))warehouseId = line.warehouseId; 
				var warehouseDocumentHeaderId:String = (line.documentObject.isNewDocument) ? null : line.documentObject.xml.id.toString();
				if(ModelLocator.getInstance().dictionaryManager.dictionaries.allWarehouses.(id.toString() == warehouseId).valuationMethod.toString() == "1"){
					var cmd:GetItemLotsCommand = new GetItemLotsCommand(line.itemId,warehouseId,shiftTransactionId,warehouseDocumentHeaderId);
					cmd.addEventListener(ResultEvent.RESULT,handleResult);
					commandArray.push({command : cmd,line : line,recalculateAll : !quantityChanged});
					cmd.execute();
				}
				//editedLine = line;
			}
		}
		
		private function handleResult(event:ResultEvent):void
		{
			var editedLine:Object;
			var recalculateAll:Boolean;
			for(var i:int=0;i<commandArray.length;i++){
				if(commandArray[i].command == event.currentTarget){
					editedLine = commandArray[i].line;
					recalculateAll = commandArray[i].recalculateAll;
					getDefaultShifts(editedLine,XMLList(XML(event.result).*),recalculateAll);
					break;
				}
			}
		}
		
		private function availableQuantity(line:Object,shifts:XMLList):Number
		{
			var quantity:Number = line.quantity;
			for each(var shift:XML in shifts){
				if(shift.@count.length() > 0 && shift.@count != ""){
					quantity -= Number(shift.@count);
				}
			}
			return quantity;
		} 
		
		private function getDefaultShifts(line:Object,shifts:XMLList,recalculateAll:Boolean = true):void
		{
			var source:XMLList = XMLList(shifts);
			var total:Number = line.quantity;
			var list:XMLList = new XMLList();
			var shift:XML;
			var i:int;
			var lines:ArrayCollection = (line.documentObject as DocumentObject).lines;
			
			var existingShifts:Array = [];
			
			for each(shift in source){
				for ( i=0; i < lines.length; i++ ){
					if(lines[i] != line && lines[i].itemId == line.itemId){
						for(var sft:int = 0; sft < lines[i].shifts.length; sft++){
							if(shift.@shiftId == lines[i].shifts[sft].sourceShiftId){
								if(shift.attribute("used").length() == 0)shift.@used = 0;
								shift.@used = (Number(shift.@used) + Number(lines[i].shifts[sft].quantity)).toFixed(4);
							}
						}
					};
				}
			}
			
			//jesli nie zmieniła sie ilosc na pozycji przeliczamy od nowa wszystkie alokacje:
			if(recalculateAll){
				for each(shift in source){
					if(shift.attribute("used").length() == 0)shift.@used = 0;
					if(total + Number(shift.@used) > Number(shift.@quantity)){
						shift.@count = (Number(shift.@quantity) - Number(shift.@used));//shift.@quantity;
						//total -= Number(shift.@quantity);
						total -= (Number(shift.@quantity) - Number(shift.@used)); 
					}else {
						shift.@count = total;
						total = 0;
					}
					list = list + shift;
				}
			}
			//jesli zmienila sie ilosc na pozycji i dodajemy/odejmujemy tylko roznice ilosci:
			else
			{
				//uzupelniamy tablice dotychczasowymi wartosciami:
				for each(shift in source){
					for(i=0;i<line.shifts.length;i++){
						if((line.shifts[i].sourceShiftId == shift.@shiftId) || (!shift.hasOwnProperty("@shiftId") && shift.@incomeWarehouseDocumentLineId == line.shifts[i].incomeWarehouseDocumentLineId)){
							shift.@count = line.shifts[i].quantity;
						}
					}
				}
				//jesli ilosc sie zwiekszyla
				total = availableQuantity(line,source);
				var difference:Number = 0;
				if(total > 0){
					for each(shift in source){
						difference = (Number(shift.@quantity) - (Number(shift.@count) + Number(shift.@used)));
						if(difference > total){
							shift.@count = (Number(shift.@count) + total);
							total = 0;
						}else{
							shift.@count = (Number(shift.@quantity) - Number(shift.@used));
							total -= difference;
						}
						list = list + shift;
					}
				//jesli ilosc sie zmniejszyla
				}else{
					total = -total;
					var j:int;
					for (j = source.length() - 1; j >= 0 ;j--){
						if(Number(source[j].@count) > total){
							source[j].@count = (Number(source[j].@count) - total);
							total = 0;
						}else{
							total -= Number(source[j].@count);
							source[j].@count = 0;
						}
						list = list + source[j];
					}
					//odwracamy tablice zeby byla ladna kolejnosc w rendererze.
					var revertedList:XMLList = list;
					list = new XMLList();
					for (j = revertedList.length() - 1; j >= 0 ;j--){
						list = list + revertedList[j];
					}
				}
			}
			
			shifts = list;
			
			var lineShifts:Array = [];
			var shiftObject:Object = {};
			for each(var lineShift:XML in list){
				if(lineShift.@count.length() > 0 && lineShift.@count != "0" && lineShift.@count != ""){
					shiftObject.containerId = null;
					shiftObject.incomeDate = lineShift.@incomeDate;
					shiftObject.incomeWarehouseDocumentLineId = lineShift.@incomeWarehouseDocumentLineId;
					shiftObject.quantity = Number(lineShift.@count).toFixed(4);
					shiftObject.sourceShiftId = lineShift.@shiftId;
					shiftObject.status = lineShift.@status;
					shiftObject.price = lineShift.@price;
					//shiftObject.version = lineShift.@version;
					shiftObject.containerLabel = lineShift.@containerLabel;
					lineShifts.push(new ShiftObject(shiftObject));
				}
			}
			line.shifts = lineShifts;
			documentObject.dispatchEvent(DocumentEvent.createEvent(DocumentEvent.DOCUMENT_LINE_CHANGE, "shifts", line));
		}
		
	}
}