package com.makolab.components.inputComponents
{
	import flash.events.Event;
	
	import mx.controls.CheckBox;
	
	public class CheckBoxListItemRenderer extends CheckBox
	{
		public function CheckBoxListItemRenderer()
		{
			this.addEventListener(Event.CHANGE,changeEventHandler);
			if (visibilityFunction != null) this.isVisible = visibilityFunction(data);
		}
		
		public var dataField:String;
		public var visibilityFunction:Function;
		private var isVisible:Boolean = true;
		
		private function changeEventHandler(event:Event):void
		{
			if (data && dataField && data is XML)
			{
				if (selected) data[dataField] = "true";
				else
				{
					if (data[dataField].length() > 0) delete data[dataField];
				}
			}
		}
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value && isVisible;
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			if (visibilityFunction != null) 
				this.isVisible = visibilityFunction(value);
			if (value && dataField)
			{
				if (value.hasOwnProperty(dataField) && Boolean(value[dataField]))
					selected = true;
				else
					selected = false;
				//if (value is XML && Tools.parseBoolean(value[dataField])
			}
		}

	}
}