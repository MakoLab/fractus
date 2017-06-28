package com.makolab.components.util
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.core.Application;
	
	public class IdleTimer
	{
		public function IdleTimer()
		{
			Application.application.stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseHandler);
			Application.application.stage.addEventListener(MouseEvent.MOUSE_DOWN,mouseHandler);
			Application.application.stage.addEventListener(KeyboardEvent.KEY_DOWN,keyboardHandler);
		}
		
		[Bindable]
		public var idleTime:int = 0;
		
		private function mouseHandler(event:MouseEvent):void
		{
			idleTime = 0;
		}
		
		private function keyboardHandler(event:KeyboardEvent):void
		{
			idleTime = 0;
		}

	}
}