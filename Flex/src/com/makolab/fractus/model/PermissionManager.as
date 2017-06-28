package com.makolab.fractus.model
{
	import com.makolab.fractus.commands.LoadConfigurationCommand;
	
	import flash.utils.Dictionary;
	
	import mx.rpc.events.ResultEvent;
	
	public class PermissionManager
	{
		
		public function PermissionManager()
		{
		}
		
		public static const LEVEL_UNDEFINED:int = -1;
		public static const LEVEL_HIDDEN:int = 0;
		public static const LEVEL_DISABLED:int = 1;
		public static const LEVEL_ENABLED:int = 2;
		
		//public var permissions:XML;
		public var permissionsDict:Dictionary;
		
		public function getPermissionLevel(key:String):int
		{
			if(key)
			{
				var model:ModelLocator = ModelLocator.getInstance();
				var central:Boolean = model.headquarters;
				var debug:Boolean = model.isDebug();
				var parentKey:String = "";
				var keyLevels:Array = key.split(".");
				var separator:String;
				
				switch (key)
				{
					//permission hard coded
					//case 'documents.lists.branchFilter': return central ? LEVEL_ENABLED : LEVEL_HIDDEN;
					//case 'documents.lists.companyFilter': return central ? LEVEL_ENABLED : LEVEL_HIDDEN;
					//case 'documents.lists.warehouseFilter.external': return central ? LEVEL_ENABLED : LEVEL_HIDDEN;
					case 'warehouse.content': 
						return ModelLocator.getInstance().isWmsEnabled ? LEVEL_ENABLED : LEVEL_HIDDEN;
						break
					//case 'administration.warehouseStructure': return central ? LEVEL_ENABLED : LEVEL_HIDDEN;
					case 'tools':
						if (ModelLocator.getInstance().isDebug()) {
							return LEVEL_ENABLED;
						} else {
							return central ? LEVEL_ENABLED : LEVEL_HIDDEN;
						}
						break;
					//case 'diagnostics': return debug ? LEVEL_ENABLED : LEVEL_HIDDEN;
				}
				
				if(permissionsDict[key]) {
					return permissionsDict[key];
				}
				
				/*
				for each(var x:XML in permissions.*) {
					if(x.@key == key) return x.@level;
				}
				*/
				
				for(var i:Number = 0; i < keyLevels.length - 1; i++)	{
					separator = (i > 0) ? "." : "";
					parentKey += separator + keyLevels[i];
				} 
				
				if(parentKey != "") return getPermissionLevel(parentKey);
			}
			return LEVEL_UNDEFINED;
		}
		
		public function loadProfile(profile:String):LoadConfigurationCommand
		{
			var cmd:LoadConfigurationCommand = new LoadConfigurationCommand();
			cmd.addEventListener(ResultEvent.RESULT, handleLoadProfileResult);
			cmd.execute({ key: "permissions.profiles." + profile });
			return cmd;
		}
		
		private function handleLoadProfileResult(event:ResultEvent):void
		{
			var result:XML = XML(event.result);
			
			var permissions:XML = XML(result.configValue.profile.permissions);
			
			permissionsDict = new Dictionary();
			
			for each (var item:XML in permissions.*) {
				permissionsDict[item.@key.toString()] = item.@level.toString();
			}
		}
		
		public function isEnabled(key:String):Boolean
		{
			var level:int = getPermissionLevel(key);
			return level == LEVEL_ENABLED || level == LEVEL_UNDEFINED;
		}
		
		public function isVisible(key:String):Boolean
		{
			return getPermissionLevel(key) != LEVEL_HIDDEN;
		}
		
		public function isHidden(key:String):Boolean
		{
			return getPermissionLevel(key) == LEVEL_HIDDEN;
		}
		
		public function isDisabled(key:String):Boolean
		{
			return getPermissionLevel(key) == LEVEL_DISABLED;
		}
					
	}
}