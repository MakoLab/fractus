package com.makolab.components.util
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.components.document.GenericDocument;
	import com.makolab.components.document.IDocumentPlugin;
	
	import flash.events.Event;
	
	public class DocumentCalculationManager implements IDocumentPlugin
	{
		public static const CALC_NET_PRICE:int = 1;
		public static const CALC_GROSS_PRICE:int = 2;
		public static const SUM_LINES:int = 3;
		public static const SUM_VAT_RATES:int = 4;

		public var calculationType:int = CALC_NET_PRICE;
		public var summationType:int = SUM_VAT_RATES;

		/*
		function DocumentCalculationManager(CalculationType, SummationType) {
			this.Quantity = null;				// ilosc [jm]
			this.VatRate = null;				// stawka VAT [%]
			this.DiscountRate = null;			// rabat [%]
			this.DiscountAmount = null;			// wartosc rabatu
			this.NetPrice = null;				// cena netto (przed rab.)
			this.GrossPrice = null;				// cena brutto (przed rab.)
			this.NetPriceDiscounted = null;		// cena netto po rabacie
			this.GrossPriceDiscounted = null;	// cena brutto po rabacie
			this.LineNet = null;				// wartosc netto pozycji
			this.LineGross = null;				// wartosc brutto pozycji
			this.LineVatAmount = null;			// wartosc vat pozycji
			this.LastPurchasePrice = null;		// ost. cena zakupu
			this.LastPurchasePriceProfitMargin = null;	// marza dla pozycji wg OCZ
			
			this.TotalNet = null;				// wart netto dokumentu
			this.TotalGross = null;				// wart brutto dokumentu
			this.TotalVatAmount = null;			// wart vat dokumentu
			this.TotalQuantity = null;			// laczna ilosc towarow na dokumencie
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

		public function initialize(docXML:GenericDocument):void
		{
			//trace("doc calc initialize");
			docXML.addEventListener(DocumentEvent.DOCUMENT_LOAD, documentEventHandler);
			docXML.addEventListener(DocumentEvent.DOCUMENT_LINE_CHANGE, documentEventHandler);
		}
		
		protected function documentEventHandler(event:DocumentEvent):void
		{
			//trace("calcman: document event")
			if (event.type == DocumentEvent.DOCUMENT_LINE_CHANGE) calculateLine(event.line, event.fieldName);
			calculateTotal(event.documentXML);
			event.setUpdateDocument();
		} 
		
		public function round(x:Number, n:int=2):Number
		{
			return Tools.round(x, n);
		}	

		public function calculateLine(line:XML, modifiedField:String):void
		{
			line.VatRate = round(line.VatRate);
			if (calculationType == CALC_NET_PRICE)
			{
				switch (modifiedField)
				{
					case "NetPrice":
						line.GrossPrice = round(line.NetPrice * (1 + line.VatRate / 100));
						calculateLine(line, "DiscountRate");
						break;
					case "GrossPrice":
						line.NetPrice = round(line.GrossPrice / (1 + line.VatRate / 100));
						calculateLine(line, "NetPrice");
						break;
					case "DiscountRate":
						line.NetPriceDiscounted = round(line.NetPrice * (1 - line.DiscountRate / 100));
						line.GrossPriceDiscounted = round(line.NetPriceDiscounted * (1 + round(line.VatRate / 100)));
						line.DiscountAmount = round(line.NetPrice - line.NetPriceDiscounted);
						calculateLine(line, "Quantity");
						break;
					case "NetPriceDiscounted":
						if (!line.NetPrice) {
							if (line.DiscountRate == 100) line.DiscountRate = 0;
							line.NetPrice = 100 * line.NetPriceDiscounted / (100 - line.DiscountRate);
							calculateLine(line, "NetPrice");
						}
						if (line.NetPrice) line.DiscountRate = round(100 * (1 - line.NetPriceDiscounted / line.NetPrice), 4);
						calculateLine(line, "DiscountRate");
						break;
					case "GrossPriceDiscounted":
						line.NetPriceDiscounted = round(line.GrossPriceDiscounted / (1 + line.VatRate / 100));
						calculateLine(line, "NetPriceDiscounted");
						break;
					case "Quantity":
						line.LineNet = round(line.NetPriceDiscounted * line.Quantity);
						line.LineVatAmount = round(line.LineNet * line.VatRate / 100);
						line.LineGross = round(Number(line.LineNet) + Number(line.LineVatAmount));
						line.LastPurchasePriceProfitMargin =
							line.NetPriceDiscounted != 0 ? round(100 * (1 - line.LastPurchasePrice / line.NetPriceDiscounted)) : 0;
						break;
					case "LineNet":
						if (!line.Quantity) break;
						line.NetPriceDiscounted = round(line.LineNet / line.Quantity);
						calculateLine(line, "NetPriceDiscounted");
						break;
					case "LineGross":
						line.LineNet = round(line.LineGross / (1 + line.VatRate / 100));				
						calculateLine(line, "LineNet");
						break;
					case "LastPurchasePrice":
						line.LastPurchasePriceProfitMargin =
							line.NetPriceDiscounted != 0 ? round(100 * (1 - line.LastPurchasePrice / line.NetPriceDiscounted)) : 0;
						break;
					case "VatRate":
						calculateLine(line, "NetPrice");
						break;
				}
			}
			else if (calculationType == CALC_GROSS_PRICE)
			{
				switch (modifiedField) {
					case "NetPrice":
						line.GrossPrice = round(line.NetPrice * (1 + line.VatRate / 100));
						calculateLine(line, "GrossPrice");
						break;
					case "GrossPrice":
						line.NetPrice = round(line.GrossPrice / (1 + line.VatRate / 100));
						calculateLine(line, "DiscountRate");
						break;
					case "DiscountRate":
						line.GrossPriceDiscounted = round(line.GrossPrice * (1 - line.DiscountRate / 100));
						line.NetPriceDiscounted = round(line.GrossPriceDiscounted / (1 + line.VatRate / 100));
						line.DiscountAmount = round(line.GrossPrice - line.GrossPriceDiscounted);
						calculateLine(line, "Quantity");
						break;
					case "NetPriceDiscounted":
						line.GrossPriceDiscounted = round(line.NetPriceDiscounted * (1 + line.VatRate / 100));
						calculateLine(line, "GrossPriceDiscounted");
						break;
					case "GrossPriceDiscounted":
						if (!line.GrossPrice) {
							if (line.DiscountRate == 100) line.DiscountRate = 0;
							line.GrossPrice = 100 * line.GrossPriceDiscounted / (100 - line.DiscountRate);
							calculateLine(line, "GrossPrice");
						}
						if (!line.GrossPrice) break;
						if (line.GrossPrice) line.DiscountRate = round(100 * (1 - line.GrossPriceDiscounted / line.GrossPrice), 4);
						calculateLine(line, "DiscountRate");
						break;
					case "Quantity":
						line.LineGross = round(line.GrossPriceDiscounted * line.Quantity);
						line.LineVatAmount = round(line.LineGross * line.VatRate / (line.VatRate + 100));
						line.LineNet = round(line.LineGross - line.LineVatAmount);
						line.LastPurchasePriceProfitMargin =
							line.NetPriceDiscounted != 0 ? round(100 * (1 - line.LastPurchasePrice / line.NetPriceDiscounted)) : 0;
						break;
					case "LineNet":
						line.LineGross = round(line.LineNet * (1 + line.VatRate / 100));
						calculateLine(line, "LineGross");
						break;
					case "LineGross":
						if (!line.Quantity) break;
						line.GrossPriceDiscounted = round(line.LineGross / line.Quantity);
						calculateLine(line, "GrossPriceDiscounted");
						break;
					case "LastPurchasePrice":
						line.LastPurchasePriceProfitMargin =
							line.NetPriceDiscounted != 0 ? round(100 * (1 - line.LastPurchasePrice / line.NetPriceDiscounted)) : 0;
						break;
					case "VatRate":
						calculateLine(line, "GrossPrice");
						break;
				}
			}
		}

		private var
			TotalNet:Number = 0,
			TotalGross:Number = 0,
			TotalVatAmount:Number = 0,
			TotalQuantity:Number = 0,
			VatTotals:Number = 0,
			Subtotals:Array = [];

		public function calculateTotal(docXML:XML):void
		{
			TotalNet = TotalGross = TotalQuantity =
			TotalVatAmount = VatTotals = 0;
			Subtotals = [];
			var lines:XMLList = XMLList(docXML.Lines.Line);
			for (var i:String in lines)
			{
				addLine(lines[i]);
			}
			calculateSum();
			docXML.Total.Net = this.TotalNet;
			docXML.Total.Gross = this.TotalGross;
			docXML.Total.VatAmount = this.TotalVatAmount;
			if (!docXML.Total.hasOwnProperty("Subtotals")) docXML.Total.Subtotals = <Subtotals/>;
			delete(docXML.Total.Subtotals.*);
			for (var j:String in Subtotals)
			{
				var subtotal:Object = Subtotals[j];
				docXML.Total.Subtotals.appendChild(<Subtotal><Net>{subtotal.Net}</Net><Gross>{subtotal.Gross}</Gross><VatAmount>{subtotal.VatAmount}</VatAmount><VatRate VatRateId={j}>{subtotal.VatRate}</VatRate></Subtotal>);
			}
		}
		
		private function addLine(line:XML):void
		{			
			if (this.summationType == DocumentCalculationManager.SUM_LINES) {
				this.TotalNet += parseFloat(line.LineNet);
				this.TotalGross += parseFloat(line.LineGross);
				this.TotalVatAmount += parseFloat(line.LineVatAmount);
				this.TotalQuantity += parseFloat(line.Quantity);
			}
			var vatRateId:int = parseInt(line.VatRate.@VatRateId);
			var subtotal:Object = this.Subtotals[vatRateId];
			if (!subtotal) {
				subtotal = {};
				subtotal.Net = 0;
				subtotal.Gross = 0;
				subtotal.VatAmount = 0;
				subtotal.Quantity = 0;
				subtotal.VatRate = parseFloat(line.VatRate);
				this.Subtotals[vatRateId] = subtotal;
			}
			subtotal.Net += parseFloat(line.LineNet);
			subtotal.Gross += parseFloat(line.LineGross);
			subtotal.Quantity += parseFloat(line.Quantity);
			subtotal.VatAmount += parseFloat(line.LineVatAmount);
		}
		
		private function calculateSum():void
		{
			var i:String, subtotal:Object;	// iteratory dla petli
			if (this.summationType == DocumentCalculationManager.SUM_VAT_RATES) {
			this.TotalNet = this.TotalGross = this.TotalVatAmount = 0;
			for (i in this.Subtotals) {
				subtotal = this.Subtotals[i];
				if (this.calculationType == DocumentCalculationManager.CALC_NET_PRICE) {
					subtotal.Net = this.round(subtotal.Net);
					subtotal.VatAmount = this.round(subtotal.Net * subtotal.VatRate / 100);			
					subtotal.Gross = this.round(subtotal.Net + subtotal.VatAmount);
				}
				else if (this.calculationType == DocumentCalculationManager.CALC_GROSS_PRICE) {
					subtotal.Gross = this.round(subtotal.Gross);
					subtotal.VatAmount = this.round(subtotal.Gross * subtotal.VatRate / (100 + subtotal.VatRate));
					subtotal.Net = this.round(subtotal.Gross - subtotal.VatAmount);
				}
				this.TotalNet += subtotal.Net;
				this.TotalGross += subtotal.Gross;
				this.TotalVatAmount += subtotal.VatAmount;
				this.TotalQuantity += subtotal.Quantity;
				}
			}
			else {
				for (i in this.Subtotals) {
					subtotal = this.Subtotals[i];
					subtotal.Net = this.round(subtotal.Net);
					subtotal.Gross = this.round(subtotal.Gross);
					subtotal.VatAmount = this.round(subtotal.VatAmount);
					subtotal.Quantity = this.round(subtotal.Quantity);
				}
			}
			this.TotalNet = this.round(this.TotalNet);
			this.TotalGross = this.round(this.TotalGross);
			this.TotalVatAmount = this.round(this.TotalVatAmount);
			this.TotalQuantity = this.round(this.TotalQuantity);
		}
	}
}

// fields of x:
// LineNet, LineGross, LineVatAmount, LineVatRate, LineVatRateId
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
	this.Profit = this.NetPriceDiscounted - this.PurchasePrice;
	this.Commission = 100 * this.Profit / this.NetPriceDiscounted;
	this.MaxDiscount = 100 * (this.NetPrice - this.PurchasePrice) / this.NetPrice;
}

DocumentCalculationManager.prototype.destroy = function() { Tools.destroyObject(this); }
	}
}
*/