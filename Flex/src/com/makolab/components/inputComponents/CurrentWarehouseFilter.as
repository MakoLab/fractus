package com.makolab.components.inputComponents
{
	import com.makolab.components.catalogue.ICatalogueFilter;
	import com.makolab.fractus.model.ModelLocator;

	public class CurrentWarehouseFilter implements ICatalogueFilter
	{
		public function setParameters(parameters:Object):void
		{
			parameters.currentWarehouse = ModelLocator.getInstance().currentWarehouseId;
		}
		
		public function set config(value:XML):void
		{
		}
		
		public function get config():XML
		{
			return null;
		}
		
		public function set template(valueList:XMLList):void{
				for each (var value:XML in valueList){
				//todo: jesli filtr ma rozpoznawac, ktory elem. z listy jest dla niego, trzeba to tu dodać
				
				// todo
				}
		}
		
		public function clear():void{
			// todo
		}
		
		public function restore():void{
				//todo
				//trzeba dopisac cialo funkcji, jesli inny filtr ma miec mozliwosc przywracania stanu tego filtra sprzed wyczyszczenia go
				//filtry mogą mieć wpływ na inne filtry poprzez wypelnienie w konfiguracji parametru 'disableFilterType', przyklad w DocNumberFilter
		}
		
	}
}