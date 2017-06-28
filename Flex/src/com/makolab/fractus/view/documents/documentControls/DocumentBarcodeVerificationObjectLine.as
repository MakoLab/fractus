package com.makolab.fractus.view.documents.documentControls
{
	import mx.collections.ArrayCollection;
	
	public class DocumentBarcodeVerificationObjectLine
	{
		public var quantity:int = 0;
		//public var line:CommercialDocumentLine;
		
		public var itemId:String;
		public var itemName:String;
		public var itemCode:String;
		public var itemQuantity:Number = 0;
		public var unitId:String = '2EC9C7C6-C250-41A6-818A-0C1B2B7D0A6C';
		//public var itemBarcode:String = "";
		public var itemBarcode:ArrayCollection = new ArrayCollection();
		
		public function DocumentBarcodeVerificationObjectLine(line:Object)
		{
			if(line!=null){
				//this.line = line;
				itemId = line.itemId;
				itemCode = line.itemCode;
				itemName = line.itemName;
				itemQuantity = line.quantity;
				unitId = line.unitId;
				
				if(line.hasOwnProperty("itemBarcode"))
				{
					//itemBarcode = line.itemBarcode;
					itemBarcode.addItem(line.itemBarcode);
				}
			}
		}

	}
}