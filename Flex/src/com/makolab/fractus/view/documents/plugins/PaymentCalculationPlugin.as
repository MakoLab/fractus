package com.makolab.fractus.view.documents.plugins
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	import com.makolab.fractus.view.documents.documentControls.IDocumentControl;
	
	public class PaymentCalculationPlugin implements IDocumentControl
	{
		public function PaymentCalculationPlugin()
		{
			super();
		}
		
		private var availablePaymentMethods:XMLList = new XMLList();
		private var millisecondsPerDay:int = 1000 * 60 * 60 * 24;
		private var _documentObject:DocumentObject;
		
		public function set documentObject(value:DocumentObject):void
		{
			_documentObject = value;
			
			if(_documentObject){
				var typeDescriptor:DocumentTypeDescriptor = new DocumentTypeDescriptor(documentObject.xml.documentTypeId.toString());
				//podpięcie listenerow
				_documentObject.addEventListener(DocumentEvent.DOCUMENT_FIELD_CHANGE,handleDocumentFieldChange);
				_documentObject.addEventListener(DocumentEvent.DOCUMENT_PAYMENT_CHANGE,handleDocumentPaymentChange);
				_documentObject.addEventListener(DocumentEvent.DOCUMENT_LINE_CHANGE,handleDocumentLineChange);
				_documentObject.addEventListener(DocumentEvent.DOCUMENT_ATTRIBUTE_CHANGE,handleDocumentAttributeChange);
				//dostepne metody platnosci
				availablePaymentMethods = new XMLList();
				var documentTypes:XMLList = DictionaryManager.getInstance().dictionaries.documentTypes.(valueOf().id == String(_documentObject.typeDescriptor.typeId));
				var defaultPaymentMethodId:String = null;
				if(documentTypes.length() > 0)
				{
					for each (var paymentMethodId:XML in documentTypes.xmlOptions.root.commercialDocument.paymentMethods.id)
					{
						var paymentMethod:XMLList = DictionaryManager.getInstance().dictionaries.paymentMethod.(id.toString() == String(paymentMethodId));
						if(paymentMethod.length() > 0)
						{
							availablePaymentMethods = availablePaymentMethods + paymentMethod[0];
							if (Tools.parseBoolean(paymentMethodId.@isDefault)) defaultPaymentMethodId = String(paymentMethodId);
						}
					}
				}
				
				if(documentObject.paymentsXML.payment.length() == 0){
					
					if(_documentObject.isNewDocument && !typeDescriptor.isOrderDocument){
						var currencyId:String = _documentObject.xml.documentCurrencyId.toString();
						var template:XML = <payment><paymentCurrencyId>{currencyId}</paymentCurrencyId></payment>;
						template.appendChild(<exchangeRate>{documentObject.xml.exchangeRate.toString()}</exchangeRate>);
						template.appendChild(<exchangeScale>{documentObject.xml.exchangeScale.toString()}</exchangeScale>);
						template.appendChild(<exchangeDate>{documentObject.xml.exchangeDate.toString()}</exchangeDate>);
						if (defaultPaymentMethodId != null) template.appendChild(<paymentMethodId>{defaultPaymentMethodId}</paymentMethodId>);
						_documentObject.paymentsXML.appendChild(template);
						_documentObject.dispatchEvent(DocumentEvent.createEvent(DocumentEvent.DOCUMENT_PAYMENT_CHANGE,null,template));
					}
				}
				
				//dodawanie domyślnej platnosci w zaleznosci od typu dokumentu.
				/* if(
					!typeDescriptor.isOrderDocument 
					&& _documentObject.isNewDocument
					&& _documentObject.paymentsXML.payment.length() == 0
				){
					var currencyId:String = DictionaryManager.getInstance().dictionaries.currency.(symbol.toString() == "PLN").id.toString(); // todo PLN hardcode - moze tak byc? //tomek
					var template:XML = <payment><amount>0</amount><paymentCurrencyId>{currencyId}</paymentCurrencyId></payment>;
					_documentObject.paymentsXML.appendChild(template);
					_documentObject.dispatchEvent(DocumentEvent.createEvent(DocumentEvent.DOCUMENT_PAYMENT_CHANGE,null,template));
					//calculatePayment(_documentObject.paymentsXML.payment[0]);
				} */
				//jesli edytujemy dokument (lub wystawiamy z innego dokumentu?) przeliczamy na dzień dobry ilość dni bo tego nie ma w xmlu dokumentu.
				//if(!documentObject.isNewDocument){
					for each (var payment:XML in _documentObject.paymentsXML.payment){
						if(payment.dueDays.length() == 0) calculatePayment(payment,"dueDate");
					}
				//}
			}
		}
		
		public function get documentObject():DocumentObject
		{
			return _documentObject;
		}
		
		private function recalculateAll():void
		{
			var payments:XMLList = _documentObject.paymentsXML.payments.payment;
			for each (var payment:XML in payments){
				calculatePayment(payment);
			}
		}
		
		private function calculatePayment(payment:XML,field:String = null):void
		{
			var issueDate:Date = Tools.isoToDate(documentObject.xml.issueDate);
			var supplierDocumentDate:Date;
			var dueDate:Date = Tools.isoToDate(payment.dueDate.toString());
				dueDate.hours = 0;
				dueDate.minutes = 0;
				dueDate.seconds = 0;
				dueDate.milliseconds = 0;
			var x:XML;
			x = DictionaryManager.getInstance().getByName("Attribute_SupplierDocumentDate");
			var supplierDateAttrFieldId:String = x ? String(x.id) : null;
			x = DictionaryManager.getInstance().getByName("Attribute_SupplierCorrectiveDocumentDate");
			var supplierCorrectiveDateAttrFieldId:String = x ? String(x.id) : null;
			var attributes:XMLList = documentObject.attributes.source.(documentFieldId.toString() == supplierDateAttrFieldId || documentFieldId.toString() == supplierCorrectiveDateAttrFieldId);
			
			//sprawdzanie czy nasz dokument to faktura do paragonu
			/* var invoiceToBill:Boolean;
			for each(var relation:XML in documentObject.xml.relations.relation){
				if(relation.relationType.toString() == "1")//relationType = 1 - typ relacji 'faktura do paragonu'
				{
					invoiceToBill = true;
				}
			} */
			
			if(attributes.length() > 0 && String(attributes[0].value) != "")supplierDocumentDate = Tools.isoToDate(attributes[0].value.toString());
			if(payment.dueDate.length() == 0 || documentObject.allowPaymentsEdit)
			{
				if (supplierDocumentDate) payment.date = Tools.dateToString(supplierDocumentDate);
				else payment.date = Tools.dateToString(issueDate);
			}
			
			var paymentDate:Date = Tools.isoToDate(payment.date.toString());
			var onlyDate:Date = paymentDate;
			onlyDate.hours = 0;
			onlyDate.minutes = 0;
			onlyDate.seconds = 0;
			onlyDate.milliseconds = 0;
			
			switch (field){
				case null:
					if(String(payment.paymentMethodId) == "" && availablePaymentMethods.length() > 0){
						// jesli wybrany jest kontrahent to sprawdzamy czy ma domyslna forme platnosci.
						if(documentObject.xml.contractor.length() > 0){
							var fieldId:String = DictionaryManager.getInstance().getIdByName("Attribute_DefaultPaymentMethod");
							var contractorAttributes:XMLList = documentObject.xml.contractor.contractor.attributes.attribute.(contractorFieldId.toString() == fieldId); 
							//jesli kontrahent ma dfp to jej uzywamy
							if(contractorAttributes.length() > 0)
								payment.paymentMethodId = contractorAttributes[0].value.toString();
							else
								payment.paymentMethodId = availablePaymentMethods[0].id.toString(); 
						}else{
							payment.paymentMethodId = availablePaymentMethods[0].id.toString();
						}
					}
					if(String(payment.dueDays) == "" || String(payment.dueDate) == "")
						_documentObject.dispatchEvent(new DocumentEvent(DocumentEvent.DOCUMENT_PAYMENT_CHANGE,false,false,"paymentMethod",payment));
					var currencyId:String = documentObject.xml.documentCurrencyId.toString();//"F01007BF-1ADA-4218-AE77-52C106DA4105"; // todo harcode
					if(String(payment.paymentCurrencyId) == "")payment.paymentCurrencyId = currencyId;
					if(String(payment.date) == "")payment.date = Tools.dateToString(paymentDate);
					if(String(payment.amount) == ""){
						//payment.amount = 0;
						calculateAmount(payment);
					}
					break;
				case "dueDate":
					if (String(payment.paymentMethodId) != ""){
						payment.dueDays = Math.round(Tools.datesDifference(dueDate,onlyDate).days);
					}
					break;
				case "paymentDate":
				case "dueDays":
					if (String(payment.paymentMethodId) != ""){
						dueDate = new Date(onlyDate.getTime());// + (Number(payment.dueDays) * millisecondsPerDay));
						dueDate.date += Number(payment.dueDays);
						payment.dueDate = Tools.dateToString(dueDate);
					}
					break;
				case "paymentMethod":
					payment.dueDays = availablePaymentMethods.(id.toString() == payment.paymentMethodId.toString()).dueDays.toString();
					_documentObject.dispatchEvent(new DocumentEvent(DocumentEvent.DOCUMENT_PAYMENT_CHANGE,false,false,"dueDays",payment));
					break;
				case "amount":
					calculateAmount(payment);
					break;
			}
		}
		
		private function handleDocumentFieldChange(event:DocumentEvent):void
		{
			var p:XML;
			switch(event.fieldName){
				case "contractor":
					//zmiana formy platnosci na domyslna kontrahenta
					if(_documentObject.xml.contractor.contractor.length() != 0)
					{
						var contractor:XML = _documentObject.xml.contractor.contractor[0];
						var paymentAttributeId:String = DictionaryManager.getInstance().dictionaries.contractorAttributes.(name.toString() == "Attribute_DefaultPaymentMethod").id.toString();
						var attributes:XMLList = contractor[0].attributes.attribute.(contractorFieldId.toString() == paymentAttributeId);
						var salesDocRelation:Boolean = false;
						if (_documentObject.xml.relations && _documentObject.xml.relations.relation.(relationType.toString() == "1").length() > 0)salesDocRelation = true;
						if (attributes.length() > 0 
							&& _documentObject.paymentsXML 
							&& _documentObject.paymentsXML.payment.length() == 1 
							&& _documentObject.isNewDocument
							&& !salesDocRelation
							&& _documentObject.typeDescriptor.xmlOptions.paymentMethods.id.(valueOf().toString() == attributes[0].value.toString()).length() > 0
							)
						{
							_documentObject.paymentsXML.payment[0].paymentMethodId = attributes[0].value.toString();
							
							_documentObject.dispatchEvent(new DocumentEvent(DocumentEvent.DOCUMENT_PAYMENT_CHANGE,false,false,"paymentMethod",_documentObject.paymentsXML.payment[0]));
						}
						/* for each (var payment:XML in _documentObject.paymentsXML.payment){
							payment.contractor = _documentObject.xml.contractor;
						} */
					}
					break;
				case "totalForPayment":
					calculateAmount();
					break;
				case "issueDate":
					for each (p in _documentObject.paymentsXML.payment){
						calculatePayment(p,"paymentDate");
					}
					break;
				case "currency":
					for each (p in _documentObject.paymentsXML.payment){
						p.paymentCurrencyId.* = documentObject.xml.documentCurrencyId.toString();
						p.exchangeRate = documentObject.xml.exchangeRate.toString();
						p.exchangeScale = documentObject.xml.exchangeScale.toString();
						p.exchangeDate = documentObject.xml.exchangeDate.toString();
					}
					break;
			}
		}
		
		private function calculateAmount(payment:XML = null):void
		{
			var amount:Number;
			if(payment){
				// jesli zmieniamy jedna z dwoch platnosci, przeliczamy ta druga.// zmiana planow: poki co, przeliczamy tylko jesli waluta platnosci jest taka sama jak dokumentu 
				if (_documentObject.paymentsXML.payment.length() == 2 && _documentObject.paymentsXML.payment[0].paymentCurrencyId.toString() == documentObject.documentCurrencyId){//_documentObject.paymentsXML.payment[1].paymentCurrencyId.toString()){
					if(_documentObject.paymentsXML.payment[0] == payment){
						if(String(_documentObject.paymentsXML.payment[0].amount) == "")_documentObject.paymentsXML.payment[0].amount = 0;
						amount = Tools.round(Number(_documentObject.totalForPayment.toString()) - Number(_documentObject.paymentsXML.payment[0].amount.toString()),2);
						if (Number(_documentObject.paymentsXML.payment[1].amount) != amount)
						{
							_documentObject.paymentsXML.payment[1].amount = amount;
							_documentObject.dispatchEvent(new DocumentEvent(DocumentEvent.DOCUMENT_PAYMENT_CHANGE,false,false,"amount",_documentObject.paymentsXML.payment[1]));
						}
					}
					if(_documentObject.paymentsXML.payment[1] == payment){
						if(String(_documentObject.paymentsXML.payment[1].amount) == "")_documentObject.paymentsXML.payment[1].amount = 0;
						amount = Tools.round(Number(_documentObject.totalForPayment.toString()) - Number(_documentObject.paymentsXML.payment[1].amount.toString()),2);
						if (Number(_documentObject.paymentsXML.payment[1].amount) != amount)
						{
							_documentObject.paymentsXML.payment[0].amount = amount;
							_documentObject.dispatchEvent(new DocumentEvent(DocumentEvent.DOCUMENT_PAYMENT_CHANGE,false,false,"amount",_documentObject.paymentsXML.payment[0]));
						}
					}
				//jesli jest tylko jedna platnosc bez wartosci, ustawiamy kwote na wartosc dokumentu
				}else if(_documentObject.paymentsXML.payment.length() == 1 && String(payment.amount) == ""){
					_documentObject.paymentsXML.payment[0].amount = _documentObject.totalForPayment;
					_documentObject.dispatchEvent(new DocumentEvent(DocumentEvent.DOCUMENT_PAYMENT_CHANGE,false,false,"amount",_documentObject.paymentsXML.payment[0]));
				//jesli mamy wiecej niz 2 platnosci to wstawiamy 0 bo wiemy ze to nowa platnosc.
				}else if(_documentObject.paymentsXML.payment.length() > 2 && String(payment.amount) == ""){
					payment.amount = 0;
					_documentObject.dispatchEvent(new DocumentEvent(DocumentEvent.DOCUMENT_PAYMENT_CHANGE,false,false,"amount",payment));
				}
			//wykonuje się przy usuwaniu paymenta i zmianie wartosci dokumentu
			}else{
				if (_documentObject.paymentsXML.payment.length() == 1){
					amount = _documentObject.totalForPayment;
					if (Number(_documentObject.paymentsXML.payment[0].amount) != amount && _documentObject.paymentsXML.payment[0].paymentCurrencyId.toString() == documentObject.documentCurrencyId)
					{
						_documentObject.paymentsXML.payment[0].amount = amount;
					}
						_documentObject.dispatchEvent(new DocumentEvent(DocumentEvent.DOCUMENT_PAYMENT_CHANGE,false,false,"amount",_documentObject.paymentsXML.payment[0]));
				}
			}
		}
		
		private function handleDocumentLineChange(event:DocumentEvent):void
		{
			
		}
		
		private function handleDocumentPaymentChange(event:DocumentEvent):void
		{
			if(event.line)
				calculatePayment(XML(event.line),event.fieldName);
			else
				calculateAmount();
		}
		
		private function handleDocumentAttributeChange(event:DocumentEvent):void
		{
			if(event.fieldName == "Attribute_SupplierDocumentDate" || event.fieldName == "Attribute_SupplierCorrectiveDocumentDate"){
				for each (var payment:XML in _documentObject.paymentsXML.payment){
					calculatePayment(payment,"paymentDate");
				}
			}
		}
	}
}