package com.makolab.fractus.view.warehouse
{
	import assets.IconManager;
	
	import com.makolab.fractus.model.ModelLocator;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.containers.TabNavigator;
	import mx.containers.TitleWindow;
	import mx.containers.VBox;
	import mx.core.IFlexDisplayObject;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;

	[Event(name="slotClick", type="flash.events.Event")]
	public class WarehouseStructureWindow extends TabNavigator implements IWarehouseStructureRenderer
	{
		public function WarehouseStructureWindow()
		{
			super();
		}
		
		private var loaders:Array;
		
		public function set components(value:Object):void
		{
			loaders = [];
			for each (var component:Object in value)
			{
				var componentTitle:String = component.title;
				var componentName:String = component.source;
				var loader:WarehouseStructureRendererWrapper = new WarehouseStructureRendererWrapper();
				loader.source = componentName + ".swf";
				loader.percentWidth = 100;
				loader.percentHeight = 100;
				var container:VBox = new VBox();
				container.percentWidth = 100;
				container.percentHeight = 100;
				container.addChild(loader);
				container.label = componentTitle;
				this.addChild(container);
				loaders.push(loader);
				if (this._warehouseStructure) loader.warehouseStructure = this._warehouseStructure;
				if (this._availableSlots) loader.availableSlots = this._availableSlots;
				if (this._highlightedSlots) loader.highlightedSlots = this._highlightedSlots;
			}
		}
		
		private var _warehouseStructure:XML;			
		public function set warehouseStructure(value:XML):void
		{
			this._warehouseStructure = value;
			for each (var loader:WarehouseStructureRendererWrapper in loaders) loader.warehouseStructure = this._warehouseStructure;
		}
		public function get warehouseStructure():XML
		{
			return this._warehouseStructure;
		}
		
		private var _availableSlots:XMLList;
		public function set availableSlots(value:XMLList):void
		{
			this._availableSlots = value;
			for each (var loader:WarehouseStructureRendererWrapper in loaders) loader.availableSlots = this._availableSlots;
		}
		public function get availableSlots():XMLList
		{
			return this._availableSlots;
		}
		
		private var _highlightedSlots:Array;
		public function set highlightedSlots(value:Array):void
		{
			this._highlightedSlots = value;
			for each (var loader:WarehouseStructureRendererWrapper in loaders) loader.highlightedSlots = this._highlightedSlots;
		}
		public function get highlightedSlots():Array
		{
			return _highlightedSlots;
		}
		
		public static function showWindow(listener:Function = null,shiftTransactionId:String = null):TitleWindow
		{
			/*
			var wsw:WarehouseStructureWindow = new WarehouseStructureWindow();
			wsw.components = [{title : 'Mapa magazynu', source : 'warehouseMap'}];
			wsw.warehouseStructure = ModelLocator.getInstance().configManager.getValue("warehouse.warehouseMap") as XML;
			wsw.width = 1000;
			wsw.height = 590;
			*/
			/*
			var wsw:WarehouseMap = new WarehouseMap();
			wsw.warehouseStructure = ModelLocator.getInstance().configManager.getValue("warehouse.warehouseMap") as XML;
			wsw.width = 1000;
			wsw.height = 590;
			wsw.addEventListener("slotClick", listener);
			*/
			//return ComponentWindow.showWindow(wsw, 0, new Rectangle(-1, -1, 1100, 650), "Struktura magazynu");

			/* var cmd:FractusCommand = new ExecuteCustomProcedureCommand("warehouse.p_getAvailableContainers", <root/>);
			cmd.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void { wsw.availableSlots = XML(event.result).*});
			cmd.execute(); */
			
			var wci:WarehouseContentInfo = new WarehouseContentInfo();
			wci.addEventListener("slotClick", listener);
			wci.shiftTransactionId = shiftTransactionId;
			wci.width = 1000;
			wci.height = 590;
			
			var window:TitleWindow = new TitleWindow();
			//window.width = 1010;
			//window.height = 590;
			window.title = "Mapa magazynu";
			window.setStyle("headerColors", [IconManager.WAREHOUSE_COLOR, IconManager.WAREHOUSE_COLOR_LIGHT]);
			window.setStyle("borderAlpha", 0.9);
			window.addChild(wci);
			window.showCloseButton = true;
			window.addEventListener(CloseEvent.CLOSE, closeHandler);
			PopUpManager.addPopUp(window as IFlexDisplayObject, ModelLocator.getInstance().applicationObject as DisplayObject,true);
			PopUpManager.centerPopUp(window);
			return window;
			
		}
		
		public static function show(source:Array):void
		{
			var dataProvider:XMLList = new XMLList();
			var container:XML = <container/>; 
			for (var i:int=0;i<source.length;i++){
				if(source[i].valueOf().@containerId.length() > 0){
					container.@id = source[i].@containerId;
					container.@quantity = source[i].@quantity;
					container.@available = 3;
					dataProvider = dataProvider + container.copy();
				}
			}
			var wsw:WarehouseMap = new WarehouseMap();
			wsw.displayMode = WarehouseMap.DISPLAY_MODE_OCCUPIED;
			wsw.warehouseStructure = ModelLocator.getInstance().configManager.getValue("warehouse.warehouseMap") as XML;
			wsw.availableSlots = dataProvider;
			wsw.width = 1000;
			wsw.height = 590;
			
			var window:TitleWindow = new TitleWindow();
			window.width = 1010;
			window.height = 580;
			window.title = "Mapa magazynu";
			window.setStyle("headerColors", [IconManager.WAREHOUSE_COLOR, IconManager.WAREHOUSE_COLOR_LIGHT]);
			window.setStyle("borderAlpha", 0.9);
			window.addChild(wsw);
			window.showCloseButton = true;
			window.addEventListener(CloseEvent.CLOSE, closeHandler);
			PopUpManager.addPopUp(window as IFlexDisplayObject, ModelLocator.getInstance().applicationObject as DisplayObject);
			PopUpManager.centerPopUp(window);
		}
		
		private static function closeHandler(event:CloseEvent):void
		{
			PopUpManager.removePopUp(event.target as IFlexDisplayObject);
		}

	}
}