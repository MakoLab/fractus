package com.makolab.fractus.view.warehouse
{
	import com.makolab.fractus.model.document.DocumentObject;
	
	import flash.events.MouseEvent;
	
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	import mx.events.DataGridEvent;
	import mx.events.FlexMouseEvent;
	import mx.managers.PopUpManager;

	public class AllocationSelector extends Button
	{
		public function AllocationSelector()
		{
			super();
			this.addEventListener(MouseEvent.CLICK,handleClick);
			//this.addEventListener(FocusEvent.FOCUS_IN,focusInHandler)
		}
		
		private function handleClick(event:MouseEvent):void
		{
			showPopUp();
		}
		
		private var _selectedItems:Array = [];
		[Bindable]
		public function set selectedItems(value:Array):void
		{
			_selectedItems = value;
		}
		public function get selectedItems():Array
		{
			return _selectedItems;
		}
		
		private function showPopUp():void
		{
			var vbox:TitleWindow = new TitleWindow();
			var lotSelector:LotSelector = new LotSelector();
			if((data.documentObject as DocumentObject).typeDescriptor.isSalesDocument)lotSelector.warehouseId = data.warehouseId;
			else lotSelector.warehouseId = this.data.documentObject.xml.warehouseId.*;
			lotSelector.itemId = this.data.itemId;
			lotSelector.shiftTransactionId = this.data.documentObject.shiftsTransaction.id;
			if(!(data.documentObject as DocumentObject).isNewDocument)lotSelector.warehouseDocumentHeaderId = (data.documentObject as DocumentObject).xml.id.toString(); 
			lotSelector.selectedShifts = _selectedItems ? _selectedItems : [];
			lotSelector.totalQuantity = this.data.quantity;
			lotSelector.addEventListener(DataGridEvent.ITEM_EDIT_END,updateValues);
			vbox.addChild(lotSelector);
			PopUpManager.addPopUp(vbox,this);
			vbox.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE,clickOutsideHandler);
			lotSelector.callCommand();
		}
		
		private function updateValues(event:DataGridEvent):void
		{
			if((event.target as LotSelector).selectedShifts){
				_selectedItems = (event.target as LotSelector).selectedShifts
				data.shifts = _selectedItems;
			}
		}
		
		private function clickOutsideHandler(event:FlexMouseEvent):void
		{
			PopUpManager.removePopUp((event.target as TitleWindow));
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			if(value && value.hasOwnProperty("shifts")){
				selectedItems = value.shifts;
			}
		}
	}
}