package com.makolab.components.data
{
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import flash.events.Event;
	import mx.rpc.Fault;

	public class FractusKernelOperation extends AbstractOperation
	{
		public static const FAULT_EXCEPTION:String = "exception";
		public static const FAULT_ILLEGAL_RESPONSE:String = "illegal response";
		public static const FAULT_ILLEGAL_RESPONSE_STRING:String = "Server returned an unhandled response";
		
		private var type : String;				// URL | XMLRPC
		internal var paramMapping : Object = {};	// name - value pairs
		private var url : String;
		
		public function FractusKernelOperation(service:FractusKernelService, url:String, type:String, paramMapping:Object) {
			super(service);
			this.url = url;
			this.type = type.toUpperCase();
			this.paramMapping = paramMapping;
			if (this.type == "XMLRPC")
			{
				if (!paramMapping.hasOwnProperty("object") || !paramMapping.hasOwnProperty("method"))
				{
					throw new Error("Invalid argument: XMLRPC operation must have 'object' and 'method' params provided.");
				}
			}
		}
		
		public override function send(... args) : AsyncToken {
			var params:Object = args[0];
			if (type == "URL")
			{
				return service.urlRequest(url, this, params);
			}
			else if (type == "XMLRPC")
			{
				var httpToken:AsyncToken = service.xmlRpcRequest(url, this, params);
				var token:AsyncToken = new AsyncToken(httpToken.message);
				httpToken.rpcToken = token;
				httpToken.addResponder(new Responder(handleRpcEvent, handleRpcEvent));
				return token;
			}
			else return null;
		}
		
		private function handleRpcEvent(event:Event):void
		{
			var newEvent:Event;
			var token:AsyncToken;
			var rpcToken:AsyncToken;
			if (event is ResultEvent)
			{
				token = (event as ResultEvent).token;
				rpcToken = token.rpcToken;
				var fault:Fault;
				if (token.result.hasOwnProperty("response"))
				{
					newEvent = ResultEvent.createEvent(token.result.response, rpcToken, (event as ResultEvent).message);
				}
				else if (token.result.hasOwnProperty("exception"))
				{
					fault = new Fault(FAULT_EXCEPTION, token.result.exception.description, token.result.exception.toString());
					newEvent = FaultEvent.createEvent(fault, rpcToken, (event as ResultEvent).message);
				}
				else
				{
					fault = new Fault(FAULT_ILLEGAL_RESPONSE, FAULT_ILLEGAL_RESPONSE_STRING, token.result.toString());
					newEvent = FaultEvent.createEvent(fault, rpcToken, (event as ResultEvent).message);
				}
			}
			else if (event is FaultEvent)
			{
				token = (event as FaultEvent).token;
				rpcToken = token.rpcToken;
				newEvent = FaultEvent.createEvent((event as FaultEvent).fault, rpcToken, (event as FaultEvent).message);
			}
			for (var i:String in rpcToken.responders)
			{
				if (newEvent is ResultEvent) rpcToken.responders[i].result(newEvent);
				else rpcToken.responders[i].fault(newEvent);
			}
		}
		
		private function handleRpcFault(event:FaultEvent):void
		{
			this.dispatchEvent(new FaultEvent(FaultEvent.FAULT, false, true, event.fault, event.token["rpcToken"], event.message));
		}

	}
	
}