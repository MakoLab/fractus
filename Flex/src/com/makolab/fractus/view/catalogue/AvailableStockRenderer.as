package com.makolab.fractus.view.catalogue
{
	import com.makolab.components.inputComponents.CurrencyRenderer;

	public class AvailableStockRenderer extends CurrencyRenderer
	{
		public function AvailableStockRenderer()
		{
			super();
			precision = -4;
			nanText = "-";
		}
		
		public override function set data(value:Object):void
		{
			super.data = value;
			var res:Number = parseFloat(value.@reservedQuantity);
			var diff:Number = parseFloat(value.@quantity) - (isNaN(res) ? 0 : res);
			this.value = diff < 0 ? 0 : diff;
		}
		
		public static function getTextValue(item:Object,dataField:String):String
		{
			var res:Number = parseFloat(item.@reservedQuantity);
			var diff:Number = parseFloat(item.@quantity) - (isNaN(res) ? 0 : res);
			return isNaN(diff) ? "" : (diff < 0 ? "0" : diff.toString());
		}
	}
}