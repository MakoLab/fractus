package com.makolab.fractus.view.documents.documentControls
{
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.document.FinancialDocumentLine;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * Dispatched when a user changes any field of verification.
	 */
	[Event(name="documentBarcodeVerificationObjectChange")]
	
	public class DocumentBarcodeVerificationObject extends EventDispatcher
	{
		public static const DOCUMENT_BARCODE_VERIFICATION_CHANGE:String = "documentBarcodeVerificationObjectChange";
		
		[Bindable]
		public var lines:ArrayCollection;
		
		public function DocumentBarcodeVerificationObject()
		{
			lines = new ArrayCollection();
			storableItemsTypes = DictionaryManager.getInstance().dictionaries.itemTypes.(isWarehouseStorable.toString() == "1");
		}
		
		public function addLine(line:Object):void{
			lines.addItem(new DocumentBarcodeVerificationObjectLine(line));
			this.dispatchEvent(new Event(DOCUMENT_BARCODE_VERIFICATION_CHANGE));
			
		}
		
		private var storableItemsTypes:XMLList;
		
		private function addToCollection(collection:ArrayCollection,documentLine:Object,line:DocumentBarcodeVerificationObjectLine):void
		{
			var lineAlreadyAdded:int = -1;
			for each ( var n:DocumentBarcodeVerificationObjectLine in collection)
			{
				if (n.itemId == documentLine.itemId)
				{
					lineAlreadyAdded = collection.getItemIndex(n);
					break;
				}
			}
			
			if (lineAlreadyAdded > -1) 
			{
				collection[lineAlreadyAdded].itemQuantity += documentLine.quantity;
			}
			else
			{
				collection.addItem(line);
				line.itemQuantity = documentLine.quantity;
			}
		}
		
		public function addLines(documentlines:ArrayCollection):void{
			var newLines:ArrayCollection = new ArrayCollection();
			var v:DocumentBarcodeVerificationObjectLine;
			var i:Object;
			
			for each(v in lines)
			{
				var documentLineExists:Boolean = false;
				for each(var l:Object in documentlines)
				{
					if (l.itemId == v.itemId) documentLineExists = true;
				}
				if (!documentLineExists)
				{
					(v as DocumentBarcodeVerificationObjectLine).itemQuantity = 0;
					if (v.itemId) newLines.addItem(v);
				}
			}
			
			if(!(documentlines.getItemAt(0) is FinancialDocumentLine)){
				for each(i in documentlines){
					var verificationLineExists:Boolean = false;
					for each(v in lines)
					{
						if (i.itemId == v.itemId)
						{
							verificationLineExists = true;
							
							addToCollection(newLines,i,v);
						}
					}
					if (!verificationLineExists)
					{
						if (i.hasOwnProperty("itemTypeId"))
						{
							if (storableItemsTypes.(id.toString() == i.itemTypeId).length() > 0)
								addToCollection(newLines,i,new DocumentBarcodeVerificationObjectLine(i));
						}else{
							addToCollection(newLines,i,new DocumentBarcodeVerificationObjectLine(i));
						}
					}
				}
				
				lines = newLines;
			}
			
		
			
		}
		
		public function getQuantity(line:DocumentBarcodeVerificationObjectLine):int{
			for each (var i:DocumentBarcodeVerificationObjectLine in lines){
				if(i == line) return i.quantity;
			}
			return 0;
		}
		
		public function setQuantity(line:DocumentBarcodeVerificationObjectLine, value:int, add:Boolean = false):void{
			for each (var i:DocumentBarcodeVerificationObjectLine in lines){
				if(i == line){
					if(add) i.quantity += value;
					else i.quantity = value;
				}
			}
			lines.refresh();
			this.dispatchEvent(new Event(DOCUMENT_BARCODE_VERIFICATION_CHANGE));
		}
		
		public function getLineById(id:Object, quantityCheck:Boolean = true):DocumentBarcodeVerificationObjectLine{
			var lastLineFound:DocumentBarcodeVerificationObjectLine = null;
			for (var i:int = 0; i<lines.length; i++){
				if(lines[i].itemId == id) {
					lastLineFound = lines[i];
					if(quantityCheck && lastLineFound.quantity >= lastLineFound.itemQuantity){
						lastLineFound = getNextLineById(id, i);
					}
					
					return lastLineFound;
				}
			}
			return null;
		}
		
		private function getNextLineById(id:Object, lastLineFoundNumber:int):DocumentBarcodeVerificationObjectLine{
			
			var lastLineFound:DocumentBarcodeVerificationObjectLine = lines[lastLineFoundNumber];
			
			for (var i:int = lastLineFoundNumber+1; i<lines.length; i++){
				if(lines[i].itemId == id) {
					lastLineFound = lines[i];
					if(lastLineFound.quantity >= lastLineFound.itemQuantity){
						lastLineFound = getNextLineById(id, i);
					}
				}
			}
			return lastLineFound;
		}
		
		public function isQuantityValid():Boolean{
			var result:Boolean = true;
			for each (var i:DocumentBarcodeVerificationObjectLine in lines){		
					if(i.quantity != i.itemQuantity) result = false;
			}
			return result;
		}
		
		public function isLinesQuantityValid():Boolean{
			var result:Boolean = true;
			for each (var i:DocumentBarcodeVerificationObjectLine in lines){		
					if(i.quantity == 0) result = false;
			}
			return result;
		}
			
		public function clear(documentlines:ArrayCollection):void
		{
			lines.removeAll();
			addLines(documentlines);
		}
	}
}