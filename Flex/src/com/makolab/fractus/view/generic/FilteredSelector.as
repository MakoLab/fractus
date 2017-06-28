package com.makolab.fractus.view.generic
{
	import com.makolab.components.inputComponents.DataObjectManager;
	import com.makolab.components.util.FPopUpManager;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.XMLListCollection;
	import mx.controls.TextInput;
	import mx.controls.listClasses.BaseListData;
	import mx.core.ClassFactory;
	import mx.events.ListEvent;

	[Event(name="slotClick", type="com.makolab.fractus.view.warehouse.WarehouseSlotEvent")]
	[Event(name="mapOpen", type="com.makolab.fractus.view.warehouse.WarehouseSlotEvent")]
	[Event(name="mapClose", type="flash.events.Event")]
	
	public class FilteredSelector extends TextInput
	{
		private var textInput:TextInput;
		protected var popup:FilteredList;
		
		public var labelField:String = "label";
		public var idField:String = "id";
		
		public function FilteredSelector()
		{
			super();
		}

		/**
		 * Determines if popup always opens on focus in or not.
		 */
		public var openAlways:Boolean = true;

		private var _dataProvider:ICollectionView;
		public function set dataProvider(value:Object):void
		{
			if (value is ICollectionView) _dataProvider = value as ICollectionView;
			else if (value is Array) _dataProvider = new ArrayCollection(value as Array);
			else if (value is XMLList) _dataProvider = new XMLListCollection(value as XMLList);
			else throw new Error("FilteredSelector: Invalid dataProvider type.");
			if(popup)popup.dataProvider = _dataProvider;
			updateLabel();
		}
		public function get dataProvider():Object
		{
			return _dataProvider;
		}
		
		private var _selectedId:String;
		[Bindable]
		public function set selectedId(value:String):void
		{
//trace("selected id " + value);
			if (value == _selectedId) return;
			_selectedId = value;
			updateLabel();
		}
		public function get selectedId():String
		{
			//trace("sId: "+_selectedId);
			return _selectedId;
		}
		
		private function updateLabel():void
		{
			var selectedItem:Object = null;
			if (this._dataProvider) for each (var o:Object in this._dataProvider)
			{
//trace("loop: " + o);
				 if (o[this.idField] == this._selectedId) selectedItem = o;
				 if (selectedItem) break;
			}
			this.text = selectedItem ? String(selectedItem[this.labelField]) : '';
		}
		
		protected override function keyDownHandler(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.UP:
				case Keyboard.DOWN:
					if (popup) popup.dispatchEvent(event);
					event.stopImmediatePropagation();
					break;
				case Keyboard.ENTER:
					if (this.text == ""){
						selectedId = null; 
						//dispatchEvent(new WarehouseSlotEvent(WarehouseSlotEvent.SLOT_CLICK, this._selectedId))
					};
					if (popup && !popup.selectedItem && (popup.dataProvider as ICollectionView).length == 1) popup.selectedItem = popup.dataProvider[0];
					if (popup && popup.selectedItem) this.selectItem(popup.selectedItem);
					break;
				default:
					break;
			}
			if (event.keyCode != Keyboard.ENTER) showPopup();
			if (event.keyCode == Keyboard.UP || event.keyCode == Keyboard.DOWN) {}
			else super.keyDownHandler(event);
		}
		
		protected function selectItem(item:Object):void
		{
			this.text = item[this.labelField];
			this.selectedId = item[this.idField];
			this.setSelection(this.text.length, this.text.length);
			this.dispatchEvent(new Event(Event.CHANGE));
			hidePopup();
			//dispatchEvent(new WarehouseSlotEvent(WarehouseSlotEvent.SLOT_CLICK, this._selectedId));			
		}
		
		public function showPopup():void
		{
			if (!popup && this.enabled)
			{
				popup = new FilteredList();
				if (popup.dataProvider != this.dataProvider) popup.dataProvider = this.dataProvider;
				if (popup.labelField != this.labelField) popup.labelField = this.labelField;
				if (popup.filterString != this.text) popup.filterString = this.text;
				popup.width = this.width;
				FPopUpManager.addPopUp(popup, this);
				popup.addEventListener(Event.REMOVED_FROM_STAGE, removeFromStageHandler);
				popup.addEventListener(ListEvent.ITEM_CLICK, handleItemClick);
				popup.focusEnabled = false;
				popup.owner = this;
			}
		}
		
		protected function handleItemClick(event:ListEvent):void
		{
			if (event.itemRenderer.data) selectItem(event.itemRenderer.data);
		}
		
		private function removeFromStageHandler(event:Event):void
		{
			popup = null;
		}
		
		public function hidePopup():void
		{
			FPopUpManager.removePopUp(popup);
			popup = null;
			if (this.dataProvider)
			{
				this.dataProvider.filterFunction = null;
				this.dataProvider.refresh();
			}
		}
		
		override protected function keyUpHandler(event:KeyboardEvent):void
		{
			super.keyUpHandler(event);
			if (popup) popup.filterString = this.text;
		}
		
		[Bindable]
		override public function set data(value:Object):void
		{
			super.data = value;
			this.selectedId = String(DataObjectManager.getDataObject(this.data, this.listData));
		}
		
		override public function get data():Object
		{
			return super.data;
		}
		
		override public function set listData(value:BaseListData):void
		{
			super.listData = value;
			this.selectedId = String(DataObjectManager.getDataObject(this.data, this.listData));
		}
		
		override protected function focusInHandler(event:FocusEvent):void
		{
			super.focusInHandler(event);
			if (this.text) this.setSelection(0, this.text.length);
			if (openAlways) this.showPopup();
		}
		
		override protected function focusOutHandler(event:FocusEvent):void
		{
			super.focusOutHandler(event);
			hidePopup();
			updateLabel();
		}
		
		public static function getFactory(dataProvider:Object, labelField:String = 'label', idField:String = 'id'):ClassFactory
		{
			var cf:ClassFactory = new ClassFactory(FilteredSelector);
			cf.properties = { dataProvider : dataProvider, labelField : labelField, idField : idField };
			return cf;
		}
	}
}