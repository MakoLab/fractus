package com.makolab.components.inputComponents
{
	import mx.controls.TextInput;
	import flash.events.Event;
	import mx.events.FlexEvent;
	import flash.events.FocusEvent;
	import mx.controls.List;
	import mx.collections.XMLListCollection;
	import mx.managers.PopUpManager;
	import flash.geom.Rectangle;
	import mx.core.ClassFactory;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import mx.events.ListEvent;

	public class SuggestionEditor extends TextInput
	{
		public var _dataProvider:XMLListCollection;
		public var nameNode:String = "name";
		public var autoCache:Boolean = true;
		
		protected var filterArray:Array = [];
		protected var list:List;
		
		public function SuggestionEditor()
		{
			addEventListener(Event.CHANGE, changeHandler);
		}
		
		public var dataObject:Object;
		private var _data:Object;
		
		public override function set data(value:Object):void
		{
			_data = value;
			dataObject = DataObjectManager.getDataObject(data, listData);
			text = dataObject.toString();
		}
		public override function get data():Object
		{
			return _data;
		}
		
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.UP || event.keyCode == Keyboard.DOWN)
			{
				if (list) list.dispatchEvent(event);
				else showPopup();
				event.stopImmediatePropagation();
			}
			else if (event.keyCode == Keyboard.ENTER)
			{
				if (list.selectedItem)
				{
					selectItem(list.selectedItem);
				}
			}
			else super.keyDownHandler(event);
		}
		
		override protected function focusOutHandler(event:FocusEvent):void
		{
			super.focusOutHandler(event);
			hidePopup();
		}
		
		public function selectItem(item:Object):void
		{
			text = list.selectedItem.toString();
			hidePopup();
			selectionBeginIndex = selectionEndIndex = text.length;
			dataObject = text;
		}
		
		protected function showPopup():void
		{
			if (!list)
			{
				list = new List();
				list.dataProvider = dataProvider;
				list.itemRenderer = new ClassFactory(SearchComboBoxItemRenderer);
				(list.itemRenderer as ClassFactory).properties  = { filterArray : this.filterArray };
				list.owner = this;
				list.focusEnabled = false;
				list.addEventListener(ListEvent.ITEM_CLICK, itemClickHandler);
				PopUpManager.addPopUp(list, this);
			}
			var bounds:Rectangle = getBounds(list.parent);
			list.x = bounds.left;
			list.y = bounds.top + bounds.height;
			list.width = bounds.width;
			list.visible = true;
		}
		
		protected function hidePopup():void
		{
			if (list) list.visible = false;
		}
		
		public function set dataProvider(value:Object):void
		{
			_dataProvider = new XMLListCollection(XMLList(value));
			_dataProvider.filterFunction = filterFunction;
			if (list) list.dataProvider = _dataProvider;
		}
		public function get dataProvider():Object
		{
			return _dataProvider;
		}
		
		protected function itemClickHandler(event:ListEvent):void
		{
			if (event.currentTarget) selectItem(event.currentTarget);
		}
		
		private function filterFunction(item:Object):Boolean
		{
			if (!item) return false;
			var txt:String = item.toString();
			if (!txt || !filterArray) return true;
			for each (var i:RegExp in filterArray) if (!txt.toUpperCase().match(i)) return false;
			return true;
		}
		
		private function changeHandler(event:Event):void
		{
			if (_dataProvider) {
				filterArray.length = 0;
				if (text) {
					var words:Array = text.split(/\s+/g);
					for each (var i:String in words) filterArray.push(new RegExp(i.toUpperCase(), "i"));
				}
				_dataProvider.refresh();
			}
			else filterArray.length = 0;
			showPopup();
		}
	}
}