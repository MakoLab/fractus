package com.makolab.components.catalogue
{
	import flash.events.Event;
	
	public class GroupTreeEditorEvent extends Event
	{
		public var groups:Object;
				
		public function GroupTreeEditorEvent(type:String,groups:Object)
		{
			super(type);
			this.groups = groups;
		}
	}
}