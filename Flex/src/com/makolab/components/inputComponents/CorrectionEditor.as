package com.makolab.components.inputComponents
{
	import com.makolab.fractus.model.document.CorrectiveCommercialDocumentLine;
	
	import mx.containers.VBox;
	import mx.controls.Label;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.core.ScrollPolicy;
	import mx.managers.IFocusManagerComponent;

	public class CorrectionEditor extends VBox implements IDropInListItemRenderer, IFocusManagerComponent
	{
		public function CorrectionEditor()
		{
			super();
			this.setStyle('verticalGap', 0);
			this.setStyle('horizontalAlign', 'right');
			this.verticalScrollPolicy = ScrollPolicy.OFF;
			this.horizontalScrollPolicy = ScrollPolicy.OFF;
			this.percentHeight = 100;
			this.percentWidth = 100;
			this.setStyle('verticalAlign', 'bottom');
		}
		
		public var precision:int = 2;
		public var amountIncreaseEnabled:Boolean = true;
		
		private var initialValueLabel:CurrencyRenderer;
		private var differentialValueLabel:Label;
		private var finalValueInput:CurrencyEditor;

		override public function setFocus():void
		{
			finalValueInput.setFocus();
		}	
			
		override protected function createChildren():void
		{
			initialValueLabel = new CurrencyRenderer();
			initialValueLabel.precision = this.precision;
			initialValueLabel.percentWidth = 100;
			this.addChild(initialValueLabel);
			differentialValueLabel = new Label();
			differentialValueLabel.setStyle('fontWeight', 'bold');
			differentialValueLabel.setStyle("textAlign","right");
			differentialValueLabel.percentWidth = 100;
			this.addChild(differentialValueLabel);
			finalValueInput = new CurrencyEditor();
			finalValueInput.percentWidth = 100;
			this.addChild(finalValueInput);
			updateData();
		}

		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			initialValueLabel.height = differentialValueLabel.height = (unscaledHeight < 25 ? 0 : NaN); 
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			initialValueLabel.width = unscaledWidth;
			differentialValueLabel.width = unscaledWidth;
			finalValueInput.width = unscaledWidth;
		}	
			
		private var _listData:BaseListData;
		
		private var _dataObject:Object;
		public function set dataObject(value:Object):void
		{
			_dataObject = value;
			if (this.finalValueInput) this.finalValueInput.data = _dataObject;
		}
		public function get dataObject():Object
		{
			return this.finalValueInput ? this.finalValueInput.dataObject : _dataObject;
		}
		
		private function updateData():void
		{
			this.dataObject = DataObjectManager.getDataObject(this.data, this.listData);
			if (dataObject != null && this.listData)
			{
				var beforeCorrection:Number;
				var bcField:String = DataGridListData(this.listData).dataField + 'BeforeCorrection';
				if (this.data && this.data.hasOwnProperty(bcField)) beforeCorrection = this.data[bcField];
				this.differentialValueLabel.text = CorrectionRenderer.formatDiff(parseFloat(String(this.dataObject)) - beforeCorrection, this.precision);
				
				var corrLine:CorrectiveCommercialDocumentLine = this.data as CorrectiveCommercialDocumentLine; 
				
				if(beforeCorrection == 0 && corrLine && corrLine.correctedLine && corrLine.correctedLine is CorrectiveCommercialDocumentLine)
				{
					if(!amountIncreaseEnabled)
						this.finalValueInput.maxValue = CorrectiveCommercialDocumentLine(corrLine.correctedLine).quantityBeforeCorrection;
				}
				else if (!amountIncreaseEnabled) this.finalValueInput.maxValue = beforeCorrection;
				
				this.initialValueLabel.data = beforeCorrection;
			}
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			updateData();
		}
		
		public function set listData(value:BaseListData):void
		{
			_listData = value;
			updateData();
		}
		public function get listData():BaseListData
		{
			return _listData;
		}
	}
}