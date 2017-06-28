package com.makolab.fractus.model
{
	import com.makolab.events.KeyboardShortcutEvent;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	public class KeyboardManager implements IEventDispatcher
	{
		public function KeyboardManager(stage:Stage = null)
		{
			dispatcher = new EventDispatcher(this);
			if (stage) this.stage = stage;
		}
		
		private var dispatcher:EventDispatcher
		
		private var _stage:Stage;
		public function set stage(value:Stage):void
		{
			_stage = value;
			if (_stage) _stage.addEventListener(KeyboardEvent.KEY_DOWN,handleKeyDown);
			if (_stage) _stage.addEventListener(KeyboardEvent.KEY_UP,handleKeyUp);
		}
		public function get stage():Stage
		{
			return _stage;
		}
		
		public function isLastKey(code:int):Boolean
		{
			var result:Boolean = false;
			var i:int;
			// 13
				if (code == Keyboard.ENTER) result = true;
			// navigation keys: 33-40
				for (i = 33; i <= 40; i++) if (code == i) result = true;
			// 45	
				if (code == Keyboard.INSERT) result = true;
			// 46
				if (code == Keyboard.DELETE) result = true;
			// 0-9: 48-57
				for (i = 48; i <= 57; i++) if (code == i) result = true;
			// a-z: 65-90
				for (i = 65; i <= 90; i++) if (code == i) result = true;
			// numpad: 96-111
				for (i = 96; i <= 111; i++) if (code == i) result = true;
			// function keys (F1 - F12): 112-123
				for (i = 112; i <= 123; i++) if (code == i) result = true;
			// ;=,-./`
				for (i = 186; i <= 192; i++) if (code == i) result = true;
			// [/]'
				for (i = 219; i <= 222; i++) if (code == i) result = true;
			
			return result;
		}
		
		private var shortcut:KeyboardShortcut = new KeyboardShortcut();
		
		protected function handleKeyDown(event:KeyboardEvent):void
		{
			var keyCode:String = "key" + event.keyCode;
			//trace("Down "+event.keyCode);
			shortcut.addKey(event.keyCode);
			
			//if (isLastKey(event.keyCode))
			//{
				dispatchEvent(new KeyboardShortcutEvent(KeyboardShortcutEvent.INVOKE,shortcut));
			//}
		}
		
		protected function handleKeyUp(event:KeyboardEvent):void
		{
			shortcut.removeKey(event.keyCode);
			//trace("Up "+event.keyCode);
			// zabezpieczenie przed prawym ALTem. 
			// Wcisniecie prawego ALT powoduje wygenerowanie eventa dla keyCode = 18(alt) ORAZ keyCode = 17(ctrl),
			// ale zwolnienie klawisza dispatchuje tylko KeyUp dla keyCode = 18, więc tak jakby ctrl byl nadal wcisiniety.
			if (event.keyCode == 18 && !event.ctrlKey) shortcut.removeKey(Keyboard.CONTROL);
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			dispatcher.addEventListener(type,listener,useCapture,priority,useWeakReference);
		}
		
		public function dispatchEvent(evt:Event):Boolean{
			return dispatcher.dispatchEvent(evt);
		}
    
		public function hasEventListener(type:String):Boolean{
		    return dispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
		    dispatcher.removeEventListener(type, listener, useCapture);
		}
		               
		public function willTrigger(type:String):Boolean {
		    return dispatcher.willTrigger(type);
		}

	}
}