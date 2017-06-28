package com.makolab.fractus.view.warehouse
{
	
	import com.makolab.components.inputComponents.CurrencyEditor;
	import com.makolab.components.inputComponents.CurrencyRenderer;
	import com.makolab.components.util.FPopUpManager;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.document.ShiftObject;
	import com.makolab.fraktus2.utils.DynamicAssetsInjector;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.containers.ControlBar;
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	import mx.controls.DataGrid;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;
	import mx.events.CloseEvent;
	import mx.events.DataGridEvent;
	import mx.events.FlexEvent;
	import mx.events.FlexMouseEvent;
	import mx.events.ListEvent;

	public class MultipleWarehouseSlotSelector extends TitleWindow
	{
		public function MultipleWarehouseSlotSelector()
		{
			super();
			slotColumn.headerText = "Gniazdo"; // todo use lm
			slotColumn.itemRenderer = new ClassFactory(SlotRenderer);
			var editorClassFactory1:ClassFactory = new ClassFactory(WarehouseSlotSelector);
			
			slotColumn.itemEditor = editorClassFactory1;
			slotColumn.editorDataField = "selectedSlotId";
			slotColumn.dataField = "containerId";
			
			var quantityColumn:DataGridColumn = new DataGridColumn();
			var rendererClassFactory:ClassFactory = new ClassFactory(CurrencyRenderer);
			rendererClassFactory.properties = {precision : -4};
			var editorClassFactory:ClassFactory = new ClassFactory(CurrencyEditor);
			editorClassFactory.properties = {precision : -4};
			quantityColumn.editorDataField = "dataObject";
			quantityColumn.itemRenderer = rendererClassFactory;
			quantityColumn.itemEditor = editorClassFactory;
			quantityColumn.headerText = "Ilość"; // todo use lm
			quantityColumn.dataField = "quantity";
			
			var attributesColumn:DataGridColumn = new DataGridColumn();
			attributesColumn.headerText = LanguageManager.getLabel('common.attributes'); // todo use lm
			attributesColumn.dataField = "attributes";
			attributesColumn.editable = false;
			var rendererFactory:ClassFactory = new ClassFactory(ShiftAttributesItemRenderer);
			rendererFactory.properties = {closeHandler : attributeEditorCloseHandler};
			attributesColumn.itemRenderer = rendererFactory;
			
			var removeButtonColumn:DataGridColumn = new DataGridColumn();
			removeButtonColumn.width = 26;
			removeButtonColumn.setStyle("align","center");
			var factory:ClassFactory = new ClassFactory(Image);
			factory.properties = {source : DynamicAssetsInjector.currentIconAssetClassRef.status_canceled};
			removeButtonColumn.itemRenderer = factory;
			removeButtonColumn.editable = false;
			
			dataGrid.columns = [slotColumn,quantityColumn,attributesColumn,removeButtonColumn];
			dataGrid.percentWidth = 100;
			dataGrid.percentHeight = 100;
			dataGrid.editable = true;
			dataGrid.addEventListener(ListEvent.ITEM_CLICK,itemClickHandler);
			dataGrid.addEventListener(DataGridEvent.ITEM_FOCUS_IN,itemEditBegin);
			dataGrid.addEventListener(DataGridEvent.ITEM_FOCUS_OUT,updateTotal);
			dataGrid.addEventListener(DataGridEvent.ITEM_EDIT_END,itemEditEndHandler);
			this.addChild(dataGrid);
			
			okButton.label = "OK";
			okButton.addEventListener(MouseEvent.CLICK,okButtonClickHandler); 
			
			var ctrlBar:ControlBar = new ControlBar();
			summaryLabel.percentWidth = 100;
			ctrlBar.direction = "horizontal";
			ctrlBar.setStyle("paddingTop",4);
			ctrlBar.setStyle("paddingBottom",4);
			ctrlBar.addChild(summaryLabel);
			ctrlBar.addChild(okButton);
			
			this.addChild(ctrlBar);
			this.addEventListener(KeyboardEvent.KEY_DOWN,handleKeyDown);
			this.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE,mouseDownOutsideHandler);
			this.addEventListener(FlexEvent.CREATION_COMPLETE,handleCreationComplete);
			if(!selectedItems || selectedItems.length == 0){
				selectedItems.push(new ShiftObject());
			}
		}
		
		private var dataGrid:DataGrid = new DataGrid();
		private var summaryLabel:Label = new Label();
		private var okButton:Button = new Button();
		private var slotColumn:DataGridColumn = new DataGridColumn();
		//private var editedItemPosition:Object;
		
		public var total:Number = 0;
		
		private function handleCreationComplete(event:FlexEvent):void
		{
			if(dataGrid.stage)dataGrid.setFocus();
		}
		
		private function updateTotal(event:Event = null):void
		{
			var quantity:Number = 0;
			for(var i:int = 0; i < dataGrid.dataProvider.length; i++){
				quantity += isNaN(Number(dataGrid.dataProvider[i].quantity)) ? 0 : Number(dataGrid.dataProvider[i].quantity);
			}
			summaryLabel.text = "Łącznie: " + quantity;
			if(quantity > total)summaryLabel.setStyle("color",0xFF8800);
			if(quantity < total)summaryLabel.setStyle("color","red");
			if(quantity == total)summaryLabel.setStyle("color","black");
		}
		
		private function okButtonClickHandler(event:MouseEvent):void
		{
			this.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
			FPopUpManager.removePopUp(this);
		}
		
		private function handleKeyDown(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case Keyboard.ESCAPE :
					event.preventDefault();
					//if(!dataGrid.editedItemPosition)
					okButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
					break;
				/* case Keyboard.ENTER :
					trace("editedItemPosition: " + dataGrid.editedItemPosition.toString());
					if(!dataGrid.editedItemPosition){
						event.preventDefault();
						okButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK))
					}else{
						dataGrid.editedItemPosition = null;
					}
					break; */
			}
		}
		
		private function slotClickHandler(event:WarehouseSlotEvent):void
		{
			if((dataGrid.dataProvider[dataGrid.dataProvider.length - 1] as ShiftObject).containerId != ""){
				var temp:Array = _selectedItems;
				temp.push(new ShiftObject());
				selectedItems = temp;
			}
			//dataGrid.setFocus();
			
			this.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE,mouseDownOutsideHandler);
			this.addEventListener(KeyboardEvent.KEY_DOWN,handleKeyDown);
		}
		
		private function attributeEditorCloseHandler():void
		{
			dataGrid.setFocus();
			this.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE,mouseDownOutsideHandler);
			this.addEventListener(KeyboardEvent.KEY_DOWN,handleKeyDown);
		}
		
		private function warehouseMapClose(event:Event):void
		{
			dataGrid.setFocus();
			//dataGrid.destroyItemEditor();
			dataGrid.selectedItem = selectedItems[dataGrid.editedItemPosition.rowIndex];
			dataGrid.editedItemPosition = {columnIndex : 1, rowIndex : dataGrid.editedItemPosition.rowIndex};
			this.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE,mouseDownOutsideHandler);
			this.addEventListener(KeyboardEvent.KEY_DOWN,handleKeyDown);
		}
		
		private function itemClickHandler(event:ListEvent):void
		{
			if(event.columnIndex == 2){
				this.removeEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE,mouseDownOutsideHandler);
				this.removeEventListener(KeyboardEvent.KEY_DOWN,handleKeyDown);
			}
			if(event.columnIndex == 3){
				var temp:Array = [];
				for (var i:int = 0; i < _selectedItems.length; i++){
					if(i != event.rowIndex)temp.push(_selectedItems[i]);
				}
				selectedItems = temp;
			}
		}
		
		private function itemEditBegin(event:DataGridEvent):void
		{
			if(event.columnIndex == 0){
				dataGrid.itemEditorInstance.addEventListener("mapOpen",mapOpenHandler);
			}
		}
		
		private function mapOpenHandler(event:Event):void
		{
			this.removeEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE,mouseDownOutsideHandler);
			this.removeEventListener(KeyboardEvent.KEY_DOWN,handleKeyDown);
			//this.editedItemPosition = dataGrid.editedItemPosition;
		}
		
		private function mouseDownOutsideHandler(event:FlexMouseEvent):void
		{
			okButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		private function itemEditEndHandler(event:DataGridEvent):void
		{
			if(event.columnIndex == 0){
				dataGrid.itemEditorInstance.addEventListener(WarehouseSlotEvent.SLOT_CLICK,slotClickHandler);
				dataGrid.itemEditorInstance.addEventListener("mapClose",warehouseMapClose);
			}
			if(event.dataField == "containerId" && event.rowIndex == dataGrid.dataProvider.length - 1 && dataGrid.editedItemRenderer.data.containerId != ""){
				var temp:Array = selectedItems;
				temp.push(new ShiftObject());
				selectedItems = temp;
			}
		}
		
		private function removeButtonClickHandler(event:MouseEvent):void
		{
			var temp:Array = [];
			for (var i:int = 0; i < _selectedItems.length; i++){
				if(i != dataGrid.selectedIndex)temp.push(_selectedItems[i]);
			}
			selectedItems = temp;
		}
		
		private var _selectedItems:Array = [];
		[Bindable]
		public function set selectedItems(value:Array):void
		{
			var temp:Array = [];
			_selectedItems = value;
			if(value){
				for(var i:int=0; i < value.length; i++){
					if(value[i].containerId/*  && value[i].quantity != 0 && !isNaN(value[i].quantity) */)temp.push(value[i]);
				}
				_selectedItems = temp;
			}
			if(!value)_selectedItems = [];
			if(_selectedItems.length == 0 || _selectedItems[_selectedItems.length-1].containerId != "")_selectedItems.push(new ShiftObject());
			dataGrid.dataProvider = _selectedItems;
			if(value.length > 0){
				var factory:ClassFactory = new ClassFactory(WarehouseSlotSelector);
				factory.properties = {shiftTransactionId : value[0].shiftTransactionId}; // todo prowizorka- do editora przekazywac caly shift i z niego wyciagac id gniazda i transakcji
				slotColumn.itemEditor = factory;
			}
			updateTotal();
		}
		
		public function get selectedItems():Array
		{
			var ret:Array = [];
			for(var i:int=0; i < _selectedItems.length; i++){
				if(_selectedItems[i].containerId != ""){
					//if(_selectedItems[i].quantity == "")_selectedItems[i].quantity = 0;
					ret.push(_selectedItems[i]);
				}
			}
			return ret;
		}
	}
}