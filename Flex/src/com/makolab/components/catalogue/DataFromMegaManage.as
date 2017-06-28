package com.makolab.components.catalogue
{
	import mx.collections.ArrayCollection;
	import mx.rpc.http.HTTPService;
	import mx.rpc.Responder;
	import mx.rpc.events.ResultEvent;
	import mx.controls.DataGrid;
	
	
	public class DataFromMegaManage
	{		
		public var rootUrlMegaManage:String;
		public var urlMegaManage:String;
		public var authorizationString:String;
		
		
		[Bindable]
		public var dataResult:ArrayCollection;
		public var httpService:HTTPService;
		
		//funkcja odpowiedzialna za mapowanie wyników
		public var getDataResult:Function;
		
		public function getData(pozycja:String):void
		{
			this.httpService = new HTTPService();
			this.httpService.useProxy = false;
			this.httpService.url = this.rootUrlMegaManage + this.urlMegaManage+"?idMM="+pozycja;
			this.httpService.headers = {"Authorization":this.authorizationString};
		//	this.httpService.headers = {"Authorization":"Basic a29tdW5pa2FjamE6TEB0ZXg="};
			this.httpService.method = "POST";
			this.httpService.send({a:1}).addResponder(new Responder(handleResult, handleFault));		
		}
		
		private function handleResult(event:ResultEvent):void
		{
			this.dataResult=this.getDataResult(event.result);
		}
		
		private function handleFault(error:Object, token:Object=null):void
		{
		}		
	}
}