package com.makolab.fractus.view.documents.plugins
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.model.*;
	import com.makolab.fractus.model.document.BusinessObject;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.model.document.FinancialDocumentLine;
	
	public class FinancialDocumentCalculationPlugin extends AbstractDocumentCalculationPlugin
	{
		[Bindable]
		public var totalAmount:Number;
		[Bindable]
		public var totalLines:Number;
		
		override protected function documentRecalculateHandler(event:DocumentEvent, fieldName:String = null):void
		{
			super.documentRecalculateHandler(event, 'amount');
		}
		
		override public function calculateLine(modifiedLine:BusinessObject, modifiedField:String):void
		{
			switch (modifiedField)
			{
				case "amount":
					break;
			}
		}

		override public function calculateTotal(doc:DocumentObject,fieldName:String = null):void
		{
			var ta:Number = 0, tl:Number = 0;
			
			for each (var line:FinancialDocumentLine in doc.lines)
			{
				if(line.amount > 0)
				{
					ta += line.amount;
					tl++;
				}
			}
			totalAmount = Tools.round(ta, 2);
			totalLines = tl;
			doc.xml.amount = totalAmount;
		}
		
	}
}