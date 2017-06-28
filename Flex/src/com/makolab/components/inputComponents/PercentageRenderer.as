package com.makolab.components.inputComponents
{
	import com.makolab.components.util.CurrencyManager;
	import com.makolab.fractus.model.DictionaryManager;
	
	import mx.controls.Label;

	public class PercentageRenderer extends Label
	{
		public var columnIdent:String;
		/**
		 * Constructor
		 */
		public function PercentageRenderer()
		{
			setStyle("textAlign", "right");
		}
		
		public var zeroText:String = null;
		public var nanText:String = '-';
		
		public var precision:int = 2;
		
		private var _value:Number;
		public function set value(value:Number):void
		{
			this._value = value;
			updateText();
		}
		public function get value():Number
		{
			return _value;
		}
		
		/**
		 * Lets you pass a value to the control.
		 */
		public override function set data(value:Object):void
		{
			super.data = value;
			var val:Object = DataObjectManager.getDataObject(data, listData);
			this.value = (val is Number) ? Number(val) : parseFloat(String(val));
		}
		
		protected function updateText():void
		{
			if (isNaN(value)) text = nanText;
			else
			{
				text = CurrencyManager.formatCurrency(value, nanText, zeroText, precision) + " %";
			}
		}
	}
}