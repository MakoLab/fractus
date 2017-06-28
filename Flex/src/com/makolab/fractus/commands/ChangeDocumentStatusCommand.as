package com.makolab.fractus.commands
{
	import com.makolab.fractus.model.GlobalEvent;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	
	public class ChangeDocumentStatusCommand extends FractusCommand
	{
		private var documentId:String;
		private var status:String;
		
		public function ChangeDocumentStatusCommand(documentId:String, status:String)
		{
			this.documentId = documentId;
			this.status = status;
			super("kernelService", "ChangeDocumentStatus");
			//ModelLocator.getInstance().eventManager.dispatchEvent(new GlobalEvent(GlobalEvent.DOCUMENT_CHANGED, "Document"));
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			var xmlParams:XML = new XML();
			var type:String = data.*[0].@type;
			switch(type)	{
				case DocumentTypeDescriptor.SERVICE_DOCUMENT:
					xmlParams = <root><serviceDocumentId>{this.documentId}</serviceDocumentId><status>{this.status}</status></root>;
					break;
				case DocumentTypeDescriptor.COMMERCIAL_DOCUMENT: 
					xmlParams = <root><commercialDocumentId>{this.documentId}</commercialDocumentId><status>{this.status}</status></root>;
					break;
				case DocumentTypeDescriptor.WAREHOUSE_DOCUMENT: 
					xmlParams = <root><warehouseDocumentId>{this.documentId}</warehouseDocumentId><status>{this.status}</status></root>;
					break;
				case DocumentTypeDescriptor.FINANCIAL_DOCUMENT:
					xmlParams = <root><financialDocumentId>{this.documentId}</financialDocumentId><status>{this.status}</status></root>;
					break;
				case DocumentTypeDescriptor.INVENTORY_DOCUMENT:
					xmlParams = <root><inventoryDocumentId>{this.documentId}</inventoryDocumentId><status>{this.status}</status></root>;
					break;
				case DocumentTypeDescriptor.COMPLAINT_DOCUMENT:
					xmlParams = <root><complaintDocumentId>{this.documentId}</complaintDocumentId><status>{this.status}</status></root>;
					break;
			}		
			return xmlParams.toXMLString();
		}		
	}
}