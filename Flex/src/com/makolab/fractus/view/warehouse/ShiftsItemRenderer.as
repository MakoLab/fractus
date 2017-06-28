package com.makolab.fractus.view.warehouse
{
	import com.makolab.components.util.CurrencyManager;
	
	import mx.controls.Label;

	public class ShiftsItemRenderer extends Label
	{
		public function ShiftsItemRenderer()
		{
			super();
		}
		
		private function setText():void
		{
			if(!data)return;
			var array:Array = [];
			if(data.shifts){
				for(var i:int=0;i<data.shifts.length;i++){
					if(Number(String(data.shifts[i].quantity).replace(",",".")) > 0)array.push((data.shifts[i].containerLabel != "" ? data.shifts[i].containerLabel : "* ") + "(" + CurrencyManager.formatCurrency(Number(String(data.shifts[i].quantity).replace(",",".")),"?",null,-4) + ")");
				}
			}
			this.text = array.join(",");
			this.enabled = true;
			if(!data.itemId){
				this.text = "Wybierz towar";
				this.enabled = false;
			}
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			setText();
		}
	}
}