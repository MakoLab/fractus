package com.makolab.components.util
{
	import com.makolab.fractus.business.Services;
	import com.makolab.fractus.business.fiscalPrint.ElzabPrinter;
	import com.makolab.fractus.business.fiscalPrint.PosnetPrinter;
	import com.makolab.fractus.business.fiscalPrint.WebServicePrinter;
	import com.makolab.fractus.commands.FiscalizeCommercialDocumentCommand;
	import com.makolab.fractus.commands.OfflinePrintCommand;
	import com.makolab.fractus.commands.PrintDocumentCommand;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mx.controls.Alert;
	import mx.rpc.events.ResultEvent;
	import mx.utils.UIDUtil;
	
	import pl.cadera.debug.logToConsole;
	
	public class ComponentExportManager
	{
		/**
		 * Constructor.
		 */
		public function ComponentExportManager()
		{
		}
		
		private var menuItems:Array = [];
		/**
		 * Returns an export context menu item.
		 */
		public function getMenuItem():ContextMenuItem
		{	
			logToConsole("getMenuItem");
			var text:String = LanguageManager.getInstance().labels.common.exportList;
			var item:ContextMenuItem = new ContextMenuItem(text);
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, this.handleMenuItemSelect);		
			return item;
		}
			public function getMenuItem1():ContextMenuItem
		{	
			var text:String = LanguageManager.getInstance().labels.common.exportListAll;
			var item:ContextMenuItem = new ContextMenuItem(text);
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, this.handleMenuItemSelect1);		
			logToConsole("getMenuItem1");
			return item;
		}
		/**
		 * Returns a context menu.
		 */
		public function getExportMenu():ContextMenu
		{
			var cm:ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			cm.customItems = [ getMenuItem1(),getMenuItem() ];
			
			return cm;
		}
		/**
		 * Calls the <code>exportComponent</code> method.
		 * @see #exportComponent
		 */
		protected function handleMenuItemSelect(event:ContextMenuEvent):void
		{
			logToConsole("handleMenuItemSelect");
			exportComponent(event.contextMenuOwner as IExportableComponent);
		}
			protected function handleMenuItemSelect1(event:ContextMenuEvent):void
		{
			logToConsole("handleMenuItemSelect1");
			exportComponent1(event.contextMenuOwner as IExportableComponent);
		}
		
		/**
		 * Calls the exportXml method of a given object, that implements the IExportableComponent interface.
		 */ 
		public function exportComponent(component:IExportableComponent):void
		{			
			logToConsole("exportComponent");
			if(component) component.exportXml("xml"); component.showExportDialog();
		}
		public function exportComponent1(component:IExportableComponent):void
		{		
			logToConsole("exportComponent1");	
			if(component) component.exportXmlAll("xml"); component.showExportDialog();
		}
		/**
		 * Exports a contractor's data.
		 * @param xml A contractor's XML.
		 * @param profileName Name of the profile u want to use.
		 * @param outputContentType An output type ("pdf", "xls",...).
		 * @see #exportObject
		 */
		public var sPartLength:int = 2000000;
		public var postGuid:String;
		public var partSend:int = 0;
		public var parts:int = 0;
		public var url:String;
		public var tempXmlString:Array;
		public var tempProfileName:String;
		public var tempOutputContentType:String;
		
		public function exportData(xml:XML, profileName:String, outputContentType:String):void	
		{		
			if(Services.getInstance().serviceMode == Services.MODE_WEB_SERVICE)
			{
				
				partSend = 1;
				url = ModelLocator.getInstance().configManager.values.services_printService_address.* + "/PrintXml";
				postGuid = UIDUtil.createUID();
				var s:String = xml.toString();
				parts = Math.ceil(s.length / sPartLength);
				tempXmlString = new Array();
				
				for (var i:int = 0; i < parts; i++) {
					tempXmlString.push(s.substr(sPartLength*i,sPartLength))
					//trace(escape(s.substr(sPartLength*i,sPartLength)));
				}
				
				tempProfileName = profileName;
				tempOutputContentType = outputContentType;
				
				sendPostDataInParts();
			}
			else //offline print
				performOfflinePrint(null, xml, profileName);
		}
		
		private function sendPostDataInParts():void {
			var variables:URLVariables = new URLVariables(); 
			variables.xml = tempXmlString[partSend-1];
			
			variables.packedId = postGuid;
			variables.partSend = partSend;
			variables.partsNumber = parts;
			variables.profileName = tempProfileName;
			variables.outputContentType = tempOutputContentType;
			
			var urlRequest:URLRequest = new URLRequest(url);
			urlRequest.data = variables;
			urlRequest.method = URLRequestMethod.POST;
			
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			urlLoader.addEventListener(Event.COMPLETE, urlLoader_complete);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			//urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			urlLoader.load(urlRequest);
		}
		
		private function urlLoader_complete(event:Event):void {
			var result:XML = XML(event.target.data);
			if(result.success == 1 && partSend < parts){
				//trace("next" + partSend + "/" + parts)
				partSend++;
				sendPostDataInParts();
			} else {
					ModelLocator.getInstance().eventManager.dispatchEvent(new Event('closeExportDialogWindow'));
				var url:String = ModelLocator.getInstance().configManager.values.services_printService_address.* + "/DownloadResource";
				
				var variables:URLVariables = new URLVariables(); 
				variables.packedId = postGuid;
				variables.profileName = tempProfileName;
				variables.outputContentType = tempOutputContentType;
				var u:URLRequest = new URLRequest(url);
				
				u.data = variables; 
				u.method = URLRequestMethod.POST;
				navigateToURL(u,"_blank");
				
			
				
				//trace("done");
				
				/*
				var urlLoader:URLLoader = new URLLoader();
				urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
				urlLoader.addEventListener(Event.COMPLETE, urlLoader_complete2);
				urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				urlLoader.load(u);
				*/
			}
		}
		
		private function httpStatusHandler(event:Event):void {
			trace("httpStatusHandler: " + event);
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			trace("securityErrorHandler: " + event);
		}

		private function ioErrorHandler(event:IOErrorEvent):void {
			trace("ioErrorHandler: " + event);
		}
		
		
		
		
		private function performOfflinePrint(id:String, xml:XML, profileName:String):void
		{
			var cmd:OfflinePrintCommand = new OfflinePrintCommand(id, xml, profileName);
			cmd.execute();
		}
		
		
		/**
		 * Exports an object of a given id.
		 * @param profileName Name of the export profile u want to use.
		 * @param id The object's idetifier.
		 * @param outputContentType An output type ("pdf", "xls",...).
		 * @see #exportData
		 */
		public function exportObject(profileName:String, id:String, outputContentType:String, useJavaScript:Boolean = false, params:Object = null):void	
		{		
			if(Services.getInstance().serviceMode == Services.MODE_WEB_SERVICE)
			{
				var url:String = ModelLocator.getInstance().configManager.values.services_printService_address.* + "/PrintBusinessObject/" + id + "/" + profileName + "/" + outputContentType;
				
				var urlVariables:URLVariables = new URLVariables();
				if (ModelLocator.getInstance().userProfileId != null) urlVariables.userProfileId = ModelLocator.getInstance().userProfileId;
				if (params) for (var i:String in params) urlVariables[i] = String(params[i]);
				
				url += '?' + urlVariables.toString().replace(/%2D/g, '-');
				
				if (!useJavaScript)
				{
					var u:URLRequest = new URLRequest(url);
					u.method = URLRequestMethod.GET;
					navigateToURL(u,"_blank");
				}
				else ExternalInterface.call("openUrl", url);
			}
			else //wydruki offline
				performOfflinePrint(id, null, profileName);
		}
		
		public function exportDocuments(typeDescriptor:DocumentTypeDescriptor, id:String, outputContentType:String, relatedDocuments:XML):void
		{
			this.exportObject(typeDescriptor.getDefaultPrintProfile(), id, outputContentType);
			
			var relatedToPrint:XML = typeDescriptor.getRelatedDocumentsToPrintSymbols();
			
			if(relatedToPrint)
			{
				for each(var symbolXml:XML in relatedToPrint.symbol)
				{
					var dt:XML = DictionaryManager.getInstance().getBySymbol(symbolXml.*, 'documentTypes');
					var docTypeId:String = dt.id.*;
					var defaultPrintProfile:String = dt.xmlOptions.*.*.@defaultPrintProfile;
					
					var toPrint:XMLList = relatedDocuments.id.(@documentTypeId == docTypeId);
					
					for each(var idXml:XML in toPrint)
					{
						this.exportObject(defaultPrintProfile, String(idXml.*), outputContentType, true);
					}
				}
			}
		}
		
		/**
		 * Prints fiscal an object of a given id using a profile of a given name.
		 * @param id The object's identifier.
		 * @param profile Name of the profile u want to use.
		 * @see #printDocumentFiscal
		 */
		public function exportObjectFiscal(id:String, profile:String):void
		{
			if(Services.getInstance().serviceMode == Services.MODE_WEB_SERVICE)
			{
				var cmd:PrintDocumentCommand = new PrintDocumentCommand("printService", "xml");
				
				var requestXML:XML = <root/>;
				requestXML.id = id;
				requestXML.profileName = profile;
				requestXML.outputContentType = "content";
				cmd.addEventListener(ResultEvent.RESULT, fiscalPrintHandler, false, 0, true);
				cmd.execute(requestXML);
			}
			else //wydruki offline
			{
				var printCmd:OfflinePrintCommand = new OfflinePrintCommand(id, null, profile);
				printCmd.addEventListener(ResultEvent.RESULT, fiscalPrintHandler, false, 0, true);
				printCmd.execute();
			}
		}
		
		private function fiscalPrintHandler(event:ResultEvent):void
		{
			this.printDocumentFiscal(XML(event.result));
		}
		
		/**
		 * Prints a document fiscal.
		 * @param xml Document's XML.
		 * @see #exportObjectFiscal 
		 */
		public function printDocumentFiscal(xml:XML):void
		{
			//flash.external.ExternalInterface.call("printDoc",xml);
			var cmd:FiscalizeCommercialDocumentCommand = new FiscalizeCommercialDocumentCommand(xml.@id);
			
			if(xml.grossValue == "0.00" && xml.lines.*.length() == 0)
			{
				Alert.show("Wydruk fiskalny dokumentu o zerowej wartości jest niedozwolony");
				return;
			}
					
			if (!ExternalInterface.available)
			{
				Alert.show("Wrapper not available","Print Error");
				return;
			}
			// WEB SERVICE
			if (String(xml.configuration.@printMethod) == "WebService")
			{
				try
				{
					var wsPrinter:WebServicePrinter = new WebServicePrinter();
					wsPrinter.printBill(XMLList(xml));
				}
				catch (error:Error)
				{
					Alert.show("Błąd! : " + error.message);
				}
			}
			// .NET
			else if(String(xml.configuration.@printMethod) == "dotNet")
			{
				var wrapperFunction:String = "printDoc";
				var response:String = ExternalInterface.call(wrapperFunction,xml.toString());
      			if (response == "2") Alert.show(LanguageManager.getLabel("alert.fiscalPrintSupportedOnIE"));
      			else if (response != "1") Alert.show(response,"Print Error");
				else cmd.execute();
			}
			// FLEXPRINT
			else
			{
				try{
					//POSNET
					/* Algorytm fiskalizacji dla Posnet jest inny niż dla Elzab
					 * z powodu wymogu zapewnienia czasu na "wybudzenie" drukarki.
					 * Algorytm wybudzania rozwidla się na 2 wątki co powoduje że błędy
					 * nie mogą być przechwytywane w ComponentExportMenagerze.
					 */
					if(String(xml.configuration.@printerModel) == "PosnetThermal5V")
					{
						var posnet:PosnetPrinter = new PosnetPrinter();
						posnet.printBill(XMLList(xml));
					}
					
					//ELZAB
					else if(String(xml.configuration.@printerModel) == "Elzab")
					{
						var elzab:ElzabPrinter = new ElzabPrinter();
						elzab.printBill(XMLList(xml));
						cmd.execute();
					}
					
					else Alert.show("Błąd! Nie określono typu drukarki");
				}
				catch (error:Error)
				{
					Alert.show("Błąd! : " + error.message);
				}
				finally
				{
					ExternalInterface.call("closePort");
				}
			}
		}

		protected static var instance:ComponentExportManager;
		/**
		 * Returns the instance of ComponentExportManager.
		 */
		public static function getInstance():ComponentExportManager
		{
			if (!instance) instance = new ComponentExportManager();
			return instance;
		}
	}	
}