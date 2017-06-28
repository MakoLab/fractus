package com.makolab.fractus.view.warehouse
{
	import com.makolab.components.util.CurrencyManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.CommercialDocumentLine;
	import com.makolab.fractus.model.document.WarehouseDocumentLine;
	
	import mx.controls.Label;
	import mx.controls.listClasses.BaseListData;

	public class SlotItemRenderer extends Label
	{
		public function SlotItemRenderer()
		{
			super();
		}
		
		private function setText():void
		{
			if(data && (data is WarehouseDocumentLine || data is CommercialDocumentLine) && data.shifts){
					var structure:XML = XML(ModelLocator.getInstance().configManager.getValue("warehouse.warehouseMap"));
					var symbol:String = "";
					var slots:XMLList;
					var array:Array = [];
					for(var i:int = 0; i < data.shifts.length; i++){
						slots = structure..slot.(@id == data.shifts[i].containerId);
						if(slots.length() > 0){
							symbol = slots[0].@label;
							array.push(symbol + "(" + CurrencyManager.formatCurrency(Number(data.shifts[i].quantity)) + ")");
						}/* else{
							array.push("brak gniazda");
						} */
					}
					this.text = array.join(" ");
			}else{
				this.text = "";
			}
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			setText();
		}
	}
}