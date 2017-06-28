package com.makolab.fractus.model.document
{
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	
	import assets.IconManager;
	
	public class DocumentTypeDescriptor
	{
		private var _dictionaryTypeDescriptor:XML;
		private var _xmlOptions:XML;
		private var _categoryNumber:uint;
		
		[Bindable] public var allowOtherCurrencies:Boolean;
		
		public static const INVENTORY_DOCUMENT:String = "InventoryDocument";
		public static const COMMERCIAL_DOCUMENT:String = "CommercialDocument";
		public static const WAREHOUSE_DOCUMENT:String = "WarehouseDocument";
		public static const FINANCIAL_DOCUMENT:String = "FinancialDocument";
		public static const FINANCIAL_REPORT:String = "FinancialReport";
		public static const SERVICE_DOCUMENT:String = "ServiceDocument";
		public static const COMPLAINT_DOCUMENT:String = "ComplaintDocument";
		
		public static const WAREHOUSE_INCOME:String = "income";
		public static const WAREHOUSE_OUTCOME:String = "outcome";
		public static const WAREHOUSE_INCOME_SHIFT:String = "incomeShift";
		public static const WAREHOUSE_OUTCOME_SHIFT:String = "outcomeShift";
		
		public static const FINANCIAL_INCOME:String = "income";
		public static const FINANCIAL_OUTCOME:String = "outcome";
		
		public static const CATEGORY_SALES:uint = 0;
		public static const CATEGORY_WAREHOUSE:uint = 1;
		public static const CATEGORY_PURCHASE:uint = 2;
		public static const CATEGORY_WAREHOUSE_RESERVATION:uint = 3;
		public static const CATEGORY_WAREHOUSE_ORDER:uint = 4;
		public static const CATEGORY_SALES_CORRECTION:uint = 5;
		public static const CATEGORY_PURCHASE_CORRECTION:uint = 6;
		public static const CATEGORY_WAREHOUSE_OUTCOME_CORRECTION:uint = 7;
		public static const CATEGORY_WAREHOUSE_INCOME_CORRECTION:uint = 8;
		public static const CATEGORY_FINANCIAL_DOCUMENT:uint = 9;
		public static const CATEGORY_SERVICE_DOCUMENT:uint = 10;
		public static const CATEGORY_PROTOCOL_COMPLAINTS:uint = 11;
		public static const CATEGORY_INVENTORY_DOCUMENT:uint = 12;
		public static const CATEGORY_SALES_ORDER_DOCUMENT:uint = 13;
		public static const CATEGORY_TECHNOLOGY_DOCUMENT:uint = 14;
		public static const CATEGORY_PRODUCTION_ORDER_DOCUMENT:uint = 15;
		public static const CATEGORY_SALES_PREORDER:uint = 16;
		
		public static var FIELD_LABELS:ArrayCollection = new ArrayCollection([
			{key: "issueDate", value: LanguageManager.getInstance().labels.documents.entryDate, category: CATEGORY_PURCHASE},
			{key: "issueDate", value: LanguageManager.getInstance().labels.documents.entryDate, category: CATEGORY_PURCHASE_CORRECTION},
			{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: CATEGORY_SALES},
			{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: CATEGORY_SALES_ORDER_DOCUMENT},
			{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: CATEGORY_SALES_CORRECTION},
			{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: CATEGORY_WAREHOUSE},
			{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: CATEGORY_WAREHOUSE_RESERVATION},
			{key: "issueDate", value: LanguageManager.getInstance().labels.documents.orderDate, category: CATEGORY_WAREHOUSE_ORDER},
			{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: CATEGORY_WAREHOUSE_OUTCOME_CORRECTION},
			{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: CATEGORY_WAREHOUSE_INCOME_CORRECTION},
			{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: CATEGORY_FINANCIAL_DOCUMENT},
			{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: CATEGORY_SERVICE_DOCUMENT},
			{key: "issueDate", value: LanguageManager.getInstance().labels.common.creationDate, category: CATEGORY_TECHNOLOGY_DOCUMENT},
			{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: CATEGORY_PRODUCTION_ORDER_DOCUMENT},
			{key: "eventDate", value: LanguageManager.getInstance().labels.documents.receptionDate, category: CATEGORY_PURCHASE},
			{key: "eventDate", value: LanguageManager.getInstance().labels.documents.receptionDate, category: CATEGORY_PURCHASE_CORRECTION},
			{key: "eventDate", value: LanguageManager.getInstance().labels.documentRenderer.salesDate, category: CATEGORY_SALES},
			{key: "eventDate", value: LanguageManager.getInstance().labels.documentRenderer.salesDate, category: CATEGORY_SALES_CORRECTION},
			{key: "eventDate", value: LanguageManager.getInstance().labels.documents.realizationDate, category: CATEGORY_WAREHOUSE_RESERVATION},
			{key: "eventDate", value: LanguageManager.getInstance().labels.documents.realizationDeadline, category: CATEGORY_WAREHOUSE_ORDER},
			{key: "eventDate", value: LanguageManager.getInstance().labels.documents.recordDate, category: CATEGORY_SERVICE_DOCUMENT},
			{key: "plannedEndDate", value: LanguageManager.getInstance().labels.documents.plannedEndDate, category: CATEGORY_SERVICE_DOCUMENT}]
		);
		public function DocumentTypeDescriptor(documentTypeId:String = null, docCategory:Object = null)
		{
			var l:XML = DictionaryManager.getInstance().getById(documentTypeId);
			if (l != null) _dictionaryTypeDescriptor = l;
			else if((documentTypeId == null) && (docCategory != null)) 
			{
				_dictionaryTypeDescriptor = <root/>;
				_categoryNumber = uint(docCategory);
				return;
			}
			else throw new Error("Unrecognized document type id '" + documentTypeId + "'.");
			_xmlOptions = _dictionaryTypeDescriptor.xmlOptions.root.*[0];
			_categoryNumber = parseInt(_dictionaryTypeDescriptor.documentCategory);
			allowOtherCurrencies = Tools.parseBoolean(_dictionaryTypeDescriptor.xmlOptions.root.*.@allowOtherCurrencies);
		}
		
		public function get typeId():String
		{
			var id:String = String(_dictionaryTypeDescriptor.id);
			return id ? id : null;
		}
		
		public function getFieldLabel(fieldName:String):String
		{
			for each(var obj:Object in FIELD_LABELS)	{ 
				if(obj.category == _categoryNumber && obj.key == fieldName)
				{
					return obj.value;
				}
			}
			return null;
		}
		
		public static function getDocumentCategory(categoryNumber:uint):String
		{
			switch (categoryNumber)
			{
				case CATEGORY_SALES:
				case CATEGORY_SALES_CORRECTION:
				case CATEGORY_PURCHASE:
				case CATEGORY_PURCHASE_CORRECTION:
				case CATEGORY_WAREHOUSE_RESERVATION:
				case CATEGORY_WAREHOUSE_ORDER:
				case CATEGORY_SALES_ORDER_DOCUMENT:
				case CATEGORY_TECHNOLOGY_DOCUMENT:
				case CATEGORY_PRODUCTION_ORDER_DOCUMENT:
				case CATEGORY_SALES_PREORDER:
					return COMMERCIAL_DOCUMENT;
					
				case CATEGORY_WAREHOUSE:
				case CATEGORY_WAREHOUSE_INCOME_CORRECTION:
				case CATEGORY_WAREHOUSE_OUTCOME_CORRECTION:
					return WAREHOUSE_DOCUMENT;
					
				case CATEGORY_FINANCIAL_DOCUMENT:
					return FINANCIAL_DOCUMENT;
					
				case CATEGORY_INVENTORY_DOCUMENT:
					return INVENTORY_DOCUMENT;

				case CATEGORY_SERVICE_DOCUMENT:
					return SERVICE_DOCUMENT;
				case CATEGORY_PROTOCOL_COMPLAINTS:
					return COMPLAINT_DOCUMENT;
				default:
					return null;
			}
		}
		
		/**
		 * Contains document category as a string eg. <code>COMMERCIAL_DOCUMENT</code> ("CommercialDocument").
		 * This is the category associated with the table the document is contained in. Can be one of the following:
		 * <ul>
		 * <li><code>COMMERCIAL_DOCUMENT</code> ("CommercialDocument")</li>
		 * <li><code>WAREHOUSE_DOCUMENT</code> ("WarehouseDocument")</li>
		 * <li><code>FINANCIAL_DOCUMENT</code> ("FinancialDocument")</li>
		 * </ul>
		 */
		public function get documentCategory():String
		{
			return DocumentTypeDescriptor.getDocumentCategory(this._categoryNumber);
		}
		/**
		* Is return icon name 
		*/
		public function get iconDocumentListName():String
		{
			switch (_categoryNumber)
			{
				case CATEGORY_SALES:
					return "list_sales";
				case CATEGORY_SALES_ORDER_DOCUMENT:	
					return "list_sales_income";
				case CATEGORY_SALES_CORRECTION:
					return "list_sales_correction";
				case CATEGORY_PURCHASE:
					return "list_purchase";
				case CATEGORY_PURCHASE_CORRECTION:
					return "list_purchase_correction";
				case CATEGORY_WAREHOUSE_RESERVATION:
					return	"list_warehouse_reservation";
				case CATEGORY_WAREHOUSE_ORDER:
					return "list_warehouse_order";
				case CATEGORY_WAREHOUSE:
					if(isWarehouseIncome)return "list_warehouse_income";
					if(isWarehouseOutcome) return "list_warehouse_outcome";
				case CATEGORY_WAREHOUSE_INCOME_CORRECTION:
					return "list_warehouse_income_correction";
				case CATEGORY_WAREHOUSE_OUTCOME_CORRECTION:
					return "list_warehouse_outcome_correction";
				case CATEGORY_FINANCIAL_DOCUMENT:
					return financialDirection > 0 ? "list_financial_income" : "list_financial_outcome";
				case CATEGORY_SERVICE_DOCUMENT:
					return "list_service";
				case CATEGORY_PROTOCOL_COMPLAINTS:
					return "list_complaint";
				case CATEGORY_PRODUCTION_ORDER_DOCUMENT:
					return "list_service";
			}
			return null;
		}
		
		public function get documentThemeColor():Object
		{
			switch (_categoryNumber)
			{
				case CATEGORY_SALES:
				case CATEGORY_SALES_CORRECTION:
				case CATEGORY_SALES_ORDER_DOCUMENT:
				case CATEGORY_SALES_PREORDER:
					return IconManager.SALES_COLOR;
				case CATEGORY_SERVICE_DOCUMENT:
					return IconManager.SERVICE_COLOR;
				case CATEGORY_PURCHASE:
				case CATEGORY_PURCHASE_CORRECTION:
					return IconManager.PURCHASE_COLOR;
				case CATEGORY_WAREHOUSE_RESERVATION:
					return IconManager.WAREHOUSE_COLOR;
				case CATEGORY_WAREHOUSE_ORDER:
					return IconManager.WAREHOUSE_COLOR;
				case CATEGORY_WAREHOUSE:
				case CATEGORY_WAREHOUSE_INCOME_CORRECTION:
				case CATEGORY_WAREHOUSE_OUTCOME_CORRECTION:
					return IconManager.WAREHOUSE_COLOR;
				case CATEGORY_FINANCIAL_DOCUMENT:
					return IconManager.FINANCIAL_COLOR;
				case CATEGORY_PROTOCOL_COMPLAINTS:
					return IconManager.COMPLAINT_COLOR;	
				case CATEGORY_PRODUCTION_ORDER_DOCUMENT:
					return IconManager.SERVICE_COLOR;
				case CATEGORY_TECHNOLOGY_DOCUMENT:
					return IconManager.SERVICE_COLOR;
			}
			return null;
		}
				
		public function get documentThemeColorLight():Object
		{
			
			switch (_categoryNumber)
			{
				case CATEGORY_SALES:
				case CATEGORY_SALES_CORRECTION:
				case CATEGORY_SALES_ORDER_DOCUMENT:
				case CATEGORY_SALES_PREORDER:
					return IconManager.SALES_COLOR_LIGHT;
				case CATEGORY_SERVICE_DOCUMENT:
					return IconManager.SERVICE_COLOR_LIGHT;
				case CATEGORY_PURCHASE:
				case CATEGORY_PURCHASE_CORRECTION:
					return IconManager.PURCHASE_COLOR_LIGHT;
				case CATEGORY_WAREHOUSE_RESERVATION:
					return IconManager.WAREHOUSE_COLOR_LIGHT;
				case CATEGORY_WAREHOUSE_ORDER:
					return IconManager.WAREHOUSE_COLOR_LIGHT;
				case CATEGORY_WAREHOUSE:
				case CATEGORY_WAREHOUSE_INCOME_CORRECTION:
				case CATEGORY_WAREHOUSE_OUTCOME_CORRECTION:
					return IconManager.WAREHOUSE_COLOR_LIGHT;
				case CATEGORY_FINANCIAL_DOCUMENT:
					return IconManager.FINANCIAL_COLOR_LIGHT;
				case CATEGORY_PROTOCOL_COMPLAINTS:
					return IconManager.COMPLAINT_COLOR_LIGHT;
				case CATEGORY_PRODUCTION_ORDER_DOCUMENT:
					return IconManager.SERVICE_COLOR_LIGHT
			}
			return null;
		}
		/**
		 * Is true when the type represents a warehouse document.
		 */
		public function get isInventoryDocument():Boolean
		{
			return documentCategory == INVENTORY_DOCUMENT; 
		}
		
		public function get isWarehouseDocument():Boolean
		{
			return documentCategory == WAREHOUSE_DOCUMENT; 
		}
		
		public function get isFinancialDocument():Boolean
		{
			return documentCategory == FINANCIAL_DOCUMENT;
		}
		
		public function get isIncomeFinancialDocument():Boolean
		{
			return documentCategory == FINANCIAL_DOCUMENT && financialDirection == 1;
		}
		
		public function get isOutcomeFinancialDocument():Boolean
		{
			return documentCategory == FINANCIAL_DOCUMENT && financialDirection == -1;
		}
		
		/**
		 * Indicates the direction of a warehouse document eg. WAREHOUSE_INCOME or WAREHOUSE_OUTCOME_SHIFT.
		 * Is null if the direction is undefined.
		 */
		public function get warehouseDirection():String
		{
			if (_xmlOptions.@warehouseDirection.length() == 0) return null;
			else return _xmlOptions.@warehouseDirection.toString();
		}
		
		/**
		 * Is true when the type represents a warehouse document which increases the quantity on stock.
		 */
		public function get isWarehouseIncome():Boolean
		{
			return warehouseDirection == WAREHOUSE_INCOME || warehouseDirection == WAREHOUSE_INCOME_SHIFT;
		}

		/**
		 * Is true when the type represents a warehouse document which decreases the quantity on stock.
		 */
		public function get isWarehouseOutcome():Boolean
		{
			return warehouseDirection == WAREHOUSE_OUTCOME || warehouseDirection == WAREHOUSE_OUTCOME_SHIFT;
		}
		
		/**
		 * Is true if the document is a warehouse shift document.
		 */
		public function get isShiftDocument():Boolean
		{
			return warehouseDirection == WAREHOUSE_INCOME_SHIFT || warehouseDirection == WAREHOUSE_OUTCOME_SHIFT;
		}
		
		public function get isIncomeShiftDocument():Boolean
		{
			return warehouseDirection == WAREHOUSE_INCOME_SHIFT;
		}

		/**
		 * Is true when the type represents a commercial document.
		 */		
		public function get isCommercialDocument():Boolean
		{
			return documentCategory == COMMERCIAL_DOCUMENT && !isOrderDocument;
		}

		/**
		 * Is true when the type represents a sales document.
		 */		
		public function get isSalesDocument():Boolean
		{
			return categoryNumber == CATEGORY_SALES;
		}
		
		public function get isServiceDocument():Boolean
		{
			return categoryNumber == CATEGORY_SERVICE_DOCUMENT;
		}
		
		public function get isProductionDocument():Boolean
		{
			return categoryNumber == CATEGORY_PRODUCTION_ORDER_DOCUMENT;
		}
		
		public function get isSalesOrderDocument():Boolean
		{
			return categoryNumber == CATEGORY_SALES_ORDER_DOCUMENT;
		}

		/**
		 * Is true when the type represents a purchase document.
		 */
		public function get isPurchaseDocument():Boolean
		{
			return categoryNumber == CATEGORY_PURCHASE;
		}
		
		public function get isPurchaseCorrectionDocument():Boolean
		{
			return categoryNumber == CATEGORY_PURCHASE_CORRECTION;
		}

		/**
		 * Is true when the type represents an order document (reservation or supply order).
		 */
		public function get isOrderDocument():Boolean
		{
			return categoryNumber == CATEGORY_WAREHOUSE_RESERVATION || categoryNumber == CATEGORY_WAREHOUSE_ORDER;
		}
		/**
		 * Is true when the type represents an warehouse reservation.
		 */
		public function get isWarehouseReservation():Boolean
		{
			return categoryNumber == CATEGORY_WAREHOUSE_RESERVATION ;
		}
		/**
		 * Is true when the type represents an warehouse order.
		 */
		public function get isWarehouseOrder():Boolean
		{
			return  categoryNumber == CATEGORY_WAREHOUSE_ORDER;
		}
		
		/**
		 * Contains a numeric category identifier, such as <code>CATEGORY_SALES</code>.
		 */
		public function get categoryNumber():uint
		{
			return _categoryNumber;
		}
		
		/**
		 * Contains the dictionary entry associated with the given type with <code>&lt;entry/&gt;</code>
		 * as a root element.
		 */
		public function get dictionaryTypeDescriptor():XML
		{
			return _dictionaryTypeDescriptor;
		}
		
		/**
		 * Contains the document type localized label, eg. "Paragon".
		 */
		public function get label():String
		{
			if(_dictionaryTypeDescriptor.label.@lang.length())
				return _dictionaryTypeDescriptor.label.(@lang==LanguageManager.getInstance().currentLanguage)[0];
				else
				
			return _dictionaryTypeDescriptor.label.toString();
		}

		/**
		 * Contains the document type symbol, eg. "PAR".
		 */
		public function get symbol():String
		{
			return _dictionaryTypeDescriptor.symbol.toString();
		}
		
		/**
		 * List of identifiers of available document features.
		 */
		public function get availableFeatures():Array
		{
			var ret:Array = null;
			if (_xmlOptions)
			{
				ret = [];
				for each (var x:XML in _xmlOptions.documentFeatures.id)
				{
					ret.push(String(x));
				}
			}
			return ret;
		}
		
		public function getDefaultFiscalPrintProfile():String
		{
			var profileNames:Array = String(_xmlOptions.@defaultFiscalPrintProfile).replace(" ","").split(",");
			return String(profileNames[0]);
		}
		
		public function getDefaultTextPrintProfile():String
		{
			var profileNames:Array = String(_xmlOptions.@defaultTextPrintProfile).replace(" ","").split(",");
			return String(profileNames[0]);
		}
		
		public function getDefaultPrintProfile():String
		{
			var profileNames:Array = String(_xmlOptions.@defaultPrintProfile).replace(" ","").split(",");
			return String(profileNames[0]);
		}
		public function getAuthorization():String
		{
			var profileNames:Array = String(_xmlOptions.@authorization).replace(" ","").split(",");
			return String(profileNames[0]);
		}
		public function getCustomUrl():String
		{
			var profileNames:Array = String(_xmlOptions.@customUrl).replace(" ","").split(",");
			return String(profileNames[0]);
		}
		public function getPricing():String
		{
			var profileNames:Array = String(_xmlOptions.@pricing).replace(" ","").split(",");
			return String(profileNames[0]);
		}
		public function getEnableExpirationDate():String
		{
			
			var profileNames:Array = String(_xmlOptions.@enableExpirationDate).replace(" ","").split(",");
			return String(profileNames[0]);
		}
		public function getDateValidation():String
		{
			var profileNames:Array = String(_xmlOptions.@dateValidation).replace(" ","").split(",");
			return String(profileNames[0]);
		}
		public function getCashId():Array
		{
			return String(_xmlOptions.@cashId).replace(" ","").split(",");
		
		}
		public function getTransferId():Array
		{
			return String(_xmlOptions.@transferId).replace(" ","").split(",");
		}
		public function getServiceId():String
		{
			return String(_xmlOptions.@serviceId).replace(" ","");
		}
		public function getDefaultPrintLocationProfile():String
		{
			var profileNames:Array = String(_xmlOptions.@defaultPrintLocationProfile).replace(" ","").split(",");
			return String(profileNames[0]);
		}
		
		public function get isShiftOrder():Boolean
		{
			if(_xmlOptions.@isShiftOrder.length() > 0 && _xmlOptions.@isShiftOrder == "true")
				return true;
			else
				return false;
		}
		
		public function get isIncomeShiftOrder():Boolean
		{
			if(this.isShiftOrder && this.categoryNumber == CATEGORY_WAREHOUSE_ORDER)
				return true;
			else
				return false;
		}
		
		public function get allowGuiCalculationTypeChange():Boolean
		{
			if(_xmlOptions.@allowGuiCalculationTypeChange.length() > 0 && _xmlOptions.@allowGuiCalculationTypeChange == "false")
				return false;
			else
				return true;
		}
		
		/**
		 * List of issue options available for the document type (eg. generateDocument).
		 */
		public function get availableIssueOptions():XMLList
		{
			return _xmlOptions.issueOptions.*;
		}
		// list for default documents for clipboard
		public function get availableDefaultDocuments():XMLList
		{
			return _xmlOptions.defaultDocuments.*;
		}
		/**
		 * List of available types/templates of derived documents, issued from document of given type.
		 */
		public function get availableDerivedDocuments():XMLList
		{
			return _xmlOptions.derivedDocuments.*;
		}
		/**
		 * List of available payment methods for the document type.  
		 */
		public function get availablePaymentMethods():XMLList
		{
			var result:XMLList = new XMLList();
			for each (var method:XML in _xmlOptions.paymentMethods.*)
				result += DictionaryManager.getInstance().getById(method.toString());
			return result;
		}
		
		/**
		 * Node found under xmlOptions/root/*Document.
		 */
		public function get xmlOptions():XML
		{
			return _xmlOptions;
		}
		
		public function get automaticPrint():String
		{
			return _xmlOptions.@automaticPrint;
		}

		public function get isCorrectiveDocument():Boolean
		{
			switch (categoryNumber)
			{
				case CATEGORY_SALES_CORRECTION:
				case CATEGORY_PURCHASE_CORRECTION:
				case CATEGORY_WAREHOUSE_INCOME_CORRECTION:
				case CATEGORY_WAREHOUSE_OUTCOME_CORRECTION:
					return true;
				default:
					return false;
			}
		}
		
		public function get financialDirection():Number
		{
			switch(String(_xmlOptions.@financialDirection))
			{
				case 'income': return 1;
				case 'outcome': return -1;
				default: return NaN;
			}
		}
		
		public function get documentTemplateChangePossibilities():Array
		{
			var result:Array = [];
			
			for each (var template:XML in _xmlOptions.documentTemplateChange.template)
			{
				result.push(template.toString());
			}
			return result;
		}
		
		public function getRelatedDocumentsToPrintSymbols():XML
		{
			if(_xmlOptions.relatedDocumentsToPrint.length() == 0) return null;
			
			return XML(_xmlOptions.relatedDocumentsToPrint);
		}
		
		public function get recalculateLines():Boolean
		{
			if (_xmlOptions.@recalculate.length() == 0) return true;
			else if(_xmlOptions.@recalculate.toString()=="false")
					return false;
			else
				return true;
		}
	}
}