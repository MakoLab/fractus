package com.makolab.fractus.commands
{
	public class GetDocumentPaymentsCommand extends ExecuteCustomProcedureCommand
	{
		public function GetDocumentPaymentsCommand(documentId:String, documentType:String)
		{ 
			var s:XML = new XML(<root><commercialDocumentHeaderId></commercialDocumentHeaderId><financialDocumentHeaderId></financialDocumentHeaderId></root>);
			switch(documentType)	{
				case "CommercialDocument": s.commercialDocumentHeaderId.appendChild(documentId);
				case "FinancialDocument": s.financialDocumentHeaderId.appendChild(documentId);
			}
			operationParams = s;
			super("document.p_getDocumentPayments");
		}

	}
}