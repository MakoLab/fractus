package com.makolab.fractus.commands
{
	public class GetAccountingEntriesCommand extends ExecuteCustomProcedureCommand
	{
		public var params:XML;
		
		public function GetAccountingEntriesCommand(documentId:String)
		{
			var s:XML = new XML(<params><documentId></documentId></params>);
			s.documentId.appendChild(documentId);
			operationParams = s;
			super("accounting.p_getAccountingEntries");
		}		
	}
}