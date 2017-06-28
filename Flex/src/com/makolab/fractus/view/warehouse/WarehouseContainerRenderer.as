package com.makolab.fractus.view.warehouse
{
	import com.makolab.components.inputComponents.DataObjectManager;
	import com.makolab.fractus.model.ModelLocator;
	
	import mx.controls.Label;

	public class WarehouseContainerRenderer extends Label
	{
		public function WarehouseContainerRenderer()
		{
			super();
		}
	
		private var _data:Object;
		
		public override function set data(value:Object):void
		{
			super.data = value;
			var val:Object = DataObjectManager.getDataObject(data, listData);
			
			if(val && (val is XML || val is XMLList))
				val = val.*;
			
			if(val)
			{
				var map:XML = ModelLocator.getInstance().configManager.getXML("warehouse.warehouseMap");
				
				this.text = map..slot.(@id == String(val)).@label;
			}	
			else this.text = "";		
		}
	}
}