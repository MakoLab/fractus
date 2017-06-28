package com.makolab.fractus.commands
{
	public class GetRelatedComercialDocumentsCommand extends ExecuteCustomProcedureCommand
	{
		public static const COMMERCIAL_DOCUMENT:int = 1;
		public static const WAREHOUSE_DOCUMENT:int = 2;
		
		public var documentId:String;
		public var objectType:int;
		
		public function GetRelatedComercialDocumentsCommand(id:String = null, objectType:int = 0)
		{
			this.documentId = id;
			this.objectType = objectType;
			super("document.p_getCommercialWarehouseRelations");
		}
		
		protected override function getOperationParams(data:Object):Object
		{
			switch(objectType)
			{
				case COMMERCIAL_DOCUMENT:
					this.operationParams = <params><commercialDocumentId>{documentId}</commercialDocumentId></params>;
					break;
				case WAREHOUSE_DOCUMENT:
					this.operationParams = <params><warehouseDocumentId>{documentId}</warehouseDocumentId></params>;
					break;
				default:
					throw new Error("GetRelatedCommercialDocumentsCommand error: unknown argumentType");
			}
			return this.operationParams;
		}
	}
}