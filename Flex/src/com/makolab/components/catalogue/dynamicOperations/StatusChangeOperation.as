package com.makolab.components.catalogue.dynamicOperations
{
	import com.makolab.fractus.commands.ChangeDocumentStatusCommand;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.GlobalEvent;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	import com.makolab.fractus.view.documents.documentLists.DocumentStatusChangeOperation;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.rpc.events.ResultEvent;
	
	public class StatusChangeOperation extends DynamicOperation
	{
		private var requestedStatus:String;
		private var questionLabelKey:String;
		
		public function StatusChangeOperation(requestedStatus:String)
		{
			super();
			this.requestedStatus = requestedStatus;
		}
		
		public override function loadParameters(operation:XML):void
		{
			if(operation.questionLabelKey.length() > 0)
				this.questionLabelKey = operation.questionLabelKey.*;
		}
		
		public override function invokeOperation(operationIndex:int = -1):void
		{
			var title:String = this.panel.documentXML.number.fullNumber;
			
			var questionLabel:String = null;
			
			Alert.yesLabel = LanguageManager.getLabel("alert.yes");
			Alert.noLabel = LanguageManager.getLabel("alert.no");
			
			if(this.questionLabelKey)
				questionLabel = LanguageManager.getLabel(this.questionLabelKey);
			
			if(this.requestedStatus == DocumentStatusChangeOperation.CANCELLED){
				var attrId:String = DictionaryManager.getInstance().getByName('Attribute_FiscalPrintDate', 'documentAttributes').id;
				var attribute:XMLList = this.panel.documentXML.attributes.attribute.(documentFieldId == attrId);
			
				if(attribute.length() != 0){
					Alert.show(LanguageManager.getInstance().labels.documents.repeatedFiscalDocumentCancellation, '', Alert.YES | Alert.NO, null, confirmFunction, null, Alert.YES);
			 	}
			 	else{
			 		Alert.show(questionLabel ? questionLabel : LanguageManager.getInstance().labels.alert.cancelDocumentQuestion, title, (Alert.YES | Alert.NO), null, confirmFunction);
			 	}
			} 
			else if(this.requestedStatus == DocumentStatusChangeOperation.COMMITED) Alert.show(questionLabel ? questionLabel : LanguageManager.getInstance().labels.alert.commitDocumentQuestion, title, (Alert.YES | Alert.NO), null, confirmFunction);
			else if(this.requestedStatus == DocumentStatusChangeOperation.SAVED) Alert.show(questionLabel ? questionLabel : LanguageManager.getInstance().labels.alert.deleteCommitDocumentQuestion, title, (Alert.YES | Alert.NO), null, confirmFunction);
		}
		
		private function confirmFunction(event:CloseEvent):void
		{
			if(event.detail == Alert.YES)
			{
				var cmd:ChangeDocumentStatusCommand = new ChangeDocumentStatusCommand(this.panel.documentId, this.requestedStatus);
				cmd.addEventListener(ResultEvent.RESULT, cmdResult);
				cmd.execute(this.panel.itemData);
				this.panel.clearSelectionFunction();
			}
		}
		
		protected function cmdResult(event:ResultEvent):void {
			var cmd:ChangeDocumentStatusCommand = (event.target as ChangeDocumentStatusCommand);
			cmd.removeEventListener(ResultEvent.RESULT, cmdResult);
			ModelLocator.getInstance().eventManager.dispatchEvent(new GlobalEvent(GlobalEvent.DOCUMENT_CHANGED, (new DocumentTypeDescriptor(this.panel.itemData.*.documentTypeId[0].toString())).categoryNumber.toString()));
		}
	}
}