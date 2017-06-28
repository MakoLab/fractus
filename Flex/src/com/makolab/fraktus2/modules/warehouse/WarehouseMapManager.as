package com.makolab.fraktus2.modules.warehouse
{
	import assets.IconManager;
	
	import com.makolab.fractus.commands.ExecuteCustomProcedureCommand;
	import com.makolab.fractus.commands.FractusCommand;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.view.warehouse.ShiftTransactionEditor;
	import com.makolab.fraktus2.events.WarehouseEvent;
	
	import flash.events.EventDispatcher;
	
	import mx.containers.Canvas;
	import mx.containers.TitleWindow;
	import mx.core.Container;
	import mx.core.IFlexDisplayObject;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.ModuleEvent;
	import mx.managers.PopUpManager;
	import mx.modules.ModuleLoader;
	import mx.rpc.events.ResultEvent;
	
	
	public class WarehouseMapManager extends EventDispatcher
	{
		
		//==================================== SINGELTON
		
		private static var instance:WarehouseMapManager;
		
		public function WarehouseMapManager()	{
		
			if (instance) throw Error("WarehouseMapManager is singleton. This class can not be instantiated")
		}

		public static function getInstance ():WarehouseMapManager
		{
			instance = (instance)? instance : new WarehouseMapManager();
			return instance; 
		}

		//====================================		
		private var isBusy:Boolean = false;
		private var moduleUrl:String  = "com/makolab/fraktus2/modules/WarehouseModule.swf";
		private var arrListeners:Array = new Array();
		
		//-- parametry podawane z mentoda showMap
		private var displayMode:int;
		private var availableSlots:XMLList = new XMLList();
		private var updateAC:Boolean;
		private var shiftTransactionId:String;	
		private var includeShiftTransactionEditor:Boolean;
		
		
		private var ml:ModuleLoader;				//Modul loader
		private var vm:IWarehouseStructureRenderer;	//Modul zaladowany jako zew SWF
		private var ste:ShiftTransactionEditor;		//Okno przesyniec  
		private var titleWindow:TitleWindow;		//Glowne okno mapy 
		
		
		private var windowParent:Container = ModelLocator.getInstance().applicationObject as Container;			
		
		//============================================== PUBLIC METHODS	
			
		public function closeMap():void
		{
			//trace( "closeMap()");
			titleWindow.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		}	
		
		/**
		* Matoda, ladujaca i pokazywjaca zew modul mapy magazynu
		*
		* @param _windowParent	Zewnetrzny konetener dla TitleWindow mapy. Jesli podawany jest null, to wykorzystany jest domyslny zdefuiniowany w tej kalsie
		* @param _updateAC		Czy ladowac swieze dane (availableSlots) z serwera 
		* @param _displayMode	Ustawienie trybu AVAIABLE = 1 lub OCUPY = 2
		* @param _shiftTransactionId	Parametr przy pobieraniu availableSlots
		* @param _availableSlots	Podanie bezposrednio availableSlots (uzuwac przy _updateAC = false) 
		* @param _includeShiftTransactionEditor	Czy uzywany jest  ShiftTransactionEditor
		* 
		* @return void.
		*/	
		public function showMap (_windowParent:Container, _updateAC:Boolean = false,
								 _displayMode:Number = 1, _shiftTransactionId:String = "",
								 _availableSlots:XMLList = null, 
								 _includeShiftTransactionEditor:Boolean = false):void 
		{	
			//trace("Show MAP");
			this.windowParent = _windowParent ? _windowParent :  ModelLocator.getInstance().applicationObject;
			this.displayMode = _displayMode;
			this.updateAC = _updateAC;
			this.availableSlots = _availableSlots ? _availableSlots : availableSlots;
			this.shiftTransactionId = _shiftTransactionId;
			this.includeShiftTransactionEditor = _includeShiftTransactionEditor;
			showWindow();			
		}

		/**
		* Rejestracja listenerow i ich rejesracja do globalnego usuniecia
		* 
		* @return void.
		*/	
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
		        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		        arrListeners.push({type:type, listener:listener});
		}

		//============================================== PRIVATE METHODS
	
		private  function showWindow():void
		{
			if (!isBusy) isBusy = true; else {trace("BUSY"); return;}
		
			ml = new ModuleLoader();
			ml.percentWidth = 100;
			ml.percentHeight = 100;					
			ml.data = {"thisObj": this}
				 
			ml.addEventListener(ModuleEvent.READY, function (e:ModuleEvent):void {
				
				//trace("Module ready" + ml.child + " ml: " + ml);
				var module:IWarehouseStructureRenderer = IWarehouseStructureRenderer(ml.child);
					module.addEventListener( WarehouseEvent.SLOT_SELECTED, onSlotSelected);
					vm = module;
					rebuildMap();
					createTitleWindow();
			});				
			
			ml.addEventListener(ModuleEvent.ERROR, function (e:ModuleEvent):void { 
				trace("Module error" + e.errorText);
			});
			ml.addEventListener(ModuleEvent.PROGRESS, function (e:ModuleEvent):void {					
				//trace("Module progress" + e.module);
			});
			
			//ml.loadModule(moduleUrl);
			ml.url = moduleUrl;
			ml.loadModule();
		
		}

		private function rebuildMap () :void 
		{
			var warehouseStructure:XML = XML(ModelLocator.getInstance().configManager.getValue('warehouse.warehouseMap'))										
				vm.warehouseStructure = new XML (warehouseStructure.configValue.warehouseMap.toXMLString());											
				vm.displayMode = displayMode;
				
				if (updateAC) loadFreshAvailableContainers(); 
				else vm.availableSlots =  availableSlots; 	
		}


		private function createTitleWindow ():void 
		{				
		
			var canvas:Canvas = new Canvas();
				canvas.percentHeight = 100;
				canvas.percentWidth = 100;
			
				titleWindow = new TitleWindow();
				titleWindow.title = "Zawartość magazynu";				
				titleWindow.showCloseButton = true;					
				titleWindow.addChild(canvas);			
	
				canvas.addChild(ml);
	
				titleWindow.setStyle("headerColors", [IconManager.WAREHOUSE_COLOR, IconManager.WAREHOUSE_COLOR_LIGHT]);
				titleWindow.setStyle("borderAlpha", 0.9);
				titleWindow.showCloseButton = true;
				titleWindow.width = 1020;
				titleWindow.height = 580;
				
				
				titleWindow.addEventListener(FlexEvent.REMOVE,  function (event:FlexEvent):void{
					
					//trace ("titleWindow.addEventListener: FlexEvent.REMOVE");
					removeRegisteredListeners();				
					isBusy = false;
				});			
				titleWindow.addEventListener(CloseEvent.CLOSE, function (event:CloseEvent):void{
					
					ml = null;	vm = null;	ste = null;			
					isBusy = false;	
					dispatchEvent(new CloseEvent(event.type, true));						
					PopUpManager.removePopUp(event.target as IFlexDisplayObject);
				});
				
				PopUpManager.addPopUp(titleWindow as IFlexDisplayObject, windowParent);
				PopUpManager.centerPopUp(titleWindow);
				
				if (includeShiftTransactionEditor) 	createShiftTransactionEditor(canvas);
		}
		
		
		private function createShiftTransactionEditor(shiftWindowParent:Container):void 
		{	
			if (!ste) 
			{
				var tw:TitleWindow = new TitleWindow();
			
				tw.width = 800;
				tw.height = 300;
				tw.x = shiftWindowParent.width -tw.width;
				tw.y = shiftWindowParent.height - tw.height;								
				tw.setStyle("backgroundAlpha", 0.8); 
				tw.showCloseButton = true;
				tw.addEventListener(CloseEvent.CLOSE, function (e:CloseEvent):void {
										
					trace("CloseEvent.CLOSE " + tw.className)
					tw.visible = false;					
				});
				
				ste =  new ShiftTransactionEditor();					
				ste.percentWidth	= 100;
				ste.percentHeight	= 100;
				ste.showFilters		= false;
				ste.skipStartupSearch	= true;				
				ste.shiftAttributeWindowParent = shiftWindowParent				
				
				
				//ste.addEventListener("saveComplete", skipStartupSearch);
				//	<warehouse:ShiftTransactionEditor id="ste" width="100%" height="100%" 
				//		showFilters="false" skipStartupSearch="true" saveComplete="init()" 
				//		shiftAttributeWindowParent="{this}"/>
				
				tw.addChild(ste);
				shiftWindowParent.addChild(tw);
				//PopUpManager.addPopUp(tw, shiftWindowParent, false);
				//PopUpManager.bringToFront(tw);
				
				tw.visible = false;
			}
		}

		
		private function loadFreshAvailableContainers ():void 
		{
		
			var params:XML = <root/>;
				if(shiftTransactionId && shiftTransactionId != "") params.shiftTransactionId = shiftTransactionId;
				var cmd:FractusCommand = new ExecuteCustomProcedureCommand("warehouse.p_getAvailableContainers", params);				
					cmd.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void 
				{
					availableSlots = XML(event.result).*
					vm.availableSlots = availableSlots;
												
				});
			cmd.execute();
		}
		

		private function removeRegisteredListeners():void
		{
		   for(var i:uint = 0; i<arrListeners.length; i++){
		      if(hasEventListener(arrListeners[i].type)){
		         removeEventListener(arrListeners[i].type, arrListeners[i].listener);
		      }
		   }
		   arrListeners = new Array();
		}

		
		//=========================================== LISTENERS
		
		private function onSlotSelected (e:WarehouseEvent):void 
		{
			//trace("WarehouseEvent " + e.slotId )
			if (includeShiftTransactionEditor && ste) 
			{
				ste.parent.visible = true;
				
				var searchParams:XML = <param><containerId>{e.slotId}</containerId></param>;
				ste.searchXml = searchParams;
				ste.search();
			}				
			dispatchEvent(e);	
		}; 


	}
}