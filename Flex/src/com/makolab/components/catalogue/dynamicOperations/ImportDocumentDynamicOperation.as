package com.makolab.components.catalogue.dynamicOperations
{
	import assets.IconManager;
	
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	import com.makolab.fractus.view.documents.documentLists.ImportDocumentOperation;
	
	import flash.net.FileFilter;
	
			
	public class ImportDocumentDynamicOperation extends DynamicOperation
	{
		public var expectedFileType:String = "portaOrder";
		public var documentCategory:uint = DocumentTypeDescriptor.CATEGORY_SALES_ORDER_DOCUMENT;
		public var template:String = "salesOrder";
		public var customLabel:String = LanguageManager.getInstance().labels.documents.importDocument;
		public var customImage:Object = IconManager.getIcon('save_small');
		
		private var fileTypes:Object = {
			portaOrder : [new FileFilter("ZAM","*.zam"),new FileFilter("wszystkie","*.*")],
			portaOrderCsv : [new FileFilter("Pliki excel","*.csv"),new FileFilter(LanguageManager.getInstance().labels.documentFilters.all, "*.*")],
			externalPortaSalesInvoice : [new FileFilter("XML","*.xml"),new FileFilter("wszystkie","*.*")]
		};
		
		public override function loadParameters(operation:XML):void
		{
			if(operation.documentCategory.length() != 0)
				this.documentCategory = operation.documentCategory.*;
				
			if(operation.template.length() != 0)
				this.template = operation.template.*;
				
			if(operation.expectedFileType.length() != 0)
				this.expectedFileType = operation.expectedFileType.*;
				
			if(operation.customLabel.length() != 0)
				this.customLabel = operation.customLabel.*;

			if(operation.customImage.length() != 0)
				this.customImage = operation.customImage.*;				
		}
		
		
		public function ImportDocumentDynamicOperation()
		{
			super();
		}
		
		public override function invokeOperation(operationIndex:int = -1):void
		{
			var ido:ImportDocumentOperation = new ImportDocumentOperation();
			ido.customImage = this.customImage;
			ido.customLabel = this.customLabel
			ido.documentCategory = this.documentCategory;
			ido.expectedFileType = this.expectedFileType;
			ido.template = this.template;
			
			ido.fileLoader.loadFile(ido.fileLoaded,fileTypes[expectedFileType]);
		}
		
		//Konfiguracja w bazie w processes.salesOrder
	}
}