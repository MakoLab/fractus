package com.makolab.fractus.commands
{
	import com.makolab.fractus.business.Services;
	import com.makolab.fractus.model.ModelLocator;
	
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	
	import mx.rpc.http.HTTPService;
	
	public class PrintDocumentCommandParcel extends FractusCommand
	{
		private var resultFormat:String;
		
		public var params:Object;
		
		public function PrintDocumentCommandParcel(serviceName:String, resultFormat:String)
		{
			this.resultFormat = resultFormat;
			super(serviceName, null);
		}
		
		public function exportObject(data:Object = null,useJavaScript:Boolean = false):void
		{
		
			var url:String = ModelLocator.getInstance().configManager.values.services_printService_address.* + "/PrintParcelOrder/" + data.id + "/" + data.profileName ;
		
			var urlVariables:URLVariables = new URLVariables();
			if (ModelLocator.getInstance().userProfileId != null) urlVariables.userProfileId = ModelLocator.getInstance().userProfileId;
			if (params) for (var i:String in params) urlVariables[i] = String(params[i]);
			
			url += '?' + urlVariables.toString().replace(/%2D/g, '-');
			
			if (!useJavaScript)
				{
					var u:URLRequest = new URLRequest(url);
					u.method = URLRequestMethod.GET;
					navigateToURL(u,"_blank");
				}
				else ExternalInterface.call("openUrl", url);
			
		}
	}
}