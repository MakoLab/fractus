package com.makolab.fractus.commands
{
	public class GetCorrectiveDocumentsCommand extends ExecuteCustomProcedureCommand
	{
		public var objectId:String;
		
		public function GetCorrectiveDocumentsCommand(id:String = null)
		{
			super(null);
			this.procedureName = 'document.p_getCorrectiveCommercialDocuments'
			this.objectId = id;
		}

		protected override function getOperationParams(data:Object):Object
		{
			return <params><documentId>{this.objectId}</documentId></params>;			
		}
		
	}
}