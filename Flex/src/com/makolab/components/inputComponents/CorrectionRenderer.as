package com.makolab.components.inputComponents
{
	import com.makolab.components.util.CurrencyManager;
	
	import mx.containers.VBox;
	import mx.controls.Label;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.core.ScrollPolicy;

	public class CorrectionRenderer extends VBox implements IDropInListItemRenderer
	{
		public function CorrectionRenderer()
		{
			super();
			this.setStyle('verticalGap', 0);
			//this.setStyle('horizontalAlign', 'right');
			this.verticalScrollPolicy = ScrollPolicy.OFF;
			this.horizontalScrollPolicy = ScrollPolicy.OFF;
			this.percentWidth = 100;
			this.percentHeight = 100;
		}
		
		private var initialValueLabel:CurrencyRenderer;
		private var differentialValueLabel:Label;
		private var finalValueLabel:CurrencyRenderer;
		
		public var precision:int = 2;
		
		override protected function createChildren():void
		{
			initialValueLabel = new CurrencyRenderer();
			initialValueLabel.precision = this.precision;
			initialValueLabel.height = 0;
			initialValueLabel.setStyle("textAlign","right");
			initialValueLabel.percentWidth = 100;
			this.addChild(initialValueLabel);
			differentialValueLabel = new Label();
			differentialValueLabel.setStyle('fontWeight', 'bold');
			differentialValueLabel.setStyle("textAlign","right");
			differentialValueLabel.height = 0;
			differentialValueLabel.percentWidth = 100;
			this.addChild(differentialValueLabel);
			finalValueLabel = new CurrencyRenderer();
			finalValueLabel.precision = this.precision;
			finalValueLabel.percentWidth = 100;
			this.addChild(finalValueLabel);
			updateData();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			initialValueLabel.width = unscaledWidth;
			differentialValueLabel.width = unscaledWidth;
			finalValueLabel.width = unscaledWidth;
		}
		
		private var _listData:BaseListData;
		
		private var _dataObject:Object;
		public function set dataObject(value:Object):void
		{
			_dataObject = value;
			if (this.finalValueLabel) this.finalValueLabel.data = dataObject;
		}
		public function get dataObject():Object
		{
			return _dataObject;
		}
		
		public static function formatDiff(diff:Number, precision:int):String
		{
			var diffTxt:String = CurrencyManager.formatCurrency(diff, '?', '', precision);
			if (diff > 0) diffTxt = '+' + diffTxt;
			return diffTxt;
		}
		
		private function updateData():void
		{
			this.dataObject = DataObjectManager.getDataObject(this.data, this.listData);
			if (dataObject != null && this.listData)
			{
				var beforeCorrection:Number;
				var dataField:String = DataGridListData(this.listData).dataField;
				if (data is XML)
				{
					// sekcja dla DocumentRenderer
					beforeCorrection = parseFloat(data.correctedLine.line[dataField]);
				}
				else
				{
					// dla DocumentEditor
					var bcField:String = dataField + 'BeforeCorrection';
					if (this.data.hasOwnProperty(bcField)) beforeCorrection = this.data[bcField];
				}
				var diff:Number = parseFloat(String(this.dataObject)) - beforeCorrection;
				this.differentialValueLabel.text = formatDiff(diff, this.precision);
				this.initialValueLabel.data = beforeCorrection;
				this.differentialValueLabel.height = this.initialValueLabel.height = (diff != 0 ? NaN : 0);
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