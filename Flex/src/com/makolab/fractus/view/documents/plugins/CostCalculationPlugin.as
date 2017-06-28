package com.makolab.fractus.view.documents.plugins
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.components.util.CurrencyManager;
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.commands.GetDeliveriesCommand;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.document.CommercialDocumentLine;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	import com.makolab.fractus.model.document.ShiftObject;
	import com.makolab.fractus.model.document.WarehouseDocumentLine;
	import com.makolab.fractus.view.documents.documentControls.IDocumentControl;
	
	import mx.rpc.events.ResultEvent;

	public class CostCalculationPlugin implements IDocumentControl
	{
		public function CostCalculationPlugin()
		{
		}
		
		private var originalPrices:Object = {};

		private var deliveryCache:Object = {};
		private function getDeliveryCacheEntry(itemId:String, warehouseId:String):Object
		{
			var entry:Object = deliveryCache[itemId + warehouseId];
			if (!entry)
			{
				entry = { deliveries : null, lines : [] };
				deliveryCache[itemId + warehouseId] = entry;
			}
			return entry;
		}
		
		private var _documentObject:DocumentObject;
		public function set documentObject(value:DocumentObject):void
		{
			_documentObject = value;
			_documentObject.addEventListener(DocumentEvent.DOCUMENT_LINE_SET_ITEM, handleSetItem);
			_documentObject.addEventListener(DocumentEvent.DOCUMENT_LINE_CHANGE, handleLineChange);
			_documentObject.addEventListener(DocumentEvent.DOCUMENT_LINE_ITEM_DETAILS_LOAD, handleItemDetailsLoad);
			_documentObject.addEventListener(DocumentEvent.DOCUMENT_FIELD_CHANGE, handleDocumentFieldChange);
			setOriginalPrices();
			loadDeliveriesForItems();
		}
		
		private function setOriginalPrices():void
		{
			if (_documentObject && _documentObject.typeDescriptor.isWarehouseOutcome)
			{
				originalPrices = {};
				for (var i:int = 0; i < _documentObject.lines.length; i++)
					if (_documentObject.lines[i].id) originalPrices[_documentObject.lines[i].id] = _documentObject.lines[i].price;
			}
		}
		
		public function get documentObject():DocumentObject
		{
			return _documentObject;
		}
		
		private function handleSetItem(event:DocumentEvent):void
		{
			var line:Object = event.line;
			var itemId:String = line.itemId;
			var warehouseId:String = (line is CommercialDocumentLine) ? CommercialDocumentLine(line).warehouseId : documentObject.xml.warehouseId;
			getDeliveryCacheEntry(itemId, warehouseId).lines.push(line);
			loadDeliveriesForItem(itemId, warehouseId);
		}
		
		private function handlerShiftsChange(event:DocumentEvent):void
		{
			updateLineCost(event.line);
		}
		
		public function loadDeliveriesForItem(itemId:String, warehouseId:String):void
		{
			if (itemId && warehouseId){
				var cmd:GetDeliveriesCommand = new GetDeliveriesCommand(itemId, warehouseId);
				cmd.addEventListener(ResultEvent.RESULT, handleDeliveriesResult);
				cmd.execute();
			}
		}
		
		public function loadDeliveriesForItems():void
		{
			var items:Array = [];
			for(var i:int = 0; i < documentObject.lines.length; i++){
				if(documentObject.lines[i].itemId){
					var item:XML;
					if(documentObject.typeDescriptor.isCommercialDocument) item = <item id={documentObject.lines[i].itemId} warehouseId={documentObject.lines[i].warehouseId}/>; 
					if(documentObject.typeDescriptor.isWarehouseDocument) item = <item id={documentObject.lines[i].itemId} warehouseId={documentObject.xml.warehouseId}/>;
					if(
						documentObject.typeDescriptor.categoryNumber == DocumentTypeDescriptor.CATEGORY_WAREHOUSE_ORDER
						|| documentObject.typeDescriptor.categoryNumber == DocumentTypeDescriptor.CATEGORY_WAREHOUSE_RESERVATION
					) item = <item id={documentObject.lines[i].itemId} warehouseId={documentObject.lines[i].warehouseId}/>; 
					if(documentObject.typeDescriptor.categoryNumber == DocumentTypeDescriptor.CATEGORY_SERVICE_DOCUMENT) item = <item id={documentObject.lines[i].itemId} warehouseId={documentObject.lines[i].warehouseId}/>;
					items.push(item);
				};
			}
			if(items.length == 0)return;
			var cmd:GetDeliveriesCommand = new GetDeliveriesCommand();
			cmd.items = items;
			cmd.addEventListener(ResultEvent.RESULT, handleDeliveriesResult);
			cmd.execute();
		}
		
		private function handleDeliveriesResult(event:ResultEvent):void
		{
			//var deliveries:Array = [];
			var deliveriesList:XMLList = XML(event.result).*;
			var itemDeliveries:Object = {};
			
			for each (var delivery:XML in deliveriesList)
			{
				/* deliveries.push({
					deliveryId : String(delivery.@id),
					documentNumber : String(delivery.@fullNumber),
					price : parseFloat(delivery.@price),
					quantity : parseFloat(delivery.@quantity)
				}); */
				if(!itemDeliveries[delivery.@itemId + delivery.@warehouseId])itemDeliveries[delivery.@itemId + delivery.@warehouseId] = [];
				itemDeliveries[delivery.@itemId + delivery.@warehouseId].push({
					deliveryId : String(delivery.@id),
					documentNumber : String(delivery.@fullNumber),
					price : delivery.@price,
					quantity : parseFloat(delivery.@quantity)
				});
			}
			
			var cmd:GetDeliveriesCommand = event.target as GetDeliveriesCommand;
			
			// zapisanie powiazanych linii na dostawach i aktualizacja kosztu.
			for(var i:int = 0; i < cmd.items.length; i++){
				var entryId:String = cmd.items[i].@id + cmd.items[i].@warehouseId;
				var entry:Object = getDeliveryCacheEntry(cmd.items[i].@id, cmd.items[i].@warehouseId);
				entry.deliveries = itemDeliveries[entryId];
				entry.lines = [];
				for(var l:int = 0; l < documentObject.lines.length; l++){
					var documentLine:Object = documentObject.lines[l];
					var warehouse:String = (documentLine is CommercialDocumentLine) ? documentLine.warehouseId : documentObject.xml.warehouseId;
					if(documentLine.itemId + warehouse == entryId)
						entry.lines.push(documentLine);
				}
				if (entry.lines) for each (var line:Object in entry.lines)
				{
					updateLineCost(line);
				}
			}
			
			/* var entry:Object = getDeliveryCacheEntry(cmd.itemId, cmd.warehouseId)
			entry.deliveries = deliveries;
			if (entry.lines) for each (var line:Object in entry.lines)
			{
				updateLineCost(line);
			} */
		}
		
		public function updateLineCost(line:Object):void
		{
			var calculateForWMS:Boolean;
			
			if (line is CommercialDocumentLine)
			{
				var entry:XML = DictionaryManager.getInstance().getById(line.itemTypeId);
				var isWarehouseStorable:Boolean = (entry != null ? entry.isWarehouseStorable.toString() == "1" : true);
				calculateForWMS = DictionaryManager.getInstance().getById(line.warehouseId).valuationMethod.toString() == "1";
				if(calculateForWMS)
				{
					CommercialDocumentLine(line).cost = calculateCostForItemFromShifts(line);
				}else{
					/* if ((line is CommercialDocumentLine) && line.additionalNodes != null && line.additionalNodes.(valueOf().localName() == "commercialWarehouseValuations").length() > 0)
					{
						valuations = line.additionalNodes.(valueOf().localName() == "commercialWarehouseValuations").commercialWarehouseValuation;
					} */
					CommercialDocumentLine(line).cost = isWarehouseStorable ? calculateCostForItem(line) : 0;
				}
				documentObject.dispatchEvent(DocumentEvent.createEvent(DocumentEvent.DOCUMENT_LINE_CHANGE,"cost", line));
			}
			else if (line is WarehouseDocumentLine && documentObject.typeDescriptor.isWarehouseOutcome)
			{
				var wdl:WarehouseDocumentLine = line as WarehouseDocumentLine;
				var cost:Number = NaN;
				calculateForWMS = DictionaryManager.getInstance().getById(documentObject.xml.warehouseId.toString()).valuationMethod.toString() == "1";
				
				if(calculateForWMS)
				{
					cost = calculateCostForItemFromShifts(line);
				}else{
					cost = calculateCostForItem(line);
				}
				if (!isNaN(cost))
				{
					//if(!wdl.shifts || (wdl.shifts && wdl.shifts.length == 0))
					//if(!calculateForWMS || (calculateForWMS && (!wdl.shifts || (wdl.shifts && wdl.shifts.length == 0))))
					//{
						wdl.value = cost;
						wdl.price = Tools.round(cost / wdl.quantity, 2);
					//}
				}
				else wdl.value = wdl.price = 0;
				
				documentObject.dispatchEvent(DocumentEvent.createEvent(DocumentEvent.DOCUMENT_LINE_CHANGE, "value", wdl));
			}
		}
		
		public function calculateCostForItem(line:Object):Number
		{
			// Algorytm opisany w specyfikacji: http://makointranet.makolab.net/Teams/Fractus/Shared%20Documents/Fractus%202%20(core)/Wy%C5%9Bwietlanie%20mar%C5%BCy,%20kosztu%20i%20warto%C5%9Bci.docx 
			// TFS bug 71.
			
			var cost:Number = 0;
			var valuations:XMLList;
			var relations:XMLList;
			var commercialWarehouseRelations:XMLList;
			var warehouseId:String;
			var quantity:Number = line.quantity;
			var itemId:String = line.itemId;
			var deliveries:Array = [];
			var vq:Number = 0;
			var v:int = 0;
			var delivery:Object;
			var valuationPrice:Number = 0;
			var q:Number = 0;
			
			if (line is WarehouseDocumentLine)
			{
				warehouseId = documentObject.xml.warehouseId;
				// wyciagniecie relacji.
				if (line.additionalNodes != null && line.additionalNodes.(valueOf().localName() == "incomeOutcomeRelations").length() > 0)
					relations = line.additionalNodes.(valueOf().localName() == "incomeOutcomeRelations").incomeOutcomeRelation;
				// obliczanie ilosci towaru wynikajacej z relacji (ilosc przed edycja)
				// i obliczenie wartosci pozycji dla tej ilosci.
				if (relations && relations.length() > 0)
				{
					vq = 0;
					for (v = 0; v < relations.length(); v++)
						vq += Number(relations[v].quantity.toString());
					 
					cost = originalPrices[line.id] * Math.min(quantity,vq);
				}
				
				deliveries = getDeliveryCacheEntry(itemId, warehouseId).deliveries as Array;
				// jesli zwiekszamy ilosc na pozycji, do wartosci dodajemy ceny wynikajace z dostaw.
				if (vq < quantity)
				{
					quantity -= vq;
					for each (delivery in deliveries)
					{
						q = Math.min(delivery.quantity, quantity);
						if(delivery.price == 0) return NaN;
						cost += delivery.price * q;
						quantity -= q;
						if (quantity <= 0) break; 
					}
					if (quantity > 0) return NaN;
				}
			}
			
			if (line is CommercialDocumentLine)
			{
				warehouseId = line.warehouseId;
				// wyciagniecie wycen.
				if (line.additionalNodes != null && line.additionalNodes.(valueOf().localName() == "commercialWarehouseValuations").length() > 0)
					valuations = line.additionalNodes.(valueOf().localName() == "commercialWarehouseValuations").commercialWarehouseValuation;
				
				// wyciagniecie relacji.
				if (line.additionalNodes != null && line.additionalNodes.(valueOf().localName() == "commercialWarehouseRelations").length() > 0)
					commercialWarehouseRelations = line.additionalNodes.(valueOf().localName() == "commercialWarehouseRelations").commercialWarehouseRelation;
				
				// ilosc i wartosc z powiazan
				var relatedQuantity:Number = 0;
				var relatedValue:Number = 0;
				for each (var cwRelation:XML in commercialWarehouseRelations)
				{
					relatedQuantity += Number(cwRelation.relatedLine.line.quantity);
					relatedValue += Number(cwRelation.relatedLine.line.value) != 0 ? Number(cwRelation.relatedLine.line.value) : NaN;
				}
				
				//ilosc i wartosc z wycen
				var valuationQuantity:Number = 0;
				var valuationValue:Number = 0;
				
				////// Dla ilosci nieprzekraczajacej ilosci z powazan wartosc okreslamy na pdst powiazan lub wycen ////////
				
				// jezeli pozycja jest nowa (nie ma wersji) to cost jest suma wartosci z relacji.
				if (line.version == null)
				{
					cost = relatedValue;
				}
				// jezeli pozycja jest wczytana do edycji pobieramy wartosc z wycen
				else
				{
					var valuationSums:Object = getValuationSums(valuations);
					valuationQuantity = valuationSums.quantity;
					valuationValue = valuationSums.value; 
					if (valuationQuantity < relatedQuantity) cost = NaN;
					else cost = valuationValue;
				}
				cost = Tools.round(Math.min(quantity,relatedQuantity) * (cost / relatedQuantity)); 
				
				////// Dla ilosci przekraczajacej ilosc z powiazan wartosc okreslamy na pdst dostepnych dostaw ///////
				
				deliveries = getDeliveryCacheEntry(itemId, warehouseId).deliveries as Array;
				
				// jesli zwiekszamy ilosc na pozycji, do wartosci dodajemy ceny wynikajace z dostaw.
				if (relatedQuantity < quantity){
					// jesli relatedQuantity == 0 to cost ze wzoru wychodzi NaN
					if (relatedQuantity == 0) cost = 0;
					quantity -= relatedQuantity;
					for each (delivery in deliveries)
					{
						q = Math.min(delivery.quantity, quantity);
						if(delivery.price == 0) return NaN;
						cost += delivery.price * q;
						quantity -= q;
						if (quantity <= 0) break; 
					}
					if (quantity > 0) return NaN;
				}
			} 
			//cost = CurrencyManager.systemToDocument(cost,documentObject);
			return cost;
		}
		
		private function getValuationSums(valuations:XMLList):Object
		{
			var quantity:Number = 0;
			var value:Number = 0;
			for (var v:int = 0; v < valuations.length(); v++)
			{
				quantity += Number(valuations[v].quantity.toString());
				value += Number(valuations[v].value.toString());
			}
			return {quantity : quantity, value : value};
		}
		
		private function calculateCostForItemFromShifts(line:Object):Number
		{
			var cost:Number = 0;
			var valuations:XMLList;
			var relations:XMLList;
			var commercialWarehouseRelations:XMLList;
			var quantity:Number = line.quantity;
			var vq:Number = 0;
			var q:Number = 0;
			var shift:ShiftObject;
			
			if (line is WarehouseDocumentLine)
			{
				// wyciagniecie relacji.
				if (line.additionalNodes != null && line.additionalNodes.(valueOf().localName() == "incomeOutcomeRelations").length() > 0)
					relations = line.additionalNodes.(valueOf().localName() == "incomeOutcomeRelations").incomeOutcomeRelation;
				// obliczanie ilosci towaru wynikajacej z relacji (ilosc przed edycja)
				// i obliczenie wartosci pozycji dla tej ilosci.
				if (relations && relations.length() > 0)
				{
					vq = 0;
					for (var r:int = 0; r < relations.length(); r++)
						vq += Number(relations[r].quantity.toString());
					 
					cost = originalPrices[line.id] * Math.min(quantity,vq);
				}
				
				// jesli zwiekszamy ilosc na pozycji, do wartosci dodajemy ceny wynikajace z dostaw.
				if (vq < quantity)
				{
					quantity -= vq;
					for each (shift in line.shifts)
					{
						q = Math.min(Number(shift.quantity), quantity);
						if(Number(shift.price) == 0) return NaN;
						cost += Number(shift.price) * q;
						quantity -= q;
						if (quantity <= 0) break; 
					}
					if (quantity > 0) return NaN;
				}
			}
			
			if (line is CommercialDocumentLine)
			{
				// wyciagniecie wycen.
				if (line.additionalNodes != null && line.additionalNodes.(valueOf().localName() == "commercialWarehouseValuations").length() > 0)
					valuations = line.additionalNodes.(valueOf().localName() == "commercialWarehouseValuations").commercialWarehouseValuation;
				
				// wyciagniecie relacji.
				if (line.additionalNodes != null && line.additionalNodes.(valueOf().localName() == "commercialWarehouseRelations").length() > 0)
					commercialWarehouseRelations = line.additionalNodes.(valueOf().localName() == "commercialWarehouseRelations").commercialWarehouseRelation;
				
				// ilosc i wartosc z powiazan
				var relatedQuantity:Number = 0;
				var relatedValue:Number = 0;
				for each (var cwRelation:XML in commercialWarehouseRelations)
				{
					relatedQuantity += Number(cwRelation.quantity);
					relatedValue += Number(cwRelation.relatedLine.line.value) != 0 ? Number(cwRelation.relatedLine.line.value) : NaN;
				}
				
				//ilosc i wartosc z wycen
				var valuationQuantity:Number = 0;
				var valuationValue:Number = 0;
				
				////// Dla ilosci nieprzekraczajacej ilosci z powazan wartosc okreslamy na pdst powiazan lub wycen ////////
				
				// jezeli pozycja jest nowa (nie ma wersji) to cost jest suma wartosci z relacji.
				if (line.version == null) cost = relatedValue;
				// jezeli pozycja jest wczytana do edycji pobieramy wartosc z wycen
				else
				{
					var valuationSums:Object = getValuationSums(valuations);
					valuationQuantity = valuationSums.quantity;
					valuationValue = valuationSums.value; 
					if (valuationQuantity < relatedQuantity) cost = NaN;
					else cost = valuationValue;
				}
				cost = Tools.round(Math.min(quantity,relatedQuantity) * (cost / relatedQuantity)); 
				
				////// Dla ilosci przekraczajacej ilosc z powiazan wartosc okreslamy na pdst dostepnych dostaw ///////
				
				// jesli zwiekszamy ilosc na pozycji, do wartosci dodajemy ceny wynikajace z dostaw.
				if (relatedQuantity < quantity){
					// jesli relatedQuantity == 0 to cost ze wzoru wychodzi NaN
					if (relatedQuantity == 0) cost = 0;
					quantity -= relatedQuantity;
					for each (shift in line.shifts)
					{
						q = Math.min(Number(shift.quantity), quantity);
						if(Number(shift.price) == 0) return NaN;
						cost += Number(shift.price) * q;
						quantity -= q;
						if (quantity <= 0) break; 
					}
					if (quantity > 0) return NaN;
				}
			}
			
			//cost = CurrencyManager.systemToDocument(cost,documentObject);
			return cost;
		}
		
		private function handleLineChange(event:DocumentEvent):void
		{
			if(event.type == DocumentEvent.DOCUMENT_LINE_CHANGE && event.fieldName == "quantity")
				updateLineCost(event.line);
			if(event.type == DocumentEvent.DOCUMENT_LINE_CHANGE && event.fieldName == "warehouseId")
				loadDeliveriesForItem(event.line.itemId,event.line.warehouseId);
			if(event.type == DocumentEvent.DOCUMENT_LINE_CHANGE && event.fieldName == "shifts")
				updateLineCost(event.line);
		}
		
		private function handleItemDetailsLoad(event:DocumentEvent):void
		{
			updateLineCost(event.line);
		}
		
		private function handleDocumentFieldChange(event:DocumentEvent):void
		{
			if (event.fieldName == "currency")
				for each (var line:Object in documentObject.lines)
					updateLineCost(line);
		}
	}
}