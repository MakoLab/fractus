package com.makolab.components.catalogue
{
	import com.makolab.components.inputComponents.DataObjectManager;
	import com.makolab.components.inputComponents.SearchComboBoxItemRenderer;
	import com.makolab.fractus.commands.SearchCommand;
	import com.makolab.fractus.model.LanguageManager;
	
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
	

	public class CatalogueSearchEditor extends TextInput
	{
		public var _dataProvider:XMLListCollection;
		
		public var autoCache:Boolean = true;
		
		protected var realTimeFilter:RealTimeFilter;
		
		protected var list:List;
		
		public var setFunction:Function;
		
		public var searchCommandType:String;
		
		public var searchParams:XML =
			<searchParams>
				<query/>
				<columns>
					<column field="name" sortOrder="1" sortType="ASC"/>
					<column field="code" sortOrder="2"/>
					<column field="version" sortOrder="3"/>
				</columns>
			</searchParams>;
			
		public var labelField:String = "@name";
		
		
		public function CatalogueSearchEditor()
		{
			addEventListener(Event.CHANGE, changeHandler);
			realTimeFilter = new RealTimeFilter();
		}
		
		public var dataObject:Object;
		private var _data:Object;
		
		public function set filterFields(value:Array):void
		{
			realTimeFilter.filterFields = value;
		}
		public function get filterFields():Array
		{
			return realTimeFilter.filterFields;
		}
		
		[Bindable]
		public override function set data(value:Object):void
		{
			_data = value;
			
			dataObject = DataObjectManager.getDataObject(data, listData);
			if (dataObject) {
				text = dataObject.toString();
			}
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
				if (list && list.selectedItem)
				{
					selectItem(list.selectedItem);
				}
				else if (text)
				{
					searchItem(text);
					text = "";
					event.stopImmediatePropagation();
				}
			}
			else super.keyDownHandler(event);
		}
		
		public function outerSearchRequest():void {
			this.focusManager.setFocus(this);
			showPopup();
			searchItem(previousTextTemp);
			previousTextTemp = '';
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
			var xmlTemp:XMLList = XML(event.result).*;
			if(xmlTemp.length() == 0) {
				dataProvider = XML('<contractor id="0" ordinalNumber="0" shortName="' + LanguageManager.getInstance().labels.error.noSearchResult + '" fullName=""/>');
				list.selectable = false;
			} else {
				dataProvider = xmlTemp;
				list.selectable = true;
			}
			
			list.rowCount = (dataProvider.length <= 1) ? dataProvider.length : 7;
		}
		
		override protected function focusOutHandler(event:FocusEvent):void
		{
			super.focusOutHandler(event);
			this.previousTextTemp = this.text;
			if(!this.wasSelected)
				this.text = this.previousText;
			
			hidePopup();
		}
		
		private var previousText:String;
		private var previousTextTemp:String;
		private var wasSelected:Boolean;
		
		override protected function focusInHandler(event:FocusEvent):void
		{
			super.focusInHandler(event);
			this.wasSelected = false;
			this.previousText = this.text;
			setSelection(text.length,text.length);
		}
		
		public function selectItem(item:Object):void
		{
			if(list.selectable) {
				this.wasSelected = true;
				text = list.selectedItem[labelField].toString();
				hidePopup();
				selectionBeginIndex = selectionEndIndex = text.length;
				dataObject = text;
				if (setFunction != null) {
					setFunction(list.selectedItem, data);
				}
			}
		}
		
		protected function showPopup():void
		{
			if (!list)
			{
				list = new List();
				list.dataProvider = dataProvider;
				list.itemRenderer = new ClassFactory(SearchComboBoxItemRenderer);
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
			if(dataProvider) {
				list.rowCount = (dataProvider.length <= 1) ? dataProvider.length : 7;
				if(dataProvider.length == 0 || !list.selectable) {
					dataProvider = XML('<contractor id="0" ordinalNumber="0" shortName="' + LanguageManager.getInstance().labels.error.pressEnter + '" fullName=""/>');
					list.selectable = false;
					list.rowCount = 1;
				}
			} else {
				dataProvider = XML('<contractor id="0" ordinalNumber="0" shortName="' + LanguageManager.getInstance().labels.error.pressEnter + '" fullName=""/>');
				list.selectable = false;
				list.rowCount = 1;
			}
			
			list.visible = true;
		}
		
		protected function hidePopup():void
		{
			if (list) list.visible = false;
		}
		
		public function set dataProvider(value:Object):void
		{
			_dataProvider = new XMLListCollection(XMLList(value));
			realTimeFilter.collection = _dataProvider;
			realTimeFilter.setFilterText(null);
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
		
		private function changeHandler(event:Event):void
		{
			realTimeFilter.setFilterText(this.text);
			if (list) list.selectedItem = null;
			showPopup();
		}
	}
}