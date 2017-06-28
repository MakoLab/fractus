package com.makolab.fractus.model
{
	import com.makolab.fractus.vo.SessionVO;
	
	import flash.ui.ContextMenu;
	
	[Bindable]
	public class ModelLocator
	{
		public static const EMPTY:int = 0;
		public static const CONTRACTORS:int = 1;
		public static const ITEMS:int = 2;
		public static const OWN_COMPANIES:int = 3;
		public static const DOCUMENTS:int = 4;
		public static const SALES_DOCUMENT_EDITOR:int = 5;
		public static const DICTIONARY:int = 6;
		public static const QUICK_SALES_DOCUMENT_EDITOR:int = 7;
		
		public var applicationObject:Main;
		
		public var configManager:ConfigManager = new ConfigManager();
		public var keyboardShortcutManager:KeyboardManager = new KeyboardManager();
		public var cm:ContextMenu = new ContextMenu();
		
		public var labelsConfig:XML = configManager.getXML("labels.pl");
		public var labelsConfigEN:XML = configManager.getXML("labels.en");
		public var permissionStructure:XML;
		
		
		public var userProfileId:String; //id profilu uzytkownika
		
		// profil uprawnień zalogowanego użytkownika
		public var permissionProfile:String;
		
		// id wybranego magazynu
		public var currentWarehouseId:String;
		// id wybranej ceny
		public var currentItemPriceId:String;
		// id firmy
		public var companyId:String;
		// id oddzialu
		public var branchId:String;
		// flaga okreslajaca czy WMS jest wlaczony
		public var isWmsEnabled:Boolean;
		// id waluty systemowej
		public var systemCurrencyId:String;
		
		public var kernelServiceUrl:String = "";
		
		public var printServiceUrl:String = "";
		
		public var isSalesLockEnabled:Boolean;
		
		public var minimalProfitMarginValidation:Boolean;
		
		//public var currentUserId:String;
		
		// true jezeli zalogowalismy sie do bazy centralnej
		public var headquarters:Boolean = true;
		
		public var q:XML;
		public var sessionVO:SessionVO;
		public var msg:String="";
		public var challengeCodeLocks:Boolean = true;
		public var isDashboard:Boolean=false;
		public var systemStartDate:Date = new Date(2009,0,1);
		
		/*
		 * Obiekty przechowujace szablony
		 */
		public var documentTemplates:XML;
		public var salesDocumentTemplates:XMLList;
		public var salesOrderDocumentTemplates:XMLList;
		public var productionOrderDocumentTemplates:XMLList;
		public var technologyDocumentTemplates:XMLList;
		public var purchaseDocumentTemplates:XMLList;
		public var warehouseDocumentTemplates:XMLList;
		public var orderDocumentTemplates:XMLList;
		public var financialDocumentTemplates:XMLList;
		public var serviceDocumentTemplates:XMLList;
		public var itemTemplates:XMLList;
		public var contractorTemplates:XMLList;
		public var complaintDocumentTemplates:XMLList;
		public var inventoryDocumentTemplates:XMLList;
		
		
		/* managers */
		public var menuManager:MenuManager = new MenuManager();
		public var errorManager:ErrorManager = new ErrorManager();
		public var sessionManager:SessionManager = new SessionManager();
		public var languageManager:LanguageManager = LanguageManager.getInstance();
		public var dictionaryManager:DictionaryManager = DictionaryManager.getInstance();
		public var permissionManager:PermissionManager = new PermissionManager();
		public var eventManager:EventManager = new EventManager();
		public var cacheDataManager:CacheDataManager = CacheDataManager.getInstance();
		
		public var exportListXML: XML;
		
		public var paymentSimple:Boolean = false;
		
		public var ownCompanyManager:OwnCompanyManager = new OwnCompanyManager();
		
		private static var instance:ModelLocator;
		
		public var currentScreen:int = EMPTY;
		
		public function get isSalesOrderModuleEnabled():Boolean
		{
			var conf:Object = configManager.values["processes_salesOrder"];
			
			if(conf == null) return false;
			else return true;
		}
		
		public function getDefaultTemplate(type:String):String
		{
			var templates:XMLList = this[type + "Templates"];
			var def:XMLList = templates.(valueOf().@isDefault == "true");
			
			if(def.length() > 0)
				return def[0].@id;
			else return null;
		}
		
		public function ModelLocator(enforcer:SingletonEnforcer)
		{
			if (enforcer == null) throw new Error("You Can Only Have One ModelLocator");
		}
	
		public static function getInstance():ModelLocator
		{			
			if (instance == null) instance = new ModelLocator(new SingletonEnforcer);
			return instance;
		}
		
		public var shouldUsePriceList:Boolean=false;
		/**
		 * Flag indicating whether we are in autoLogon mode if set to <code>true</code>.
		 * We dont know yet in what mode we are if set to <code>null</code>.
		 */
		public var autoLogon:Boolean = false;
		
		/**
		 * Checks whether we are in debug mode.
		 * 
		 * @return <code>true</code> if we are in debug mode; otherwise <code>false</code>.
		 */
		public function isDebug():Boolean
		{
			return this.sessionManager.showDiagnostics();
		}
		
		public function toString():String
		{
			return "ModelLocator";
		}
		
	}
}

class SingletonEnforcer {}