package com.makolab.components.layoutComponents
{
	import flash.events.Event;

	public class FormEvent extends Event
	{
		public static const SUBMIT:String = "submit";
		public var fieldValues:Object;
		public var buttonName:String;
		
		public function FormEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public static function createSubmitEvent(fieldValues:Object, buttonName:String):FormEvent
		{
			var e:FormEvent = new FormEvent(SUBMIT);
			e.fieldValues = fieldValues;
			e.buttonName = buttonName;
			return e;
		}
		
	}
}