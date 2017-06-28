package com.makolab.fractus.commands
{
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.view.ComponentWindow;
	
	import mx.core.UIComponent;
	import mx.rpc.events.ResultEvent;
	
	public class ShowCatalogueCommand extends FractusCommand
	{
		public static const CATALOGUE_CONTRACTORS:int = 1;
		public static const CATALOGUE_ITEMS:int = 2;
		
		public var catalogueType:int;
		
		public function ShowCatalogueCommand()
		{
			
		}
		
		override public function execute(data:Object = null):Object
		{
			logExecution(null);
			var catalogue:UIComponent;
			if (catalogueType = CATALOGUE_CONTRACTORS) catalogue = new ContractorsCatalogue();
			else if (catalogueType = CATALOGUE_ITEMS) catalogue = new ItemsCatalogue();
			var window:ComponentWindow = ComponentWindow.showWindow(catalogue);
			window.commitFunction = editor.saveDocument;
		}
		
		private function handleCommandResult(event:ResultEvent):void
		{
			var documentObject:DocumentObject = new DocumentObject();
			documentObject.loadXML(XML(event.result).commercialDocument[0]);
			showEditor(documentObject);
			dispatchEvent(ResultEvent.createEvent(documentObject));
		}

		private function showEditor(documentObject:DocumentObject):void
		{

		}
	}
}