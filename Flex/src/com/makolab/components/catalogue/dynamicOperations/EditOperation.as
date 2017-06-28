package com.makolab.components.catalogue.dynamicOperations
{
	import com.makolab.fractus.commands.ShowDocumentEditorCommand;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	public class EditOperation extends PreviewOperation
	{
		public var simple:Boolean = false;
	
		public override function invokeOperation(operationIndex:int = -1):void
		{
			var typeDescriptor:DocumentTypeDescriptor = this.panel.documentTypeDescriptor;
			
			var id:String = this.panel.documentId;
			var category:uint = typeDescriptor.categoryNumber
			
			var askQuestion:Boolean = false;
			
			if(typeDescriptor.getDefaultFiscalPrintProfile() != "")
			{
				//sprawdzamy jakie jest id atrybutu z fiskalizacja
				var attrId:String = DictionaryManager.getInstance().getByName('Attribute_FiscalPrintDate', 'documentAttributes').id;
				
				var attribute:XMLList = this.panel.documentXML.attributes.attribute.(documentFieldId == attrId);
				
				if(attribute.length() != 0)
					askQuestion = true;					
			}
			
			if(!askQuestion)
				this.showDocumentEditor(category, this.simple ? ShowDocumentEditorCommand.EDITOR_SIMPLE : ShowDocumentEditorCommand.EDITOR_ADVANCED, id);
			else
			{
				Alert.yesLabel = LanguageManager.getLabel("alert.yes");
		 		Alert.noLabel = LanguageManager.getLabel("alert.no");
		 		var alert:Alert = Alert.show(LanguageManager.getLabel("documents.repeatedFiscalDocumentEdition"), '', Alert.YES | Alert.NO, null, fiscalizedDocumentEditionQuestionHandler, null, Alert.YES);
		 		alert.data = {'id' : id, 'category' : category, 'editorType' : (this.simple ? ShowDocumentEditorCommand.EDITOR_SIMPLE : ShowDocumentEditorCommand.EDITOR_ADVANCED)};
			}
		}
		
		private function fiscalizedDocumentEditionQuestionHandler(event:CloseEvent):void
	 	{
	 		if(event.detail == Alert.YES)
	 			this.showDocumentEditor(event.target.data['category'], event.target.data['editorType'], event.target.data['id']);
	 	}
		
		private function showDocumentEditor(category:uint, editorType:int, id:String):void
		{
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(category);
			cmd.documentId = id;
			cmd.editorType = editorType;
			cmd.execute();
		}
	}
}