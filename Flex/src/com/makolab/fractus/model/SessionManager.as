package com.makolab.fractus.model
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.Application;
	
	[Event(name="timeoutReached", type="flash.events.Event")]
	
	[Bindable]
	public class SessionManager extends EventDispatcher
	{
		public static const NOT_LOGGED_IN:int = 0;
		public static const LOGGING_IN:int = 1;
		public static const LOGGED_IN:int = 2;
		public static const SESSION_RESTORE:int = 3;
		
		public var currentState:int = NOT_LOGGED_IN;
		public var sessionId:String;
		public var userId:String;
		public var login:String;
		public var logOutFunction:Function;
		
		private var _timeout:int = 0;
		private var timer:Timer = new Timer(1000);
		
		public function set timeout(value:int):void
		{
			_timeout = value;
			timer.repeatCount = value;
			timer.reset();
			timer.start();
		}
		public function get timeout():int
		{
			return _timeout;
		}
		
		private var _stage:Stage;
		public function set stage(value:Stage):void
		{
			_stage = value;
			_stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseHandler);
			_stage.addEventListener(MouseEvent.MOUSE_DOWN,mouseHandler);
			_stage.addEventListener(KeyboardEvent.KEY_DOWN,keyboardHandler);
		}
		public function get stage():Stage
		{
			return _stage;
		}
		
		public function SessionManager(timeout:int = 1)
		{
			this.timeout = timeout;
			timer.addEventListener(TimerEvent.TIMER_COMPLETE,timerCompleteHandler);
		}
		
		private function timerCompleteHandler(event:TimerEvent):void
		{
			if (logOutFunction != null) logOutFunction("Wylogowano automatycznie. Upłynął maksymalny czas bezczynności.");
			currentState = NOT_LOGGED_IN;
			timer.stop();
			dispatchEvent(new Event("timeoutReached"));
		}
		
		private function mouseHandler(event:MouseEvent):void
		{
			if (currentState != NOT_LOGGED_IN)
			{
				timer.reset();
				timer.start();
			}
		}
		
		private function keyboardHandler(event:KeyboardEvent):void
		{
			if (currentState != NOT_LOGGED_IN)
			{
				timer.reset();
				timer.start();
			}
		}
		
		/**
		 * Returns true if a user authorised to view diagnostic options is logged in.
		 */
		public function showDiagnostics():Boolean
		{
			return login == 'makoadmin' || login == 'xxx';
		}

	}
}