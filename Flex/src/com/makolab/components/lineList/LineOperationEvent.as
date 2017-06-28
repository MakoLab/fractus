package com.makolab.components.lineList
{
	import flash.events.Event;

	public class LineOperationEvent extends Event
	{
		public static const OPERATION_INVOKE:String = "operationInvoke";
		
		public function LineOperationEvent(type:String, bubbles:Boolean = false, cancellable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}