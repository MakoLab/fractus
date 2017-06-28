package com.makolab.fractus.view.documents.plugins
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.components.util.CurrencyManager;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.document.BusinessObject;
	import com.makolab.fractus.model.document.CommercialDocumentLine;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	import com.makolab.fractus.model.document.WarehouseDocumentLine;
	import com.makolab.fractus.view.documents.documentControls.IDocumentControl;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.events.ValidationResultEvent;
	import mx.validators.ValidationResult;

	public class DocumentValidationPlugin implements IDocumentControl
	{
		//errorcodes
		public static const WAREHOUSE_EQUAL_ERRORCODE:String = 'warehouseEqual';
		public static const NO_LINES_ERRORCODE:String = 'noLines';
		public static const NO_CONTRACTOR_ERRORCODE:String = 'noContractor';
		public static const CONTRACTOR_FORBIDDEN_ERRORCODE:String = 'contractorForbidden';
		public static const TARGET_WAREHOUSE_NOT_SPECIFIED_ERRORCODE:String = 'targetWarehouseNotSpecified';
		public static const LINES_VALIDATION_ERRORCODE:String = 'linesValidation';
		public static const NO_FINANCIAL_REGISTER_ERRORCODE:String = 'NoFinancialRegisterSpecified';
		public static const SLOTS_ON_NONALOCATIONS_WAREHOUSE_ERRORCODE:String = 'slotsOnNonAlocationsWarehouse';
		public static const SHIFTS_ON_NONALOCATIONS_WAREHOUSE_ERRORCODE:String = 'shiftsOnNonAlocationsWarehouse';
		public static const NO_CUSTOMER_TYPE_SELECTED_ERRORCODE:String = 'noCustomerTypeSelected';
		public static const LINES_PAYMENTS_DIFFERENCE_ERRORCODE:String = 'linesPaymentsDifference';
		
		//subfields
		public static const TARGET_WAREHOUSE_SUBFIELD:String = 'targetWarehouse';
		public static const LINES_SUBFIELD:String = 'lines';
		public static const CONTRACTOR_SUBFIELD:String = 'contractor';
		public static const FINANCIAL_REGISTER_SUBFIELD:String = 'financialRegister';
		public static const CALCULATION_TYPE_SUBFIELD:String = 'netCalculationType';
		
		public function DocumentValidationPlugin()
		{
		}

		private var _documentObject:DocumentObject;
		public function set documentObject(value:DocumentObject):void
		{
			_documentObject = value;
			_documentObject.addEventListener(DocumentEvent.DOCUMENT_COMMIT, handleCommit);
			for each (var line:BusinessObject in _documentObject.lines)
			{
				if (line['quantity'] < 0)
				{
					_documentObject.allowNegativeLines = true;
					break;
				}
			}
		}
		
		public function get documentObject():DocumentObject
		{
			return _documentObject;
		}
		
		private var ignoreWarnings:Boolean = false;
		
		protected function handleCommit(event:DocumentEvent):void
		{
			var result:Array = validate();
			if (result && result.length > 0)
			{
				var msg:String = '';
				var errMsg:String = '';
				var error:Boolean = false;
				var warning:Boolean = false;
				var proceedQuestion:String = LanguageManager.getLabel('documents.proceedQuestion');
				for (var i:String in result)
				{
					if (msg) msg += "\n";
					msg += ValidationResult(result[i]).errorMessage;
					warning = true;
					if (ValidationResult(result[i]).isError){
						errMsg += ValidationResult(result[i]).errorMessage + "\n";
						error = true;
					}
				}
				if (warning && !ignoreWarnings) event.preventDefault();
				if (warning && !error && !ignoreWarnings)Alert.show(msg + "\n" + proceedQuestion, LanguageManager.getLabel('documents.validationErrors'), Alert.YES | Alert.NO, null, alertCloseHandler, null, Alert.NO);
				if (error) Alert.show(errMsg, LanguageManager.getLabel('documents.validationErrors'));
				if(ignoreWarnings)ignoreWarnings = false;
			}
		}
		
		private function alertCloseHandler(event:CloseEvent):void
		{
			if(event.detail == Alert.YES){
				ignoreWarnings = true;
				_documentObject.dispatchEvent(new DocumentEvent(DocumentEvent.DOCUMENT_COMMIT));
			}
		}
		
		protected function validate():Array
		{
			var result:Array = [];
			
			financialRegisterCheck(result);
			
			//sprawdzenie na MMkach czy jest wybrany magazyn docelowy
			oppositeWarehouseIdCheck(result);
			
			//sprawdzenie czy na przynajmniej jednej linii jest wybrany towar
			noLinesCheck(result);
			
			//roznego rodzaju walidacje linii
			linesCheck(result);
			
			//sprawdzenie czy dokument powinien posiadac kontrahenta
			contractorExistenceCheck(result);
			
			//sprawdzanie, czy uzytkownik wybral kontenery mimo, ze FZ nie generuje PZ.
			slotCheck(result);
			
			//sprawdzenie, czy uzytkownik wybral transze mimo, ze FS nie generuje WZ.
			shiftCheck(result);
			
			//sprawdzenei czy wybrano typ zamowienia sprzedazowego
			salesOrderTypeCheck(result);
			
			//sprawdzamy, czy suma z platnosci jest zgodna z wartoscia dokumentu
			paymentsLinesEqualityCheck(result);
			
			documentObject.dispatchEvent(new ValidationResultEvent(ValidationResultEvent.INVALID, false, false, null, result));
				
			return result;
		}
		
		private function salesOrderTypeCheck(result:Array):void
		{
			if(documentObject.typeDescriptor.categoryNumber == DocumentTypeDescriptor.CATEGORY_SALES_ORDER_DOCUMENT &&
				(documentObject.xml.netCalculationType.@selected.length() == 0 || documentObject.xml.netCalculationType.@selected == ""))
			{
				result.push(new ValidationResult(true, CALCULATION_TYPE_SUBFIELD, NO_CUSTOMER_TYPE_SELECTED_ERRORCODE, LanguageManager.getLabel("documents.messages.noCustomerTypeSelected")));
			}
		}
		
		private function slotCheck(result:Array):void
		{
			if(
				documentObject.typeDescriptor.isPurchaseDocument
				&& documentObject.documentOptions 
				&& documentObject.documentOptions.(valueOf().@method == "incomeFromPurchase").length() > 0
				&& documentObject.documentOptions.(valueOf().@method == "incomeFromPurchase")[0].@selected == "0"
			){
				for(var i:int=0; i < documentObject.lines.length; i++){
					if(documentObject.lines[i].shifts && documentObject.lines[i].shifts.length > 0)
					{
						result.push(new ValidationResult(false,LINES_SUBFIELD,SLOTS_ON_NONALOCATIONS_WAREHOUSE_ERRORCODE, LanguageManager.getLabel("documents.messages.slotsOnNonAlocationsWarehouse")));
						break;
					}
				}
			}
		}
		
		private function shiftCheck(result:Array):void
		{
			if(
				documentObject.typeDescriptor.isSalesDocument
				&& documentObject.documentOptions
				&& documentObject.documentOptions.(valueOf().@method == "outcomeFromSales").length() > 0
				&& documentObject.documentOptions.(valueOf().@method == "outcomeFromSales")[0].@selected == "0"
			){
				for(var i:int=0; i < documentObject.lines.length; i++){
					if(documentObject.lines[i].shifts && documentObject.lines[i].shifts.length > 0)
						result.push(new ValidationResult(false,LINES_SUBFIELD,SHIFTS_ON_NONALOCATIONS_WAREHOUSE_ERRORCODE, LanguageManager.getLabel("documents.messages.shiftsOnNonAlocationsWarehouse")));
						break;
				}
			}
		}
		
		private function financialRegisterCheck(result:Array):void
		{
			if (documentObject.typeDescriptor.isFinancialDocument && !String(documentObject.xml.financialReport.financialReport.financialRegisterId))
			{
				// tutaj negatywny wynik walidacji - brak rejestru/raportu
				result.push(new ValidationResult(true, FINANCIAL_REGISTER_SUBFIELD, NO_FINANCIAL_REGISTER_ERRORCODE, LanguageManager.getLabel("documents.messages.noFinancialRegisterSpecified")));
			}
		}
		
		private function linesCheck(result:Array):void
		{
			var ordinalNumber:int = 1;
			var fullError:String = "";
			var lblLine:String = LanguageManager.getLabel("common.line");
			
			for each(var line:BusinessObject in documentObject.lines)
			{
				var valResultKey:String = getDocumentLineColor(line);
				
				if(valResultKey)
				{
					if(fullError != "") fullError += "\n";
					
					fullError += (lblLine + " " + ordinalNumber + ": " + LanguageManager.getLabel(valResultKey));
				}
				
				ordinalNumber++;				
			}
			
			if(fullError != "")
				result.push(new ValidationResult(true, LINES_SUBFIELD, LINES_VALIDATION_ERRORCODE, fullError));
		}
				
		private function oppositeWarehouseIdCheck(result:Array):void
		{
			if (documentObject.typeDescriptor.isShiftDocument)
			{
				var attribId:String = DictionaryManager.getInstance().dictionaries.documentFields.(valueOf().name == 'ShiftDocumentAttribute_OppositeWarehouseId').id;
				if (documentObject.attributes.source.(documentFieldId == attribId).value == String(documentObject.xml.warehouseId))
				{
					result.push(new ValidationResult(true, TARGET_WAREHOUSE_SUBFIELD, WAREHOUSE_EQUAL_ERRORCODE, LanguageManager.getLabel("documents.messages.shiftWarehouseEqual")));
				}
				else if (documentObject.attributes.source.(documentFieldId == attribId).value == "")
				{
					result.push(new ValidationResult(true, TARGET_WAREHOUSE_SUBFIELD, TARGET_WAREHOUSE_NOT_SPECIFIED_ERRORCODE, LanguageManager.getLabel("documents.messages.destinationShiftWarehouseNotSpecified")));
				}
			}
		}
		
		public static function getDocumentLineColor(line:BusinessObject):String
		{
			var cLine:CommercialDocumentLine = line as CommercialDocumentLine;
			//var ccLine:CorrectiveCommercialDocumentLine = line as CorrectiveCommercialDocumentLine;
			var wLine:WarehouseDocumentLine = line as WarehouseDocumentLine;
			//var cwLine:CorrectiveWarehouseDocumentLine = line as CorrectiveWarehouseDocumentLine;
			/*if (ccLine)
			{
				// TODO walidacja pozycji korekty handl.	
			}
			else if (cwLine)
			{
				// TODO walidacja pozycji korekty mag
			}
			else */
			var allowNegative:Boolean = false;
			
			if (cLine)
			{
				if (!cLine.itemId || !cLine.itemName)
					return null;
					
				allowNegative = cLine.documentObject.allowNegativeLines;
				
				//poniewaz nie ma specyfikacji w formie papierowej jakie typy dokumentow moga miec dopuszczalne ceny
				//to zrobie to lopatologicznie zeby mozna bylo nawet co dziennie zmieniac ta implementacje w latwy sposob
				//bo na pewno co jakis czas beda sie zmienialy zalozenia co do tego ktory dokument moze miec cene 0 a ktory nie
				switch(cLine.documentObject.typeDescriptor.categoryNumber)
				{
					case DocumentTypeDescriptor.CATEGORY_PURCHASE:
						if(!allowNegative && cLine.quantity <= 0)
							return "error.lines.quantityBelowOrEqualZero";
						
						if (!allowNegative && (cLine.netValue <= 0 || isNaN(cLine.netValue)))
					 		return "error.lines.netValueBelowOrEqualZero";
						break;
					case DocumentTypeDescriptor.CATEGORY_PURCHASE_CORRECTION:
						if(!allowNegative && cLine.quantity < 0)
							return "error.lines.quantityBelowOrEqualZero2";
						
						if (!allowNegative && (cLine.netValue < 0 || isNaN(cLine.netValue)))
						 	return "error.lines.netValueBelowOrEqualZero2";
						break;
					case DocumentTypeDescriptor.CATEGORY_SALES:
						if(!allowNegative && cLine.quantity <= 0)
							return "error.lines.quantityBelowOrEqualZero";
						
						if (!allowNegative && (cLine.netValue <= 0 || isNaN(cLine.netValue)))
					 		return "error.lines.netValueBelowOrEqualZero";
						break;
					case DocumentTypeDescriptor.CATEGORY_SALES_CORRECTION:
						if(!allowNegative && cLine.quantity < 0)
							return "error.lines.quantityBelowOrEqualZero2";
						
						if (!allowNegative && (cLine.netValue < 0 || isNaN(cLine.netValue)))
						 	return "error.lines.netValueBelowOrEqualZero2";
						break;
					case DocumentTypeDescriptor.CATEGORY_WAREHOUSE_ORDER:
						if(!allowNegative && cLine.quantity <= 0)
							return "error.lines.quantityBelowOrEqualZero";
						
						if (!allowNegative && (cLine.netValue < 0 || isNaN(cLine.netValue)))
					 		return "error.lines.netValueBelowOrEqualZero2";
						break;
					case DocumentTypeDescriptor.CATEGORY_WAREHOUSE_RESERVATION:
						if(!allowNegative && cLine.quantity <= 0)
							return "error.lines.quantityBelowOrEqualZero";
						
						if (!allowNegative && (cLine.netValue < 0 || isNaN(cLine.netValue)))
						 	return "error.lines.netValueBelowOrEqualZero2";
						break;
				}
			}
			else if (wLine)
			{
				if (!wLine.itemId || !wLine.itemName)
					return null;
					
				allowNegative = wLine.documentObject.allowNegativeLines;
					
				switch(wLine.documentObject.typeDescriptor.categoryNumber)
				{
					case DocumentTypeDescriptor.CATEGORY_WAREHOUSE:
						if(wLine.documentObject.typeDescriptor.isWarehouseIncome)
						{
							if (!allowNegative && (wLine.value < 0 || isNaN(wLine.value)))
					 			return "error.lines.netValueBelowOrEqualZero2";
						}
						
						if(!allowNegative && wLine.quantity <= 0)
							return "error.lines.quantityBelowOrEqualZero";
						break;
					case DocumentTypeDescriptor.CATEGORY_WAREHOUSE_INCOME_CORRECTION:
						if (!allowNegative && (wLine.value < 0 || isNaN(wLine.value)))
					 		return "error.lines.netValueBelowOrEqualZero2";
					 	
					 	if(!allowNegative && wLine.quantity < 0)
							return "error.lines.quantityBelowOrEqualZero2";
						break;
					case DocumentTypeDescriptor.CATEGORY_WAREHOUSE_OUTCOME_CORRECTION:
						if(!allowNegative && wLine.quantity < 0)
							return "error.lines.quantityBelowOrEqualZero2";
						break;
				}
			}
			return null;
		}
		
		private function contractorExistenceCheck(result:Array):void
		{
			var optionality:String = String(documentObject.typeDescriptor.dictionaryTypeDescriptor.xmlOptions.root.commercialDocument.@contractorOptionality);
			//jezeli typ ma zdefiniowany warunek na kontrahenta
			if (optionality && optionality != "")
			{
				if(optionality.toUpperCase() == "MANDATORY" && documentObject.xml.contractor.length() == 0)
					result.push(new ValidationResult(true, CONTRACTOR_SUBFIELD, NO_CONTRACTOR_ERRORCODE, LanguageManager.getLabel("documents.messages.contractorIsMandatory")));
				else if(optionality.toUpperCase() == "FORBIDDEN" && documentObject.xml.contractor.length() != 0)
					result.push(new ValidationResult(true, CONTRACTOR_SUBFIELD, CONTRACTOR_FORBIDDEN_ERRORCODE, LanguageManager.getLabel("documents.messages.contractorIsForbidden")));
			}
		}
		
		private function noLinesCheck(result:Array):void
		{
			/*var isAtLeastOneItem:Boolean = false;
			
			for each (var line:Object in documentObject.lines)
			{
				if(line.itemId)
					isAtLeastOneItem = true;
			}
			
			if(!isAtLeastOneItem)*/
			if(documentObject.lines.length == 0 && documentObject.typeDescriptor.categoryNumber != DocumentTypeDescriptor.CATEGORY_SERVICE_DOCUMENT)
				result.push(new ValidationResult(true, LINES_SUBFIELD, NO_LINES_ERRORCODE, LanguageManager.getLabel("documents.messages.noLines")));
		}
		
		private function paymentsLinesEqualityCheck(result:Array):void
		{
			if (!documentObject.typeDescriptor.isCommercialDocument) return;
			if (documentObject.typeDescriptor.categoryNumber==DocumentTypeDescriptor.CATEGORY_SALES_ORDER_DOCUMENT) return;
			var amount:Number = 0;
			var fullXML:XML = documentObject.getFullXML();
			for each(var payment:XML in documentObject.paymentsXML.payment){
				amount += CurrencyManager.paymentToDocument(payment,documentObject);
			}
			//var difference:String = CurrencyManager.formatCurrency(Math.abs(documentObject.totalForPayment - amount));
			if (!isNaN(documentObject.totalForPayment) && documentObject.totalForPayment != amount)
			{
				result.push(new ValidationResult(false, CALCULATION_TYPE_SUBFIELD, LINES_PAYMENTS_DIFFERENCE_ERRORCODE, LanguageManager.getLabel("documents.messages.linesPaymentsDifference")));
			}
		}
	}
}