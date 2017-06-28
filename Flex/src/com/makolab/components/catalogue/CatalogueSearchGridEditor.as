package com.makolab.components.catalogue
{
	import com.makolab.components.inputComponents.DataObjectManager;
	import com.makolab.components.list.CommonGrid;
	import com.makolab.fractus.commands.SearchCommand;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import mx.collections.XMLListCollection;
	import mx.containers.HBox;
	import mx.controls.ComboBox;
	import mx.controls.List;
	import mx.controls.TextInput;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.events.ResultEvent;

	public class CatalogueSearchGridEditor extends TextInput
	{
		public var _dataProvider:XMLListCollection;
		
		public var autoCache:Boolean = true;
		
		protected var realTimeFilter:RealTimeFilter;
		
		protected var list:List;
		protected var cg:CommonGrid;
		protected var cb:ComboBox;
		private var hb:HBox;
		
		public var setFunction:Function;
		public var setDataObject:Function;
		
		public var searchCommandType:String;
		[Bindable]
		public var searchField:String = "";
		[Bindable]
		public var supplierFilter:Boolean;
		[Bindable]
		public var receiverFilter:Boolean;
		
		// automatyczne wyszukiwanie po wejściu focusu
		public var autoSearch:Boolean = false;
		
		[Bindable]
		public var itemId:String;

		private var _config:XML;
		public function set config(value:XML):void
		{
			_config = value;
			if (_config) realTimeFilter.setFilterFields(_config.columns.column);
		}
		public function get config():XML
		{
			return _config;
		}
		
		public var labelField:String = "@name";
		
		public function CatalogueSearchGridEditor()
		{
			realTimeFilter = new RealTimeFilter();
			addEventListener(Event.CHANGE, changeHandler);
		}
		
		public var dataObject:Object;
		public var dataSelectedObject:Object;
		[Bindable]
		public var parentDataObject:Object;
		private var _data:Object;
		
		public override function set data(value:Object):void
		{
			_data = value;
			dataObject = DataObjectManager.getDataObject(_data, listData);
			if (dataObject && dataObject!=data) {
				text = String(dataObject);
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
				if (cg) {
					cg.dispatchEvent(event);
					event.stopImmediatePropagation();
				}
				//else showPopup();
				//
			}
			else if (event.keyCode == Keyboard.ENTER)
			{
				if (cg && cg.selectedItem && cg.visible)	// alternatywne rozwiazanie do nullowania cg.selectedItem && realTimeFilter.filterFunction(cg.selectedItem))
				{
					selectItem(cg.selectedItem);
				}
				else if (text)
				{
					searchItem(text);
					text = "";
					event.stopImmediatePropagation();
				}
				else if (text=="")
				{
					event.stopImmediatePropagation();
					if (setFunction != null) {
				setDataObject(null);
				if(cg)
				cg.selectedItem = null;
				setFunction(null,null);
				hidePopup();
			}
				}
			}
			else super.keyDownHandler(event);
		}
		
		public function searchItem(query:String):void
		{
			var searchParams:XML = config.searchParams[0].copy();
			if(searchField)	{
				var column:XML = new XML("<column/>");
				column.@field = searchField;
				column.appendChild(query);				
				searchParams.filters.appendChild(column);
				query = "";
			}
			if(supplierFilter)	{
				column = new XML("<column/>");
				column.@field = "isSupplier";
				column.appendChild("1");
				searchParams.filters.appendChild(column);
			}
			
			if(receiverFilter)	{
				column = new XML("<column/>");
				column.@field = "isReceiver";
				column.appendChild("1");
				searchParams.filters.appendChild(column);
			}
			var cmd:SearchCommand = new SearchCommand(searchCommandType);
			if(this.owner) {
				searchParams.appendChild('<callingTarget>'+(this.owner.name).split("_")[0]+'</callingTarget>')
			}
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
		
		override protected function focusInHandler(event:FocusEvent):void
		{
			super.focusInHandler(event);
			if (autoSearch)
			{
				showPopup();
				if (!dataProvider || dataProvider.length == 0) searchItem('');
			}
		}
		
		public function selectItem(item:Object):void
		{
			dataObject = cg.selectedItem[labelField].toString();
			dataSelectedObject = cg.selectedItem;
			text = String(dataObject);
			hidePopup();
			selectionBeginIndex = selectionEndIndex = text.length;
			if (item.@id.length() > 0) itemId = item.@id;
			if (setFunction != null) {
				setDataObject(dataObject);
				setFunction(cg.selectedItem, data);
			}
			cg.selectedItem = null;
		}
		
		protected function showPopup():void
		{
			if(!cg)	{
				cg = new CommonGrid();
				cg.config = config.columns;
				cg.labelField = labelField;
				cg.dataProvider = dataProvider;
				cg.addEventListener(ListEvent.ITEM_CLICK, itemClickHandler);
				cg.owner = this;
				cg.focusEnabled = false;
				PopUpManager.addPopUp(cg, this);
			}
			var bounds:Rectangle = getBounds(cg.parent);
			cg.x = bounds.left;
			cg.y = bounds.top + bounds.height;
			cg.width = 700;			
			cg.visible = true;
		}
		
		protected function hidePopup():void
		{
			if (cg) cg.visible = false;
		}
		
		public function set dataProvider(value:Object):void
		{
			_dataProvider = new XMLListCollection(XMLList(value));
			realTimeFilter.collection = _dataProvider;
			realTimeFilter.setFilterText(null);
			if (cg) {
				cg.data = _dataProvider;
			}
		}
		public function get dataProvider():Object
		{
			return _dataProvider;
		}
		
		protected function itemClickHandler(event:ListEvent):void
		{
			if (event.currentTarget) {
				selectItem(cg.selectedItem);		
			}	
		}
		
		private function changeHandler(event:Event):void
		{
			realTimeFilter.setFilterText(this.text);
			if (cg) cg.selectedItem = null;
			showPopup();
		}
	}
}