package com.makolab.fractus.view.warehouse
{
	import com.makolab.components.layoutComponents.ComboButton2;
	import com.makolab.components.util.CurrencyManager;
	import com.makolab.components.util.FPopUpManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.CommercialDocumentLine;
	import com.makolab.fractus.model.document.ShiftObject;
	import com.makolab.fractus.model.document.WarehouseDocumentLine;
	
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.ViewStack;
	import mx.controls.DataGrid;
	import mx.controls.Label;
	import mx.core.ScrollPolicy;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import flash.events.MouseEvent;


	public class SlotItemEditor extends HBox
	{
		public function SlotItemEditor()
		{
			super();
			
			var slotSelectorCanvas:Canvas = new Canvas();
			slotSelectorCanvas.percentWidth = 100;
			slotSelector.percentWidth = 100;
			slotSelectorCanvas.addChild(slotSelector);
			
			var labelCanvas:Canvas = new Canvas();
			labelCanvas.percentWidth = 100;
			labelCanvas.percentHeight = 100;
			labelCanvas.horizontalScrollPolicy = ScrollPolicy.OFF;
			slotLabel.percentWidth = 100;
			slotLabel.percentHeight = 100;
			slotLabel.setStyle("verticalCenter",0);
			labelCanvas.addChild(slotLabel);
			
			viewStack.percentWidth = 100;
			viewStack.percentHeight = 100;
			viewStack.addChild(slotSelectorCanvas);
			viewStack.addChild(labelCanvas);
			
			this.addChild(viewStack);
			this.addChild(popUpOpener);
			this.horizontalScrollPolicy = ScrollPolicy.OFF;
			popUpOpener.width = 20;
			popUpOpener.height = 20;
			slotSelector.percentWidth = 100;
			this.setStyle("horizontalGap",0);
			this.addEventListener(FlexEvent.CREATION_COMPLETE,createCompleteHandler);
			popUpOpener.addEventListener(MouseEvent.CLICK,showPopUp);
			slotSelector.addEventListener(WarehouseSlotEvent.SLOT_CLICK,slotClickHandler);
			//this.addEventListener(DropdownEvent.OPEN,showPopUp);
			window.addEventListener(CloseEvent.CLOSE,handlePopupClose);
			window.setStyle("headerHeight",0);
		}
		
		private function createCompleteHandler(event:FlexEvent):void
		{
			if(viewStack.selectedIndex == 0)slotSelector.setFocus();
			else popUpOpener.setFocus();
		}
		
		private var popUpOpener:ComboButton2 = new ComboButton2();
		private var slotSelector:WarehouseSlotSelector = new WarehouseSlotSelector();
		private var slotLabel:Label = new Label();
		private var viewStack:ViewStack = new ViewStack(); 
		
		private var window:MultipleWarehouseSlotSelector = new MultipleWarehouseSlotSelector();
		
		private var editorPosition:Object;
		private var _lineComponent:DataGrid;
		public function set lineComponent(value:DataGrid):void
		{
			_lineComponent = value;
			editorPosition = value.editedItemPosition;
		}
		public function get lineComponent():DataGrid
		{
			return _lineComponent;
		}
		
		private function slotClickHandler(event:WarehouseSlotEvent):void
		{
			this.selectedItems = [new ShiftObject({containerId : slotSelector.selectedSlotId, quantity : data.quantity})];
			data.shifts = selectedItems;
		}
		
		private var _selectedItems:Array = [];
		[Bindable]
		public function set selectedItems(value:Array):void
		{
			_selectedItems = value;
			var symbol:String = "";
			var slots:XMLList;
			var structure:XML = XML(ModelLocator.getInstance().configManager.getValue("warehouse.warehouseMap"));
			var array:Array = [];
			
			if(value is Array){
				for each(var shift:Object in data.shifts){
					slots = structure..slot.(@id == shift.containerId);
					if(slots.length() > 0){
						symbol = slots[0].@label;
						array.push(symbol + "(" + CurrencyManager.formatCurrency(Number(shift.quantity)) + ")");
					}/* else{
						array.push("brak gniazda");
					} */
				}
				//this.label = array.join(" ");
				if(value.length == 1){
					slotSelector.enabled = true;
					slotSelector.selectedSlotId = value[0].containerId;
					slotSelector.shiftTransactionId = value[0].shiftTransactionId;
				}else if(value.length == 0){
					slotSelector.enabled = true;
					slotSelector.selectedSlotId = null;
				}else{
					//slotSelector.enabled = false;
					//slotSelector.selectedSlotId = null;
					viewStack.selectedIndex = 1;
					slotLabel.text = array.join(" ");
					slotLabel.toolTip = slotLabel.text;
				}
			}
		}
		public function get selectedItems():Array
		{
			return _selectedItems;
		}
		
		private function showPopUp(event:Event):void
		{
			window.selectedItems = selectedItems;
			FPopUpManager.addPopUp(window,this);
		}
		
		private function handlePopupClose(event:CloseEvent):void
		{
			data.shifts = window.selectedItems;
			if(data.shifts.length == 1 && (isNaN(data.shifts[0].quantity) || data.shifts[0].quantity == ""))data.shifts[0].quantity = window.total;
			if(data.shifts.length > 1){
				for(var i:int = 0; i < data.shifts.length; i++){
					if(isNaN(data.shifts[i].quantity) || data.shifts[i].quantity == "")data.shifts[i].quantity = 0;
				}
			}
			if(lineComponent)lineComponent.editedItemPosition = editorPosition;
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			if(data.itemId){
				slotSelector.enabled = true;
				popUpOpener.enabled = true;
				this.toolTip = "";
			}else{
				slotSelector.enabled = false;
				popUpOpener.enabled = false;
				this.toolTip = "Wybierz towar"; // todo uzyj languageManagera
			}
			if(value is WarehouseDocumentLine || value is CommercialDocumentLine)
			{
				if(value)window.total = data.quantity;
				if(value)selectedItems = value.shifts;
			}/* else if(value is XML){
				if(value)selectedSlotId = value.containerId.toString();
			} */
			slotSelector.enabled = popUpOpener.enabled = data.itemId && ((value.documentObject.isNewDocument && value.documentObject.typeDescriptor.isPurchaseDocument) || value.documentObject.typeDescriptor.isWarehouseIncome);
		}
	}
}