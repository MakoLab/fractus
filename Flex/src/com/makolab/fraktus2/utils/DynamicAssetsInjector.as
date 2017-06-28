package  com.makolab.fraktus2.utils
{
	import com.makolab.fraktus2.modules.assets.DefaultIconAssets;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;
	
	import mx.events.ModuleEvent;
	import mx.modules.IModuleInfo;
	import mx.modules.Module;
	import mx.modules.ModuleManager;
	/**
	 * ...
	 * @author Wojciech Asztemborski
	 */
	[Event(name="ASSETS_READY", type="mx.events.ModuleEvent")]
	public class DynamicAssetsInjector extends EventDispatcher
	{
		
		[Bindable]
		public static var currentIconAssetClassRef:Class = DefaultIconAssets;
		
		//[Bindable]
		//public static var currentImagesAssetClassRef:Class = DefaultImagesAssets;
		
		
		private static var loader:Loader
		
		private var info:IModuleInfo; 		// Przypisuję obiekt info, aby niz zjad Garbadge Collecort (to jest fix)
		private var m:Module = new Module();
		
		
		public function reloadAssetsClass(swfUrl:String):void {

		
			info = ModuleManager.getModule(swfUrl);
			
			info.addEventListener(ModuleEvent.READY, function (e:ModuleEvent):void 
			{	 
				
				var wrapperIconAssetClass:Class = 	ApplicationDomain.currentDomain.getDefinition("com.makolab.fraktus2.modules.assets.IconAssets") as Class;
				currentIconAssetClassRef = wrapperIconAssetClass;
				dispatchEvent(new Event("ASSETS_READY", true));
			});
			
			info.addEventListener(ModuleEvent.PROGRESS, function (e:ModuleEvent):void 
			{
				//trace("Module progress" + e.module);
			});
			
			info.addEventListener(ModuleEvent.ERROR, function (e:ModuleEvent):void 
			{
				trace("Module error: " + e.errorText);
			});		
			
			
			info.addEventListener(ModuleEvent.UNLOAD, function (e:ModuleEvent):void 
			{
				//trace("unload: "+ e.module);
			});
			
			info.addEventListener(ModuleEvent.SETUP, function (e:ModuleEvent):void 
			{
				//trace("setup")	 
			});
						
			info.load(ApplicationDomain.currentDomain);
		}		
		
	}

}