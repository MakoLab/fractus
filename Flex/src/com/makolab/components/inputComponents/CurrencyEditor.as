package com.makolab.components.inputComponents
{
	import com.makolab.components.util.CurrencyManager;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import mx.controls.TextInput;
	
	[Event(name="update",type="flash.events.Event")]
	
	public class CurrencyEditor extends TextInput
	{
		private var _dataObject:Number;
		
		private var _forceValidValue:Boolean = false;
	
		public var precision:int = -6;
		public var maxValue:Number = 1000000000000;
		public var minValue:Number = NaN;
		public var nanVal:String = '?';
		public var nanValues:Array = [];
		
		private function updateText():void
		{
			text = CurrencyManager.formatCurrency(_dataObject, this.nanVal, null, precision);
		}
		
		/**
		 * Lets you pass a value to the editor.
		 * @see #data
		 */
		
		public function set forceValidValue(value:Boolean):void
		{
			_forceValidValue = value;
			if(value)restrict = "0-9,. ";
			else restrict = "";
		}
		public function get forceValidValue():Boolean
		{
			return _forceValidValue;
		}
		
		public function set dataObject(value:Object):void
		{
			_dataObject = parseFloat(String(value));
			updateText();
		}
		/**
		 * @private
		 */
		public function get dataObject():Object
		{
			updateDO();
			return _dataObject;
		}
		/**
		 * Lets you pass a value to the editor.
		 * @see #dataObject
		 */
		public override function set data(value:Object):void
		{
			super.data = value;
			dataObject = DataObjectManager.getDataObject(data, listData);
		}
		/**
		 * Constructor.
		 */
		public function CurrencyEditor()
		{
			super();
			setStyle("textAlign", "right");
			if(_forceValidValue)restrict = "0-9,. ";
		}
		
		override protected function focusInHandler(event:FocusEvent):void
		{
			super.focusInHandler(event);
			if (isNaN(_dataObject)) text = '';
		}
		
		override protected function focusOutHandler(event:FocusEvent):void
		{
			super.focusOutHandler(event);
			updateDO();
			updateText();
		}
		
		private function updateDO():void
		{
			var val:Number = CurrencyManager.parseCurrency(text, Math.abs(precision));
			if (isNaN(val) && forceValidValue) _dataObject = 0;
			for (var i:int = 0; i < nanValues.length; i++)
				if (text == nanValues[i] && forceValidValue) _dataObject = NaN;
			if (!isNaN(val)) _dataObject = val;
			if (!isNaN(maxValue) && _dataObject > maxValue) _dataObject = maxValue;
			if (!isNaN(minValue) && _dataObject < minValue) _dataObject = minValue;
			dispatchEvent(new Event("update"));
		}
	}
}