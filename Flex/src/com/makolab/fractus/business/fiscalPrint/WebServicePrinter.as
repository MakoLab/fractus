package com.makolab.fractus.business.fiscalPrint
{
	
	import com.makolab.fractus.business.Services;
	import com.makolab.fractus.commands.FiscalizeCommercialDocumentCommand;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.vo.ErrorVO;
	
	import mx.controls.Alert;
	import mx.rpc.Fault;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.soap.WebService;
		
	public class WebServicePrinter implements IResponder
	{
		[Bindable] public var currentWsdlPath:String = "";
		[Bindable] public var wsdlPath:String = "";
		[Bindable] public var webService:WebService;
		[Bindable] public var billXML:XMLList;
		[Bindable] public var defaultErrorHandling:Boolean = true;
		
		
		
		public function WebServicePrinter()
		{
		}
				
		public function printBill(bill:XMLList):void
		{
			billXML = bill;
			
			if(!String(bill.configuration.@wsdl)){
				throw new Error("Brak konfiguracji wsdl."); 
			}
			else{
				webService = Services.getInstance().getWebService("fiscalPrinterWebService");
				
				wsdlPath = String(bill.configuration.@wsdl);
				currentWsdlPath = webService.wsdl;
						
				
				if((wsdlPath != currentWsdlPath) || (webService.ready == false)){
					webService.wsdl = wsdlPath;
					webService.loadWSDL(wsdlPath);
				}
			
				webService.getOperation("FiscalPrint").send(bill).addResponder(this);
			}
		}
		
		public function printTextual(text:String):void
		{
			var param:XML = XML(text.substr(0, text.indexOf("@@@@")));
			
			if(!String(param.@wsdl)){
				throw new Error("Brak konfiguracji wsdl."); 
			}
			else{
				webService = Services.getInstance().getWebService("textualPrinterWebService");
				
				wsdlPath = param.@wsdl;
				currentWsdlPath = webService.wsdl;
						
				
				if((wsdlPath != currentWsdlPath) || (webService.ready == false)){
					webService.wsdl = wsdlPath;
					webService.loadWSDL(wsdlPath);
				}
			
				webService.getOperation("TextualPrint").send(text).addResponder(this);
			}
		}
	
		public function fault(info:Object):void
		{
			if (String(info.fault.faultString).match("exception")){
				//logResult(info.fault);
				var error:ErrorVO = ErrorVO.createFromFault(info.fault as Fault);
				if (defaultErrorHandling) ModelLocator.getInstance().errorManager.handleError(error);
				this.dispatchEvent(FaultEvent.createEvent(info.fault as Fault));					
			}
			else{
				Alert.show("Nie obsłużony wyjątek po stronie serwera wydruku.");
			}			
		}
		
		public function result(data:Object):void
		{
			if(billXML)
			{
				var cmd:FiscalizeCommercialDocumentCommand = new FiscalizeCommercialDocumentCommand(billXML.@id);
				cmd.execute();
			}
		}
	}
}