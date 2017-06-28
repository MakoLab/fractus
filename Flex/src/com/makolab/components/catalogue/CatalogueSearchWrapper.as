package com.makolab.components.catalogue
{
	import com.makolab.components.inputComponents.ComboButton;
	import com.makolab.components.inputComponents.DataObjectManager;
	import com.makolab.fractus.model.LanguageManager;
	
	import flash.events.MouseEvent;
	
	import mx.containers.HBox;
	import mx.controls.ComboBox;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.core.ScrollPolicy;
	import mx.events.ListEvent;
	
	public class CatalogueSearchWrapper extends HBox implements IDropInListItemRenderer
	{	
		private var _data:Object;
		private var _listData:BaseListData;
		[Bindable] public var dataObject:Object;
		private var cb:ComboBox;
		public var cs:CatalogueSearchGridEditor;
		private var _supplierFilter:Boolean;
		private var _receiverFilter:Boolean;
		
		[Bindable]
		public function set receiverFilter(value:Boolean):void
		{
			_receiverFilter = value;
			cs.receiverFilter = receiverFilter;
		}
		
		public function get receiverFilter():Boolean
		{
			return _receiverFilter;
		}
		
		[Bindable]
		public function set supplierFilter(value:Boolean):void
		{
			_supplierFilter = value;
			cs.supplierFilter = supplierFilter;
		}
		
		public function get supplierFilter():Boolean
		{
			return _supplierFilter;
		}
		
		public var labelField:String = "@name";	
		private var _comboData:XML;
		
		private var popUp:ComboButton;
		
		private var _itemOperations:Array;
		private var _generalOperatons:Array;
		
		private var _showItemOperations:Boolean = true;
		[Bindable] 
		public function set showItemOperations(value:Boolean):void
		{
			_showItemOperations = value;
			if(!value){
				if(this.contains(popUp))removeChild(popUp);
			}else{
				if(!this.contains(popUp))this.addChildAt(popUp,2);
			}
		}
		public function get showItemOperations():Boolean
		{
			return _showItemOperations;
		}
		
		private var _itemId:String;
		public function set itemId(value:String):void
		{
			_itemId = value;
			if (cs) cs.itemId = _itemId;
		}
		public function get itemId():String
		{
			return _itemId;
		}
		
		private var _menuItems:Object;
		public function set menuItems(value:Object):void
		{
			if(value == null) {
				_menuItems = new XML('<item name="item" global="1"> brak uprawnień </item>');
				if (popUp) popUp.list.selectable = false;
			} else {
				_menuItems = value;
				if (popUp) popUp.list.selectable = true;
			}
			if (popUp){
				popUp.dataProvider = _menuItems;
				popUp.labelFunction=lFunction;
			}	
		}
		private function lFunction(item:Object):String
		{
			if(item.label.@lang.length())
				return item.label.(@lang==LanguageManager.getInstance().currentLanguage)[0];
			else if(item.label.length())
				return item.label;
			else
				return item.toString();
		}
		public function get menuItems():Object
		{
			return _menuItems;
		}
		
		public function set itemOperations(value:Array):void
		{
			_itemOperations = value;
			menuItems = _generalOperatons + _itemOperations;			
		}
		public function get itemOperations():Array { return _itemOperations; }
		
		public function set generalOperations(value:Array):void
		{
			_generalOperatons = value;
			menuItems = _generalOperatons + _itemOperations;
		}
		public function get generalOperations():Array { return _generalOperatons; }
		
		public function set text(value:String):void
		{
			this.cs.text = value;
		}
		
		public function get text():String
		{
			return this.cs.text;
		}
		
		public function CatalogueSearchWrapper()
		{
			super();
			cb = new ComboBox();
			cb.addEventListener(ListEvent.CHANGE,cbChangeHandler);
			cb.percentWidth = 30;
			cb.tabEnabled = false;
			cs = new CatalogueSearchGridEditor();
			cs.setDataObject = setDataObject;
			cs.percentWidth = 70;
			cs.itemId = _itemId;
			cs.config = config;
			this.addChild(cs);
			this.addChild(cb);
			if(showItemOperations)
			{
				popUp = new ComboButton();
				popUp.percentHeight = 100;
				popUp.dataProvider = _menuItems;
				popUp.addEventListener(ListEvent.ITEM_CLICK, itemClickHandler);
				popUp.tabEnabled = false;
				this.addChild(popUp);
			}
			this.horizontalScrollPolicy = ScrollPolicy.OFF;
			this.verticalScrollPolicy = ScrollPolicy.OFF;
			this.setStyle('horizontalGap', 2);
		}
		
		protected function itemClickHandler(event:ListEvent):void
		{
			
		}
		
		private var _config:XML;
		public function set config(value:XML):void
		{
			_config = value;
			if (cs) cs.config = value;
		}
		public function get config():XML
		{
			return _config;
		}
		
		[Bindable]
		public override function set data(value:Object):void
		{
			_data = value;
			cs.data = _data;
			dataObject = DataObjectManager.getDataObject(data, listData);
			if (dataObject) {
				cs.text = dataObject.toString();
				cs.parentDataObject = dataObject;
			}
			cs.setFocus();	
			cs.setSelection(0,cs.text.length);
		}
		
		public override function get data():Object
		{
			return _data;
		}
		
		public function set listData(value:BaseListData):void	{
			_listData = value;
		}	
		
		public function get listData():BaseListData	{
			return _listData;
		}	
		
		public function set comboData(value:XML):void	{
			_comboData = value;
			
			if(value.*.label.length())
				cb.dataProvider = value.*.label.(@lang==LanguageManager.getInstance().currentLanguage);
			else
				cb.dataProvider = value.*.@label;
			
			if(value && value.column.length() <= 1)
			{
				cb.visible = false;
				cb.includeInLayout = false;				
				cs.percentWidth = 100;
			}
			else
			{
				cb.visible = true;
				cb.includeInLayout = true;
				cs.percentWidth = 70;
			}
		}	
		
		public function get comboData():XML	{
			return _comboData;
		}
		
		public function set searchCommandType(value:String):void	{
			cs.searchCommandType = value;
		}
		
		public function set setFunction(value:Function):void	{
			cs.setFunction = value;
		}
		
		public function setDataObject(value:Object):void	{
			dataObject = value;
		}
		
		private function cbChangeHandler(event:ListEvent):void	{
			cs.searchField = comboData.*[cb.selectedIndex].@field;
				
		}
	}
}