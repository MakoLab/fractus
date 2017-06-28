package com.makolab.fractus.model
{
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.commands.ExecuteCustomProcedureCommand;
	
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectProxy;
	
	public class CacheDataManager
	{
		public function CacheDataManager(enforcer:SingletonEnforcer)
		{
			if (enforcer == null) throw new Error("You Can Only Have One CacheDataManager");
		}
		
		private static var instance:CacheDataManager;
		
		public static const SALESMEN:String = "salesmen";
		
		public var parametersTemplate:String = null;
		
		private var commandsObject:Object = {};

		public static function getInstance():CacheDataManager
		{			
			if (instance == null) instance = new CacheDataManager(new SingletonEnforcer);
			return instance;
		}
		
		[Bindable]
		public var cacheData:ObjectProxy = new ObjectProxy();
		
		public var requestData:Object = {};
		
		private function loadData(dataSetName:String, procedureName:String, parameters:XML = null,component:Object = null,componentProperty:String = null):void
		{
			if(!parameters)parameters = <root/>;
			var cmd:ExecuteCustomProcedureCommand = new ExecuteCustomProcedureCommand(procedureName,parameters);
			commandsObject[dataSetName] = {command : cmd, component : component, componentProperty : componentProperty};
			cmd.addEventListener(ResultEvent.RESULT,handleCommandResult);
			cmd.execute();
		} 
		
		private function handleCommandResult(event:ResultEvent):void
		{
			for(var s:String in commandsObject){
				if(commandsObject[s].command == event.target){
					cacheData[s] = XML(event.result);
					if(commandsObject[s].component && commandsObject[s].componentProperty)
						commandsObject[s].component[commandsObject[s].componentProperty] = cacheData[s].*;
					delete commandsObject[s];
					break;
				}
			}
		}
		
		public function getData(dataSetName:String,component:Object,componentProperty:String,forceNewRequest:Boolean = false, procedureName:String = null, parameters:Object = null):void
		{
			//requestData["salesmen"] = {procedureName : "contractor.p_getSalesmen", parameters: <root/>};//<root><itemId>{productId}</itemId></root> { productId : '123asdadqweasdasd' }
			if(cacheData[dataSetName] && !forceNewRequest){
				component[componentProperty] = cacheData[dataSetName].*;
			}
			// jakub - pierwszy warunek dosc dziwny ale wprowadzilem go dla zachowania wstecznej kompatybilnosci
			// blokujemy wykonywanie zapytania jezeli wymagane sa parametry a ich nie dostarczono
			else if (!requestData[dataSetName] || !requestData[dataSetName].requireParameters || parameters)
			{
				if(!procedureName)procedureName = (requestData[dataSetName] ? requestData[dataSetName].procedureName : null);
				var parametersXML:XML;
				parametersXML = (requestData[dataSetName] ? XML(Tools.replaceParameters(requestData[dataSetName].parameters,parameters)) : null);
				loadData(dataSetName,procedureName,parametersXML,component,componentProperty);
			}
		}
	}
}

class SingletonEnforcer {}