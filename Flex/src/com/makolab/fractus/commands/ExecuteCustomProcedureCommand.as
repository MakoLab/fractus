package com.makolab.fractus.commands
{
	import com.makolab.components.util.ErrorReport;
	import com.makolab.fractus.model.ModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;

	public class ExecuteCustomProcedureCommand extends FractusCommand
	{
		protected var procedureName:String;
		protected var operationParams:XML;
		protected var setXmlFunction:Function;
		
		public var timeout:Number = NaN;
		
		public function ExecuteCustomProcedureCommand(procedureName:String,params:XML = null,outputFormat:String = "xml")
		{
			this.procedureName = procedureName;
			if(params)operationParams = params;
			super("kernelService", "ExecuteCustomProcedure",outputFormat);
		}
				
		override public function execute(data:Object = null,addUser:Boolean=true):AsyncToken
		{
			if (data is Function) setXmlFunction = data as Function;
			var param:Object = getOperationParams(data);
			var token:AsyncToken;
			
			
			if (operation)
			{
				if(param&&(param as String))
				if((param as String).search("searchParams")!=-1)
				if(ModelLocator.getInstance().sessionManager.userId)
				{
					var str1:String="<searchParams";
					var str:String="<searchParams userId=\""+ModelLocator.getInstance().sessionManager.userId+"\"";
					param=(param as String).replace(str1,str);
				}
				if(param  != null)
				{
					if(param.hasOwnProperty("procedure"))
					{
						procedureName = param.@procedure;
					}
				}
				token = operation.send(procedureName, param, outputFormat); 
				token.addResponder(this);
				
			}
			logExecution({ procedureName : procedureName, param : param});
			return token;
		}

		override protected function getOperationParams(data:Object):Object
		{
			var param:XML = this.operationParams.copy();
			if (!isNaN(this.timeout)) param.@timeout = this.timeout;
			return param.toXMLString();
		}
		
		override protected function resultHandler(event:ResultEvent):void
		{
			super.resultHandler(event);
			if ((targetObject && targetField) || setXmlFunction != null) {
				try
				{
					var resultXML:XML = XML(event.result);
					if (targetObject && targetField) targetObject[targetField] = resultXML;
					else if (setXmlFunction != null) setXmlFunction(resultXML);
				}
				catch (e:Error)
				{
					ErrorReport.showWindow("XML processing error", event.result.toString(), "Report error");
				}
			}
		}

	}
}