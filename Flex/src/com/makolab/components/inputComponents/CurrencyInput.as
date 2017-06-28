package com.makolab.components.inputComponents
{
	import com.makolab.components.util.CurrencyManager;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import mx.controls.TextInput;
	import mx.events.FlexEvent;

	
	public class CurrencyInput extends TextInput
	{
		[Bindable]
		public function set value(val:Number):void
		{
			_value = val;
			text = CurrencyManager.formatCurrency(_value);		
		}
		public function get value():Number
		{
			var val:Number = CurrencyManager.parseCurrency(text);
			if (isNaN(val)) return Number(data);//_value;
			else return val;
		}

		/*
		public override function set listData(value:BaseListData):void
		{
			super.listData = value;
			_value = CurrencyManager.parseCurrency(value.label);
			text = CurrencyManager.formatCurrency(_value);
		}
		*/
		
		private var _value:Number;
		
		public function CurrencyInput()
		{
			super();
			//addEventListener(Event.CHANGE, changeHandler, false, EventPriority.DEFAULT_HANDLER + 10);
			addEventListener(FlexEvent.DATA_CHANGE, handleDataChange);
			addEventListener(FocusEvent.FOCUS_IN, focusChange);
			setStyle("textAlign", "right");
		}
		
		private function handleDataChange(event:FlexEvent):void
		{
			text = CurrencyManager.formatCurrency(CurrencyManager.parseCurrency(text));			
		}
		
		private function focusChange(event:FocusEvent): void
		{
			selectionBeginIndex = 0;
			selectionEndIndex = text.length;
		}
		
		private function changeHandler(event:Event):void
		{
			/*
			var val:Number = parseCurrency(text);
			if (isNaN(val))
			{
				text = formatCurrency(_value);
				selectionBeginIndex = 0;
				selectionEndIndex = text.length;
			}
			else
			{
				value = val;
			}
			*/
		}
		

	}
}