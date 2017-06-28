package com.makolab.fractus.model
{
	import flash.events.EventDispatcher;
	
	public class EventManager extends EventDispatcher
	{
			
		static private var instance:EventManager = new EventManager();
		
		public function EventManager()
		{
		}

		public static function getInstance():EventManager
		{
			return instance;
		}
	}
}