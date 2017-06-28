package com.makolab.components.catalogue
{
	import assets.IconManager;
	
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.commands.ShowDocumentEditorCommand;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	import com.makolab.fractus.view.documents.documentControls.ContractorComponent;
	import com.makolab.fractus.view.documents.documentEditors.DocumentEditor;
	
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	import mx.events.MenuEvent;
	import mx.rpc.events.ResultEvent;
	

	public class CreateNewDocumentOperation extends CatalogueOperation
	{
		private var operations:Array = [
			/* {label : "Faktura VAT sprzedaży", template : "invoice", category : DocumentTypeDescriptor.CATEGORY_SALES},
			{label : "Paragon", template : "bill", category : DocumentTypeDescriptor.CATEGORY_SALES},
			{label : "Wydanie zewnętrzne", template : "externalOutcome", category : DocumentTypeDescriptor.CATEGORY_WAREHOUSE},
			{label : "Kasa wyda", template : "cashOutcome", category : DocumentTypeDescriptor.CATEGORY_FINANCIAL_DOCUMENT} */
			];
			
		private var operationsList:XMLList;
		
		private var defaultType:Object;
		
		public function CreateNewDocumentOperation()
		{
			super();
			this.image = IconManager.getIcon("toDocument_small");
			this.extendedOperations = operations;
			//this.label = "Faktura VAT sprzedaży";
		}
		
		public function set configuration(value:XML):void
		{
			for each (var documentType:XML in value.documentType)
			{
				if(ModelLocator.getInstance().permissionManager.isEnabled(documentType.@permissionKey)) {
					var o:Object = {};
					o.label = ModelLocator.getInstance().documentTemplates.*.template.(@id == documentType.@template)[0].@label.toString();
					o.category = documentType.@category;
					if (isNaN(Number(documentType.@category))) o.category = DocumentTypeDescriptor[documentType.category];
					o.template = documentType.@template;
					operations.push(o);
					if (Tools.parseBoolean(documentType.@default))
						defaultType = o;
				}
			}
			if (!defaultType && operations.length > 0) defaultType = operations[0];
			this.label = defaultType.label;
			extendedOperations = operations;
		}
		
		override protected function clickHandler(event:MouseEvent):void
		{
			//popUpButton.open();
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(defaultType.category);
			cmd.template = defaultType.template;
			cmd.addEventListener(ResultEvent.RESULT,commandResult);
			cmd.execute();
		}
		
		override public function handleItemClick(event:MenuEvent):void
		{
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(event.item.category);
			cmd.template = event.item.template;
			cmd.addEventListener(ResultEvent.RESULT,commandResult);
			cmd.execute();
		}
		
		private function commandResult(event:ResultEvent):void
		{
			var editor:DocumentEditor
			if (event.result)
			{
				editor = (event.result as DocumentObject).editor;
				if (editor.documentObject.xml.@disableContractorChange.length() == 0 
					&& editor.documentObject.typeDescriptor.xmlOptions.@contractorOptionality != 'forbidden')
				editor.addEventListener(FlexEvent.CREATION_COMPLETE,documentLoadHandler);
			}
			
		}
		
		private function documentLoadHandler(event:FlexEvent):void
		{
			if ((event.target as DocumentEditor) && (event.target as DocumentEditor).hasOwnProperty("contractorComponent"))
			{
				(event.target["contractorComponent"] as ContractorComponent).setContractorData(itemData.contractor.id.toString());
			}					
		}
		
	}
}