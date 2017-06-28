package com.makolab.components.inputComponents
{
	import mx.controls.ComboBox;
	import mx.collections.XMLListCollection;
	import flash.events.Event;
	import mx.events.FlexEvent;
	import flash.events.KeyboardEvent;
	import mx.core.ClassFactory;
	import mx.controls.List;
	import mx.controls.listClasses.ListItemRenderer;

	public class SearchComboBox extends ComboBox
	{
		private var _list:XMLListCollection;
		private var filterArray:Array = [];
		
		public function SearchComboBox():void	
		{
			super();
			editable = true;
			addEventListener(Event.CHANGE, handleChange);
			setStyle("openDuration", 0);
			itemRenderer = new ClassFactory(SearchComboBoxItemRenderer);
			(itemRenderer as ClassFactory).properties = { filterArray : filterArray };
		}
				
		public function set list(value:XMLListCollection):void
		{
			_list = value;
			_list.filterFunction = filterFunction;
			dataProvider = _list;
		}
		public function get list():XMLListCollection
		{
			return _list;
		}
		
		private function filterFunction(item:Object):Boolean
		{
			if (!item) return false;
			var txt:String = item.toString();
			if (!txt || !filterArray) return true;
			for each (var i:RegExp in filterArray) if (!txt.toUpperCase().match(i)) return false;
			return true;
		}
		
		private function handleChange(event:Event):void
		{
			if (_list) {
				filterArray.length = 0;
				if (text) {
					var words:Array = text.split(/\s+/g);
					for each (var i:String in words) filterArray.push(new RegExp(i.toUpperCase(), "i"));
				}
				_list.refresh();
			}
			else filterArray.length = 0;
			open();
		}
		
	}
}