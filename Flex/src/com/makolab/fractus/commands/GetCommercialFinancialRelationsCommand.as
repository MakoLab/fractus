package com.makolab.fractus.commands
{
	public class GetCommercialFinancialRelationsCommand extends ExecuteCustomProcedureCommand
	{
		public static const COMMERCIAL_DOCUMENT:int = 1;
		public static const FINANCIAL_DOCUMENT:int = 2;
		
		public var documentId:String;
		public var objectType:int;
		
		public function GetCommercialFinancialRelationsCommand(id:String = null, objectType:int = 0)
		{
			this.documentId = id;
			this.objectType = objectType;
			super("document.p_getFinancialCommercialRelatedDocuments");
		}
		
		protected override function getOperationParams(data:Object):Object
		{
			switch(objectType)
			{
				case COMMERCIAL_DOCUMENT:
					this.operationParams = <params><commercialDocumentId>{documentId}</commercialDocumentId></params>;
					break;
				case FINANCIAL_DOCUMENT:
					this.operationParams = <params><financialDocumentId>{documentId}</financialDocumentId></params>;
					break;
				default:
					throw new Error("GetRelatedComercialDocumentsCommand error: unknown argumentType");
			}
			return this.operationParams;
		}
	}
}