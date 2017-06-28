package com.makolab.fractus.commands
{
	import com.makolab.fractus.business.Services;
	import com.makolab.fractus.model.ModelLocator;
	
	import flash.net.URLVariables;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.http.HTTPService;
	
	public class PrintDocumentCommand extends FractusCommand
	{
		private var resultFormat:String;
		
		public var params:Object;
		
		public function PrintDocumentCommand(serviceName:String, resultFormat:String)
		{
			this.resultFormat = resultFormat;
			super(serviceName, null);
		}
		
		override public function execute(data:Object = null,addUser:Boolean=true):AsyncToken
		{
			var httpService:HTTPService = new HTTPService();
			if(serviceName)httpService = Services.getInstance().getHTTPService(serviceName);
			var url:String = ModelLocator.getInstance().configManager.values.services_printService_address.* + "/PrintBusinessObject/" + data.id + "/" + data.profileName + "/" + data.outputContentType;
		
			var urlVariables:URLVariables = new URLVariables();
			if (ModelLocator.getInstance().userProfileId != null) urlVariables.userProfileId = ModelLocator.getInstance().userProfileId;
			if (params) for (var i:String in params) urlVariables[i] = String(params[i]);
			
			url += '?' + urlVariables.toString().replace(/%2D/g, '-');
			
			httpService.url = url;
			httpService.resultFormat = this.resultFormat;
			logExecution( { url : url } );
			httpService.send().addResponder(this);
			return null;
		}
	}
}