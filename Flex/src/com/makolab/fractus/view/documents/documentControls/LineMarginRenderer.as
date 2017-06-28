package com.makolab.fractus.view.documents.documentControls
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.components.util.CurrencyManager;
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.CommercialDocumentLine;
	
	import mx.controls.dataGridClasses.DataGridItemRenderer;

	public class LineMarginRenderer extends DataGridItemRenderer
	{
		public function LineMarginRenderer()
		{
			super();
		}
		
		
		override public function set data(value:Object):void
		{
			super.data = value;
			//updateView(data as CommercialDocumentLine);
			(data as CommercialDocumentLine).documentObject.addEventListener(DocumentEvent.DOCUMENT_LINE_CHANGE,lineChangeHandler);
		}
		
		private function lineChangeHandler(event:DocumentEvent):void
		{
			if (event.line == data && event.fieldName == "cost") updateView(data as CommercialDocumentLine);
		}
		
		override public function validateProperties():void
		{
			super.validateProperties();
			updateView(this.data as CommercialDocumentLine);
		}
		
		private function updateView(line:CommercialDocumentLine):void
		{
			setStyle('color',0x000000);
			setStyle('textAlign', 'right');
			this.background = false;
					
			if (line)
			{
				var entry:XML = DictionaryManager.getInstance().getById(line.itemTypeId);
				var isWarehouseStorable:Boolean = (entry != null ? entry.isWarehouseStorable.toString() == "1" : false);
				
				var margin:Number = 100 * (CurrencyManager.documentToSystem(line.netValue,line.documentObject) - line.cost) / CurrencyManager.documentToSystem(line.netValue,line.documentObject);
				if(line.netValue == 0)margin = NaN;
				
				var marginTxt:String;
				if(isNaN(margin) && isWarehouseStorable) {
					//TEXT
					marginTxt = '!';
					//TOOLTIP
					this.toolTip = LanguageManager.getInstance().labels.documents.messages.notEnoughGoodsInWarehouse; 
					setStyle('color',0xffffff);
					setStyle('textAlign', 'center');
					this.background = true;
					this.backgroundColor = 0xFF0000;
				} else if(isNaN(margin) && !isWarehouseStorable) {
					//TEXT
					marginTxt = '-';
					//TOOLTIP
					this.toolTip = LanguageManager.getInstance().labels.documents.estimatingCostNotPossible; 
				} else {
					//TEXT
					marginTxt = CurrencyManager.formatCurrency(margin, '-', '0', -2) + '%';
					//TOOLTIP
					var symbol:String = DictionaryManager.getInstance().getById(ModelLocator.getInstance().systemCurrencyId).symbol.toString();
					var lineNetValue:String = CurrencyManager.formatCurrency(CurrencyManager.documentToSystem(line.netValue,line.documentObject)) + symbol;
					this.toolTip =
						LanguageManager.getInstance().labels.common.profit + ": " + marginTxt + "\n" +
						LanguageManager.getInstance().labels.common.cost + ": " + CurrencyManager.formatCurrency(line.cost, '-', '0', 2) + symbol + "\n" +
						LanguageManager.getInstance().labels.common.averagePrice + ": " + CurrencyManager.formatCurrency(line.cost / line.quantity, '-', '0', 2) + symbol + "\n"+
						LanguageManager.getInstance().labels.documents.netValuePosition + ": " + lineNetValue;
					if (Tools.round(margin,2) <= 0) setStyle('color',0xff0000);
				}
				
				this.text = marginTxt;
			}
			else
			{
				this.toolTip = null;
				this.text = null;
			}
		}
		
	}
}