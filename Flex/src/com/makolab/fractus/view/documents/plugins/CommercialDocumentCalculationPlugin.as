package com.makolab.fractus.view.documents.plugins
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.fractus.model.*;
	import com.makolab.fractus.model.document.BusinessObject;
	import com.makolab.fractus.model.document.BusinessObjectAttribute;
	import com.makolab.fractus.model.document.CommercialDocumentLine;
	import com.makolab.fractus.model.document.CommercialDocumentVatTableEntry;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.view.documents.documentEditors.DocumentEditor;
	
	import mx.collections.ArrayCollection;
	
	public class CommercialDocumentCalculationPlugin extends AbstractDocumentCalculationPlugin
	{
		public static const CALC_NET_PRICE:String = '1';
		public static const CALC_GROSS_PRICE:String = '0';
		public static const SUM_LINES:String = '0';
		public static const SUM_VAT_RATES:String = '1';
		
		public static const CALCULATION_LOGIC_SALES:int = 0;
		public static const CALCULATION_LOGIC_PURCHASE:int = 1;
		
		[Bindable]
		public var calculationType:String;
		public var summationType:String = SUM_VAT_RATES;
		
		[Bindable] 
		public var totalCost:Number = 0;
		[Bindable] 
		public var valuatedLinesProfitMargin:Number = 0;
		[Bindable]
		public var totalQuantity:Number;
		[Bindable]
		public var totalValue:Number;
		[Bindable]
		public var totalLines:Number;
		[Bindable]
		public var totalProfitMargin:Number;
		
		public var calculationLogic:int = CALCULATION_LOGIC_SALES;

		/*
		function DocumentCalculationManager(CalculationType, SummationType) {
			this.quantity = null;				// ilosc [jm]
			this.vatRateId = null;				// stawka VAT [%]
			this.discountRate = null;			// rabat [%]
			this.DiscountAmount = null;			// wartosc rabatu
			this.initialNetPrice = null;				// cena netto (przed rab.)
			this.initialGrossPrice = null;				// cena brutto (przed rab.)
			this.netPrice = null;		// cena netto po rabacie
			this.grossPrice = null;	// cena brutto po rabacie
			this.netValue = null;				// wartosc netto pozycji
			this.grossValue = null;				// wartosc brutto pozycji
			this.vatValue = null;			// wartosc vat pozycji
			this.lastPurchasePrice = null;		// ost. cena zakupu
			this.lastPurchasePriceProfitMargin = null;	// marza dla pozycji wg OCZ
			
			this.TotalNet = null;				// wart netto dokumentu
			this.TotalGross = null;				// wart brutto dokumentu
			this.TotalVatAmount = null;			// wart vat dokumentu
			this.Totalquantity = null;			// laczna ilosc towarow na dokumencie
			this.Subtotals = null;				// tablica z podsumowaniami vat
			
			// delivery calculation
			this.PurchasePrice = null;			// purchase price of one delivery
			this.Profit = null;					// sales price - purchase price
			this.Commission = null;				// profit / sales price
			this.MaxDiscount = null;			// discount such that commission = 0
			
			this.CalculationType = CalculationType;
			this.SummationType = SummationType;
		}
		*/
		
		override public function initialize(docObj:DocumentObject, docXML:DocumentEditor):void
		{
			super.initialize(docObj, docXML);
			calculateSystemCurrencyNetValue();
			docObj.addEventListener(DocumentEvent.DOCUMENT_FIELD_CHANGE,handleDocumentFieldChange);
			updateCalculationType();
			setDiffTable();
			setDocumentValue();
			//setTotalForPayment();
			updateStatistics();
		}
		
		private function calculateSystemCurrencyNetValue(line:CommercialDocumentLine = null):void
		{
			if (line)
				line.systemCurrencyNetPrice = line.netPrice * parseFloat(line.documentObject.xml.exchangeRate.toString()) / parseFloat(line.documentObject.xml.exchangeScale.toString());
			else
				for each (var l:CommercialDocumentLine in documentObject.lines)
				{
					l.systemCurrencyNetPrice = l.netPrice * parseFloat(l.documentObject.xml.exchangeRate.toString()) / parseFloat(l.documentObject.xml.exchangeScale.toString());
				}
		}
		
		private function updateStatistics():void
		{
			var tl:Number = 0, tq:Number = 0;
			
			for each(var line:CommercialDocumentLine in documentObject.lines)
			{
				if(!line.itemId)
					continue;
					
				tl++;
				tq += line.quantity;
			}
			
			this.totalLines = tl;
			this.totalQuantity = tq;
			this.totalValue = parseFloat(documentObject.xml.netValue);
		}
		
		public function updateCalculationType():void
		{
			if (documentObject) this.calculationType = this.documentObject.xml.netCalculationType.*;
		}
		
		//todo nowy event do przeliczania całego dokumentu
		
		override protected function documentLineChangeHandler(event:DocumentEvent):void
		{
			updateCalculationType();
			super.documentLineChangeHandler(event);
		} 
		
		override protected function documentRecalculateHandler(event:DocumentEvent, fieldName:String = null):void
		{
			updateCalculationType();
			super.documentRecalculateHandler(event, 'initialNetPrice');
		}
		
		override protected function documentFieldChangeHandler(event:DocumentEvent):void
		{
			if ( event.fieldName == "currency" && documentObject.typeDescriptor.symbol == "FVE")
			{
				for each ( var line:CommercialDocumentLine in documentObject.lines )
				{
					line.initialNetPrice = line.systemCurrencyNetPrice / parseFloat(line.documentObject.xml.exchangeRate.toString()) * parseFloat(line.documentObject.xml.exchangeScale.toString());
					line.initialNetPrice = line.initialNetPrice / (1 - (line.discountRate / 100));
					calculateLine(line,"initialNetPrice");
				}
				calculateTotal(documentObject);
			}	
		}
		
		private var vatRates:Object;
		
		protected function getVatRate(id:String):Number
		{
			var vatRate:XML = DictionaryManager.getInstance().getById(id);
			return vatRate ? parseFloat(vatRate.rate) : 0;
		}
		
		private function getComplaintDiscount():Number
		{
			var attr:XML = documentObject.getAttribute('Attribute_ComplaintDiscount');
			if (attr == null) return 0;
			var G:Number = parseFloat(attr.value);
			if (isNaN(G)) return 0;
			else return G;
		}
		
		private function getDiscountRate(line:CommercialDocumentLine):Number
		{
			var L:Number = line.discountRate;
			var G:Number = getComplaintDiscount();
			return 100 * (1 - (1 - L/100)*(1 - G/100));
		}
		
		private function setDiscountRate(discountRate:Number, line:CommercialDocumentLine):void
		{
			var G:Number = getComplaintDiscount();
			var R:Number = discountRate;
			var L:Number = 100 * (1 - ((100 - R)/(100 - G)));
			line.discountRate = L;
		}
		
		override public function calculateLine(modifiedLine:BusinessObject, modifiedField:String):void
		{
			/*
			oznaczenia:
			R = discountRate
			L = rabatNaLinii
			G = rabatNaNaglowku
			
			R = 100 * (1 - (1 - L/100)*(1 - G/100)) jezeli discountRate wystepuje po prawej stronie rownania
			L = 100 * (1 - ((100 - R)/(100 - G))) jezeli discountRate wystepuje po lewej stronie rownania w kodzie
			*/
			var line:CommercialDocumentLine = modifiedLine as CommercialDocumentLine;
			if (calculationType == CALC_NET_PRICE)
			{
				switch (modifiedField)
				{
					case "initialNetPrice":
						if (this.calculationLogic == CALCULATION_LOGIC_SALES)
						{
							// dla dok sprzedazy - cena przed rabatem powoduje przeliczenie cen po rabacie
							line.initialGrossPrice = round(line.initialNetPrice * (1 + getVatRate(line.vatRateId) / 100));
						}
						else if (this.calculationLogic == CALCULATION_LOGIC_PURCHASE)
						{
							// dla dok zakupu - przeliczamy narzut, nie zmieniamy ceny zakupu
							/* wersja z narzutem
							if (line.netPrice) line.discountRate = round(100 * (line.initialNetPrice / line.netPrice - 1), 4);
							else line.discountRate = 0;
							*/
							if (line.initialNetPrice != 0) line.discountRate = round(100 * (1 - line.netPrice / line.initialNetPrice), 4);
							else line.discountRate = 0;
						}
						calculateLine(line, "discountRate");
						break;
					case "initialGrossPrice":
						line.initialNetPrice = round(line.initialGrossPrice / (1 + getVatRate(line.vatRateId) / 100));
						calculateLine(line, "initialNetPrice");
						break;
					case "discountRate":
						if (this.calculationLogic == CALCULATION_LOGIC_SALES)
						{
							// dla dok sprzedazy - obliczamy cene po rabacie na podstawie rabatu, przeliczamy wartosci
							//line.netPrice = round(line.initialNetPrice * (1 - line.discountRate / 100));
							line.netPrice = round(line.initialNetPrice * (1 - this.getDiscountRate(line) / 100));
							line.grossPrice = round(line.netPrice * (1 + round(getVatRate(line.vatRateId) / 100)));
							line.systemCurrencyNetPrice = line.netPrice * parseFloat(line.documentObject.xml.exchangeRate.toString()) / parseFloat(line.documentObject.xml.exchangeScale.toString());
							calculateLine(line, "quantity");
							//line.DiscountAmount = round(line.initialNetPrice - line.netPrice);
						}
						else if (this.calculationLogic == CALCULATION_LOGIC_PURCHASE)
						{
							// dla dok zakupu - obliczamy cene sprzedazy na podstawie ceny zakupu i narzutu
							// line.initialNetPrice = round(line.netPrice * (1 + line.discountRate / 100));	// narzut
							if (line.discountRate != 100) line.initialNetPrice = round(100 * line.netPrice / (100 - line.discountRate), 2);		// marża
							line.initialGrossPrice = round(line.initialNetPrice * (1 + round(getVatRate(line.vatRateId) / 100)));
						}
						line.discountNetValue = round(line.initialNetPrice - line.netPrice);
						line.discountGrossValue = round(line.initialGrossPrice - line.grossPrice);
						break;
					case "netPrice":
						if (this.calculationLogic == CALCULATION_LOGIC_SALES)
						{
							// dla dok sprzedazy - przeliczamy marze i jeszcze raz puszczamy liczenie calej pozycji
							// jezeli cena przed rabatem jest 0 to przeliczamy zeby nie byla zerem
							if (line.initialNetPrice == 0)
							{
								//if (line.discountRate == 100) line.discountRate = 0;
								//line.initialNetPrice = 100 * line.netPrice / (100 - line.discountRate);
								if (this.getDiscountRate(line) == 100) this.setDiscountRate(0, line);
								line.initialNetPrice = 100 * line.netPrice / (100 - this.getDiscountRate(line));
								calculateLine(line, "initialNetPrice");
							}
							//if (line.initialNetPrice) line.discountRate = round(100 * (1 - line.netPrice / line.initialNetPrice), 4);
							if (line.initialNetPrice) this.setDiscountRate(round(100 * (1 - line.netPrice / line.initialNetPrice), 4), line);
							line.systemCurrencyNetPrice = line.netPrice * parseFloat(line.documentObject.xml.exchangeRate.toString()) / parseFloat(line.documentObject.xml.exchangeScale.toString());
							calculateLine(line, "discountRate");
						}
						else if (this.calculationLogic == CALCULATION_LOGIC_PURCHASE)
						{
							// dla dok zakupu - przeliczamy ceny sprzedazy i marze na ich podstawie oraz liczymy wartosci
							//line.initialNetPrice = line.netPrice * (1 + line.discountRate / 100);
							line.grossPrice = round(line.netPrice * (1 + getVatRate(line.vatRateId) / 100));
							calculateLine(line, "initialNetPrice");
							calculateLine(line, "quantity");
						}
						break;
					case "systemCurrencyNetPrice":
						line.netPrice = line.systemCurrencyNetPrice / parseFloat(line.documentObject.xml.exchangeRate.toString()) * parseFloat(line.documentObject.xml.exchangeScale.toString());
						calculateLine(line, "netPrice");
						break;
					case "grossPrice":
						line.netPrice = round(line.grossPrice / (1 + getVatRate(line.vatRateId) / 100));
						//line.systemCurrencyNetPrice = Tools.round(line.netPrice / parseFloat(line.documentObject.xml.exchangeRate.toString()) * parseFloat(line.documentObject.xml.exchangeScale.toString()));
						calculateLine(line, "netPrice");
						break;
					case "quantity":
						
						line.netValue = round(line.netPrice * line.quantity);
						line.vatValue = round(line.netValue * getVatRate(line.vatRateId) / 100);
						line.grossValue = round(Number(line.netValue) + Number(line.vatValue));
						//line.lastPurchasePriceProfitMargin =
						//	line.netPrice != 0 ? round(100 * (1 - line.lastPurchasePrice / line.netPrice)) : 0;
						break;
					case "netValue":
						if (!line.quantity) break;
						line.netPrice = round(line.netValue / line.quantity);
						calculateLine(line, "netPrice");
						break;
					case "grossValue":
						line.netValue = round(line.grossValue / (1 + getVatRate(line.vatRateId) / 100));				
						calculateLine(line, "netValue");
						break;
					/*case "lastPurchasePrice":
						line.lastPurchasePriceProfitMargin =
							line.netPrice != 0 ? round(100 * (1 - line.lastPurchasePrice / line.netPrice)) : 0;
						break;*/
					case "vatRateId":
						calculateLine(line, "initialNetPrice");
						if (this.calculationLogic == CALCULATION_LOGIC_PURCHASE) calculateLine(line, "netPrice");
						break;
				}
			}
			else if (calculationType == CALC_GROSS_PRICE)
			{
				switch (modifiedField) {
					case "initialNetPrice":
						line.initialGrossPrice = round(line.initialNetPrice * (1 + getVatRate(line.vatRateId) / 100));
						calculateLine(line, "initialGrossPrice");
						break;
					case "initialGrossPrice":
						if (this.calculationLogic == CALCULATION_LOGIC_SALES)
						{
							// dla dok sprzedazy - przeliczenie cen po rabacie
							line.initialNetPrice = round(line.initialGrossPrice / (1 + getVatRate(line.vatRateId) / 100));
						}
						else if (this.calculationLogic == CALCULATION_LOGIC_PURCHASE)
						{
							// dla dok zakupu - przeliczenie marzy
							if (line.initialGrossPrice != 0) line.discountRate = round(100 * (1 - line.grossPrice / line.initialGrossPrice), 4);
							else line.discountRate = 0;
						}
						calculateLine(line, "discountRate");
						break;
					case "discountRate":
						if (this.calculationLogic == CALCULATION_LOGIC_SALES)
						{
							//line.grossPrice = round(line.initialGrossPrice * (1 - line.discountRate / 100));
							line.grossPrice = round(line.initialGrossPrice * (1 - this.getDiscountRate(line) / 100));
							line.netPrice = round(line.grossPrice / (1 + getVatRate(line.vatRateId) / 100));
							line.systemCurrencyNetPrice = line.netPrice * parseFloat(line.documentObject.xml.exchangeRate.toString()) / parseFloat(line.documentObject.xml.exchangeScale.toString());
							//line.DiscountAmount = round(line.initialGrossPrice - line.grossPrice);
							calculateLine(line, "quantity");
						}
						else if (this.calculationLogic == CALCULATION_LOGIC_PURCHASE)
						{
							// dla dok zakupu - obliczamy cene sprzedazy na podstawie ceny zakupu i narzutu
							// line.initialNetPrice = round(line.netPrice * (1 + line.discountRate / 100));	// narzut
							if (line.discountRate != 100) line.initialGrossPrice = round(100 * line.grossPrice / (100 - line.discountRate), 2);		// marża
							line.initialNetPrice = round(line.initialGrossPrice / (1 + round(getVatRate(line.vatRateId) / 100)));
						}
						line.discountNetValue = round(line.initialNetPrice - line.netPrice);
						line.discountGrossValue = round(line.initialGrossPrice - line.grossPrice);
						break;
					case "netPrice":
						line.grossPrice = round(line.netPrice * (1 + getVatRate(line.vatRateId) / 100));
						line.systemCurrencyNetPrice = line.netPrice * parseFloat(line.documentObject.xml.exchangeRate.toString()) / parseFloat(line.documentObject.xml.exchangeScale.toString());
						calculateLine(line, "grossPrice");
						break;
					case "systemCurrencyNetPrice":
						line.netPrice = line.systemCurrencyNetPrice / parseFloat(line.documentObject.xml.exchangeRate.toString()) * parseFloat(line.documentObject.xml.exchangeScale.toString());
						calculateLine(line, "netPrice");
						break;
					case "grossPrice":
						if (this.calculationLogic == CALCULATION_LOGIC_SALES)
						{
							if (!line.initialGrossPrice) {
								//if (line.discountRate == 100) line.discountRate = 0;
								//line.initialGrossPrice = 100 * line.grossPrice / (100 - line.discountRate);
								if (this.getDiscountRate(line) == 100) this.setDiscountRate(0, line);
								line.initialGrossPrice = 100 * line.grossPrice / (100 - this.getDiscountRate(line));
								calculateLine(line, "initialGrossPrice");
							}
							if (line.initialGrossPrice) line.discountRate = round(100 * (1 - line.grossPrice / line.initialGrossPrice), 4);
							calculateLine(line, "discountRate");
						}
						else if (this.calculationLogic == CALCULATION_LOGIC_PURCHASE)
						{
							line.netPrice = round(line.grossPrice / (1 + getVatRate(line.vatRateId) / 100));
							calculateLine(line, "initialGrossPrice");
							calculateLine(line, "quantity");
						}
						break;
					case "quantity":
					var num:Number=line.grossPrice * line.quantity;
					var num3:Number=round(num,3)-round(num,2)*1.000;
					var num2:Number=num3>=0.0049999?round(num)+0.01:round(num);
						line.grossValue =num2;
						line.vatValue = round(line.grossValue * getVatRate(line.vatRateId) / (getVatRate(line.vatRateId) + 100));
						line.netValue = round(line.grossValue - line.vatValue);
						//line.lastPurchasePriceProfitMargin =
						//	line.netPrice != 0 ? round(100 * (1 - line.lastPurchasePrice / line.netPrice)) : 0;
						break;
					case "netValue":
						line.grossValue = round(line.netValue * (1 + getVatRate(line.vatRateId) / 100));
						calculateLine(line, "grossValue");
						break;
					case "grossValue":
						if (!line.quantity) break;
						line.grossPrice = round(line.grossValue / line.quantity);
						calculateLine(line, "grossPrice");
						break;
					/*case "lastPurchasePrice":
						line.lastPurchasePriceProfitMargin =
							line.netPrice != 0 ? round(100 * (1 - line.lastPurchasePrice / line.netPrice)) : 0;
						break;*/
					case "vatRateId":
						calculateLine(line, "initialGrossPrice");
						if (this.calculationLogic == CALCULATION_LOGIC_PURCHASE) calculateLine(line, "grossPrice");
						break;
				}
			}
			line.discountNetValue = line.initialNetPrice - line.netPrice;
			line.discountGrossValue = line.initialGrossPrice - line.grossPrice;
			line.initialNetValue = line.initialNetPrice * line.quantity;
			line.initialGrossValue = line.initialGrossPrice * line.quantity;
		}

		private var
			TotalNet:Number = 0,
			TotalGross:Number = 0,
			TotalVatAmount:Number = 0,
			Totalquantity:Number = 0,
			VatTotals:Number = 0,
			Subtotals:Object;

		override public function calculateTotal(doc:DocumentObject, fieldName:String = null):void
		{
			var tl:Number = 0, tq:Number = 0;
			var tc:Number = 0,nv:Number = 0, vlnv:Number = 0, dpm:Number = 0, vlpm:Number = 0;
			
			TotalNet = TotalGross = Totalquantity =
			TotalVatAmount = VatTotals = 0;
			Subtotals = {};
			//var lines:XMLList = XMLList(doc.lines.line);
			
			var attr:XML = DictionaryManager.getInstance().getByName("LineAttribute_SalesOrderGenerateDocumentOption", "documentFields");
			var lineAttrId:String = attr ? attr.id : null;
			
			for each (var line:CommercialDocumentLine in doc.lines)
			{
				if(!line.itemId)
					continue;
					
				if(lineAttrId != null) //w systemie zdefiniowano atrybut
				{
					var a:BusinessObjectAttribute = line.getAttributeByFieldId(lineAttrId);
					
					if(a != null && (String(a.value) == "2" || String(a.value) == "4"))
						continue;
				}
					
				addLine(line);
				tl++;
				tq += line.quantity;
				
				nv += line["netValue"];
				tc += isNaN(line["cost"]) ? 0 : line["cost"];
				vlnv += isNaN(line["cost"]) ? 0 : line["netValue"];
			}
			
			this.totalLines = tl;
			this.totalQuantity = tq;
			
			nv = nv * Number(documentObject.xml.exchangeRate) / Number(documentObject.xml.exchangeScale.toString());
			vlnv = vlnv * Number(documentObject.xml.exchangeRate) / Number(documentObject.xml.exchangeScale.toString());
			
			this.totalProfitMargin = (nv - tc)/nv * 100;
			this.valuatedLinesProfitMargin = (vlnv - tc)/vlnv * 100;
			this.totalCost = tc;
			
			if(fieldName != "cost"){
				calculateSum();
				
				//przeliczanie tabeli VAT jesli wlaczone automatyczne przeliczanie.
				var attributeDefinition:XML = DictionaryManager.getInstance().getByName("Attribute_ManualVatTable");
				var attribute:XMLList;
				var fieldId:String;
				if (attributeDefinition) fieldId = attributeDefinition.id.toString();
				var atrrs:XMLList = doc.attributes.source.attribute;
				attribute = doc.attributes.source.(documentFieldId.toString() == fieldId);
				if (!attribute || attribute.length() == 0 || (attribute && attribute.length() > 0 && attribute[0].value.toString() != "1"))
				{
					calculateVatTable();
					setDiffTable();
					documentObject.dispatchEvent(new DocumentEvent(DocumentEvent.DOCUMENT_FIELD_CHANGE,false,false,"vatTable"));
				}else{
					if (documentObject.typeDescriptor.isCorrectiveDocument)
					{
						calculateVatTable();
						setAutomaticDiffTable();
						calculateVatTableFromDifferential();
					}
				}
			}
		}
		
		private function calculateVatTable():void
		{
			var vatTable:ArrayCollection = new ArrayCollection();
			for (var j:String in Subtotals)
			{
				var subtotal:Object = Subtotals[j];
				var vtEntry:CommercialDocumentVatTableEntry = new CommercialDocumentVatTableEntry();
				
				vtEntry.netValue = subtotal.Net;
				vtEntry.grossValue = subtotal.Gross;
				vtEntry.vatValue = subtotal.VatAmount;
				vtEntry.vatRateId = subtotal.vatRateId;
				
				vatTable.addItem(vtEntry);
				
				/*vatTable.addItem(
					{
						netValue : subtotal.Net,
						grossValue : subtotal.Gross,
						vatValue : subtotal.VatAmount,
						vatRateId : subtotal.vatRateId
					}
				);*/
			}
		
			//doc.vatTable = vatTable;
			this.mergeVatTableEntries(documentObject, vatTable);
		}
		
		private function calculateVatTableFromDifferential():void
		{
			var newVatTable:ArrayCollection = new ArrayCollection();
			
			for each (var entryBeforeCorrection:CommercialDocumentVatTableEntry in documentObject.vatTableBeforeCorrection)
			{
				var newVatTableEntry:CommercialDocumentVatTableEntry = new CommercialDocumentVatTableEntry();
				//newVatTableEntry.id = entryBeforeCorrection.id;
				//newVatTableEntry.version = entryBeforeCorrection.version;
				newVatTableEntry.netValue = entryBeforeCorrection.netValue;
				newVatTableEntry.grossValue = entryBeforeCorrection.grossValue;
				newVatTableEntry.vatValue = entryBeforeCorrection.vatValue;
				newVatTableEntry.vatRateId = entryBeforeCorrection.vatRateId;
				newVatTable.addItem(newVatTableEntry);
			}
			
			var vatTableEntry:CommercialDocumentVatTableEntry;
			
			for each (var differentialEntry:CommercialDocumentVatTableEntry in documentObject.differentialVatTable)
			{
				vatTableEntry = null;
				
				for (var i:int = 0; i < newVatTable.length; i++)
				{
					if (differentialEntry.vatRateId == newVatTable[i].vatRateId)
					{
						vatTableEntry = new CommercialDocumentVatTableEntry();
						vatTableEntry.vatRateId = differentialEntry.vatRateId;
						if (newVatTable[i].id) vatTableEntry.id = newVatTable[i].id;
						if (newVatTable[i].version) vatTableEntry.version = newVatTable[i].version;
						vatTableEntry.grossValue = this.round(differentialEntry.grossValue + newVatTable[i].grossValue);
						vatTableEntry.netValue = this.round(differentialEntry.netValue + newVatTable[i].netValue);
						vatTableEntry.vatValue = this.round(differentialEntry.vatValue + newVatTable[i].vatValue);
						newVatTable[i] = vatTableEntry;
					}
				}
				
				if (!vatTableEntry)
				{
					vatTableEntry = new CommercialDocumentVatTableEntry();
					vatTableEntry.vatRateId = differentialEntry.vatRateId;
					vatTableEntry.grossValue = differentialEntry.grossValue;
					vatTableEntry.netValue = differentialEntry.netValue;
					vatTableEntry.vatValue = differentialEntry.vatValue;
					newVatTable.addItem(vatTableEntry);
				}
			}
			
			documentObject.vatTable = newVatTable;
		}
		
		private function setDocumentValue():void
		{
			var totalNet:Number = 0;
			var totalGross:Number = 0;
			var totalVat:Number = 0;
				if (documentObject.typeDescriptor.isCorrectiveDocument)
				{
					for (var i:int = 0; i < documentObject.differentialVatTable.length; i++)
					{
						totalNet += documentObject.differentialVatTable[i].netValue;
						totalGross += documentObject.differentialVatTable[i].grossValue;
						totalVat += documentObject.differentialVatTable[i].vatValue;
					}
				}else{
					if(documentObject.vatTable){
						for (var j:int = 0; j < documentObject.vatTable.length; j++)
						{
							totalNet += documentObject.vatTable[j].netValue;
							totalGross += documentObject.vatTable[j].grossValue;
							totalVat += documentObject.vatTable[j].vatValue;
						}
					}
				}
			documentObject.xml.netValue = this.round(totalNet);
			documentObject.xml.grossValue = this.round(totalGross);
			documentObject.xml.vatValue = this.round(totalVat);
			this.totalValue = this.round(totalNet);
	
			setTotalForPayment();
		}
		
		private function handleDocumentFieldChange(event:DocumentEvent):void
		{
			if (event.fieldName == "vatTable") 
			{
				if (documentObject.typeDescriptor.isCorrectiveDocument) calculateVatTableFromDifferential();
				setDocumentValue();
			}
		}
		
		private function setDiffTable():void
		{
			if (documentObject.typeDescriptor.isCorrectiveDocument)
			{
				documentObject.differentialVatTable = 
					calculateDifferentialVatTable
					(
						documentObject.vatTableBeforeCorrection,
						documentObject.vatTable
					);
			}
		}
		
		private function setAutomaticDiffTable():void
		{
			if (documentObject.typeDescriptor.isCorrectiveDocument)
			{
				documentObject.automaticDifferentialVatTable = 
					calculateDifferentialVatTable
					(
						documentObject.vatTableBeforeCorrection,
						documentObject.vatTable
					);
			}			
		}
		
		private function setTotalForPayment():void
		{
			var doc:DocumentObject = this.documentObject;
			var total:Number = parseFloat(doc.xml.grossValue);
			var totalBefore:Number = parseFloat(doc.xml.grossValueBeforeCorrection);
			/* if (doc.typeDescriptor.isCorrectiveDocument) doc.totalForPayment = total - totalBefore;
			else  */doc.totalForPayment = total;
			doc.dispatchEvent(DocumentEvent.createEvent(DocumentEvent.DOCUMENT_FIELD_CHANGE,"totalForPayment"));
		}
		
		private function mergeVatTableEntries(doc:DocumentObject, vatTable:ArrayCollection):void
		{
			for each (var oldVtEntry:CommercialDocumentVatTableEntry in doc.vatTable)
			{
				for each(var newVtEntry:CommercialDocumentVatTableEntry in vatTable)
				{
					if(oldVtEntry.vatRateId == newVtEntry.vatRateId)
					{
						if(oldVtEntry.id)
							newVtEntry.id = oldVtEntry.id;
							
						if(oldVtEntry.version)
							newVtEntry.version = oldVtEntry.version;
					}
				}
			}
			
			doc.vatTable = vatTable;
		}
		
		private function addLine(line:CommercialDocumentLine):void
		{			
			if (this.summationType == CommercialDocumentCalculationPlugin.SUM_LINES) {
				this.TotalNet += line.netValue;
				this.TotalGross += line.grossValue;
				this.TotalVatAmount += line.vatValue;
				this.Totalquantity += line.quantity;
			}
			var vatRateId:String = String(line.vatRateId);
			var subtotal:Object = this.Subtotals[vatRateId];
			if (!subtotal) {
				subtotal = {};
				subtotal.Net = 0;
				subtotal.Gross = 0;
				subtotal.VatAmount = 0;
				subtotal.quantity = 0;
				subtotal.vatRateId = vatRateId;
				this.Subtotals[vatRateId] = subtotal;
			}
			subtotal.Net += line.netValue;
			subtotal.Gross += line.grossValue;
			subtotal.quantity += line.quantity;
			subtotal.VatAmount += line.vatValue;
		}
		
		private function calculateSum():void
		{
			var i:String, subtotal:Object;	// iteratory dla petli
			if (this.summationType == CommercialDocumentCalculationPlugin.SUM_VAT_RATES) {
				this.TotalNet = this.TotalGross = this.TotalVatAmount = 0;
				for (i in this.Subtotals) {
					subtotal = this.Subtotals[i];
					if (this.calculationType == CommercialDocumentCalculationPlugin.CALC_NET_PRICE) {
						subtotal.Net = this.round(subtotal.Net);
						subtotal.VatAmount = this.round(subtotal.Net * getVatRate(subtotal.vatRateId) / 100);			
						subtotal.Gross = this.round(subtotal.Net + subtotal.VatAmount);
					}
					else if (this.calculationType == CommercialDocumentCalculationPlugin.CALC_GROSS_PRICE) {
						subtotal.Gross = this.round(subtotal.Gross);
						subtotal.VatAmount = this.round(subtotal.Gross * getVatRate(subtotal.vatRateId) / (100 + getVatRate(subtotal.vatRateId)));
						subtotal.Net = this.round(subtotal.Gross - subtotal.VatAmount);
					}
					this.TotalNet += subtotal.Net;
					this.TotalGross += subtotal.Gross;
					this.TotalVatAmount += subtotal.VatAmount;
					this.Totalquantity += subtotal.quantity;
				}
			}
			else {
				for (i in this.Subtotals) {
					subtotal = this.Subtotals[i];
					subtotal.Net = this.round(subtotal.Net);
					subtotal.Gross = this.round(subtotal.Gross);
					subtotal.VatAmount = this.round(subtotal.VatAmount);
					subtotal.quantity = this.round(subtotal.quantity);
				}
			}
			this.TotalNet = this.round(this.TotalNet);
			this.TotalGross = this.round(this.TotalGross);
			this.TotalVatAmount = this.round(this.TotalVatAmount);
			this.Totalquantity = this.round(this.Totalquantity);
		}
		
		public static function calculateDifferentialVatTable(initialTable:ArrayCollection, finalTable:ArrayCollection):ArrayCollection
		{
			var diffTable:ArrayCollection = new ArrayCollection();
			var initialEntry:CommercialDocumentVatTableEntry, newEntry:CommercialDocumentVatTableEntry, diffEntry:CommercialDocumentVatTableEntry;
			// tworzenie mapowania id stawki -> wpis dla aktualnej tabeli vat
			var rate:Object;
			var rates:Object = {};
			var ratesArray:Array = [];
			for each (var rateId:String in DictionaryManager.getInstance().dictionaries.vatRates.id)
			{
				rate = { id : rateId, before : null, after : null };
				rates[rateId] = rate;
				ratesArray.push(rate);
			}
			for each (initialEntry in initialTable) rates[initialEntry.vatRateId].before = initialEntry;
			for each (newEntry in finalTable) rates[newEntry.vatRateId].after = newEntry;
			
			// tworzenie wpisow roznicowych w oparciu o pierwotne wpisy
			for each (rate in ratesArray)
			{
				if (!rate.before && !rate.after) continue;
				initialEntry = rate.before ? rate.before : new CommercialDocumentVatTableEntry();
				newEntry = rate.after ? rate.after : new CommercialDocumentVatTableEntry();
				diffEntry = new CommercialDocumentVatTableEntry();
				diffEntry.vatRateId = rate.id;
				diffEntry.netValue = newEntry.netValue - initialEntry.netValue;
				diffEntry.grossValue = newEntry.grossValue - initialEntry.grossValue;
				diffEntry.vatValue = newEntry.vatValue - initialEntry.vatValue;
				diffTable.addItem(diffEntry);
			}
			
			return diffTable;
		}
	}
}

// fields of x:
// netValue, grossValue, vatValue, LinevatRateId, LinevatRateIdId
/*
DocumentCalculationManager.prototype.addLine = function(x) {

}

DocumentCalculationManager.prototype.calculateSum = function() {

}

DocumentCalculationManager.prototype.getDocumentTotal = function() {
	return this.TotalGross;
	/* the amount to pay should always be the gross value
	switch (this.CalculationType) {
		case DocumentCalculationManager.CALC_NET_PRICE: return this.TotalNet;
		case DocumentCalculationManager.CALC_GROSS_PRICE: return this.TotalGross;
	}
	
}
DocumentCalculationManager.prototype.calculateDelivery = function() {
	this.Profit = this.netPrice - this.PurchasePrice;
	this.Commission = 100 * this.Profit / this.netPrice;
	this.MaxDiscount = 100 * (this.initialNetPrice - this.PurchasePrice) / this.initialNetPrice;
}

DocumentCalculationManager.prototype.destroy = function() { Tools.destroyObject(this); }
	}
}
*/