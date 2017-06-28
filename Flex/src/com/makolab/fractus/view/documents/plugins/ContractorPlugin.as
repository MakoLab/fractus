package com.makolab.fractus.view.documents.plugins
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.commands.GetContractorDealingCommand;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.view.documents.documentControls.IDocumentControl;
	import com.makolab.fractus.view.documents.documentEditors.AdvancedSalesDocumentEditor;
	import com.makolab.fractus.view.documents.documentEditors.DocumentEditor;
	
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.collections.XMLListCollection;
	import mx.rpc.events.ResultEvent;

	/**
	 * Plugin that manages contractor change operations.
	 */
	public class ContractorPlugin implements IDocumentControl
	{
		
		private var _documentObject:DocumentObject;
		[Bindable]
		public function set documentObject(value:DocumentObject):void
		{
			_documentObject = value;
			if (_documentObject) initialize(_documentObject, _documentObject.editor);
		}
		public function get documentObject():DocumentObject { return _documentObject; }

		/**
		 * Owner document for the plugin
		 */
		private var ownerDocument:AdvancedSalesDocumentEditor;
		
		/**
		 * Initializes plugin for the specified <code>GenericDocument</code>
		 * 
		 * @param document Owner document for the plugin.
		 */
		public function initialize(documentObject:DocumentObject, document:DocumentEditor):void
		{
			documentObject.addEventListener(DocumentEvent.DOCUMENT_FIELD_CHANGE, documentFieldChangeEventHandler);
			documentObject.addEventListener(DocumentEvent.DOCUMENT_LOAD, documentLoadEventHandler);
			
			if(documentObject.xml.version.length() == 0) //tylko dla dokumentow nowych
				ModelLocator.getInstance().configManager.requestValue("document.discountSlider", true);
		}
		
		/**
		 * Event handler for <code>DocumentEvent.DOCUMENT_FIELD_CHANGE</code> event.
		 * 
		 * @param event DocumentEvent containing event info.
		 */
		private function documentLoadEventHandler(event:DocumentEvent):void
		{
			var documentObject:DocumentObject = event.target as DocumentObject;
			if(documentObject.xml.contractor.contractor.length() == 0 ||
				documentObject.xml.contractor.contractor.addresses.address.length() == 0)
				this.documentObject.enableAddressSelection = false;
			else
				this.documentObject.enableAddressSelection = true;
		}	

		private function getContractorDealingHandler(event:ResultEvent):void
		{
			var dealing:Number = parseFloat(XML(event.result).*);
			
			var prevThreshold:Number = -1;
			var sortedCollection:XMLListCollection = new XMLListCollection(ModelLocator.getInstance().configManager.values.document_discountSlider.*.*.*);
			var sort:Sort = new Sort();
			sort.fields = [ new SortField("threshold", true, false, null) ];
			sortedCollection.sort = sort;
			
			for each(var entry:XML in sortedCollection)
			{
				if(dealing > prevThreshold && dealing <= Number(entry.threshold.*))
				{
					documentObject.defaultLineDiscount = Number(entry.discountRate.*);
					break;
				}									
				prevThreshold = Number(entry.threshold.*);
			}
			
			if(documentObject.defaultLineDiscount == 0 && dealing > prevThreshold && prevThreshold > -1)
			{
				//wieksze niz ostatni przedzial wiec bierzemy najwiekszy prog
				var discount:Number = Number(ModelLocator.getInstance().configManager.values.document_discountSlider.*.*.*.discountRate.(valueOf().parent().threshold.* == prevThreshold).*);
				
				documentObject.defaultLineDiscount = discount; 				
			}
		}
		
		/**
		 * Event handler for <code>DocumentEvent.DOCUMENT_FIELD_CHANGE</code> event.
		 * 
		 * @param event DocumentEvent containing event info.
		 */
		private function documentFieldChangeEventHandler(event:DocumentEvent):void
		{
			if(event.fieldName != "contractor") return;
			
			var documentObject:DocumentObject = event.target as DocumentObject;
			
			if(documentObject.xml.version.length() == 0 && documentObject.xml.contractor.length != 0) //tylko dla dokumentow nowych
			{
				//tutaj moze byc sytuacjia ze jeszcze nie bylo responsa z konfiguracja i sie moze wywalic...
				if(ModelLocator.getInstance().configManager.values.document_discountSlider &&
					ModelLocator.getInstance().configManager.values.document_discountSlider.*.*.*.length() != 0)
				{
					var days:String = ModelLocator.getInstance().configManager.values.document_discountSlider.*.*.@days;
					var dealingCmd:GetContractorDealingCommand = new GetContractorDealingCommand(documentObject.xml.contractor.contractor.id.*, days);
					dealingCmd.addEventListener(ResultEvent.RESULT, getContractorDealingHandler);
					dealingCmd.execute();
				}
				else
					documentObject.defaultLineDiscount = 0;
			}
			
			if(documentObject.xml.contractor.contractor.length() == 0)
			{
				documentObject.enableAddressSelection = false;
				return;
			}
			
			if(documentObject.xml.contractor.contractor.addresses.address.length() != 0)
			{
				this.documentObject.enableAddressSelection = true;
				documentObject.xml.contractor.addressId = this.getAddressForBilling(documentObject.xml.contractor.contractor).id.*;

				documentObject.dispatchEvent(DocumentEvent.createEvent(DocumentEvent.DOCUMENT_FIELD_CHANGE, "contractorAddressId"));
			}
			else
				this.documentObject.enableAddressSelection = false;
		}
		
		/**
		 * Gets the contractor billing address. If the address is not present it gets default address.
		 * 
		 * @param contractor Contractor xml list (node).
		 * 
		 * @return Selected address for billing.
		 */
		protected function getAddressForBilling(contractor:XMLList):XML
		{
			var addressBilling:String = DictionaryManager.getInstance().getByName("Address_Billing").id;
			var addressDefault:String = DictionaryManager.getInstance().getByName("Address_Default").id;
			
			var choosenAddress:XMLList = contractor.addresses.address.(contractorFieldId == addressBilling);
			
			if(choosenAddress.length() == 0)
				choosenAddress = contractor.addresses.address.(contractorFieldId == addressDefault);
				
			if(choosenAddress.length() == 0)
				choosenAddress = contractor.addresses.address[0]
			
			return XML(choosenAddress);			
		}
	}
}