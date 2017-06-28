package com.makolab.fractus.view.documents.plugins
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.document.BusinessObjectAttribute;
	import com.makolab.fractus.model.document.CommercialDocumentLine;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.view.documents.documentControls.IDocumentControl;
	
	import mx.controls.Alert;

	/** A plugin responsible for automatic line attribute processing:
	 * - sets the default value of a line attribute
	 */
	public class LineAttributePlugin implements IDocumentControl
	{
		public function LineAttributePlugin()
		{
		}

		private var _documentObject:DocumentObject
		public function set documentObject(value:DocumentObject):void
		{
			_documentObject = value;
			_documentObject.addEventListener(DocumentEvent.DOCUMENT_LINE_CHANGE, handleSetItem);
		}
		
		public function get documentObject():DocumentObject
		{
			return _documentObject;
		}
		
		private function handleSetItem(event:DocumentEvent):void
		{
			if(event.fieldName != "initialNetPrice")return;
			var attrEntry:XML = null;
			var line:CommercialDocumentLine = null;
			var attr:BusinessObjectAttribute = null;
			var value:String;
			
			if(documentObject && documentObject.typeDescriptor.isServiceDocument)
			{
				attrEntry = DictionaryManager.getInstance().getByName('LineAttribute_GenerateDocumentOption', 'documentFields');
				line = event.line as CommercialDocumentLine;
				attr = line.getAttributeByFieldId(attrEntry.id);
				if (!attr)
				{
					attr = line.addAttribute(attrEntry.id);
					value = String(attrEntry.metadata.values.value.(valueOf().isDefault == 1).name[0]);
					if (value) attr.value = value;
				}
			}
			else if(documentObject && documentObject.typeDescriptor.isSalesOrderDocument)
			{
				attrEntry = DictionaryManager.getInstance().getByName('LineAttribute_SalesOrderGenerateDocumentOption', 'documentFields');
				line = event.line as CommercialDocumentLine;
				attr = line.getAttributeByFieldId(attrEntry.id);
				if (!attr)
				{
					value = String(attrEntry.metadata.values.value.(valueOf().isDefault == 1).name[0]);
					
					var itemTypes:XMLList = DictionaryManager.getInstance().dictionaries.itemTypes.(id.toString() == line.itemTypeId);
					if(itemTypes.length() > 0){
						var itemType:String = itemTypes[0].isWarehouseStorable.toString(); 
						var fieldId:String = DictionaryManager.getInstance().dictionaries.documentFields.(name.toString() == "Attribute_SalesOrderSalesType").id.toString();
						var attribute:XML;
						for(var i:int = 0; i < documentObject.attributes.length; i++){
							if(documentObject.attributes[i].documentFieldId.toString() == fieldId){
								attribute = documentObject.attributes[i];
								break;
							}
						}
						if(attribute){
							switch(attribute.value.toString()){
								case DocumentObject.ITEM_SALE:
									value = "1";
									break;
								case DocumentObject.ITEM_SALE_RESERVATION:
									value = "3";
									break;
								case DocumentObject.SERVICE_SALE:
									if(itemType == "1")value = "2";
									else value = "1";
									break;
								case DocumentObject.SERVICE_SALE_RESERVATION:
									if(itemType == "1")value = "4";
									else value = "3";
									break;
							}
						}else{
							value = null;
							Alert.show("Proszę wybrać rodzaj sprzedaży"); // todo: labele
						}
					}
					if(value){
						attr = line.addAttribute(attrEntry.id);
						attr.value = value;
					}
				}
			}
		}
	}
}