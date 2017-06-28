package com.makolab.components.util
{
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;
	
	public class LocalFileLoader
	{
		
		private var printService:String = ModelLocator.getInstance().configManager.getString("services.printService.address");			
		private var fileReference:FileReference = new FileReference();
		private var parentHandler:Function;
		private var putService:String="/PutFile";
		
		public function LocalFileLoader()
		{			
		}

		public function loadFile(parentHendler:Function,filterTypes:Array = null,putService:String="/PutFile" ):void
		{
			this.putService=putService;
			this.parentHandler = parentHendler;
			this.fileReference.addEventListener(Event.SELECT, this.onFileSelect, false, 0, true);
			this.fileReference.browse(filterTypes);
		}
		
		private function onFileSelect(event:Event):void
		{
			var request:URLRequest = new URLRequest(this.printService + putService);
			request.method = "POST";
			request.contentType = "application/binary";
			//request.contentType = "text/xml"; 
			
			this.fileReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, this.uploadComplete, false, 0, true);
			this.fileReference.addEventListener(IOErrorEvent.IO_ERROR, this.uploadError, false, 0, true);
			this.fileReference.upload(request);
		}
		
		private function uploadError(event:IOErrorEvent):void
		{
			Alert.show(LanguageManager.getInstance().labels.common.uploadError);
		}
		
		private function uploadComplete(event:DataEvent):void
		{
			var uploadedFilename:String = event.data;
			
			var request:URLRequest = new URLRequest(this.printService + "/GetFile/" + uploadedFilename);
			//request.contentType = "text/xml"; 
			//request.requestHeaders= new Array(new URLRequestHeader("Content-Type", "text/xml"));
			var urlLoader:URLLoader = new URLLoader(request);
			//urlLoader.dataFormat=URLLoaderDataFormat.BINARY;
			
			urlLoader.addEventListener(Event.COMPLETE, this.downloadComplete, false, 0, true);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, this.uploadError, false, 0, true);
			urlLoader.load(request);
		
		}
		
		private function downloadComplete(event:Event):void
		{
			var ldr:URLLoader = event.currentTarget as URLLoader;
			var fileContent:XML = XML(ldr.data);
			var fileName:String = this.fileReference.name;
			
/**
* 
*/
			parentHandler.call(this, fileContent, fileName);
		}

	}
}