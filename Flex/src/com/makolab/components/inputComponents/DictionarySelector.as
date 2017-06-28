package com.makolab.components.inputComponents
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.List;
	import mx.controls.PopUpButton;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.events.ListEvent;

	public class DictionarySelector extends PopUpButton implements IListItemRenderer
	{
		private var _dataProvider:Object;
		public var colorField:String;
		public var iconField:String;
		public var valueMapping:Object = { "*" : "*" };
		public var idField:String;
		public var icons:Object;
		public var level:Number;
		public var nodeName:String;
		
		private var _selectedItem:Object;
		private var _labelField:String;
		private var _listLabelField:String;
		
		private var _listLabelFunction:Function;
		[Bindable]
		public function set listLabelFunction(value:Function):void
		{
			_listLabelFunction = value;
			if (popUp) List(popUp).labelFunction = _listLabelFunction;
		}
		public function get listLabelFunction():Function
		{
			return _listLabelFunction;
		}
		
		[Bindable]
		public var labelFunction:Function;
		
		public var maxRows:int = 10;
				
		public function set dataProvider(value:Object):void
		{
			var popUp:List = List(popUp);
			popUp.dataProvider = value;
			
			if(value)
			{
				var items:int = value.length();
				
				//ustalanie max ilosci wierszy
				if(items < this.maxRows)
					popUp.rowCount = items;
				else
					popUp.rowCount = this.maxRows;
			}
		}
		public function get dataProvider():Object
		{
			return popUp ? List(popUp).dataProvider : null;
		}
		
		public function set labelField(value:String):void
		{
			_labelField = value;
			if (_labelField && !listLabelField) List(popUp).labelField = _labelField; 
		}
		public function get labelField():String { return _labelField; }
		
		public function set listLabelField(value:String):void
		{
			_listLabelField = value;
			if (_listLabelField) List(popUp).labelField = _listLabelField;
		}
		public function get listLabelField():String { return _listLabelField; }
		
		public function get selectedItem():Object { return _selectedItem; }
		public function set selectedItem(value:Object):void {
			_selectedItem = value;
			if (labelFunction != null) label = labelFunction(_selectedItem);
			else if (labelField && value) label = _selectedItem[labelField];
			if (!dataObject) _dataObject = new Object();
			for (var i:String in valueMapping)
			{
				if (valueMapping[i] == '*' && typeof(_dataObject) != "object" && typeof(_dataObject) != "xml")
				{
					_dataObject = _selectedItem[i].toString();
				}
				else if(value) _dataObject[valueMapping[i]] = _selectedItem[i].toString();
			}
			if (colorField && value) opaqueBackground = _selectedItem[colorField];
			if (iconField && icons && value) setStyle("icon", icons[_selectedItem[iconField]]);
		}
    		
		private var _dataObject:Object;
		
		[Bindable]
		public function set dataObject(value:Object):void
		{
			if (value is XML || value is XMLList) _dataObject = value.copy();
			else _dataObject = value;
			var si:Object = null;
			for (var itemIndex:String in dataProvider)
			{
				var item:Object = dataProvider[itemIndex];
				var sel:Boolean = true;
				for (var i:String in valueMapping)
				{
					if (valueMapping[i] == '*' && typeof(dataObject) != 'object' && typeof(dataObject) != 'xml')
					{
						if (dataObject != item[i].toString()) sel = false;
					} 
					else if (dataObject[valueMapping[i]].toString() != item[i].toString()) sel = false;
				}
				if (sel)
				{
					si = item;
					break;
				}
			}
			selectedItem = si;
			if(popUp)List(popUp).selectedItem = selectedItem;
		}
		public function get dataObject():Object
		{
			return _dataObject;
		}
				
		override public function set data(value:Object):void
		{
			super.data = value;
			dataObject = DataObjectManager.getDataObject(data, listData);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			popUp.width = unscaledWidth;
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
		
		public function DictionarySelector()
		{
			super();
			openAlways = true;
			initPopUp();
			this.alpha = 1;
		}

		protected function initPopUp():void
		{
			// TODO: wprowadzić style dla popupa
			// TODO: okreslic programowo wysokosc popupa
			var dropdown:List = new List();
			dropdown.setStyle("backgroundColor", 0xeeeeee);
			//dropdown.setStyle("backgroundAlpha", 0.8);
			dropdown.addEventListener(ListEvent.CHANGE, listChangeHandler);
			dropdown.dataProvider = dataProvider;
			dropdown.iconFunction = getIcon;
			dropdown.labelFunction = _listLabelFunction;
			if (labelField || listLabelField) dropdown.labelField = listLabelField ? listLabelField : labelField;
			dropdown.setStyle("textAlign", "left");			
			popUp = dropdown;
		}
		
		protected override function keyDownHandler(event:KeyboardEvent):void
		{
			if (event.keyCode != 13)
				super.keyDownHandler(event);
		}
		
		protected function listChangeHandler(event:ListEvent):void
		{
			selectedItem = List(popUp).selectedItem;
			dispatchEvent(event);
		}
		
		protected function getIcon(item:Object):Class
		{
			if (icons && iconField) return icons[item[iconField]];
			else return null;
		}
		
	}
}