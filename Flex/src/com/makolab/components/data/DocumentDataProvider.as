package data
{
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;
	import flash.events.MouseEvent;
	import mx.collections.ICollectionView;
	import mx.controls.DataGrid;
	
	public class DocumentDataProvider
	{
		private var http:HTTPService = new HTTPService();
		
		[Bindable]
		public var documentXML:XML;
		
		public function loadDocument() : void
		{
			http.url = "document.xml";
			http.addEventListener("result", this.documentLoaded);
			http.resultFormat = "e4x";
			http.send()
		}
		
		private function documentLoaded(event:ResultEvent):void
		{
			//trace(http.lastResult);
			documentXML = XML(http.lastResult);
			//list = document.SalesDocument.Lines.Line;
			//trace("cur " + documentXML.Currency.name());
		}
		
		public function listClick(event:MouseEvent):void
		{
			//trace(documentXML);
			documentXML.Lines.Line[0].LineNet = 666;
			//document.SalesDocument.Lines.Line[0].LineNet = 666;
			
			
		}
		
	}
}