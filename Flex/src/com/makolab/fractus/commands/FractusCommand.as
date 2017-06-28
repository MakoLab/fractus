package com.makolab.fractus.commands
{
	import com.makolab.fractus.business.Services;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.view.diagnostics.CommandExecutionLog;
	import com.makolab.fractus.vo.ErrorVO;
	
	import flash.events.EventDispatcher;
	
	import mx.rpc.AbstractOperation;
	import mx.rpc.AbstractService;
	import mx.rpc.AsyncToken;
	import mx.rpc.Fault;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	[Event(name="result", type="mx.rpc.events.ResultEvent")]
	[Event(name="fault", type="mx.rpc.events.ResultEvent")]
	public class FractusCommand extends EventDispatcher implements IResponder
	{
		protected var serviceName:String;
		protected var operationName:String;
		protected var outputFormat:String;
		
		public var nextCommand:FractusCommand;
		public var nextCommandArgument:Object;
		
		public var targetObject:Object;
		public var targetField:String;
		public var sourceNode:String;
		
		public var defaultErrorHandling:Boolean = true;
		
		protected var replaceNewline:Boolean = false;
		
		public function FractusCommand(serviceName:String = null, operationName:String = null, outputFormat:String = "xml")
		{
			this.serviceName = serviceName;
			this.operationName = operationName;
			this.outputFormat = outputFormat;
			addEventListener(ResultEvent.RESULT, resultHandler);
		}

		public function execute(data:Object = null,addUser:Boolean=true):AsyncToken
		{
			var param:Object = getOperationParams(data);
			
			var t:AsyncToken;
			if (operation) { 
				
				if(param&&param.search("searchParams")!=-1)
				if(ModelLocator.getInstance().sessionManager.userId&&addUser)
				{
					var str1:String="<searchParams";
					var str:String="<searchParams userId=\""+ModelLocator.getInstance().sessionManager.userId+"\"";
					param=(param as String).replace(str1,str);
				}
			logExecution({param : param});
			t = operation.send(param,outputFormat, outputFormat);
			t.addResponder(this);
			}
			return t;
		}
		
		public function cancel(messageId:String):void
		{
			if (operation) operation.cancel(messageId);
		}
		
		protected function getOperationParams(data:Object):Object
		{
			if (data == null) return null;
			else return String(data);
		}
		
		public function result(data:Object):void
		{
			var result:Object;
			if (replaceNewline) result = String(data.result).replace(/\r\n/g, '\n');
			else result = data.result;
			logResult(result);
			dispatchEvent(ResultEvent.createEvent(result));
			if (nextCommand) nextCommand.execute(nextCommandArgument);
		}
		
		protected function resultHandler(event:ResultEvent):void
		{
			if (targetObject && targetField)
			{
				var xml:Object = String(event.result).replace(/<\?.*\?>/, '');
				xml = XML(xml);
				if (sourceNode) targetObject[targetField] = xml[sourceNode][0];
				else targetObject[targetField] = xml;
			}			
		}
		
		public function fault(info:Object):void
		{
			//trace("fault: " + info.fault);
			logResult(info.fault);
			// Nie wyswietlamy bledu zwiazanego z blednie zakodowanym soap'em.
			// ... tak TEGO bledu.
			if ((info as FaultEvent).fault.faultCode == "DecodingError") return;
			
			var error:ErrorVO = ErrorVO.createFromFault(info.fault as Fault);
			if (defaultErrorHandling) ModelLocator.getInstance().errorManager.handleError(error);
			this.dispatchEvent(FaultEvent.createEvent(info.fault as Fault));
		}
				
		protected function get operation():AbstractOperation
		{
			return operationName && service ? service.getOperation(operationName) : null;
		}
		
		protected function get service():AbstractService
		{
			return Services.getInstance().getKernelService();
		}
		
		protected function logExecution(params:Object):void
		{
			if (CommandExecutionLog.instance) CommandExecutionLog.instance.logCommand(this.operationName, params, this);
		}
		
		protected function logResult(result:Object):void
		{
			if (CommandExecutionLog.instance) CommandExecutionLog.instance.setResult(this, result);
		}
	}
}