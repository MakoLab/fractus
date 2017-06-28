package com.makolab.events
{
	import com.makolab.fractus.model.KeyboardShortcut;
	
	import flash.events.Event;

	public class KeyboardShortcutEvent extends Event
	{
		public static const INVOKE:String = "invoke"
		
		public function KeyboardShortcutEvent(type:String, shortcut:KeyboardShortcut, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.shortcut = shortcut;
			super(type, bubbles, cancelable);
		}
		
		public var shortcut:KeyboardShortcut;
		
	}
}