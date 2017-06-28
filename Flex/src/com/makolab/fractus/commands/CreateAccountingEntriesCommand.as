package com.makolab.fractus.commands
{
	public class CreateAccountingEntriesCommand extends ExecuteCustomProcedureCommand
	{
		public var params:XML;
		
		public function CreateAccountingEntriesCommand(documentId:String, documentCategory:String)
		{
			var s:XML = new XML(<params><documentId/><documentCategory/></params>);
			s.documentId.appendChild(documentId);
			s.documentCategory.appendChild(documentCategory);
			operationParams = s;
			super("accounting.p_createAccountingEntries");
		}		
	}
}