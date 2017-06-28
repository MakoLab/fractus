package com.makolab.components.inputComponents
{
	import mx.containers.VBox;
	import mx.controls.Label;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;

	public class StringCorrectionRenderer extends VBox implements IDropInListItemRenderer
	{
		public function StringCorrectionRenderer()
		{
			super();
			this.setStyle('verticalGap', 0);
			this.setStyle('horizontalAlign', 'left');
			this.horizontalScrollPolicy = "off";
		}
		
		private var initialValueLabel:Label;
		private var differentialValueLabel:Label;
		private var finalValueLabel:Label;
		
		public var precision:int;
		
		override protected function createChildren():void
		{
			initialValueLabel = new Label();
			initialValueLabel.percentWidth = 100;
			initialValueLabel.height = 0;
			this.addChild(initialValueLabel);
			differentialValueLabel = new Label();
			differentialValueLabel.percentWidth = 100;
			differentialValueLabel.height = 0;
			this.addChild(differentialValueLabel);
			finalValueLabel = new Label();
			finalValueLabel.percentWidth = 100;
			this.addChild(finalValueLabel);
			updateData();
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
		
		private function updateData():void
		{
			this.dataObject = DataObjectManager.getDataObject(this.data, this.listData);
			if (dataObject != null && this.listData)
			{
				var beforeCorrection:String;
				var dataField:String = DataGridListData(this.listData).dataField;
				if (data is XML)
				{
					// sekcja dla DocumentRenderer
					beforeCorrection = String(data.correctedLine.line[dataField]);
				}
				else
				{
					// dla DocumentEditor
					var bcField:String = dataField + 'BeforeCorrection';
					if (this.data.hasOwnProperty(bcField)) beforeCorrection = this.data[bcField];
				}
				if (beforeCorrection != dataObject)
				{
					this.differentialValueLabel.text = "Po korekcie:";
					this.differentialValueLabel.height = this.initialValueLabel.height = NaN;
					this.initialValueLabel.setStyle('color', 0x999999);
					this.differentialValueLabel.setStyle('color', 0x999999);
					this.differentialValueLabel.setStyle('fontStyle', 'italic');
					this.initialValueLabel.text = beforeCorrection;
				}
				else
				{
					this.differentialValueLabel.height = this.initialValueLabel.height = 0;
					this.differentialValueLabel.setStyle('color', 0);
				}
				this.finalValueLabel.text = String(dataObject);
				this.toolTip = String(dataObject);
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