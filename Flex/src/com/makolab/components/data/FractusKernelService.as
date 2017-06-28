package com.makolab.components.data
{
	import mx.rpc.AbstractService;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.http.mxml.HTTPService;

	public class FractusKernelService extends AbstractService
	{
		private var httpService : HTTPService;
		private var xmlRpcHttpService : HTTPService;
		
		public var rootUrl:String;
		
		public function FractusKernelService() {
			super();
			httpService = new HTTPService();
			httpService.resultFormat = "object";
			xmlRpcHttpService = new HTTPService();
			xmlRpcHttpService.resultFormat = "object";
						
			operations.getDocument = new FractusKernelOperation(this, "document.xml", "URL", {});
			operations.searchItem = new FractusKernelOperation(this, "towary.xml.asp", "URL", { query : "query" });
			operations.getItemInfo = new FractusKernelOperation(this, "towar.xml.asp", "URL", { itemId : "id" });

			operations.searchItemContractor = new FractusKernelOperation(this, "kontrahenci.xml.asp", "URL", {query: "query"});
			operations.getItemInfoContractor = new FractusKernelOperation(this, "kontrahent.xml.asp", "URL", {itemId: "id"});
			operations.saveNoteContractor = new FractusKernelOperation(this, "notatki.xml.asp", "URL", {itemId: "id"});
			operations.loadConfigData = new FractusKernelOperation(this, "config.xml.asp", "URL", {itemId: "id"});
			operations.getContractorsGroups = new FractusKernelOperation(this, "grupy.xml.asp", "URL", {});
			operations.saveContractorsGroups = new FractusKernelOperation(this, "grupySave.xml.asp", "URL", {contractorXML: "xml", filterSelected: "filter"});
			operations.getConfigXMLDocuent = new FractusKernelOperation(this, "config.xml.asp", "URL", {documentType : "typDok"});
			operations.getDocumentLinesAttributes =new FractusKernelOperation(this, "atrybuty.xml.asp", "URL", {query: "query"});
			operations.getContractorDataFromMM = new FractusKernelOperation(this, "contractorDataMM.xml.asp", "URL", {idMM: "idMM", plik: "file"});
			
			
			operations.dictionaryList =  new FractusKernelOperation(this, "dictionaryList.asp", "URL", {dictionaryTable: "dictionaryTable",config:"config",items:"items"});		
			operations.dictionaryItem =  new FractusKernelOperation(this, "dictionaryItem.asp", "URL", {dictionaryTable :"dictionaryTable",config:"config",item:"item", id : "id",identity:"identity",param:"param"});	
			operations.dictionaryLanguage = new FractusKernelOperation(this, "dictionaryLanguage.asp", "URL", {});
			operations.dictionarySaveItem =  new FractusKernelOperation
				(
					this,
					"dictionarySave.asp",
					"XMLRPC",
					 {
					 	
					 	object : "dictionary",
						method : "DictionarySaveItem",
						params : ["dictionaryTable","identity","id","xml"]}
				);	
				operations.dictionaryDeleteItem =  new FractusKernelOperation
				(
					this,
					"dictionarySave.asp",
					"XMLRPC",
					 {
					 	
					 	object : "dictionary",
						method : "DictionaryDeleteItem",
						params : ["dictionaryTable","identity","id"]}
				);			
		
			operations.createDocument = new FractusKernelOperation
				(
					this,
					"NetModule.asp",
					"XMLRPC",
					{
						object : "netModule",
						method : "CreateNewDocument",
						params : ["documentType", "source", "sourceId", "target"]
					}
				);
			operations.loadDocument = new FractusKernelOperation
				(
					this,
					"NetModule.asp",
					"XMLRPC",
					{
						object : "netModule",
						method : "LoadDocument",
						params : ["documentId", "target"]
					}
				);
				operations.loadDocumentReclamation = new FractusKernelOperation
				(
					this,
					"NetModuleReclamation.asp",
					"XMLRPC",
					{
						object : "netModuleReclamation",
						method : "LoadDocument",
						params : ["documentId"]
					}
				);
			operations.createDocumentReclamation = new FractusKernelOperation
				(
					this,
					"NetModuleReclamation.asp",
					"XMLRPC",
					{
						object : "netModuleReclamation",
						method : "CreateNewDocument",
						params : ["documentType","source", "sourceId"]
					}
				);	
		    operations.commitDocumentReclamation = new FractusKernelOperation
				(
					this,
					"NetModuleReclamation.asp",
					"XMLRPC",
					{
						object : "netModuleReclamation",
						method : "CommitDocument",
						params : ["XMLDocument", "Option"]
					}
				);
		}
		
		public function urlRequest(url:String, operation:FractusKernelOperation, params:Object):AsyncToken
		{
			var urlParams:Object = {};
			for (var i:String in params)
			{
				if (operation.paramMapping.hasOwnProperty(i)) urlParams[operation.paramMapping[i]] = params[i];
				else urlParams[i] = params[i];
			}
			httpService.url = rootUrl + url;
			httpService.method = "GET";
			return httpService.send(urlParams);
		}
		
		public function xmlRpcRequest(url:String, operation:FractusKernelOperation, params:Object):AsyncToken
		{
			var object:String = operation.paramMapping.object;
			var method:String = operation.paramMapping.method;
			var paramList:Object = operation.paramMapping.params;
			var xml:XML = <request objectName={object} methodName={method}></request>;
			for (var i:String in paramList) {
				var val:Object = (params && params.hasOwnProperty(paramList[i])) ? params[paramList[i]] : "";
				var valStr:String = (val is XML) ? val.toXMLString() : val.toString();
				xml.appendChild(<argument>{XML("<![CDATA[" + valStr.replace(/\]/g, '\\]') + "]]>")}</argument>);
			}
			xmlRpcHttpService.url = rootUrl + url;
			xmlRpcHttpService.method = "POST";
			xmlRpcHttpService.contentType = "text/xml";
			var token:AsyncToken = xmlRpcHttpService.send(entityEncode(xml.toXMLString()));
			return token;
		}

		private function handleRpcFault(event:FaultEvent):void
		{
			var rpcToken:AsyncToken = event.token["rpcToken"] as AsyncToken;
			rpcToken.dispatchEvent(new FaultEvent(FaultEvent.FAULT, false, true, event.fault, rpcToken, event.message));
		}
				
		// replace all non-ASCII characters with a corresponding entity (&#xxxx;)
		private function entityEncode(strText:String):String
		{
			return strText.replace(
					/([^\x00-\x80])/g,
					function (str:String, p1:String, offset:int, s:String):String
						{
							return  '&#' + p1.charCodeAt(0) + ';'
						}
				);
		}
	}
}