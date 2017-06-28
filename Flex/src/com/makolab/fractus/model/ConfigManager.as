package com.makolab.fractus.model
{
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.commands.FractusCommand;
	import com.makolab.fractus.commands.LoadConfigurationCommand;
	
	import flash.utils.describeType;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectProxy;
	
	import xml.DefaultConfiguration;	
			
	public class ConfigManager
	{
		[Bindable]
		public var values:ObjectProxy = new ObjectProxy();
		
		public function requestValue(key:String,refresh:Boolean=false):Boolean
		{
			if (!values.labels_pl) initDefaultValues();
			var k:String = key.replace(/\./g, "_");
			if(!refresh && values[k]) return true;
			loadValue(key);
			return false;
		}
		
		protected function loadValue(key:String):FractusCommand
		{
			var loadConfigCmd:LoadConfigurationCommand = new LoadConfigurationCommand();
			//loadConfigCmd.targetObject = values;
			//loadConfigCmd.targetField = k;
			loadConfigCmd.addEventListener(ResultEvent.RESULT, handleResult);
			loadConfigCmd.execute({key : key});
			return loadConfigCmd;			
		}
		
		private function handleResult(event:ResultEvent):void
		{
			var result:XML = XML(event.result);
			for each (var x:XML in result.configValue)
			{
				var key:String = String(x.@key).replace(/\./g, "_");
				if (key.substr(0, 3) == 'ui_')
				{
					key = key.substr(3);
					values[key] = x.*[0];
				}
				else values[key] = <root>{x}</root>;
			}
			updateCallLaterFunctions(event.target as FractusCommand);
		}
		
		public function loadUiConfig():FractusCommand
		{
			var loadConfigCmd:LoadConfigurationCommand = new LoadConfigurationCommand();
			loadConfigCmd.addEventListener(ResultEvent.RESULT, handleResult);
			loadConfigCmd.execute({key : 'ui.*,itemsSet.set1'});
			return loadConfigCmd;
		}
			
		public function initDefaultValues():void
		{
			var defaultConfig:DefaultConfiguration = new DefaultConfiguration();
			var defaultConfigDesc:XML = describeType(defaultConfig);
			
			for each (var a:XML in defaultConfigDesc..accessor)
			{
				var key:String = String(a.@name);
				if (a.@type == 'XML') values[key] = defaultConfig[key];
			}
		}
		
		public function getValue(key:String):Object
		{
			if (!values.labels_pl) initDefaultValues();
			var keyRep:String = key.replace(/\./g, "_");
			if (!this.values.hasOwnProperty(keyRep)) return null;
			else return this.values[keyRep];
		}
		
		public function getNumber(key:String):Number
		{
			var val:Number = parseFloat(this.getString(key));
			return val;
		}
		
		public function getXML(key:String):XML
		{
			var val:XML = (getValue(key) as XML);
			//url="http://172.18.254.247/LatestBuilds/Proxy/default.aspx"
			if(key=="dashboard___")
			{
val=<config url="http://svn_serv/LatestBuilds/Proxy/default.aspx">
				<panel position='1'>
					<dockPanel type="DashboardDockPanelTurnOver"/>
					<dockPanel type="DashboardDockPanelChat"/>
	           	</panel>	
				<panel position='2'>
					<dockPanel type="DashboardDockPanelFZ"/>
			        <dockPanel type="DashboardDockPanelWZ"/>
				</panel>
				<dashboardConfig>	
				<dashboard percentHeight="50" percentWidth="100" id="dockingPanel1" positionNumber="1"></dashboard>
				<dashboard percentHeight="50" percentWidth="100" id="dockingPanel2" positionNumber="2"></dashboard>
				
				</dashboardConfig>		
</config>
			}
			if (val == null) throw new Error("No XML config value found for key \"" + key + "\"");
			else return val.copy();
		}
		
		public function isAvailable(key:String):Boolean
		{
			return this.getValue(key) != null;
		}
		
		/**
		 * Returns plain XML value without surrounding root/configValue tags.
		 */ 
		public function getXMLValue(key:String):XML
		{
			var result:XML = this.getXML(key);
			if (result.configValue.*.length() == 1) return result.configValue.*[0];
			else return result;
		}
	
		public function getString(key:String):String
		{
			var val:XML = getValue(key) as XML;
			var valStr:String = val ? val.configValue.toString() : null;
			return valStr;
		}
					
		public function getBoolean(key:String):Boolean
		{
			return Tools.parseBoolean(getString(key));
		}
		
		private var callLaterFunctions:ArrayCollection = new ArrayCollection();
		
		public function requestList(keys:Array, callLaterFunction:Function, functionArgs:Array = null, forceRefresh:Boolean = false):void
		{
			var descriptor:Object = { 'keys' : keys, 'callLaterFunction' : callLaterFunction, 'functionArgs' : functionArgs };
			this.callLaterFunctions.addItem(descriptor);
			var allAvailable:Boolean = true;
			if (!forceRefresh) for (var i:String in keys)
			{
				var key:String = String(keys[i]).replace(/\./g, "_");
				if (!this.values.hasOwnProperty(key)) allAvailable = false;
			}
			if (allAvailable && !forceRefresh)
			{
				removeCallLaterFunction(descriptor);
				descriptor.callLaterFunction.apply(null, descriptor.functionArgs);
			}
			else
			{
				descriptor.command = loadValue(keys.join(','));
			}
		}
		
		private function removeCallLaterFunction(descriptor:Object):void
		{
			for (var i:int = 0; i < callLaterFunctions.length; i++)
			{
				if (callLaterFunctions.getItemAt(i) === descriptor)
				{
					callLaterFunctions.removeItemAt(i);
					break;
				}
			}
		}
		
		private function updateCallLaterFunctions(command:FractusCommand):void
		{
			for (var i:String in callLaterFunctions)
			{
				var descriptor:Object = callLaterFunctions[i];
				var allAvailable:Boolean = false;	// true
				if (command == descriptor.command) allAvailable = true;
				/*
				for (var j:String in descriptor.keys)
				{
					if (getValue(descriptor.keys[j]) == null)
					{
						allAvailable = false;
						break;
					} 
				}
				*/
				if (allAvailable)
				{
					removeCallLaterFunction(descriptor);
					descriptor.callLaterFunction.apply(null, descriptor.functionArgs);
				}
			}
		}
		
		public static function reportConfigurationError(text:String,title:String,flags:uint = 4):void
		{
			var showConfigurationAlerts:Boolean = ModelLocator.getInstance().configManager.getBoolean("showConfigurationAlerts");
			if (showConfigurationAlerts)
			{
				Alert.show(text,title,flags);
			}
		}
	
		}
		
	}