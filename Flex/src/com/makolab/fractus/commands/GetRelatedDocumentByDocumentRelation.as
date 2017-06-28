package com.makolab.fractus.commands
{
	public class GetRelatedDocumentByDocumentRelation extends ExecuteCustomProcedureCommand
	{
		public static const COMMERCIAL_DOCUMENT:int = 1;
		public static const WAREHOUSE_DOCUMENT:int = 2;
		public static const COMPLAINT_DOCUMENT:int = 3;
		public static const INVENTORY_DOCUMENT:int = 4;
		public static const FINANCIAL_DOCUMENT:int = 5;
		
		public var documentId:String;
		public var objectType:int;
		
		public function GetRelatedDocumentByDocumentRelation(id:String = null, objectType:int = 0)
		{
			this.documentId = id;
			this.objectType = objectType;
			super("document.p_getRelatedDocuments");
		}
		
		protected override function getOperationParams(data:Object):Object
		{
			switch(objectType)
			{
				case COMMERCIAL_DOCUMENT:
					this.operationParams = <root><commercialDocumentHeaderId>{documentId}</commercialDocumentHeaderId></root>;
					break;
				case WAREHOUSE_DOCUMENT:
					this.operationParams = <root><warehouseDocumentHeaderId>{documentId}</warehouseDocumentHeaderId></root>;
					break;
				case COMPLAINT_DOCUMENT:
					this.operationParams = <root><complaintDocumentHeaderId>{documentId}</complaintDocumentHeaderId></root>;
					break;
				case INVENTORY_DOCUMENT:
					this.operationParams = <root><inventoryDocumentHeaderId>{documentId}</inventoryDocumentHeaderId></root>;
					break;
				case FINANCIAL_DOCUMENT:
					this.operationParams = <root><financialDocumentHeaderId>{documentId}</financialDocumentHeaderId></root>;
					break;
				default:
					throw new Error("GetRelatedDocumentByDocumentRelation error: unknown argumentType");
			}
			return this.operationParams;
		}
	}
}