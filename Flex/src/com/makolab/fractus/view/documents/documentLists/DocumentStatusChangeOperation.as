package com.makolab.fractus.view.documents.documentLists
{
	import assets.IconManager;
	
	import com.makolab.components.catalogue.CatalogueEvent;
	import com.makolab.components.catalogue.CatalogueOperation;
	import com.makolab.fractus.commands.ChangeDocumentStatusCommand;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.GlobalEvent;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.rpc.events.ResultEvent;

	public class DocumentStatusChangeOperation extends CatalogueOperation
	{
		public function DocumentStatusChangeOperation()
		{
			super();
		}
		
		public static const CANCELLED:String = "-20";
		public static const COMMITED:String = "40";
		public static const SAVED:String = "20";
		public static const BOOKED:String = "60";
		private var _status:String = "";
		
		[Bindable]
		public function set status(value:String):void
		{
			_status = value;
			switch(value){
				case CANCELLED:
					this.operationId = "operationCancelDocument";
					this.image = IconManager.getIcon('status_canceled');
					if(!label)label = LanguageManager.getInstance().labels.documents.cancel;
					break;
				case COMMITED:
					this.operationId = "operationCommitDocument";
					this.image = IconManager.getIcon('status_commited');
					if(!label)label = LanguageManager.getInstance().labels.documents.commit;
					break;
				case SAVED:
					this.operationId = "operationSaveDocument";
					this.image = IconManager.getIcon('status_saved');
					if(!label)label = LanguageManager.getInstance().labels.documents.save;
					break;
				case BOOKED:
					this.operationId = "operationBookDocument";
					this.image = IconManager.getIcon('status_booked');
					if(!label)label = LanguageManager.getInstance().labels.documents.book;
					break;
			}
			enableFunction();
			this.addEventListener(CatalogueEvent.OPERATION_INVOKE,operationInvoke);
		}
		
		public function get status():String
		{
			return _status;
		}
		
		private var lastItemData:Object;
		
		override public function set itemData(val:Object):void
		{
			super.itemData = val;
			if (val != null && String(val)) lastItemData = val;
			this.enabled = model.permissionManager.isEnabled(permissionKey);
			if(model.permissionManager.isHidden(permissionKey))
				this.includeInLayout = false;
				
			if(val is XML)
				var typeDescriptor:DocumentTypeDescriptor = new DocumentTypeDescriptor(val.*.documentTypeId);
					
			if(this.enabled)	{
					enableFunction();
				if(typeDescriptor)
				if(typeDescriptor.isFinancialDocument)
						{
							if(typeDescriptor.symbol!="KP"&&typeDescriptor.symbol!="KW")
							{	
								//hard text
								if(!model.permissionManager.isEnabled(permissionKey+"nf"))
									{
										this.enabled = false;
										//hard text
										toolTip = "Nie można anulować dokumentu finansowego niegotówkowego";
									}
							}
						}			
			
			}
			else
					{
						// QLA hardtext
						if(typeDescriptor)
						if(typeDescriptor.isFinancialDocument&&!this.enabled)
						{
							if(model.permissionManager.isEnabled(permissionKey+"nf"))
							{
							
								if(typeDescriptor.symbol!="KP"&&typeDescriptor.symbol!="KW")
								{//hard text
									
									enableFunction();
											this.enabled = true;
										
								}
							}
						}
					}
		}
		
		private function enableFunction():void
		{
			if(itemData && itemData.*.documentTypeId.*.length() > 0){
				var typeDesc:DocumentTypeDescriptor = new DocumentTypeDescriptor(itemData.*.documentTypeId.*[0].toString()); 
				var docStatus:String = itemData.*.status.*.toString();
				
				var hasCorrections:Boolean = false;
				toolTip = null;
				
				if(itemData.*.@disableDocumentChange.length() > 0 && 
					String(itemData.*.@disableDocumentChange).indexOf("documents.messages.disableDocumentChange.relatedCorrectiveDocuments") >= 0)
				{
					hasCorrections = true;
					
					if(this.status == CANCELLED)
						toolTip = LanguageManager.getLabel("documents.messages.disableDocumentChange.relatedCorrectiveDocuments");
				}
				
				var hasBillToInvoiceRelation:Boolean = false;
				var isBill:Boolean = false;
				
				if(itemData.*.relations.relation.(relationType == "1").length())
				{
					hasBillToInvoiceRelation = true;
					
					if(typeDesc.xmlOptions.@invoiceAppendable.length() > 0 &&
						typeDesc.xmlOptions.@invoiceAppendable != "")
						isBill = true;
				}
				
				
				if(typeDesc.isShiftDocument){
					var oppositeDocFieldId:String = DictionaryManager.getInstance().dictionaries.documentFields.(name.* == "ShiftDocumentAttribute_OppositeDocumentStatus").id.*;
					var attribute:XMLList = itemData.*.attributes.attribute.(documentFieldId.* == oppositeDocFieldId);
					var oppositeDocStatus:String = "";
					if(attribute.length())oppositeDocStatus = attribute[0].value.*.toString();
					this.enabled = false;
					
					if(typeDesc.isWarehouseIncome)
					{
						if(status == COMMITED && docStatus == SAVED && oppositeDocStatus == COMMITED && !hasCorrections)this.enabled = true;
						if(status == CANCELLED && docStatus == SAVED && oppositeDocStatus == COMMITED && !hasCorrections)this.enabled = true;
					}
					if(typeDesc.isWarehouseOutcome)
					{
						if(status == CANCELLED && docStatus == SAVED && oppositeDocStatus == "" && !hasCorrections)this.enabled = true;
						if(status == CANCELLED && docStatus == COMMITED && oppositeDocStatus == CANCELLED && !hasCorrections)this.enabled = true;
						if(status == CANCELLED && docStatus == COMMITED && oppositeDocStatus == CANCELLED && !hasCorrections)this.enabled = true;
					}
				} else if(hasBillToInvoiceRelation) {
					this.enabled = false;
					
					if(isBill)
						this.toolTip = LanguageManager.getLabel("documents.options.receiptHasInvoice");
					else
						this.toolTip = LanguageManager.getLabel("documents.options.invoiceHasReceipt");
				} else if(typeDesc.isInventoryDocument) {
						this.enabled = false;
						if(status == CANCELLED && docStatus == SAVED)this.enabled = true;
						if(status == COMMITED && docStatus == SAVED)this.enabled = true;
				} else {
					this.enabled = false;
					if(status == CANCELLED && docStatus == COMMITED && !hasCorrections)this.enabled = true;
					if(status == COMMITED && docStatus == SAVED && !hasCorrections)this.enabled = true;
				}
			} else {
				this.enabled = false;
			}
		}
		
		private function operationInvoke(event:CatalogueEvent):void
		{
			event.deselectItem = true;
			var title:String = lastItemData.*.number.fullNumber;
			if(status == CANCELLED) {
				
				var attrId:String = DictionaryManager.getInstance().getByName('Attribute_FiscalPrintDate', 'documentAttributes').id;
				var attribute:XMLList = event.itemData.*.attributes.attribute.(documentFieldId == attrId);
			
				if(attribute.length() != 0) {
					Alert.yesLabel = LanguageManager.getLabel("alert.yes");
			 		Alert.noLabel = LanguageManager.getLabel("alert.no");
			 		var alert:Alert = Alert.show(LanguageManager.getLabel("documents.repeatedFiscalDocumentCancellation"), '', Alert.YES | Alert.NO, null, confirmFunction, null, Alert.YES);
			 	} else {
			 		Alert.show(LanguageManager.getLabel("alert.cancelDocumentQuestion"), title, (Alert.YES | Alert.NO), null, confirmFunction);
			 	}
			}
			if(status == COMMITED) Alert.show(LanguageManager.getLabel("alert.commitDocumentQuestion"), title, (Alert.YES | Alert.NO), null, confirmFunction);
		}
		
		private function confirmFunction(event:CloseEvent):void
		{
			if(event.detail == Alert.YES) changeStatus();
		}
		
		private function changeStatus():void
		{
			var docId:String = String(lastItemData.*[0].id);
			var cmd:ChangeDocumentStatusCommand = new ChangeDocumentStatusCommand(docId, status);
			cmd.addEventListener(ResultEvent.RESULT, cmdResult);
			cmd.execute(lastItemData);
		}
		
		protected function cmdResult(event:ResultEvent):void {
			var cmd:ChangeDocumentStatusCommand = (event.target as ChangeDocumentStatusCommand);
			cmd.removeEventListener(ResultEvent.RESULT, cmdResult);
			model.eventManager.dispatchEvent(new GlobalEvent(GlobalEvent.DOCUMENT_CHANGED, (new DocumentTypeDescriptor(lastItemData.*.documentTypeId[0].toString())).categoryNumber.toString()));
		}
	}
}