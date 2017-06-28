package com.makolab.fractus.view.documents.documentControls
{
	import assets.IconManager;
	
	import com.makolab.components.inputComponents.DataObjectManager;
	import com.makolab.fractus.model.LanguageManager;
	
	import mx.controls.Image;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.controls.listClasses.IListItemRenderer;

	public class OrderRealizationStatusRenderer extends Image implements IDropInListItemRenderer, IListItemRenderer
	{
		public function OrderRealizationStatusRenderer()
		{
			super();
			setStyle('horizontalAlign', 'center');
			setStyle('horizontalCenter', '0');
			scaleContent = false;
		}
		
		private var _dataObject:Object;
		public var _listData:BaseListData;
		
		//implements listData in HBox
		public override function set listData(value:BaseListData):void	
		{
			_listData = value;
			dataObject = DataObjectManager.getDataObject(data, listData);
		}
		public override function get listData():BaseListData
		{
			return _listData;
		}
		
		private var _data:Object;
		[Bindable]
		public override function set data(value:Object):void
		{
			_data = value;
			dataObject = DataObjectManager.getDataObject(data, listData);
		}
		public override function get data():Object
		{
			return _data;
		}
		
		[Bindable]
		public function set dataObject(value:Object):void
		{
			if (_dataObject == value) return;
			_dataObject = value;

			if(value && String(value) == "1")
			{
				source = IconManager.getIcon("status_commited");
				toolTip = LanguageManager.getLabel("documents.realizedStatus");
			}
			else
			{
				source = null;
				toolTip = null;
			}
		}
		
		public function get dataObject():Object
		{
			return _dataObject;
		}
	}
}