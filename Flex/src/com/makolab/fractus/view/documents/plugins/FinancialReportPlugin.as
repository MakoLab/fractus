package com.makolab.fractus.view.documents.plugins
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.fractus.commands.GetOpenFinancialReportCommand;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.view.documents.documentControls.IDocumentControl;
	
	import mx.rpc.events.ResultEvent;

	public class FinancialReportPlugin implements IDocumentControl
	{
		public function FinancialReportPlugin()
		{
		}

		private var _documentObject:DocumentObject;
		public function set documentObject(value:DocumentObject):void
		{
			_documentObject = value;
			_documentObject.addEventListener(DocumentEvent.DOCUMENT_FIELD_CHANGE, handleDocumentFieldChange);
		}
		
		protected function handleDocumentFieldChange(event:DocumentEvent):void
		{
			if (event.fieldName != 'financialRegisterId') return;
			var reportId:String = documentObject.xml.financialReport.financialReport.financialRegisterId;
			delete documentObject.xml.financialReport.financialReport.number; // na potrzeby wyswietlania - znika numer wybranego raportu
			delete documentObject.xml.financialReport.financialReport.id;	// nie mozemy przekazac na serwer poprzedniego raportu
			documentObject.xml.financialReport.financialReport.@type = "FinancialReport";
			var cmd:GetOpenFinancialReportCommand = new GetOpenFinancialReportCommand(reportId);
			cmd.addEventListener(ResultEvent.RESULT, handleResult);
			cmd.defaultErrorHandling = false;
			cmd.execute();
		}
		
		public function get documentObject():DocumentObject
		{
			return _documentObject;
		}
		
		protected function handleResult(event:ResultEvent):void
		{
			documentObject.xml.financialReport.financialReport = XML(event.result).financialReport;
		}
		
	}
}