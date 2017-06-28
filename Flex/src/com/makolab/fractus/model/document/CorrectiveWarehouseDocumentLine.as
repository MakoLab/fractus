package com.makolab.fractus.model.document
{
	public class CorrectiveWarehouseDocumentLine extends WarehouseDocumentLine
	{
		public var quantityBeforeCorrection:Number;
		
		public var priceBeforeCorrection:Number;
		public var valueBeforeCorrection:Number;
				
		public function CorrectiveWarehouseDocumentLine(line:XML=null, parent:DocumentObject=null)
		{
			super(line, parent);
		}
		
		override public function deserialize(value:XML):void
		{
			super.deserialize(value);
			/*
			var l:XMLList = value.correctedLine.line;
			
		    if (l.length() > 0) for each (var node:XML in l[0].*)
		 	{
		 		var name:String = node.localName();
		 		switch (name)
		 		{
		 			case "itemName":
		 				this[name + 'BeforeCorrection'] = BusinessObject.deserializeString(node);		 			
		 				break;

		 			case "quantity":
		 			case "price":
		 			case "value":
		 				this[name + 'BeforeCorrection'] = BusinessObject.deserializeNumber(node);
		 				break;

		 		}
		 	}
		 	*/
		 	this.quantityBeforeCorrection = this.quantity;
		 	this.priceBeforeCorrection = this.price;
		 	this.valueBeforeCorrection = this.value;
		}
		
		override public function copy():BusinessObject
		{
			var newLine:CorrectiveWarehouseDocumentLine = super.copy() as CorrectiveWarehouseDocumentLine;
			
			newLine.quantityBeforeCorrection = this.quantityBeforeCorrection;
			
			newLine.priceBeforeCorrection = this.priceBeforeCorrection;
			newLine.valueBeforeCorrection = this.valueBeforeCorrection;
			
			return newLine;
		}
		
		public function restoreValues():void
		{
			this.quantity = this.quantityBeforeCorrection;
			
			this.price = this.priceBeforeCorrection;
			this.value = this.valueBeforeCorrection;		
		}
	}
}