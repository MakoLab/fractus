package com.makolab.components.inputComponents
{
	import mx.controls.Label;

	public class FloatRenderer extends Label
	{
		/**
		 * Constructor
		 */
		public function FloatRenderer()
		{
			setStyle("textAlign", "right");
		}
		
		public var zeroText:String = "0";
		public var nanText:String = "-";
		
		/**
		 * Lets you pass a value to the control.
		 */
		public override function set data(value:Object):void
		{
			super.data = value;
			var dataObject:Object = DataObjectManager.getDataObject(value, listData);
			if (dataObject == null) text = nanText;
			var num:Number = parseFloat(String(dataObject));
			if (isNaN(num)) text = nanText;
			else if (num == 0) text = zeroText;
			else text = String(num).replace(/\./, ',');
		}
	}
}