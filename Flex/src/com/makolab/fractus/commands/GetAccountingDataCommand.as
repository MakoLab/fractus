package com.makolab.fractus.commands
{
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	
	public class GetAccountingDataCommand extends ExecuteCustomProcedureCommand
	{
		public var documentId:String;
		public var documentCategory:String;
		
		public function GetAccountingDataCommand(documentId:String, documentCategory:String)
		{
			super("accounting.p_getDocumentData");
			this.documentId = documentId;
			this.documentCategory = documentCategory;
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			var params:XML = <params/>;
			var paramName:String;
			switch (documentCategory)
			{
				case DocumentTypeDescriptor.COMMERCIAL_DOCUMENT:
					paramName = 'commercialDocumentId';
					break;
				case DocumentTypeDescriptor.WAREHOUSE_DOCUMENT:
					paramName = 'warehouseDocumentId';
					break;
				case DocumentTypeDescriptor.FINANCIAL_DOCUMENT:
					paramName = 'financialDocumentId';
					break;
			}
			if (paramName && documentId) params[paramName] = documentId;
			return params;
		}
		
	}
}