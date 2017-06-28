package com.makolab.fractus.view.generic
{
	import com.makolab.components.inputComponents.DataObjectManager;
	
	import mx.controls.LinkButton;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;

	public class CellDetailsButton extends LinkButton implements IDropInListItemRenderer
	{
		private var _listData:BaseListData;
		private var _dataObject:Object;
		public var labelFunction:Function;
		
		
		public function CellDetailsButton()
		{
			super();
		}
		/*
		*ListData
		*/
		public override function get listData():BaseListData
		{
			return this._listData;
		}
		
		public override function set listData(value:BaseListData):void
		{
			this._listData = value;
			this.dataObject = DataObjectManager.getDataObject(data, listData);
		}
		
		/*
		*Data
		*/
		public override function set data(value:Object):void
		{	
			super.data = value;
			this.dataObject = DataObjectManager.getDataObject(data, listData);
		}
		
		public override function get data():Object
		{
			return super.data;
		}
		/*
		*DataObject
		*/
		public function set dataObject(value:Object):void
		{
			if (labelFunction is Function)
			{
				this.label = labelFunction(value, this);
			}
			else if (value != null)
			{
				this.label = value.toString();
			} 
			else
			{
				this.label ="";
			}
			this._dataObject = value;	
		}
		public function get dataObject():Object
		{
			return this._dataObject;
		}
	}
}