package com.makolab.fractus.view.documents.plugins
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.commands.*;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.view.documents.documentControls.IDocumentControl;
	import com.makolab.fractus.view.documents.documentEditors.DocumentEditor;
	
	import mx.controls.DateField;
	import mx.rpc.events.ResultEvent;

	/**
	 * Plugin that manages document number changes.
	 */
	public class DocumentNumberPlugin implements IDocumentControl
	{
		private var _documentObject:DocumentObject;
		[Bindable]
		public function set documentObject(value:DocumentObject):void
		{
			_documentObject = value;
			if (_documentObject) initialize(_documentObject, _documentObject.editor);
		}
		public function get documentObject():DocumentObject { return _documentObject; }

		public static const INTERNAL_DATE_FORMAT:String = "YYYY-MM-DD";
		
		/**
		 * Previous document number before change.
		 */
		private var previousNumber:String;
		
		/**
		 * Previous document full number before change.
		 */
		private var previousFullNumber:String;
		
		/**
		 * Previous number setting id before change.
		 */
		private var previousNumberSettingId:String;
		
		/**
		 * Previous state of the "userModified" attribute flag before change.
		 */
		private var previousUserModified:Object;

		private var previousIssueDate:String;
		private var previousFinancialRegisterId:String;
		
		/**
		 * Owner document for the plugin.
		 */
		private var ownerDocument:DocumentEditor;
		
		/**
		 * Initializes a new instance of the <code>DocumentNumberPlugin</code> class.
		 */
		public function DocumentNumberPlugin()
		{
		}

		/**
		 * Initializes plugin for the specified <code>GenericDocument</code>
		 * 
		 * @param document Owner document for the plugin.
		 */
		public function initialize(documentObject:DocumentObject, documentEditor:DocumentEditor):void
		{
			this.ownerDocument = documentEditor;
			documentObject.addEventListener(DocumentEvent.DOCUMENT_LOAD, documentLoadEventHandler);
			documentObject.addEventListener(DocumentEvent.DOCUMENT_FIELD_CHANGE, documentFieldChangeEventHandler);
		}
		
		/**
		 * Event handler for DOCUMENT_LOAD event.
		 */
		private function documentLoadEventHandler(event:DocumentEvent):void
		{
			var documentObject:DocumentObject = event.target as DocumentObject;
			this.saveCurrentNumberValues(documentObject.xml);
			this.setNumberStateFree();
			setNumberSettingMethod();
			
			if(documentObject.draftId) //dokumenty wczytane ze schowka maja miec odswiezony numer
			{
				this.refreshNumber(documentObject, true);
			}
		}
		
		private function refreshNumber(documentObject:DocumentObject, forceRefresh:Boolean = false):void
		{
			var documentXML:XML = documentObject.xml;
			var cmd:FractusCommand = null;
			
			var financialRegisterSymbol:String = null;
			
			if(documentObject.typeDescriptor.isFinancialDocument)
			{
				var entry:XML = DictionaryManager.getInstance().getById(documentXML.financialReport.financialReport.financialRegisterId.*);
				financialRegisterSymbol = entry.symbol.*;
			}
			
			if ((this.previousNumber != documentXML.number.number && this.isNumberUserModified(documentXML)) ||
				(this.previousNumberSettingId != documentXML.number.numberSettingId.* && documentXML.number.number.@userModified == "1"))
			{
				if(!manualNumberSetting)
				documentXML.number.fullNumber.* = this.computeFullNumber(documentXML.number.number,
						documentXML.number.numberSettingId.*, DateField.stringToDate(documentXML.issueDate.*, DocumentNumberPlugin.INTERNAL_DATE_FORMAT),
						DictionaryManager.getInstance().getById(documentXML.documentTypeId).symbol.*);
				
				cmd = new CheckNumberExistenceCommand((manualNumberSetting ? "" : this.computeSeriesValue(documentXML.number.numberSettingId.*,
					DateField.stringToDate(documentXML.issueDate.*, DocumentNumberPlugin.INTERNAL_DATE_FORMAT),
					DictionaryManager.getInstance().getById(documentXML.documentTypeId).symbol.*,
					financialRegisterSymbol)), 
					parseInt(documentXML.number.number.*));
					
				cmd.addEventListener(ResultEvent.RESULT, handleCheckNumberExistenceCommand);
				cmd.execute({}); 
			}
			else if (((this.previousNumberSettingId != documentXML.number.numberSettingId.*) ||
				(this.previousUserModified != documentXML.number.number.@userModified) ||
				this.previousIssueDate != documentXML.issueDate.* ||
					(documentXML.financialReport.financialReport.financialRegisterId.length() > 0 &&
					this.previousFinancialRegisterId != documentXML.financialReport.financialReport.financialRegisterId.*) ||
				forceRefresh)
				&& !manualNumberSetting)
			{
				cmd = new GetFreeDocumentNumberCommand(documentXML.documentTypeId.*,
					documentXML.issueDate.*, documentXML.number.numberSettingId.*, financialRegisterSymbol);				
				
				cmd.addEventListener(ResultEvent.RESULT, handleGetFreeDocumentNumberCommand);
				cmd.execute({});
			}
			
			this.saveCurrentNumberValues(documentXML);
		}
		
		private var manualNumberSetting:Boolean;
		
		/**
		 * Event handler for DOCUMENT_FIELD_CHANGE event.
		 */
		private function documentFieldChangeEventHandler(event:DocumentEvent):void
		{
			if(event.fieldName != "documentNumber" && event.fieldName != "financialRegisterId" && event.fieldName != "issueDate") return;
			
			if(event.fieldName == "issueDate"){
				setNumberSettingMethod();
			}
				
			this.refreshNumber(DocumentObject(event.target));
		}
		
		private function setNumberSettingMethod():void
		{
			var issueDate:Date = Tools.isoToDate(documentObject.xml.issueDate);
				var systemStart:Date = ModelLocator.getInstance().systemStartDate;
				if(issueDate < systemStart){
					//saveCurrentNumberValues(documentObject.xml);
					documentObject.xml.number.number = 0;
					//documentObject.xml.number.numberSettingId = "";
					if(documentObject.isNewDocument && documentObject.draftId == null)documentObject.xml.number.fullNumber.* = "";
					delete documentObject.xml.number.numberSettingId;
					documentObject.xml.number.@SkipAutonumbering = 1;
					manualNumberSetting = true;
				}else{
					manualNumberSetting = false;
					//if(this.previousUserModified != documentObject.xml.number.number.@userModified){
					documentObject.xml.number.numberSettingId = previousNumberSettingId;
					documentObject.xml.number.@SkipAutonumbering = 0;
					//}
				}
		}
		
		/**
		 * Gets a flag whether user modified document number manually.
		 * 
		 * @param documentXML XML of the document to check for the flag.
		 * 
		 * @return <code>true</code> if user modified document number manually; otherwise <code>false</code>.
		 */
		private function isNumberUserModified(documentXML:XML):Boolean
		{
			if(!documentXML.number.number.@userModified || documentXML.number.number.@userModified == "0")
				return false;
			else
				return true; 
		}
		
		/**
		 * Event handler for the check whether the manually modified document number is free to get 
		 * or already taken by another document.
		 * 
		 * @param event ResultEvent containing response from the server.
		 */
		private function handleCheckNumberExistenceCommand(event:ResultEvent):void
		{
			var isExist:Boolean = Boolean(event.result);
			//var salesDocument:AdvancedSalesDocumentEditor = AdvancedSalesDocumentEditor(this.ownerDocument);
			
			if(isExist)
			{
				this.setNumberStateAlreadyInUse();
			}
			else
			{
				this.setNumberStateFree();
			}
		}
		
		/**
		 * Sets visual components in state that signals that the number is already in use.
		 */
		private function setNumberStateAlreadyInUse():void
		{
			/*
			var salesDocument:SalesDocumentEditor = SalesDocumentEditor(this.ownerDocument);
			
			salesDocument.numberRendererColor = 0xff0000;	// red
			salesDocument.numberRendererToolTip = "Numer jest już zajęty";
			*/
		}
		
		/**
		 * Sets visual components in state that signals that the number is free.
		 */
		private function setNumberStateFree():void
		{
			/*
			var salesDocument:SalesDocumentEditor = SalesDocumentEditor(this.ownerDocument);
			
			salesDocument.numberRendererColor = 0x000000;	// black
			salesDocument.numberRendererToolTip = null;
			*/
		}
		
		/**
		 * Event handler for the GetFreeDocumentNumber command.
		 * 
		 * @param event ResultEvent containing response from the server.
		 */
		private function handleGetFreeDocumentNumberCommand(event:ResultEvent):void
		{
			var response:XML = XML(event.result);
			//var salesDocument:AdvancedSalesDocumentEditor = AdvancedSalesDocumentEditor(this.ownerDocument);
			
			this.ownerDocument.documentObject.xml.number.fullNumber.* = response.fullNumber.*;
			this.ownerDocument.documentObject.xml.number.number.* = response.number.*;
			this.setNumberStateFree();
			
			//?
			//this.ownerDocument.documentXML = new XML(this.ownerDocument.documentXML);
			
			this.saveCurrentNumberValues(this.ownerDocument.documentObject.xml);
			
			this.ownerDocument.documentObject.dispatchEvent(DocumentEvent.createEvent(DocumentEvent.DOCUMENT_FIELD_CHANGE, "documentNumber"));
		}
		
		/**
		 * Saves all current document number settings to the previousNumber, previousFullNumber,
		 * previousNumberSettingId, previousUserModified.
		 * 
		 * @param documentXML XML of the document.
		 */ 
		private function saveCurrentNumberValues(documentXML:XML):void
		{
			this.previousNumber = documentXML.number.number.*;
			this.previousFullNumber = documentXML.number.fullNumber;
			if(!manualNumberSetting)this.previousNumberSettingId = documentXML.number.numberSettingId.*;
			this.previousUserModified = documentXML.number.number.@userModified;
			this.previousIssueDate = documentXML.issueDate.*;
			
			if(documentXML.financialReport.financialReport.financialRegisterId.length() > 0)
				this.previousFinancialRegisterId = documentXML.financialReport.financialReport.financialRegisterId.*;
		}
		
		/**
		 * Computes series value.
		 * 
		 * @param numberSettingId NumberSettingId.
		 * @param documentIssueDate Document's issue date.
		 * @param documentSymbol Document's symbol.
		 * 
		 * @return Computed series value.
		 */
		private function computeSeriesValue(numberSettingId:String, documentIssueDate:Date, documentSymbol:String, financialRegisterSymbol:String):String
		{
			var branchSymbol:String = DictionaryManager.getInstance().getById(ModelLocator.getInstance().branchId).symbol.*;
			
			if (financialRegisterSymbol == null)
				financialRegisterSymbol = "??";
			
			var dict:Object = { "[DocumentYear]" : documentIssueDate.getFullYear(), 
								"[DocumentMonth]" : documentIssueDate.getMonth()+1,
								"[DocumentDay]" : documentIssueDate.getDate(),
								"[DocumentSymbol]" : documentSymbol,
								"[BranchSymbol]" : branchSymbol,
								"[FinancialRegisterSymbol]" : financialRegisterSymbol };
			
			var numberSetting:XML = DictionaryManager.getInstance().getById(numberSettingId);
			
			var fullNumber:String = numberSetting.seriesFormat.*;
			
			for (var key:String in dict)
			{
				fullNumber = fullNumber.replace(key, dict[key]);
			}
			
			return fullNumber;
		}
		
		/**
		 * Computes full document number.
		 * 
		 * @param sequentialNumber Document's sequentialNumber.
		 * @param numberSettingId NumberSettingId.
		 * @param documentIssueDate Document's issue date.
		 * @param documentSymbol Document's symbol.
		 * 
		 * @return Computed series value.
		 */
		private function computeFullNumber(sequentialNumber:String, numberSettingId:String, documentIssueDate:Date, documentSymbol:String):String
		{
			var dict:Object = { "[DocumentYear]" : documentIssueDate.getFullYear(), 
								"[DocumentMonth]" : documentIssueDate.getMonth()+1,
								"[DocumentDay]" : documentIssueDate.getDate(),
								"[DocumentSymbol]" : documentSymbol,
								"[SequentialNumber]" : sequentialNumber };
			
			var numberSetting:XML = DictionaryManager.getInstance().getById(numberSettingId);
			
			var fullNumber:String = numberSetting.numberFormat.*;
			
			for (var key:String in dict)
			{
				fullNumber = fullNumber.replace(key, dict[key]);
			}
			
			return fullNumber;
		}
	}
}