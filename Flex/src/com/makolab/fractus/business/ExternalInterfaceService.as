package com.makolab.fractus.business
{
	import com.makolab.fractus.model.ModelLocator;
	
	import flash.external.ExternalInterface;
	
	import mx.core.mx_internal;
	import mx.managers.CursorManager;
	import mx.messaging.messages.AbstractMessage;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AbstractService;
	import mx.rpc.AsyncToken;
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.UIDUtil;
	
	use namespace mx_internal;

	public class ExternalInterfaceService extends AbstractService
	{
		public var functionName:String = "eval";
		public var operationNamePrefix:String = "";
		
		protected var pendingTokens:Object = {};
		
		public function ExternalInterfaceService(destination:String=null)
		{
			super(destination);
			ExternalInterface.addCallback("asyncResponse", handleAsyncResponse);
			ExternalInterface.addCallback("asyncErrorResponse", handleAsyncErrorResponse);
		}
		
		public override function getOperation(name:String):AbstractOperation
		{
			var operation:AbstractOperation = super.getOperation(name);
			if (!operation)
			{
				operations[name] = new ExternalInterfaceOperation(this, name);
				operation = super.getOperation(name);
			}
			return operation;
		}
		
		private function escapeString(input:String):String
		{
			return input.replace(/\\/g, "\\\\").replace(new RegExp("'", "g"), "\\'").replace(/\n/g, "\\n").replace(/\r/g, "\\r").replace(/([\x00-\x19])/g, "");
		}
		
		public function execute(operation:AbstractOperation, params:Array):AsyncToken
		{
			var token:AsyncToken = new AsyncToken(new AbstractMessage());
			var uid:String = UIDUtil.createUID();
			var args:Array = [];
			//for (var i:String in params) args.push("'" + String(params[i]).replace(new RegExp("'", "g"), "\\\\'").replace(/\n/g, "\\\\n").replace(/\r/g, "\\\\r") + "'");
			//var cmd:String = operationNamePrefix + operation.name + "(" + args.join(", ") + ")";
			pendingTokens[uid] = { token : token, operation : operation };
			var param:String = null, param2:String = null;
			if (params.length > 0 && params[0] != null) param = escapeString(String(params[0]));
			if (params.length > 1 && params[1] != null) param2 = escapeString(String(params[1]));

			ExternalInterface.call(functionName, uid, operation.name, param, param2);
			if(!ModelLocator.getInstance().isDashboard)
			CursorManager.setBusyCursor();
			
			return token;
		}
		
		public function handleAsyncErrorResponse(uid:String, fault:String):void
		{
			var pt:Object = pendingTokens[uid];
			if (!pt) return;
			var faultEvent:FaultEvent = FaultEvent.createEvent(new Fault('', fault), pt.token);
			pt.operation.dispatchRpcEvent(faultEvent);
			delete pendingTokens[uid];
			CursorManager.removeBusyCursor();
		}
		
		public function handleAsyncResponse(uid:String, result:String):void
		{
			var pt:Object = pendingTokens[uid];
			if (!pt) return;
			var resultEvent:ResultEvent = ResultEvent.createEvent(result, pt.token);
			pt.operation.dispatchRpcEvent(resultEvent);
			delete pendingTokens[uid];
			CursorManager.removeBusyCursor();
		}
		/*
		public function _execute(token:AsyncToken, operation:AbstractOperation, params:Array):void
		{
			var args:Array = [];
			for (var i:String in params) args.push("'" + String(params[i]).replace(new RegExp("'", "g"), "\\\\'").replace(/\n/g, "\\\\n").replace(/\r/g, "\\\\r") + "'");
			var cmd:String = operationNamePrefix + operation.name + "(" + args.join(", ") + ")";
			ExternalInterface.marshallExceptions = true;
			try
			{
				//var result:Object = 
			}
			catch(e:Error)
			{
				var faultEvent:FaultEvent = FaultEvent.createEvent(new Fault(String(e.errorID), e.name, e.message), token);
				operation.dispatchRpcEvent(faultEvent);
			}
			var resultEvent:ResultEvent = ResultEvent.createEvent(result, token);
			operation.dispatchRpcEvent(resultEvent);
		}
		*/
	}
}