package com.makolab.components.inputComponents
{
	import mx.controls.TextInput;
	import flash.events.KeyboardEvent;
	import mx.events.FlexEvent;
	import mx.containers.Panel;
	import catalogue.CatalogueBrowser;
	import catalogue.CatalogueOperationEvent;
	import catalogue.CatalogueOperation;
	import mx.controls.listClasses.BaseListData;

	public class CatalogueInput extends TextInput
	{
		public static const SELECT_ITEM_OPERATION:String = "selectItem";
		
		public var showCatalogueFunction:Function;
		public var hideCatalogueFunction:Function;
		public var catalogueBrowser:CatalogueBrowser;
		
		private var itemName:String;
		
		public function get value():String
		{
			return itemName;
		}
		
		public override function set listData(value:BaseListData):void
		{
			super.listData = value;
			itemName = value.label;
			//trace("set list data: " + itemName);
		}
		
		public var selectItemFunction:Function;
		
		private var previousOperationVisibility:Boolean;
		
		public function CatalogueInput()
		{
			super();
			addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		protected override function keyDownHandler(event:KeyboardEvent):void
		{
			if (event.keyCode == 13)
			{
				if (showCatalogueFunction != null) showCatalogueFunction();
				if (catalogueBrowser)
				{
					catalogueBrowser.initSearch(text);
					text = "";
					catalogueBrowser.addEventListener(CatalogueOperationEvent.OPERATION_INVOKE, operationInvokeHandler);
					var operation:CatalogueOperation = catalogueBrowser.getOperation(SELECT_ITEM_OPERATION);
					if (operation)
					{
						previousOperationVisibility = operation.visible;
						operation.visible = true;
						catalogueBrowser.setDefaultOperation(SELECT_ITEM_OPERATION);
					}
				}
				event.stopImmediatePropagation();
			}
		}
		
		private function operationInvokeHandler(event:CatalogueOperationEvent):void
		{
			var operation:CatalogueOperation = event.operation;
			if (operation.operationId == SELECT_ITEM_OPERATION)
			{
				if (hideCatalogueFunction != null) hideCatalogueFunction();
				catalogueBrowser.removeEventListener(CatalogueOperationEvent.OPERATION_INVOKE, operationInvokeHandler);
				operation.visible = previousOperationVisibility;
				selectItemFunction(event.itemData, data);
				this.setFocus();
			}
		}
		
	}
}