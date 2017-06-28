package com.makolab.fractus.view.warehouse
{
	import com.makolab.components.util.CurrencyManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.CommercialDocumentLine;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.model.document.ShiftObject;
	import com.makolab.fractus.model.document.WarehouseDocumentLine;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Label;

	public class SlotRenderer extends Label
	{
		public function SlotRenderer()
		{
			super();
			ModelLocator.getInstance().configManager.requestList(["warehouse.warehouseMap"],setText);
		}
		
		private function setText():void
		{
			if(!data)return;
			var structure:XML = XML(ModelLocator.getInstance().configManager.getValue("warehouse.warehouseMap"));
			var symbol:String = "";
			var slots:XMLList;
			var array:Array = [];
			if((data is WarehouseDocumentLine || data is CommercialDocumentLine) && (data.documentObject as DocumentObject).typeDescriptor.isCommercialDocument && ModelLocator.getInstance().dictionaryManager.dictionaries.allWarehouses.(id.toString() ==  data.warehouseId).valuationMethod.toString() == "0"){
				this.text = "Magazyn bez wyboru dostaw";
				data.shifts = [];
			}else if(data is Array || data is ArrayCollection){
				for (var i:int = 0; i < data.length; i++){
					slots = structure..slot.(@id == data[i].containerId);
					if(slots.length() > 0){
						symbol = slots[0].@label;
						array.push(symbol + "(" + CurrencyManager.formatCurrency(Number(data.quantity)) + ")");
					}else{
						array.push("brak gniazda");
					}
				}
				this.text = array.join(" ");
			}else if(data is ShiftObject){
				slots = structure..slot.(@id == data.containerId);
				if(slots.length() > 0)this.text = slots[0].@label;
				else this.text = "";
			}
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			setText();
		}
	}
}