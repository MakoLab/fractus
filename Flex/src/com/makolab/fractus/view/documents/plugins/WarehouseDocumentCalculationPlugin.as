package com.makolab.fractus.view.documents.plugins
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.fractus.model.*;
	import com.makolab.fractus.model.document.BusinessObject;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.model.document.WarehouseDocumentLine;
	
	public class WarehouseDocumentCalculationPlugin extends AbstractDocumentCalculationPlugin
	{
		[Bindable]
		public var totalQuantity:Number;
		[Bindable]
		public var totalValue:Number;
		[Bindable]
		public var totalLines:Number;
		
		override protected function documentRecalculateHandler(event:DocumentEvent, fieldName:String = null):void
		{
			super.documentRecalculateHandler(event, 'price');
		}
		
		override public function calculateLine(modifiedLine:BusinessObject, modifiedField:String):void
		{
			var line:WarehouseDocumentLine = modifiedLine as WarehouseDocumentLine;
			switch (modifiedField)
			{
				case "value":
					line.price = round(line.value / line.quantity);
					if (line.quantity == 0) line.price = 0;
					// no break so recursive call not necessary
				case "price":
				case "quantity":
					line.value = round(line.price * line.quantity);
					break;
			}
		}

		override public function calculateTotal(doc:DocumentObject,fieldName:String = null):void
		{
			var tq:Number = 0, tv:Number = 0, tl:Number = 0;
			
			for each (var line:WarehouseDocumentLine in doc.lines)
			{
				if(line.itemId == "" || line.itemId == null) continue;
				
				tq += line.quantity;
				tv += line.value;
				tl++;
			}
			totalQuantity = tq;
			totalValue = tv;
			totalLines = tl;
			doc.xml.value = totalValue;
		}
		
	}
}