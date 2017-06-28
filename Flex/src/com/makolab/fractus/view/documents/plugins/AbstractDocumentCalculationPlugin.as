package com.makolab.fractus.view.documents.plugins
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.model.document.BusinessObject;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.view.documents.documentControls.IDocumentControl;
	import com.makolab.fractus.view.documents.documentEditors.DocumentEditor;
	
	public class AbstractDocumentCalculationPlugin implements IDocumentControl
	{
		private var _documentObject:DocumentObject;
		[Bindable]
		public function set documentObject(value:DocumentObject):void
		{
			_documentObject = value;
			if (_documentObject) initialize(_documentObject, _documentObject.editor);
		}
		public function get documentObject():DocumentObject { return _documentObject; }
		
		public function initialize(docObj:DocumentObject, docXML:DocumentEditor):void
		{
			docObj.addEventListener(DocumentEvent.DOCUMENT_LINE_CHANGE, documentLineChangeHandler);
			docObj.addEventListener(DocumentEvent.DOCUMENT_LINE_ADD, documentLineChangeHandler);
			docObj.addEventListener(DocumentEvent.DOCUMENT_LINE_DELETE, documentLineChangeHandler);
			docObj.addEventListener(DocumentEvent.DOCUMENT_RECALCULATE, documentRecalculateHandler);
			docObj.addEventListener(DocumentEvent.DOCUMENT_FIELD_CHANGE, documentFieldChangeHandler);
		}
		
		protected function documentLineChangeHandler(event:DocumentEvent):void
		{
			calculateLine(BusinessObject(event.line), event.fieldName);
			calculateTotal(event.target as DocumentObject, event.fieldName);
			event.setUpdateDocument();
		} 
		
		protected function documentRecalculateHandler(event:DocumentEvent, fieldName:String = null):void
		{
			if (fieldName) for each (var line:BusinessObject in documentObject.lines) calculateLine(line, fieldName);
			calculateTotal(documentObject);
		}
		
		protected function documentFieldChangeHandler(event:DocumentEvent):void
		{
			
		}
		
		public function round(x:Number, n:int=2):Number
		{
			return Tools.round(x, n);
		}	

		public function calculateLine(modifiedLine:BusinessObject, modifiedField:String):void {}

		public function calculateTotal(doc:DocumentObject, fieldName:String = null):void {}
		
	}
}