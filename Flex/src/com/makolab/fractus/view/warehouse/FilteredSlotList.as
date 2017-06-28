package com.makolab.fractus.view.warehouse
{
	import mx.collections.ICollectionView;
	import mx.controls.List;

	[Event(name="slotClick", type="warehouseMap.WarehouseSlotEvent")]
	public class FilteredSlotList extends List
	{
		public function FilteredSlotList()
		{
			super();
			this.labelField = "@label";
		}
		
		private var _warehouseStructure:XML;			
		public function set warehouseStructure(value:XML):void
		{
			this._warehouseStructure = value;
			if (value) this.dataProvider = value..slot;
			ICollectionView(this.dataProvider).filterFunction = this.filterFunction;
		}
		public function get warehouseStructure():XML
		{
			return this._warehouseStructure;
		}
		
		private var _availableSlots:XMLList;
		public function set availableSlots(value:XMLList):void
		{
			this._availableSlots = value;
			////
		}
		public function get availableSlots():XMLList
		{
			return this._availableSlots;
		}
		
		private var _highlightedSlots:Array;
		public function set highlightedSlots(value:Array):void
		{
			this._highlightedSlots = value;
			////
		}
		public function get highlightedSlots():Array
		{
			return _highlightedSlots;
		}
		/*
		private var _textInput:TextInput;
		public function set textInput(value:TextInput):void
		{
			if (_textInput)
			{
				_textInput.removeEventListener(Event.CHANGE, handleTiChange);
				_textInput.removeEventListener(KeyboardEvent.KEY_DOWN, handleTiKeyDown);
			}
			_textInput = value;
			if (_textInput)
			{
				_textInput.addEventListener(Event.CHANGE, handleTiChange, false, EventPriority.DEFAULT, true);
				_textInput.addEventListener(KeyboardEvent.KEY_DOWN, handleTiKeyDown, false, - 1000, true);
			}
		}
		public function get textInput():TextInput
		{
			return _textInput;
		}
		*/
		
		private var _filterString:String;
		public function set filterString(value:String):void
		{
			if (_filterString != value)
			{
				this._filterString = value;
				if (this.dataProvider) ICollectionView(this.dataProvider).refresh();	
			}
		}
		public function get filterString():String
		{
			return _filterString;
		}
		
		private function filterFunction(item:Object):Boolean
		{
			if (!_filterString) return true;
			return Boolean(String(item.@label).match(new RegExp('^' + _filterString, 'i')));
		}
		
		/*
		private function handleTiChange(event:Event):void
		{
		}
		
		private function handleTiKeyDown(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.UP:
				case Keyboard.DOWN:
					this.dispatchEvent(event);
					break;
				case Keyboard.ENTER:
					if (!this.selectedItem && ICollectionView(this.dataProvider).length == 1) this.selectedItem = this.dataProvider[0];
					if (this.selectedItem)
					{
						this.text = popup.selectedItem.@label;
						dispatchEvent(new WarehouseSlotEvent(WarehouseSlotEvent.SLOT_CLICK, this.selectedItem.@id));
					}
					break;
				default:
					break;
			}
		}
		*/
		
	}
}