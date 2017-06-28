package com.makolab.fractus.business.fiscalPrint
{


	
	import flash.external.ExternalInterface;
	
	import mx.formatters.NumberBaseRoundType;
	import mx.formatters.NumberFormatter;
	import mx.controls.Alert;
	import com.makolab.components.util.Tools;

	public class ElzabPrinter implements IFiscalPrinterApi
	{

		public const ZNAK_PUSTY:int = 0;
		public const ACK:String = "6;";
		public const NAK:String = "21;";
		public const NaN:String = "NaN;";

		[Bindable] public var configTable:Array = new Array();
		[Bindable] public var configResult:String = "";

		[Bindable] public var cashierNumber:String = "";
		[Bindable] public var cashNumber:String = "";
		[Bindable] public var billNumber:String = "";
		[Bindable] public var grossValue:Number = new Number();
		[Bindable] public var salePositionTable:Array = new Array();

		[Bindable] public var cancelString:String = "";
		[Bindable] public var identifyString:String = "";
		[Bindable] public var beginBillString:String = "";
		[Bindable] public var beginSalePositionString:String = "";
		[Bindable] public var endSalePositionsString:String = "";
		[Bindable] public var endBillString:String = "";
		[Bindable] public var additionalInfoString:String = "";
		
		[Bindable] public var printerStateByte0String:String = "";
		[Bindable] public var printerStateByte1String:String = "";
		[Bindable] public var printerStateByte2String:String = "";
		[Bindable] public var printerStateByte3String:String = "";

		[Bindable] public var printerConfirmation:String = "";

		[Bindable] public var salePositionsTableResult:Array = new Array(); 

		[Bindable] public var portNumber:String = "";


		[Bindable] public var map:Object = {
			'ą' : 165,
			'Ą' : 164,
			'ć' : 134,
			'Ć' : 143,
			'ę' : 169,
			'Ę' : 168,
			'ł' : 136,
			'Ł' : 157,
			'ń' : 228,
			'Ń' : 227,
			'ó' : 162,
			'Ó' : 224,
			'ś' : 152,
			'Ś' : 151,
			'ź' : 171,
			'Ź' : 141,
			'ż' : 190,
			'Ż' : 189
		}

		public function ElzabPrinter()
		{
			
		}

		public function adjustStringLength(length:int, word:String):String 
		{
			var newWord:String = new String(word); 

			if(newWord.length < length){
				for (var x:int=0; x < length - word.length; x++){
					newWord = newWord + " ";
				}
			}
			else if (word.length > length){
				newWord = word.substring(0,length);
			}

			return newWord;
		}
	
		public function calculateBinaryBytes(value:uint):Array 
		{
			var result:Array = new Array();
							
			for(var i:int=0; i<8; i++)
			{
				result[i] = value % 2;
				value = value / 2;
			}
			
			return  result;
		}
	
		public function calculateBytes(value:uint):String 
		{
			var result:String = "";
							
			for(var i:int = 1; i <= 4; i++)
			{
				result = result + (value % 256) + ";";
				value = value / 256;
			}
			
			return  result;
		}
		
		public function checkComaPosition(value:String):int 
		{
			return value.length - (value.indexOf(".")+1);   // "+1" bo musi byc liczone od 1 a nie od 0
		}
		
		public function checkErrors():void 
		{
			var printerStateByte0:String = "";
			var printerStateByte1:String = "";
			var printerStateByte2:String = "";
			var printerStateByte3:String = "";
			var byte0:Array = new Array();
			var byte0result:Array = new Array();
			var byte1:Array = new Array();
			var byte1result:Array = new Array();
			var byte2:Array = new Array();
			var byte2result:Array = new Array();
			var byte3:Array = new Array();
			var byte3result:Array = new Array();
				
			var zmiennaStanu:String = "";
		
		
			ExternalInterface.call("printSequence", printerStateByte0String);
			printerStateByte0 = ExternalInterface.call("readChar", 1);
	
			ExternalInterface.call("printSequence", printerStateByte1String);
			printerStateByte1 = ExternalInterface.call("readChar", 1);
	
			ExternalInterface.call("printSequence", printerStateByte2String);
			printerStateByte2 = ExternalInterface.call("readChar", 1);
	
			ExternalInterface.call("printSequence", printerStateByte3String);
			printerStateByte3 = ExternalInterface.call("readChar", 1);
	
	
			byte0 = printerStateByte0.split(";",1);
			byte1 = printerStateByte1.split(";",1);
			byte2 = printerStateByte2.split(";",1);
			byte3 = printerStateByte3.split(";",1);
		
		
			byte0result = calculateBinaryBytes(byte0[0]);
			byte1result = calculateBinaryBytes(byte1[0]);
			byte2result = calculateBinaryBytes(byte2[0]);
			byte3result = calculateBinaryBytes(byte3[0]);
	
		
			//algorytm z instrukcji (poprawiony)
			
			
			zmiennaStanu = String(byte1result[1]) + String(byte2result[0]) + String(byte2result[6]);
			
	
			if(zmiennaStanu == "000") {
				
			}
			else if ((zmiennaStanu == "010") || (zmiennaStanu == "110") || (zmiennaStanu == "001")){
				throw new Error("Błąd drukarki");
			}
			
			
							
			if(	(byte2result[1] == 1) ||	// Czy jest papier w drukarce?
				(byte1result[3] == 1) ||	// Czy zalegly raport dobowy?
				(byte1result[4] == 1) ||	// Czy skasowany CMOS?
				(byte1result[6] == 1) ||	// Czy wyświetlacz klienta podłączony?
				(byte0result[2] == 1) || 	// tylko odczyt	
				(byte3result[6] == 1) || 	// zwora w poz serwisowej
				(byte3result[7] == 1) || 	// brak komunikacji z kontrolerem
				(byte2result[2] == 1)) 		// awaria drukarki
			{
				throw new Error("Błąd drukarki");
			}
		}
		
		public function convertChars(word:String):String 
		{
			var result:String = "";
				 
			for (var x:int=0;x<word.length;x++){
				
				var code:int = word.charCodeAt(x);

				if (code > 127)
					{
						code = map[word.charAt(x)];
						if (!code) code = ZNAK_PUSTY;
					}
					result += String(code) + ";";
				} 

			return result;
		}
		
		public function prepareAdditionalString():String
		{
			var result:String = "";
	
			//NUMER nr sys xxxxxxxx
			result = "27;9;" + "60;" + convertChars(billNumber) + "10;";
	
			return result;
		}

		public function prepareCashierString():String
		{
			var result:String = "";
	
			result = "27;67;" + convertChars(cashNumber) + convertChars(cashierNumber);
	
			return result;
		}
		
		public function prepareCommandStrings():void
		{
			cancelString = "27;35;";
			identifyString = "27;255;";
			beginBillString = "27;33;";
	
			beginSalePositionString = "27;6;32;";
			endSalePositionsString = "27;7;" + calculateBytes(.01 * Math.round((grossValue*100)*100));
			endBillString = "27;36;";
			additionalInfoString = "27;149;";
			
			printerStateByte0String = "27;155;";
			printerStateByte1String = "27;148;";
			printerStateByte2String = "27;149;";
			printerStateByte3String = "27;150;";
			
		}

		public function prepareSalePositions(salePositionTable:Array):Array 
		{
				var nameResult:String = "";
				var quantity:Number = new Number();
				var quantityResult:String = "";
				var quantityCheck:Number = new Number();
				var unitOfMeasureResult:String = "";
				var vatRateResult:String = "";
				var grossPriceResult:String = "";
				var grossValueResult:String = "";
				var coma:int = new int;

				var result:String = "";
				var salePositionsResult:Array = new Array();
								
				var commentResult:String = "";
				var nf:NumberFormatter = new NumberFormatter();

				for (var i:int=0; i < salePositionTable.length; i++){
	
					nameResult = convertChars(adjustStringLength(28, salePositionTable[i][0]));
					commentResult = convertChars("0");
										
					quantityCheck = Number(salePositionTable[i][1]);
					
					nf.precision = 4;
					nf.rounding = NumberBaseRoundType.NEAREST;
					quantity =  Number(nf.format(salePositionTable[i][1]));
					
										
					if((quantity - quantityCheck) != 0){
						throw new Error("Dokładność ilości towaru przekracza dokładność drukarki");
					}
					else{
						coma = checkComaPosition(String(quantityCheck));
						quantityResult = calculateBytes(quantity* (Math.pow(10, coma)));
					}
										
					vatRateResult = convertChars(salePositionTable[i][2]);
					grossPriceResult = calculateBytes(.01 * Math.round((salePositionTable[i][3] * 100) * 100));
					grossValueResult = calculateBytes(.01 * Math.round((salePositionTable[i][4] * 100) * 100));
					unitOfMeasureResult = convertChars(adjustStringLength(4, salePositionTable[i][5]));
					result = nameResult + commentResult + quantityResult + String(coma) + ";" + unitOfMeasureResult + grossPriceResult + "27;" + vatRateResult + grossValueResult; 
					salePositionsResult.push(result);
				}
	
			return salePositionsResult;
		}

		public function printBill(bill:XMLList):void
		{
				configResult = processConfigXML();
				
				processBillXML(bill);

				prepareCommandStrings();
		
				salePositionsTableResult = prepareSalePositions(salePositionTable);
	
				ExternalInterface.call("initPrinter", configResult, portNumber);
								
				ExternalInterface.call("printSequence", identifyString);
				printerConfirmation = ExternalInterface.call("readChar", 2);
							
				if(printerConfirmation == "NaN;NaN;") {
					throw new Error("Błąd w komunikacji z drukarką");
				}
				
				
		/*			ExternalInterface.call("printSequence", cancelString);
					
					printerConfirmation = ExternalInterface.call("readChar", 1);
					if(printerConfirmation == ACK) {
						// funkcja sprawdzająca powód anulowania paragonu
					}
					else if (printerConfirmation == NAK){
						
					}
					else {
						throw new Error("Nieoczekiwany znak cancel");
					}
		*/	
				
				
				ExternalInterface.call("printSequence", prepareCashierString());
	
					printerConfirmation = ExternalInterface.call("readChar", 1);
					if(printerConfirmation == ACK) {
						
					}
					else if (printerConfirmation == NAK){
						checkErrors();	
					}
					else {
						throw new Error("Nieoczekiwana odpowiedź drukarki");
					}
					
	
					
				ExternalInterface.call("printSequence", beginBillString);
				
					printerConfirmation = ExternalInterface.call("readChar", 1);
					if(printerConfirmation == ACK) {
						
					}
					else if (printerConfirmation == NAK){
						checkErrors();
					}
					else {
						throw new Error("Nieoczekiwana odpowiedź drukarki");
					}
								
				
				for (var i:int; i < salePositionsTableResult.length; i++){
					
					ExternalInterface.call("printSequence", beginSalePositionString);
					ExternalInterface.call("printSequence", salePositionsTableResult[i]);
				}

				ExternalInterface.call("printSequence", endSalePositionsString);

				ExternalInterface.call("printSequence", prepareAdditionalString());

				ExternalInterface.call("printSequence", endBillString);

					printerConfirmation = ExternalInterface.call("readChar", 1);
					if(printerConfirmation == ACK) {
						
					}
					else if (printerConfirmation == NAK){
						checkErrors();
					}
					else {
						throw new Error("Nieoczekiwana odpowiedź drukarki");
					}

				
				//zamknięcie portu wywoływane z poziomu ComponentExportManager.as
		}
		
		public function processBillXML(bill:XMLList):void
		{
			cashierNumber = String(bill.cashier);
			billNumber = String(bill.number);

			if(String(bill.cash) != "") {
				cashNumber = bill.cash;
			} 
			else {
				cashNumber = "01";
			}

			grossValue = bill.grossValue;

			for each (var x:XML in bill.lines.*){
				
				var pomTable:Array = new Array();
				
				for each (var y:XML in x.*){
					pomTable.push(String(y));
				}
					
				salePositionTable.push(pomTable);	
			}
			
			portNumber = String(bill.configuration.@portName);
			
		}

		public function processConfigXML():String
		{
			var result:String;
			
			result = "9600;1;1;0;0;1;0;1;0;0;0;0;1;0;8;2;0;1000;1000;1000;1000;1000;";

			return result;
		}
		
		public function roundN(n:Number, m:Number):Number
		{
			return Tools.round(n, m);
		}
	}
}




