package com.makolab.fractus.view.generic
{
	import com.makolab.components.inputComponents.DataObjectManager;
	
	import mx.controls.Label;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;

	public class TooltipLabelRenderer extends Label implements IDropInListItemRenderer
	{
		public var toolTipField:String = "@itemName";
		private var _listData:BaseListData;
		
		private var _dataObject:Object;

		[Bindable]
		public function set dataObject(value:Object):void
		{
			_dataObject = value;
			if (value)
			{
				this.text = String(value);
				this.toolTip = data[this.toolTipField];
			}
			else toolTip = text = null;
		}

		public function get dataObject():Object { return _dataObject; }

		public override function set data(value:Object):void
		{
			super.data = value;
			dataObject = DataObjectManager.getDataObject(data, listData);
		}
		
		override public function set listData(value:BaseListData):void
		{
			_listData = value;
		}
		
		override public function get listData():BaseListData
		{
			return _listData
		}
	}
}