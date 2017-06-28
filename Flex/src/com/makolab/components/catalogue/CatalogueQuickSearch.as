package com.makolab.components.catalogue
{
	import com.makolab.components.inputComponents.DataObjectManager;
	import com.makolab.components.inputComponents.SearchComboBoxItemRenderer;
	import com.makolab.fractus.commands.SearchCommand;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import mx.collections.XMLListCollection;
	import mx.controls.List;
	import mx.controls.TextInput;
	import mx.core.ClassFactory;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.events.ResultEvent;

	[Event(name="itemSelect", type="com.makolab.components.catalogue.CatalogueEvent")]
	public class CatalogueQuickSearch extends TextInput
	{
		public var _dataProvider:XMLListCollection;
		
		public var autoCache:Boolean = true;
		
		protected var filterArray:Array = [];
		protected var list:List;
		
		public var setFunction:Function;
		
		public var searchCommandType:String;
		
		public var searchParams:XML =
			<searchParams>
				<query/>
				<columns>
					<column field="name" sortOrder="1" sortType="ASC"/>
					<column field="code" sortOrder="2" sortType="ASC"/>
					<column field="version" sortOrder="3" sortType="ASC"/>
				</columns>
			</searchParams>;
			
		public var labelField:String = "@name";
		
		
		public function CatalogueQuickSearch()
		{
			addEventListener(Event.CHANGE, changeHandler);
		}
		
		public var dataObject:Object;
		private var _data:Object;
		
		public override function set data(value:Object):void
		{
			_data = value;
			dataObject = DataObjectManager.getDataObject(data, listData);
			if (dataObject) text = dataObject.toString();
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
				else if (text)
				{
					searchItem(text);
					filterArray.length = 0;
					text = "";
					event.stopImmediatePropagation();
				}
				else event.stopImmediatePropagation();
			}
			else super.keyDownHandler(event);
		}
		
		public function searchItem(query:String):void
		{
			var cmd:SearchCommand = new SearchCommand(searchCommandType);
			cmd.searchParams = searchParams;
			cmd.addEventListener(ResultEvent.RESULT, searchResult);
			cmd.execute( { query : query } );
		}
		
		protected function searchResult(event:ResultEvent):void
		{
			dataProvider = XML(event.result).*;
		}
		
		override protected function focusOutHandler(event:FocusEvent):void
		{
			super.focusOutHandler(event);
			hidePopup();
		}
		
		public function selectItem(item:Object):void
		{
			text = list.selectedItem[labelField].toString();
			hidePopup();
			selectionBeginIndex = selectionEndIndex = text.length;
			dataObject = text;
			if (setFunction != null) setFunction(list.selectedItem, data);
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
				list.labelField = labelField;
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
			var txt:String = item[labelField].toString();
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