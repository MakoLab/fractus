package com.makolab.fractus.commands
{
	import com.makolab.fractus.business.Services;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	
	public class GetCommentsCommand extends FractusCommand
	{
		private var resultFormat:String;
		
		public var params:Object;
		
		public function GetCommentsCommand(serviceName:String)
		{
			
			//this.resultFormat = resultFormat;
			super(serviceName, null);
		}
		
		override public function execute(data:Object = null):AsyncToken
		{
			var service:WebService = Services.getInstance().getWebService("commentsWebService");
			service.loadWSDL('http://svn_serv/RemoteInterface/RemoteInterface.svc?wsdl');
		//	service.loadWSDL('http://demo.fractus.pl/Fractus/F2Motomar/RemoteInterface/RemoteInterface.svc?wsdl');
			service.addEventListener( mx.rpc.events.ResultEvent.RESULT, myfault);
			service.addEventListener( mx.rpc.events.FaultEvent.FAULT, myresult); 
			var token:AsyncToken = service.getOperation("GetComment").send(data);  
			return token;
			
			//return null;
		}
		
		public function myfault(info: mx.rpc.events.ResultEvent):void
		{
			trace(info);
		}
		
		public function myresult(data: mx.rpc.events.FaultEvent):void
		{
			trace(data);
		}
	}
}