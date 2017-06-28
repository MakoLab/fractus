package com.makolab.fractus.view.warehouse
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.components.util.CurrencyManager;
	import com.makolab.components.util.FPopUpManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.DocumentObject;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.containers.ControlBar;
	import mx.containers.HBox;
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	import mx.controls.DataGrid;
	import mx.controls.Label;
	import mx.controls.LinkButton;
	import mx.controls.listClasses.BaseListData;
	import mx.events.DataGridEvent;
	import mx.events.DropdownEvent;
	import mx.events.FlexMouseEvent;
	import mx.managers.PopUpManager;
	
	[Event(name="shiftsChange", type="flash.events.Event")]

	public class AllocationSelector2 extends LinkButton
	{
		public function AllocationSelector2()
		{
			super();
			this.setStyle("borderStyle","none");
			this.addEventListener(MouseEvent.CLICK,function ():void{setPopup()});
			this.addEventListener(DropdownEvent.OPEN,function ():void{setPopup()});
			lotSelector.addEventListener(DataGridEvent.ITEM_EDIT_END,updateValues);
			lotSelector.addEventListener(DataGridEvent.ITEM_EDIT_END,updateDocumentObject);
			lotSelector.addEventListener("valuesUpdated",updateTotal);
			lotSelector.addEventListener("validationError",validationErrorHandler);
			lotSelector.addEventListener("commit",function():void{removePopup();if(grid && editedPosition){grid.editedItemPosition = editedPosition};});
			//var titleWindow:TitleWindow = new TitleWindow();
			titleWindow.setStyle("headerHeight",0);
			titleWindow.setStyle("verticalGap",0);
			titleWindow.setStyle("dropShadowEnabled",true);
			titleWindow.setStyle("shadowDistance",2);
			titleWindow.width = 600;
			titleWindow.addChild(lotSelector);
			titleWindow.addEventListener(KeyboardEvent.KEY_DOWN,function (keyboardEvent:KeyboardEvent):void{if(keyboardEvent.keyCode == Keyboard.ESCAPE){removePopup();if(grid && editedPosition){grid.editedItemPosition = editedPosition};}});
			titleWindow.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE,function ():void{removePopup();});
			var controlBar:ControlBar = new ControlBar();
			var hbox:HBox = new HBox();
			hbox.percentWidth = 100;
			controlBar.addChild(hbox);
			controlBar.height = 30;
			controlBar.setStyle("paddingTop",0);
			controlBar.setStyle("paddingBottom",0);
			titleWindow.addChild(controlBar);
			var okButton:Button = new Button();
			okButton.label = "OK";
			okButton.toolTip = "[Esc]"
			okButton.addEventListener(MouseEvent.CLICK,function ():void{PopUpManager.removePopUp(titleWindow);if(grid && editedPosition){grid.editedItemPosition = editedPosition}});
			if(lotSelector.useCountColumn){
				summaryLabel.text = "Ilość łącznie: ";
				summaryLabel.percentWidth = 100;
				hbox.addChild(summaryLabel);
			}
			hbox.addChild(okButton);
		}
		private var arrowIcon:Class;
		private var _selectedItems:Array;
		private var lotSelector:LotSelector = new LotSelector();
		private var summaryLabel:Label = new Label();
		private var titleWindow:TitleWindow = new TitleWindow();
		
		private function validationErrorHandler(event:Event):void
		{
			this.setStyle("color","red");
			this.errorString = "Błędna wartość"; // todo use LanguageManager
		}
		
		[Bindable] public var editedPosition:Object;
		[Bindable] public var grid:DataGrid;
		
		private function setPopup(event:FocusEvent=null):void
		{
			if(!enabled)return;
			this.errorString = "";
			if(data.documentObject){
				if((data.documentObject as DocumentObject).typeDescriptor.isSalesDocument)lotSelector.warehouseId = data.warehouseId;
				else lotSelector.warehouseId = this.data.documentObject.xml.warehouseId.*;
			}else{
				if(data.warehouseId)lotSelector.warehouseId = data.warehouseId;
			}
			lotSelector.itemId = this.data.itemId;
			lotSelector.documentCurrencyId = ModelLocator.getInstance().systemCurrencyId;
			if(data.documentObject)lotSelector.shiftTransactionId = this.data.documentObject.shiftsTransaction.id;
			if(data.documentObject && !(data.documentObject as DocumentObject).isNewDocument)lotSelector.warehouseDocumentHeaderId = (data.documentObject as DocumentObject).xml.id.toString(); 
			lotSelector.selectedShifts = _selectedItems ? _selectedItems : [];
			lotSelector.totalQuantity = this.data.quantity;
			lotSelector.percentWidth = 100;
			
			FPopUpManager.addPopUp(titleWindow,this);
			lotSelector.callCommand();
		}
		
		private function removePopup():void
		{
			PopUpManager.removePopUp(titleWindow);
		}
			
		private function updateTotal(event:Event = null):void
		{
			var total:Number = 0;
			for(var i:int=0;i<_selectedItems.length;i++){
				total += Number(String(_selectedItems[i].quantity).replace(",",".")); 
			}
			summaryLabel.text = "Ilość łącznie: " + CurrencyManager.formatCurrency(total,"?",null,-4);
			if(Number(data.quantity) > total){
				summaryLabel.setStyle("color","0xFF8800");
				this.setStyle("color","0xFF8800");
			}
			if(Number(data.quantity) < total){
				summaryLabel.setStyle("color","red");
				this.setStyle("color","red");
			}
			if(Number(data.quantity) == total){
				summaryLabel.setStyle("color","black");
				this.setStyle("color","black");
			}
		}
		
		private function updateDocumentObject(event:DataGridEvent):void
		{
			data.shifts = _selectedItems;
			if (data.documentObject) data.documentObject.dispatchEvent(new DocumentEvent(DocumentEvent.DOCUMENT_LINE_CHANGE,false,false,"shifts",data));
		}
		
		private function updateValues(event:Event=null):void
		{
			if(lotSelector.selectedShifts){
				_selectedItems = lotSelector.selectedShifts;
				updateTotal();
			}
			updateText();
		}
		
		private function updateText():void
		{
			var array:Array = [];
			if(_selectedItems){
				for(var i:int=0;i<_selectedItems.length;i++){
					if(Number(_selectedItems[i].quantity) > 0)array.push((_selectedItems[i].containerLabel != "" ? _selectedItems[i].containerLabel : "* ") + "(" + CurrencyManager.formatCurrency(Number(String(_selectedItems[i].quantity).replace(",",".")),"?",null,-4) + ")");
				}
			}
			this.label = array.join(",");
			if(!data.itemId){
				this.label = "Wybierz towar";
				this.enabled = false;
			}
		}
		
		[Bindable]
		public var itemId:String;
		
		[Bindable]
		public function set selectedItems(value:Array):void
		{
			_selectedItems = value;
			lotSelector.selectedShifts = _selectedItems;
			updateText();
			updateTotal();
		}
		
		public function get selectedItems():Array
		{
			updateValues();
			return _selectedItems;
		}
		
		private function documentObjectChangeHandler(event:DocumentEvent):void
		{
			selectedItems = data.shifts;
		}
		
		override public function set listData(value:BaseListData):void
		{
			super.listData = value;
			editedPosition = {columnIndex : listData.columnIndex, rowIndex : listData.rowIndex};
			if (value.owner is DataGrid) grid = value.owner as DataGrid;
		}
		 
		override public function set data(value:Object):void{
			super.data = value;
			
			if(value){
				if(value.hasOwnProperty("shifts")){
					selectedItems = value.shifts;
					this.enabled = true;
					if(
						value.documentObject
						&&(value.documentObject as DocumentObject).typeDescriptor.isSalesDocument
						&& ModelLocator.getInstance().dictionaryManager.dictionaries.allWarehouses.(id.toString() ==  value.warehouseId).valuationMethod.toString() == "0"
					)this.enabled = false;
					if(value.documentObject)(value.documentObject as DocumentObject).addEventListener(DocumentEvent.DOCUMENT_LINE_CHANGE,documentObjectChangeHandler);
				}else{
					this.enabled = false;
				}
				if(!value.itemId)this.enabled = false;
			}
		}
	}
}