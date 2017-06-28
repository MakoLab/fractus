package com.makolab.fractus.commands
{
	public class GetRelatedWarehouseDocumentsCommand extends ExecuteCustomProcedureCommand
	{
		public static const INCOME_LINE:int = 1;
		public static const INCOME_DOCUMENT:int = 2;
		public static const OUTCOME_LINE:int = 3;
		public static const OUTCOME_DOCUMENT:int = 4;
		
		public var objectId:String;
		public var objectType:int;
		
		public function GetRelatedWarehouseDocumentsCommand(id:String = null, argumentType:int = 0)
		{
			super(null);
			this.objectId = id;
			this.objectType = argumentType;
		}

		protected override function getOperationParams(data:Object):Object
		{
			var proc:String;
			switch (this.objectType)
			{
				case OUTCOME_LINE:
					proc = 'document.p_getIncomesForOutcome';
					operationParams = <params><outcomeId>{objectId}</outcomeId></params>;
					break;
				case INCOME_LINE:
					proc = 'document.p_getOutcomesForIncome';
					operationParams = <params><incomeId>{objectId}</incomeId></params>;
					break;
				case OUTCOME_DOCUMENT:
					proc = 'document.p_getRelatedWarehouseDocuments';
					operationParams = <params><outcomeDocumentId>{objectId}</outcomeDocumentId></params>;
					break;
				case INCOME_DOCUMENT:
					proc = 'document.p_getRelatedWarehouseDocuments';
					operationParams = <params><incomeDocumentId>{objectId}</incomeDocumentId></params>;
					break;
				default:
					throw new Error("GetRelatedWarehouseDocumentsCommand error: unspecified object type.");
			}
			this.procedureName = proc;
			return this.operationParams;			
		}
		
	}
}