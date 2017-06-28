package com.makolab.components.inputComponents
{
	import mx.controls.PopUpButton;
	import mx.controls.List;
	import mx.controls.Label;
	import mx.events.ListEvent;
	import mx.effects.easing.Linear;
	import mx.core.IUIComponent;
	import mx.events.DropdownEvent;
	import flash.events.MouseEvent;

	[Event(name="itemClick", type="mx.events.ListEvent")]
	public class LastItemDropdown extends PopUpButton
	{
		public function LastItemDropdown()
		{
			super();
			this.addEventListener(DropdownEvent.OPEN, handleOpen);
			this.addEventListener(MouseEvent.CLICK, handleClick);
			this.list = new List();
			list.addEventListener(ListEvent.ITEM_CLICK, handleItemClick);
			list.setStyle('fontWeight', 'normal');
			list.setStyle('textAlign', 'left');
			this.popUp = this.list;			
		}
		
		private var currentItem:Object;
		
		public var labelField:String = null;
		public var labelFunction:Function = null;
		
		private var _dataProvider:Object;
		[Bindable]
		public function set dataProvider(value:Object):void
		{
			_dataProvider = value;
			if (list)
			{
				list.dataProvider = value;
				list.rowCount = list.dataProvider.length;
			}
			if (dataProvider && dataProvider[0]) selectedItem = dataProvider[0];
			else selectedItem = null;
			if (list) list.selectedItem = currentItem;
		}
		public function get dataProvider():Object
		{
			return _dataProvider;
		}
		
		private var list:List;
		
		protected function handleOpen(event:DropdownEvent):void
		{
			if (this.labelField) this.list.labelField = this.labelField;
			if (this.labelFunction != null) this.list.labelFunction = this.labelFunction;
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			this.list.minWidth = this.unscaledWidth;
		}
		
		protected function handleItemClick(event:ListEvent):void
		{
			this.selectedItem = event.itemRenderer.data;
			this.dispatchEvent(event);
		}
		
		protected function handleClick(event:MouseEvent):void
		{
			super.clickHandler(event);
			this.dispatchEvent(new ListEvent(ListEvent.ITEM_CLICK)); 
		}
		
		public function set selectedItem(item:Object):void
		{
			this.currentItem = item;
			if (!item) this.label = null;
			else if (this.labelFunction != null) this.label = labelFunction(item);
			else if (this.labelField) this.label = item[labelField];
			else this.label = String(item);
		}
		public function get selectedItem():Object
		{
			return this.currentItem;
		}
	}
}