package com.makolab.fractus.commands
{
	public class GetBankByNumberCommand extends ExecuteCustomProcedureCommand
	{
		public var params:XML;
		
		public function GetBankByNumberCommand(number:String)
		{
			var s:XML = new XML(<root/>);
			s.appendChild(number);
			operationParams = s;
			super("contractor.p_getBankByNumber");
		}		
	}
}