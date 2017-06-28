package com.makolab.components.util
{
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.DocumentObject;
	
	import mx.formatters.CurrencyFormatter;
	import mx.formatters.NumberBaseRoundType;
	
	public class CurrencyManager
	{
		public static var decimalSeparator:String = ",";
		public static var groupSeparator:String = " ";
		
		public static function formatCurrency(val:Number, nanVal:String = "?", zeroVal:String = null, precision:int = 2):String
		{
			if (isNaN(val)) return nanVal;
			if (val == 0 && zeroVal != null) return zeroVal;
			
			var absPrecision:int = Math.abs(precision);
			
			var currencyFormatter:CurrencyFormatter = new CurrencyFormatter();
				currencyFormatter.precision = absPrecision;
				currencyFormatter.currencySymbol = "";
				currencyFormatter.decimalSeparatorTo = ",";
				currencyFormatter.decimalSeparatorFrom = ",";
				currencyFormatter.thousandsSeparatorFrom = " ";
				currencyFormatter.thousandsSeparatorTo = " ";
				currencyFormatter.useNegativeSign = true;
				currencyFormatter.useThousandsSeparator = true;
				currencyFormatter.rounding = NumberBaseRoundType.NEAREST;
			
			if(precision >= 0)
				return currencyFormatter.format(val);
			else
			{
				var retVal:String = currencyFormatter.format(val);
				
				if(retVal.indexOf(decimalSeparator) >= 0)
				{
					while(retVal.charAt(retVal.length - 1) == "0")
					{
						retVal = retVal.substr(0, retVal.length - 1);
					}
					
					if(retVal.charAt(retVal.length - 1) == decimalSeparator)
						retVal = retVal.substr(0, retVal.length - 1);
				}
				
				return retVal;
			}
		}
		
		public static function parseCurrency(s:String, precision:int = 2):Number
		{
			s = s.replace(/\s/g, '');
			var re:RegExp = new RegExp(groupSeparator, 'g');
			s = s.replace(re, '');
			re = new RegExp("\\" + decimalSeparator, '');
			s = s.replace(re, '.');
			var ret:Number = parseFloat(s);
			if (isNaN(ret)) return ret;
			else return Number(ret.toFixed(precision));
		}
	
		public static function paymentToDocument(payment:XML, document:DocumentObject):Number
		{
			var result:Number = NaN;
			
			if (payment && document)
			{
				result = Number(payment.amount.toString());
				if (payment.paymentCurrencyId.toString() != document.xml.documentCurrencyId.toString())
				{
					var paymentAmount:Number = Number(payment.amount.toString());
					var paymentExchangeRate:Number = Number(payment.exchangeRate.toString());
					var paymentExchangeScale:Number = Number(payment.exchangeScale.toString());
					var systemCurrencyValue:Number = paymentAmount * paymentExchangeRate / paymentExchangeScale;
					
					if (ModelLocator.getInstance().systemCurrencyId == document.xml.documentCurrencyId.toString())
					{
						result = systemCurrencyValue;
					}
					else
					{
						var documentExchangeRate:Number = Number(document.xml.exchangeRate.toString());
						var documentExchangeScale:Number = Number(document.xml.exchangeScale.toString());
						result = systemCurrencyValue * documentExchangeScale / documentExchangeRate;
					}
				}
			}
			
			return result;
		}
	
		public static function systemCurrencyValue(amount:Number,currencyId:String,exchangeRate:Number,exchangeScale:Number):Number
		{
			var result:Number = amount;
			if (currencyId != ModelLocator.getInstance().systemCurrencyId) result = amount * exchangeRate / exchangeScale;
			
			return result;
		}
	
		public static function documentToPayment(payment:XML, document:DocumentObject):Number
		{
			var result:Number = NaN;
			
			if (payment && document)
			{
				result = Number(document.xml.documentCurrencyId.toString());
				if (payment.paymentCurrencyId.toString() != document.xml.documentCurrencyId.toString())
				{
					var paymentAmount:Number = Number(payment.amount.toString());
					var paymentExchangeRate:Number = Number(payment.exchangeRate.toString());
					var paymentExchangeScale:Number = Number(payment.exchangeScale.toString());
					var systemCurrencyValue:Number = paymentAmount * paymentExchangeRate / paymentExchangeScale;
					
					if (ModelLocator.getInstance().systemCurrencyId == document.xml.documentCurrencyId.toString())
					{
						result = systemCurrencyValue;
					}
					else
					{
						var documentExchangeRate:Number = Number(document.xml.exchangeRate.toString());
						var documentExchangeScale:Number = Number(document.xml.exchangeScale.toString());
						result = systemCurrencyValue * documentExchangeRate / documentExchangeScale;
					}
				}
			}
			
			return result;
		}
		
		public static function systemToDocument(value:Number,document:DocumentObject):Number
		{
			var result:Number = NaN;
			
			if (document)
			{
				result = value;
				if (ModelLocator.getInstance().systemCurrencyId != document.xml.documentCurrencyId.toString())
				{
					var documentExchangeRate:Number = Number(document.xml.exchangeRate.toString());
					var documentExchangeScale:Number = Number(document.xml.exchangeScale.toString());
					result = value * documentExchangeScale / documentExchangeRate;
				}
			}
			
			return result;
		}
		
		public static function documentToSystem(value:Number,document:DocumentObject):Number
		{
			var result:Number = NaN;
			
			if (document)
			{
				result = value;
				if (ModelLocator.getInstance().systemCurrencyId != document.xml.documentCurrencyId.toString())
				{
					var documentExchangeRate:Number = Number(document.xml.exchangeRate.toString());
					var documentExchangeScale:Number = Number(document.xml.exchangeScale.toString());
					result = value * documentExchangeRate / documentExchangeScale;
				}
			}
			
			return result;
		}
		
		public static function documentToSystemWithDocumentXML(value:Number,documentXML:XML):Number
		{
			var result:Number = NaN;
			
			if (documentXML)
			{
				result = value;
				if (ModelLocator.getInstance().systemCurrencyId != documentXML.documentCurrencyId.toString())
				{
					var documentExchangeRate:Number = Number(documentXML.exchangeRate.toString());
					var documentExchangeScale:Number = Number(documentXML.exchangeScale.toString());
					result = value * documentExchangeRate / documentExchangeScale;
				}
			}
			
			return result;
		}
	}
}