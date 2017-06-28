package com.makolab.fractus.view.warehouse
{

	
	import com.makolab.components.util.FPopUpManager;
	import com.makolab.events.KeyboardShortcutEvent;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.CommercialDocumentLine;
	import com.makolab.fractus.model.document.ShiftObject;
	import com.makolab.fractus.model.document.WarehouseDocumentLine;
	import com.makolab.fraktus2.events.WarehouseEvent;
	import com.makolab.fraktus2.modules.warehouse.WarehouseMapManager;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ICollectionView;
	import mx.controls.Button;
	import mx.controls.TextInput;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.events.CloseEvent;
	import mx.events.ListEvent;

	[Event(name="slotClick", type="com.makolab.fractus.view.warehouse.WarehouseSlotEvent")]
	[Event(name="mapOpen", type="com.makolab.fractus.view.warehouse.WarehouseSlotEvent")]
	[Event(name="mapClose", type="flash.events.Event")]
	
	public class WarehouseSlotSelector extends TextInput
	{
		private var textInput:TextInput;
		private var button:Button;
		private var popup:FilteredSlotList;
		
		public var buttonVisible:Boolean;
		
		private var _warehouseStructure:XML;
		public function set warehouseStructure(value:XML):void
		{
			_warehouseStructure = value;
			updateLabel();
		}
		public function get warehouseStructure():XML
		{
			return ModelLocator.getInstance().configManager.getXML("warehouse.warehouseMap");// todo przywrócić po stworzeniu wrappera _warehouseStructure;
		}
		
		private var _selectedSlotId:String;
		[Bindable]
		public function set selectedSlotId(value:String):void
		{
			_selectedSlotId = value;
			updateLabel();
		}
		public function get selectedSlotId():String
		{
			return _selectedSlotId;
		}
		
		public var shiftTransactionId:String;
		
		private function updateLabel():void
		{
			if (warehouseStructure)
			{
				var l:XMLList = warehouseStructure..slot.(@id == _selectedSlotId);
				if (l.length() > 0) this.text = l[0].@label;
				else this.text = "";
			}			
		}
		
		public function WarehouseSlotSelector()
		{
			super();
			this.setStyle("horizontalGap", 0);
			ModelLocator.getInstance().configManager.requestValue("warehouse.warehouseMap");
		}
		
		private function shortcutInvokeHandler(event:KeyboardShortcutEvent):void
		{
			if (event.shortcut.equals([Keyboard.CONTROL,77]))
				button.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			/*
			textInput = new TextInput();
			this.addChild(textInput);
			textInput.percentWidth = 100;
			*/
			button = new Button();
			button.label = "\u2026";
			button.enabled = this.enabled;
			button.width = 20;
			button.percentHeight = 100;
			button.setStyle("paddingLeft", 0);
			button.setStyle("paddingRight", 0);
			button.toolTip = "ctrl + m";
			button.addEventListener(MouseEvent.CLICK, buttonClickHandler);
			this.addChild(button);
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			button.x = unscaledWidth - 21;
			button.y = 1;
			button.height = unscaledHeight - 2;
			button.width = 20;
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
						selectedSlotId = null; 
						dispatchEvent(new WarehouseSlotEvent(WarehouseSlotEvent.SLOT_CLICK, this._selectedSlotId))
					};
					if (popup && !popup.selectedItem && (popup.dataProvider as ICollectionView).length == 1) popup.selectedItem = popup.dataProvider[0];
					if (popup && popup.selectedItem) this.selectSlot(popup.selectedItem);
					break;
				default:
					break;
			}
			if (event.keyCode != Keyboard.ENTER) showPopup();
			if (event.keyCode == Keyboard.UP || event.keyCode == Keyboard.DOWN) {}
			else super.keyDownHandler(event);
		}
		
		protected function selectSlot(slotData:Object):void
		{
			this.text = slotData.@label;
			this.selectedSlotId = slotData.@id;
			hidePopup();
			dispatchEvent(new WarehouseSlotEvent(WarehouseSlotEvent.SLOT_CLICK, this._selectedSlotId));			
		}
		
		public function showPopup():void
		{
			if (!popup)
			{
				popup = new FilteredSlotList();
				if (popup.warehouseStructure != this.warehouseStructure) popup.warehouseStructure = this.warehouseStructure;
				if (popup.filterString != this.text) popup.filterString = this.text;
				popup.width = this.width;
				FPopUpManager.addPopUp(popup, this);
				popup.addEventListener(Event.REMOVED_FROM_STAGE, removeFromStageHandler);
				popup.addEventListener(ListEvent.ITEM_CLICK, handleItemClick);
				popup.focusEnabled = false;
				popup.owner = this;
			}
		}
		
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			if(button)button.enabled = value;
		}
		
		protected function handleItemClick(event:ListEvent):void
		{
			if (event.itemRenderer.data) selectSlot(event.itemRenderer.data);
		}
		
		private function removeFromStageHandler(event:Event):void
		{
			popup = null;
		}
		
		public function hidePopup():void
		{
			FPopUpManager.removePopUp(popup);
			popup = null;
		}
		
		override protected function keyUpHandler(event:KeyboardEvent):void
		{
			super.keyUpHandler(event);
			if (popup) popup.filterString = this.text;
		}
		
		private var _selectedItems:Array = [];
		
		[Bindable]
		public function set selectedItems(value:Array):void
		{
			_selectedItems = value;
			var txt:Array = [];
			this.selectedSlotId = null;
			if(value){
				for(var i:int=0;i<value.length;i++){
					txt.push(value[i].containerId); 
				}
			}
			this.selectedSlotId = txt[0];
		}
		
		public function get selectedItems():Array
		{
			var ids:Array = [this.selectedSlotId];
			var id:String = "";
			var version:String = "";	
			if(_selectedItems && _selectedItems.length > 0){
				id = _selectedItems[0].shiftId;
				version = _selectedItems[0].version;
			}
			_selectedItems = [];
			for(var i:int=0;i<ids.length;i++){
				_selectedItems.push(new ShiftObject({containerId : ids[i],status : 40,quantity : 1,shiftId : id,version : version}));
			}
			return _selectedItems;
		}
		 
		override public function set data(value:Object):void{
			super.data = value;
			if(value is WarehouseDocumentLine || value is CommercialDocumentLine)
			{
				if(value)selectedItems = value.shifts;
			}else if(value is XML){
				if(value)selectedSlotId = value.containerId.toString();
			}else if(value is ShiftObject){
				if(value)selectedSlotId = value.containerId;
			}
		}
		
		override protected function focusInHandler(event:FocusEvent):void
		{
			super.focusInHandler(event);
			ModelLocator.getInstance().keyboardShortcutManager.addEventListener(KeyboardShortcutEvent.INVOKE,shortcutInvokeHandler,false,0,true);
		}
		
		override protected function focusOutHandler(event:FocusEvent):void
		{
			super.focusOutHandler(event);
			ModelLocator.getInstance().keyboardShortcutManager.removeEventListener(KeyboardShortcutEvent.INVOKE,shortcutInvokeHandler);
			hidePopup();
		}
		
		private function buttonClickHandler(event:MouseEvent):void
		{
			MODULES::wms {
				
				
				var wm:WarehouseMapManager = WarehouseMapManager.getInstance();
					wm.showMap(null, true, 1, shiftTransactionId); 
					wm.addEventListener( WarehouseEvent.SLOT_SELECTED, slotClickHandler);			
					wm.addEventListener( CloseEvent.CLOSE, windowCloseHandler);	
				this.dispatchEvent(new Event("mapOpen"));
				/*
				var window:TitleWindow = WarehouseStructureWindow.showWindow(slotClickHandler,shiftTransactionId);
				window.addEventListener(CloseEvent.CLOSE,windowCloseHandler);
				*/
			}
		}
		
		private function windowCloseHandler(event:CloseEvent):void
		{
			this.dispatchEvent(new Event("mapClose"));
		}
		
		private function slotClickHandler(event:WarehouseEvent):void
		{
			this.selectedSlotId  = event.slotId;
			this.selectedItems = [new ShiftObject({containerId : event.slotId})];
			
			//this.selectedItems = [new ShiftObject({containerId : event.target.selectedSlotId})];
			//this.selectedSlotId = event.target.selectedSlotId;
			if (this.data is WarehouseDocumentLine || this.data is CommercialDocumentLine)
			{
				this.data[DataGridListData(this.listData).dataField] = this.selectedItems;
			}
			else if (this.data is XML)
			{
				this.data.containerId = this.selectedSlotId;
			}
			else if (this.data is ShiftObject)
			{
				this.data.containerId = this.selectedSlotId;
			}
			WarehouseMapManager.getInstance().closeMap();
			dispatchEvent(new WarehouseSlotEvent(WarehouseSlotEvent.SLOT_CLICK, this._selectedSlotId));
			//PopUpManager.removePopUp(event.target.parent);
		}
	}
}