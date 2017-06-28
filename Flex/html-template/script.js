var makoPrintAX;
var swfObject;

function init() {
	document.onkeydown = detectEvent;
	swfObject = document.Main || window.Main;
	swfObject.focus();
	//window.onbeforeunload = onBeforeUnloadHandler;
}

function detectEvent(e) {
	var evt = e || window.event;
	if (evt.keyCode == 9) return false;
	else return true;
}

function printDoc(xml) {
	if(!isIE) return "2";
	try
	{
		if(!makoPrintAX){
			makoPrintAX = new ActiveXObject("Makolab.Printing.MakoPrintActiveX");
		}
		makoPrintAX.PrintFiscal(xml);
		return("1");
	}
	catch(exc)
	{
		return(exc.description);
	}
}

function callMethod(uid, methodName, param, param2)
{
	window.external.CallMethod(uid, methodName, param, param2);
}

function openUrl(url)
{
	window.open(url, '_blank');
}

// ELZAB printer
function initPrinter(portStateString, portNumber)
 {

	var tab = portStateString.split(";");
	
	port = new ActiveXObject("ASPPortExt.ASPSerialPortExt");
	
	if(port == null){
	return false;
	}
	
		if(port.Open(portNumber)){}
		
		port.getportstate();
		
		port.PortStateParam("BaudRate") = tab[0];
		port.PortStateParam("fBinary") = tab[1];
		port.PortStateParam("fParity") = tab[2];
		port.PortStateParam("fOutxCtsFlow") = tab[3];
		port.PortStateParam("fOutxDsrFlow") = tab[4];
		port.PortStateParam("fDtrControl") = tab[5];
		port.PortStateParam("fDsrSensitivity") = tab[6];
		port.PortStateParam("fTXContinueOnXoff") = tab[7];
		port.PortStateParam("fOutX") = tab[8];
		port.PortStateParam("fInX") = tab[9];
		port.PortStateParam("fErrorChar") = tab[10];
		port.PortStateParam("fNull") = tab[11];
		port.PortStateParam("fRtsControl") = tab[12];
		port.PortStateParam("fAbortOnError") = tab[13];
		port.PortStateParam("ByteSize") = tab[14];
		port.PortStateParam("Parity") = tab[15];
		port.PortStateParam("StopBits") = tab[16];
		
		if(port.setportstate){}
				
		port.PortTimeoutsParam("ReadIntervalTimeout")= tab[17];
		port.PortTimeoutsParam("ReadTotalTimeoutMultiplier")= tab[18];
		port.PortTimeoutsParam("ReadTotalTimeoutConstant")= tab[19];
		port.PortTimeoutsParam("WriteTotalTimeoutMultiplier")= tab[20];
		port.PortTimeoutsParam("WriteTotalTimeoutConstant")= tab[21];
				
		if(port.SetPortTimeouts){}
		
		return true;
 }

function printChar(kod)
{
	if(port.put(kod)) {}
}


function printSequence(string)
{
	var tab = string.split(";");

	for(indeks in tab){
		printChar(tab[indeks]);
	}
}

function closePort()
{
	port.close();
}

function readChar(kod)
{
	var pom;
	var result = "";
	var znak;
	
	for( var i=0; i < kod; i++)
		{
			pom = port.read(1);
			znak = pom.charCodeAt(0);
			result += znak + ";";
		}
	return result;
}

function onBeforeUnloadHandler(event) { 
	var message = 'Zamknięcie lub odświeżenie strony spowoduje wylogowanie z systemu Fractus i utratę niezapisanych danych.'; 
	if (typeof event == 'undefined') { 
		event = window.event; 
	} 
	if (event) { 
		event.returnValue = message; 
	} 
	return message; 
}

function fullscreenOn() {
	if (fullScreenApi.supportsFullScreen) {
		fullScreenApi.requestFullScreen("Main");
	}
}


function showImageUploader(uploadUrl)
{
	var popup = window.open("ImageUploader.html", "ImageUploader", "width=600,height=500,scrollbars=no");
	popup.window.uploadUrl = uploadUrl;
}

(function() 
{    
	var fullScreenApi = {
            supportsFullScreen: false,
            isFullScreen: function() { return false; }, 
            requestFullScreen: function() {},
            cancelFullScreen: function() {},
			fullScreenEventName: '',
			prefix: ''
		},
	browserPrefixes = 'webkit moz o ms khtml'.split(' ');
	// check for native support    
	if (typeof document.cancelFullScreen != 'undefined') {        
		fullScreenApi.supportsFullScreen = true;    
	} else {        
		// check for fullscreen support by vendor prefix        
		for (var i = 0, il = browserPrefixes.length; i < il; i++ ) {
			fullScreenApi.prefix = browserPrefixes[i];
			if (typeof document[fullScreenApi.prefix + 'CancelFullScreen' ] != 'undefined' ) {
				fullScreenApi.supportsFullScreen = true;
				break; 
			}
		}
	}     
	// update methods to do something useful    
	if (fullScreenApi.supportsFullScreen) {
		fullScreenApi.fullScreenEventName = fullScreenApi.prefix + 'fullscreenchange';
		fullScreenApi.isFullScreen = function() {
			switch (this.prefix) {
				case '': 		return document.fullScreen;
				case 'webkit': 	return document.webkitIsFullScreen;
				default: 		return document[this.prefix + 'FullScreen'];
			}
		}
		fullScreenApi.requestFullScreen = function(el) {
			return (this.prefix === '') ? el.requestFullScreen() : el[this.prefix + 'RequestFullScreen']();
		}
		fullScreenApi.cancelFullScreen = function(el) {
			return (this.prefix === '') ? document.cancelFullScreen() : document[this.prefix + 'CancelFullScreen']();
		}
	}     
	// jQuery plugin    
	if (typeof jQuery != 'undefined') {
		jQuery.fn.requestFullScreen = function() {
			return this.each(function() {
				if (fullScreenApi.supportsFullScreen) {
					fullScreenApi.requestFullScreen(this);
				}
			});
		};
	}     
	// export api    
	window.fullScreenApi = fullScreenApi;
})();