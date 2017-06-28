package com.makolab.events
{
	import flash.events.Event;
	
	public class AllEvent extends Event {
		
		public static const KEY_PRESSED:String = 'keyPressed';
		public static const FUNCTION_CALL:String = 'functionCall';
		
		private var _body:*;
		private var _bubbles:Boolean;
		
		public function AllEvent(type:String, body:* = null, bubbles:Boolean = true) {
			super(type,bubbles);
			_body = body;
			_bubbles = bubbles;
		}
		
		public function get body():* {
			return _body;
		}
		
		override public function get bubbles():Boolean {
			return _bubbles;
		}
		
		public override function clone():Event {
			return new AllEvent(type, body, bubbles);
		}
	}
}