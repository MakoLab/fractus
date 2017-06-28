package com.makolab.fractus.commands
{
	public class GetDocumentByPaymentIdCommand extends ExecuteCustomProcedureCommand
	{
		public function GetDocumentByPaymentIdCommand(paymentId:String)
		{
			super('document.p_getPaymentDocument', <root>{paymentId}</root>);
		}
	}
}