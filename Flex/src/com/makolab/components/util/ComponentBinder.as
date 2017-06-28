package com.makolab.components.util
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public class ComponentBinder
	{
		private var components:Array;
		private var _dataProvider:Object;
		
		public function ComponentBinder(dataProvider:Object = null)
		{
			reset();
			this.dataProvider = dataProvider;
		}
		
		public function reset():void
		{
			if (components) for each (var o:Object in components)
			{
				IEventDispatcher(o.component).removeEventListener(o.eventName, handleEvent);
			}
			components = [];
		}
		
		public function set dataProvider(value:Object):void
		{
			_dataProvider = value;
			if (_dataProvider) initializeComponentValues();
		}
		public function get dataProvider():Object
		{
			return _dataProvider;
		}
		
		private function initializeComponentValues():void
		{
			for each (var o:Object in components) if (!o.target is Function) setComponentValue(o.component, o.dataField, o.target);
		}
		
		public function addComponent(component:IEventDispatcher, dataField:String = 'text', eventName:String = 'change', target:Object = null):void
		{
			if (target == null) target = component['id'];
			component.addEventListener(eventName, handleEvent, false, 0, true);
			components.push({component : component, eventName : eventName, dataField : dataField, target : target});
			if (!(target is Function) && _dataProvider) setComponentValue(component, dataField, String(target));
		}
		
		private function setComponentValue(component:Object, dataField:String, target:String):void
		{
			var value:Object = _dataProvider[target];
			if (component[dataField] is Boolean) component[dataField] = (parseInt(String(value)) > 0);
			else component[dataField] = value;
		}
		
		private function handleEvent(event:Event):void
		{
			for each (var o:Object in components) if (o.component == event.currentTarget)
			{
				if (o.target is Function) o.target(o.component[o.dataField]);
				else if (o.component[o.dataField] is Boolean) dataProvider[String(o.target)] = (o.component[o.dataField] ? 1 : 0);
				else dataProvider[String(o.target)] = o.component[o.dataField];
				break;
			}
		}

	}
}