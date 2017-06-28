package com.makolab.fractus.business.fiscalPrint
{
	
	import com.makolab.fractus.commands.FiscalizeCommercialDocumentCommand;
	
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	
	import mx.controls.Alert;

	public class PosnetPrinter implements IFiscalPrinterApi
	{
		public const ZNAK_PUSTY:int = 0;
		public const CAN:String = "24;";
		public const DC1:String = "17;";
		public const BEL:String = "7;";
		public const DLE:String = "16;";
		public const ENQ:String = "5;";
		public const checkErrorString:String = "35;110;";
		public const beginCommandString:String = "27;80;";	//Esc P
		public const endCommandString:String = "27;92;";	// Esc \
		public const CR:String = "13;";
		public const blockErrorHandling:String = "49;35;101;56;56;";
	
		
		[Bindable] public var billPositionsCount:Number = new Number();
		[Bindable] public var cashierNumber:String = "";
		[Bindable] public var tillNumber:String = "";
		[Bindable] public var billNumber:String = "";
		[Bindable] public var grossValue:Number = new Number();
		[Bindable] public var salePositionTable:Array = new Array();
		[Bindable] public var portNumber:String = "";
		[Bindable] public var salePositionsTableResult:Array = new Array();
		[Bindable] public var configResult:String = "";
		
		[Bindable] public var printerResponse:String = "";
		[Bindable] public var printerResponseBinary:Array = new Array();
		[Bindable] public var billDocument:XMLList = new XMLList();
	
		[Bindable] public var map:Object = {
			'ą' : 134,
			'Ą' : 143,
			'ć' : 141,
			'Ć' : 149,
			'ę' : 145,
			'Ę' : 144,
			'ł' : 146,
			'Ł' : 156,
			'ń' : 164,
			'Ń' : 165,
			'ó' : 162,
			'Ó' : 163,
			'ś' : 158,
			'Ś' : 152,
			'ź' : 166,
			'Ź' : 160,
			'ż' : 167,
			'Ż' : 161
		}
		
		
		public function PosnetPrinter()
		{
		}

		public function adjustStringLength(length:int, word:String):String 
		{
			var newWord:String = new String(word); 

			
			if (word.length > length){
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
			
			return result;
		}
				 
		public function calculateBytes(value:uint):String 
		{
			var result:String = "";
							
			for(var i:int = 1; i <= 2; i++)
			{
				result = result + (value % 256) + ";";
				value = value / 256;
			}
			
			return result;
		}
		
		public function calculateChecksum(value:String):String 
		{
				var wynik:String = "";
				var result:int = 255;
				var tab:Array = new Array();
				
				tab = value.split(";");
				
			for( var i:int = 0; i<tab.length -1 ; i++){
				
				result = result ^ tab[i];
				
			}
			if (result < 10) {
				wynik = result.toString()+ ";";
				wynik = "48;" + convertChars(dec2hex(wynik));
			}
			else{
				wynik = result.toString()+ ";";
				wynik = convertChars(dec2hex(wynik));
			}
			
			return (wynik.substr(0,wynik.length - 3));	
		}
		
		public function cancelTransaction():String 
		 {
			var result:String = "";
			var pom:String = convertChars("0$e");
			var checksum:String = calculateChecksum(pom); 
			
			result = pom + checksum; 
		
			return result;
		}
		
		public function checkDLE():void 
		{
			ExternalInterface.call("printSequence", DLE);
			
			printerResponse = ExternalInterface.call("readChar", 1); 
			
			printerResponseBinary = calculateBinaryBytes(uint(printerResponse.substring(0,printerResponse.length - 1)));
	
			if(printerResponseBinary[0] == 1) {
				throw new Error("Błąd mechanizmu/sterownika");
			}
			else if(printerResponseBinary[1] == 1)
			{
				throw new Error("Brak papieru lub rozładowana bateria akumulatora");
			}
	
			checkErrors();
		}
		
		public function chceckENQ():Boolean 
		{
			ExternalInterface.call("printSequence", ENQ);
			
			printerResponse = ExternalInterface.call("readChar", 1); 
			
			printerResponseBinary = calculateBinaryBytes(uint(printerResponse.substring(0,printerResponse.length - 1)));
	
			if(printerResponseBinary[2] != 1) {
				return false;
			}
			
			return true;
		}
				
		public function checkErrors():void 
		{
			var pom:Array = new Array();
			var pom1:String = "";
			var errorCode:String = "";
			var i:int = 5;
			
			ExternalInterface.call("printSequence", beginCommandString + checkErrorString + endCommandString);
			
			printerResponse = ExternalInterface.call("readChar", 11);
			pom = printerResponse.split(";");
	
	
			while(pom[i] != 27) {
				errorCode = errorCode + String.fromCharCode(pom[i]);
				i++;
			}
	
			switch (errorCode) {
		
				case "1" : {
					throw new Error("Nie zainicjalizowany zegar RTC");
					break;
				}
				case "4" : {
					throw new Error("Błąd danych");
					break;
				}
				case "5" : {
					throw new Error("Błąd wykonania (zapisu) do zegara RTC lub błąd odczytu zegara RTC");
					break;
				}
				case "7" : {
					throw new Error("Data wcześniejsza od daty ostatniego zapisu w pamięci fiskalnej (wykonanie raportu dobowego lub programowanie stawek PTU niemożliwe !)");
					break;
				}
				case "16" : {
					throw new Error("Błędna nazwa (pusta lub za długa)");
					break;
				}
				case "17" : {
					throw new Error("Błędne oznaczenie ilości (puste lub za długie)");
					break;
				}
				case "18" : {
					throw new Error("Błędne oznaczenie stawki PTU (lub brak), próba sprzedaży w stawce nieaktywnej lub próba sprzedaży towaru zablokowanego");
					break;
				}
				case "20" : {
					throw new Error("Błąd wartości BRUTTO lub RABAT (syntaktyka, zakres lub brak)");
					break;
				}
				case "21" : {
					throw new Error("Sekwencja odebrana przez drukarkę przy wyłączonym trybie transakcji");
					break;
				}
				case "27" : {
					throw new Error("Błędna suma całkowita TOTAL lub błędna kwota RABAT");
					break;
				}
				case "28" : {
					throw new Error("Przepełnienie totalizera (max. 99 999 999,99 dla jednej grupy podatkowej)");
					break;
				}
				case "31" : {
					throw new Error("Nadmiar dodawania (przekroczenie zakresu gotówki w kasie)");
					break;
				}
				case "33" : {
					throw new Error("Błąd napisu <zmiana> lub <kasjer> lub <numer> lub <kaucja> (np. za długi lub zawierający błędne znaki)");
					break;
				}
				case "34" : {
					throw new Error("Błąd jednej z kwot lub pozostałych napisów");
					break;
				}
				case "35" : {
					throw new Error("Zerowy stan totalizerów");
					break;
				}
				case "36" : {
					throw new Error("Już istnieje zapis o tej dacie");
					break;
				}
				case "37" : {
					throw new Error("Operacja przerwana z klawiatury (przed rozpoczęciem drukowania)");
					break;
				}
				case "38" : {
					throw new Error("Błąd nazwy");
					break;
				}
				case "39" : {
					throw new Error("Błąd oznaczenia PTU");
					break;
				}
				case "40" : {
					throw new Error("Brak nagłówka w pamięci RAM");
					break;
				}
				case "41" : {
					throw new Error("Błąd napisu <numer_kasy> (za długi lub zawierający błędne znaki)");
					break;
				}
				case "42" : {
					throw new Error("Błąd napisu <numer_kasjera>");
					break;
				}
				case "51" : {
					throw new Error("Błąd wartości <kwota>");
					break;
				}
				case "84" : {
					throw new Error("Przekroczona liczba wysłanych napisów na wyświetlacz");
					break;
				}
				case "92" : {
					throw new Error("Przepełnienie bazy towarowej");
					break;
				}
				case "94" : {
					throw new Error("Przekroczenie maksymalnej kwoty sprzedaży");
					break;
				}
				case "95" : {
					throw new Error("Próba ponownego rozpoczęcia transakcji (drukarka w trybie transakcji)");
					break;
				}
				case "96" : {
					throw new Error("Przekroczony limit czasu na wydruk paragonu (20 minut)");
					break;
				}
				case "97" : {
					throw new Error("Blokada sprzedaży z powodu słabego akumulatora");
					break;
				}
				case "98" : {
					throw new Error("Blokada sprzedaży z powodu założonej zwory serwisowej");
					break;
				}
				case "255" : {
					throw new Error("Nierozpoznana komenda");
					break;
				}
		
				//błędy mniej ważne
		
		
				case "2" : {
					throw new Error("Błąd nr " + errorCode + " " + "Błąd bajtu kontrolnego");
					break;
				}
				case "3" : {
					throw new Error("Błąd nr " + errorCode + " " + "Zła ilość parametrów");
					break;
				}
				case "6" : {
					throw new Error("Błąd nr " + errorCode + " " + "-Błąd odczytu totalizerów, błąd operacji z pamięcią fiskalną");
					break;
				}
				case "8" : {
					throw new Error("Błąd nr " + errorCode + " " + "Błąd operacji - niezerowe totalizery !");
					break;
				}
				case "9" : {
					throw new Error("Błąd nr " + errorCode + " " + "Błąd operacji I/O (np. nie usunięta zwora serwisowa)");
					break;
				}
				case "10" : {
					throw new Error("Błąd nr " + errorCode + " " + "-Błąd operacji I/O (nie przesłana baza towarowa z aplikacji)");
					break;
				}
				case "11" : {
					throw new Error("Błąd nr " + errorCode + " " + "Błąd programowania stawek PTU");
					break;
				}
				case "12" : {
					throw new Error("Błąd nr " + errorCode + " " + "Błędny nagłówek, zbyt długi lub pusty (zawiera np. same spacje");
					break;
				}
				case "13" : {
					throw new Error("Błąd nr " + errorCode + " " + "Próba fiskalizacji urządzenia w trybie fiskalnym");
					break;
				}
				case "19" : {
					throw new Error("Błąd nr " + errorCode + " " + "Błąd wartości CENA (syntaktyka, zakres, brak ");
					break;
				}
				case "22" : {
					throw new Error("Błąd nr " + errorCode + " " + "Błąd operacji STORNO (np. próba wykonania jej w trybie 'blokowym' OFFLINE");
					break;
				}
				case "23" : {
					throw new Error("Błąd nr " + errorCode + " " + "zakończenie transakcji bez sprzedaży");
					break;
				}
				case "25" : {
					throw new Error("Błąd nr " + errorCode + " " + "Błędny kod terminala/ kasjera (zła długość lub format) lub błędna treść dodatkowych linii");
					break;
				}
				case "26" : {
					throw new Error("Błąd nr " + errorCode + " " + "kwoty 'WPŁATA' (syntaktyka; jeżeli różnica WPŁATA-TOTAL");
					break;
				}
				case "29" : {
					throw new Error("Błąd nr " + errorCode + " " + "Żądanie zakończenia (pozytywnego !) trybu transakcji, w momencie kiedy nie został on jeszcze włączony");
					break;
				}
				case "30" : {
					throw new Error("Błąd nr " + errorCode + " " + "Błąd kwoty WPŁATA (syntaktyka)");
					break;
				}
				case "32" : {
					throw new Error("Błąd nr " + errorCode + " " + "Wartość po odjęciu staje się ujemna (przyjmuje się wówczas stan zerowy kasy !)");
					break;
				}
				case "43" : {
					throw new Error("Błąd nr " + errorCode + " " + "Błąd napisu <numer_par>");
					break;
				}
				case "44" : {
					throw new Error("Błąd nr " + errorCode + " " + "Błąd napisu <kontrahent>");
					break;
				}
				case "45" : {
					throw new Error("Błąd nr " + errorCode + " " + "Błąd napisu <terminal>");
					break;
				}
				case "46" : {
					throw new Error("Błąd nr " + errorCode + " " + "Błąd napisu <numer_karty>");
					break;
				}
				case "47" : {
					throw new Error("Błąd nr " + errorCode + " " + "Błąd napisu <numer_karty>");
					break;
				}
				case "48" : {
					throw new Error("Błąd nr " + errorCode + " " + "Błąd napisu <data_m>");
					break;
				}
				case "49" : {
					throw new Error("Błąd nr " + errorCode + " " + "Błąd napisu <data_r>");
					break;
				}
				case "50" : {
					throw new Error("Błąd nr " + errorCode + " " + "Błąd napisu <kod_autoryz>");
					break;
				}
				case "82" : {
					throw new Error("Błąd nr " + errorCode + " " + "Przekroczona liczba programowania kodów autoryzacyjnych przez RS");
					break;
				}
				case "83" : {
					throw new Error("Błąd nr " + errorCode + " " + "Zła wartość kaucji przesłanej w $z");
					break;
				}
				case "90" : {
					throw new Error("Błąd nr " + errorCode + " " + "Operacja tylko z kaucjami - nie można wysłać towarów");
					break;
				}
				case "91" : {
					throw new Error("Błąd nr " + errorCode + " " + "Była wysłana forma płatności - nie można wysłać towarów");
					break;
				}
				case "93" : {
					throw new Error("Błąd nr " + errorCode + " " + "Błąd anulowania formy płatności");
					break;
				}
		
		
				default : {
					throw new Error("Błąd drukarki");
					break;
				}
			}
		}
		
		public function closePort():void 
		{
			ExternalInterface.call("closePort");
		}
		
		public function convertChars(word:String):String 
		{
			var result:String = new String;
				 
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
				
		public function dec2hex(value:String):String 
		{
	
			var tab:Array = new Array();
			var result:String = "";
			
			tab = value.split(";");

			for( var i:int = 0; i<tab.length-1 ; i++){
			
				var pom:int = new int(tab[i]);
				result = result + pom.toString(16) + ";";
				
			} 
	
			return result;
		}
		
		public function hex2dec(value:String):String 
		{

			var tab:Array = new Array();
			var result:String = "";
			
			tab = value.split(";");

			for( var i:int = 0; i<tab.length-1 ; i++){
				
				result = result + parseInt(tab[i], 16) + ";";
				
			} 
			
	 		return result;
		}
				
		public function prepareBeginBillString():String 
		{
			var result:String = new String; 
			var pom:String = new String; 
			var checksum:String = new String; 
					
			// rozpoczęcie transakcji		ESC P Pl; Pn $h <linia1> CR <linia2> CR <linia3> CR <check> ESC \
			pom = convertChars(billPositionsCount + ";" + "1" + "$h" + "#" + billNumber);
			// można dodać + CR po nawiasie, ale bez tego i tak działa więc nie dodaje, być może będzie problem przy innej wersji drukarki
			
			checksum = calculateChecksum(pom); 
			result = beginCommandString + pom + checksum + endCommandString; 
			
			return result;
		}
		
		public function prepareEndBillString():String 
		{
			var result:String = new String; 
			var part1:String = new String; 
			var part2:String = new String; 
			var pom:String = new String; 
			var checksum:String = new String; 
		
			
			part1 = convertChars("1;0$e" + tillNumber + cashierNumber);
			part2 = convertChars("0/" + grossValue + "/");
			pom = part1 + "13;" + part2;
			checksum = calculateChecksum(pom); 
			result = beginCommandString + pom + checksum + endCommandString; 
			
			return result;
		}
		
		public function prepareSalePositions(salePositionTable:Array):Array 
		{
			var name:String = "";
			var quantity:String = "";
			var grossPrice:String = "";
			var grossValue:String = "";
			var result:String = "";
			var pomResult:String = "";
			var checkSum:String = "";
			var pi:String = "";
			var ptu:String = "";
			
			var salePositionsResult:Array = new Array();
			
			var part1:String = "";
			var part2:String = "";
			var part3:String = "";
			var pom:String = "";
			
			for (var i:int=0; i < salePositionTable.length; i++){
	
				pi = String(i+1);
				name =adjustStringLength(40, salePositionTable[i][0]);
				quantity = salePositionTable[i][1];
				ptu = salePositionTable[i][2];
				grossPrice = salePositionTable[i][3];
				grossValue = salePositionTable[i][4];
				
				//Esc P Pi $1 nazwa CR ilość CR ptu / cena / brutto / cc Esc \
				
				part1 = convertChars(pi + "$l" + name);
				part2 = convertChars(quantity);
				part3 = convertChars(ptu+ "/" + grossPrice + "/" + grossValue + "/");
				
				pom = part1 + CR + part2 + CR + part3;
				checkSum = calculateChecksum(pom);
				result = pom + checkSum;
				salePositionsResult.push(result);
			}
			return salePositionsResult;
		}

		public function printBill(bill:XMLList):void
		{
			billDocument = bill;
			
			configResult = processConfigXML();
			
			processBillXML(bill);

			salePositionsTableResult = prepareSalePositions(salePositionTable);
	
			if(ExternalInterface.call("initPrinter", configResult, portNumber)) {
				
			}
			else{
				throw new Error("Problem z utworzeniem portu COM");
			}
	
			ExternalInterface.call("printSequence", DLE); 
				
			printerResponse = ExternalInterface.call("readChar", 1);
	
		
			if(printerResponse == "NaN;"){
				wakeUpPrinter();
			}
			else{
				printingAlgorithm();
			}
	
		}
		
		public function printingAlgorithm():void 
		{
			ExternalInterface.call("printSequence", beginCommandString + cancelTransaction() + endCommandString);
	
			ExternalInterface.call("printSequence", beginCommandString + blockErrorHandling + endCommandString);
	
				if(chceckENQ()) {
				}
				else {
					checkDLE();
				}
	
			ExternalInterface.call("printSequence", prepareBeginBillString());
			
				for (var i:int; i < salePositionsTableResult.length; i++){
					
					ExternalInterface.call("printSequence", beginCommandString);
					ExternalInterface.call("printSequence", salePositionsTableResult[i]);
					ExternalInterface.call("printSequence", endCommandString);
					
					if(chceckENQ()) {	
					}
					else {
						checkDLE();
					}
				}
	
			ExternalInterface.call("printSequence", prepareEndBillString());
			
				if(chceckENQ()) {
				}
				else {
				checkDLE();
				}

			closePort();
			var cmd:FiscalizeCommercialDocumentCommand = new FiscalizeCommercialDocumentCommand(billDocument.@id);
			cmd.execute();
		}
		
		public function processBillXML(bill:XMLList):void
		{
			billPositionsCount = 0;
			
			if(String(bill.cashier) != "") {
				cashierNumber = String(bill.cashier);
			} 
			else {
				cashierNumber = "01";
			}
			
			billNumber = String(bill.number);

			if(String(bill.till) != "") {
				
				if(int(bill.till) > 9) {
					throw new Error("Przekroczona dostępna ilość kas");
				}				
				tillNumber = String(bill.till);
			}
			else {
				tillNumber = "1";
			}

			grossValue = bill.grossValue;

			for each (var x:XML in bill.lines.*){
				
				var pomTable:Array = new Array();
				
					for each (var y:XML in x.*){
						pomTable.push(String(y));
					}
				
					billPositionsCount++;
					salePositionTable.push(pomTable);	
			}
			
			portNumber = String(bill.configuration.@portName);
			
		}
			
		public function processConfigXML():String
		{
			var result:String;
			
			result = "9600;1;1;0;0;1;0;1;0;0;0;0;1;0;8;2;0;100;100;100;100;100;";

			return result;
		}
		
		public function timerHandler(event:TimerEvent):void 
		{
			var pom:String = "";
						
			ExternalInterface.call("closePort");		
			pom = processConfigXML();
		
			ExternalInterface.call("initPrinter", pom, portNumber);
			
			ExternalInterface.call("printSequence", DLE); 
			
			printerResponse = ExternalInterface.call("readChar", 1);
	
			try{
				if(printerResponse == "NaN;"){
					
					
					throw new Error("Brak komunikacji z drukarką");
				}
				else {
					printingAlgorithm();
					
				}
			}
			catch(error:Error){
				ExternalInterface.call("closePort");
				
				Alert.show("Błąd! " + error.message);
			}


		}
				
		public function wakeUpPrinter():void 
		{
			var timeDelay:Timer = new Timer(10000, 1);
			timeDelay.addEventListener(TimerEvent.TIMER_COMPLETE, timerHandler);
			timeDelay.start();
			
		}

	}
	
}




