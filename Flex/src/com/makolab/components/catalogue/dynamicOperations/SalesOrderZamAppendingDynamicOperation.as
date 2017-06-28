package com.makolab.components.catalogue.dynamicOperations
{
	import assets.IconManager;
	
	import com.makolab.components.inputComponents.SalesOrderZamAppendingOperation;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	
	import flash.net.FileFilter;
	
		
	public class SalesOrderZamAppendingDynamicOperation extends DynamicOperation
	{
		public var expectedFileType:String = "portaOrder";
		public var documentCategory:uint = DocumentTypeDescriptor.CATEGORY_SALES_ORDER_DOCUMENT;
		public var template:String = "salesOrder";
		public var customLabel:String = LanguageManager.getInstance().labels.documents.importDocument;
		public var customImage:Object = IconManager.getIcon('save_small');
		private var putService:String="/PutFile";
		private var putServiceAnsi:String="/PutFileAnsi";
		private var fileTypes:Object = {
			portaOrder : [new FileFilter("ZAM","*.zam"),new FileFilter("wszystkie","*.*")],
			portaOrderCsv : [new FileFilter("Pliki excel","*.csv"),new FileFilter(LanguageManager.getInstance().labels.documentFilters.all, "*.*")]
		};
		
		public override function loadParameters(operation:XML):void
		{
			if(operation.documentCategory.length() != 0)
				this.documentCategory = operation.documentCategory.*[0];
				
			if(operation.template.length() != 0)
				this.template = operation.template.*[0];
				
			if(operation.expectedFileType.length() != 0)
				this.expectedFileType = operation.expectedFileType.*[0];
				
			if(operation.customLabel.length() != 0)
				this.customLabel = operation.customLabel.*[0];

			if(operation.customImage.length() != 0)
				this.customImage = operation.customImage.*[0];	
			
		}
		
		
		public function SalesOrderZamAppendingDynamicOperation()
		{
			super();
		}
		
		public override function invokeOperation(operationIndex:int = -1):void
		{
			var appendingOperation:SalesOrderZamAppendingOperation = new SalesOrderZamAppendingOperation();
			appendingOperation.customImage = this.customImage;
			appendingOperation.customLabel = this.customLabel		
			appendingOperation.expectedFileType = this.expectedFileType;
			appendingOperation.documentId = this.panel.documentId;
			appendingOperation.documentType = this.panel.objectType;
			if(this.expectedFileType=="portaOrderCsv")
				appendingOperation.fileLoader.loadFile(
			appendingOperation.fileLoaded,fileTypes[expectedFileType],putServiceAnsi);
				else
				appendingOperation.fileLoader.loadFile(
			appendingOperation.fileLoaded,fileTypes[expectedFileType],putService);
			
		}
		
		//Konfiguracja w bazie w processes.salesOrder
	}
}