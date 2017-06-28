package com.makolab.fractus.model
{
	import com.makolab.fractus.commands.GetApplicationUsersCommand;
	import com.makolab.fractus.commands.GetEmployeesCommand;
	import com.makolab.fractus.commands.LoadDictionariesCommand;
	
	import mx.rpc.events.ResultEvent;
	
	[Event(name="usersLoaded", type="flash.events.Event")]
	[Event(name="employeesLoaded", type="flash.events.Event")]
	
	public class DictionaryManager
	{
		
		public static const DOCUMENT_CATEGORY_COMMERCIAL:int = 0;
		public static const DOCUMENT_CATEGORY_WAREHOUSE:int = 1;
		
		public var dictionaryTemplate:XML = 
			<dictionary>
				<contractorField/>
				<contractorRelationType/>
				<country/>
				<currency/>
				<documentField/>
				<documentFieldRelation/>
				<documentType/>
				<issuePlace/>
				<itemField/>
				<itemRelationAttrValueType/>
				<itemRelationType/>
				<itemType/>
				<jobPosition/>
				<paymentMethod/>
				<unit/>
				<unitType/>
				<vatRate/>
				<documentStatus/>
			</dictionary>;
			
		[Bindable]
		public var dictionaryData: XML = dictionaryTemplate.copy();
		public var dictionaryModified: XML = dictionaryTemplate.copy();
				
		public var dictionaryIndex:int;		
		private static var instance:DictionaryManager;
		public var dictionariesXML:Object;
		//public var dictionaryVersion:int;
		
		public var attributeValues:Object;
		
		public function DictionaryManager()
		{
			
		}
				
		[Bindable]
		public var dictionaries:Object;
		
		public static function getInstance():DictionaryManager
		{
			if (!instance) instance = new DictionaryManager();
			return instance;
		}
		
		public function setDictionariesXML(dictionariesXML:XML):void
		{
			this.dictionariesXML = dictionariesXML;
			var dictionaries:Object = {};
			var model:ModelLocator = ModelLocator.getInstance();
			if (dictionariesXML)
			{
				//this.dictionaryVersion = parseInt(dictionariesXML.@version); 
				dictionaries.branches = dictionariesXML.branch.*;
				dictionaries.companies = dictionariesXML.company.*;
				dictionaries.containerTypes = dictionariesXML.containerType.*;
				dictionaries.countries = dictionariesXML.country.*;
				dictionaries.contractorAddresses = dictionariesXML.contractorField.*.(String(name).match(/^Address_.+/));
				dictionaries.contractorAccounts = dictionariesXML.contractorField.*.(String(name).match(/^Account_.+/));
				dictionaries.contractorContacts = dictionariesXML.contractorField.*.(String(name).match(/^Contact_.+/));
				dictionaries.contractorSalesLockAttributes = dictionariesXML.contractorField.*.(String(name).match(/^SalesLockAttribute_.+/));
				dictionaries.contractorAttributes = dictionariesXML.contractorField.*.(String(name).match(/^Attribute_.+/) && String(name) != 'Attribute_Remark' && String(name) != 'Attribute_Annotation' && String(name) != 'Attribute_Warning');
				dictionaries.contractorEmployees = dictionariesXML.contractorRelationType.*.(name == 'Contractor_ContactPerson');
				dictionaries.contractorRemarks = dictionariesXML.contractorField.*.(name == 'Attribute_Remark' || name == 'Attribute_Annotation' || name == 'Attribute_Warning');
				dictionaries.contractorFields = dictionariesXML.contractorField.*;
				dictionaries.currency = dictionariesXML.currency.*;
				dictionaries.documentAttributes = dictionariesXML.documentField.*.(String(name).match(/^Attribute_.+/) && String(name) != 'Attribute_Remarks');
				dictionaries.documentFeatures = dictionariesXML.documentField.*.(String(name).match(/^DocumentFeature_.+/));
				dictionaries.documentRemarks = dictionariesXML.documentField.*.(name == 'Attribute_Remarks');
				dictionaries.documentFields = dictionariesXML.documentField.*;
				dictionaries.documentTypes = dictionariesXML.documentType.*;
				dictionaries.documentStatus = dictionariesXML.documentStatus.*;
				dictionaries.getById = this.getById;
				dictionaries.getByName = this.getByName;
				dictionaries.itemFields = dictionariesXML.itemField.*;
				dictionaries.itemAttributes = dictionariesXML.itemField.*.(String(name).match(/^Attribute_.+/));
				dictionaries.itemAttributesStandard = dictionariesXML.itemField.*.(String(name).match(/^Attribute_.+/) && String(order) > 100);
				dictionaries.itemPrices = dictionariesXML.itemField.*.(String(name).match(/^Price_.+/));
				dictionaries.itemImage = dictionariesXML.itemField.*.(name == 'Attribute_Image');
				dictionaries.itemTypes = dictionariesXML.itemType.*;
				dictionaries.itemRelationTypes = dictionariesXML.itemRelationType.*;
				dictionaries.languages = dictionariesXML.language.*;
				dictionaries.numberSettings = dictionariesXML.numberSetting.*;
				dictionaries.paymentMethod = dictionariesXML.paymentMethod.*;
				dictionaries.unitTypes = dictionariesXML.unitType.*;
				dictionaries.units = dictionariesXML.unit.*;
				dictionaries.vatRates = dictionariesXML.vatRate.*;
				dictionaries.warehouses = dictionariesXML.warehouse.*.(valueOf().branchId == model.branchId);	// only local warehouses
				dictionaries.foreignWarehouses = dictionariesXML.warehouse.*.(valueOf().branchId != model.branchId);	// warehouses in other branches 	
				dictionaries.allWarehouses = dictionariesXML.warehouse.*;	// both local and foreign
				dictionaries.allActiveWarehouses = dictionariesXML.warehouse.*.(valueOf().isActive == "1");	// both local and foreign
				
				if(model.headquarters)
					dictionaries.allActiveFilteredWarehouses = dictionariesXML.warehouse.*.(valueOf().isActive == "1");	// both local and foreign
				else
					dictionaries.allActiveFilteredWarehouses = dictionariesXML.warehouse.*.(valueOf().branchId == model.branchId && valueOf().isActive == "1");	// local only
				
				dictionaries.accountingRules = dictionariesXML.accountingRule.*;
				dictionaries.accountingJournals = dictionariesXML.accountingJournal.*;
				dictionaries.vatRegisters = dictionariesXML.vatRegister.*;
				dictionaries.issuePlaces = dictionariesXML.issuePlace.*;
				dictionaries.financialRegisters = dictionariesXML.financialRegister.*;
				dictionaries.shiftFields = dictionariesXML.shiftField.*;
				dictionaries.servicePlaces = dictionariesXML.servicePlace.*;
				dictionaries.printProfiles = dictionariesXML.printProfile.*;
				
				//dictionaries.dictionaryConfig = dictionariesXML.dictionary.*;
			}
			
			// prowizorka, tzeba poprawic w slowniku
			for each (var x:XML in dictionaries.servicePlaces) x.label = String(x.name);
			
			this.dictionaries = dictionaries;
			if(!dictionaries.users)loadUsers();
			if(!dictionaries.employees)loadEmployees();
		}
		
		public function loadDictionaries():LoadDictionariesCommand
		{
			var cmd:LoadDictionariesCommand = new LoadDictionariesCommand();
			cmd.execute();
			return cmd;
		}
		
		public function loadEmployees():void
		{
			var cmd:GetEmployeesCommand = new GetEmployeesCommand();
			cmd.addEventListener(ResultEvent.RESULT,getEmployeesResult);
			cmd.execute();
		}
		
		private function getEmployeesResult(event:ResultEvent):void
		{
			var employees:XMLList = XML(event.result).*;
			for each (var x:XML in employees) x.label = String(x.shortName);
			dictionaries.employees = employees;
			if (dictionariesXML) dictionariesXML.employees = <employees>{dictionaries.employees}</employees>;
			this.dispatchEvent(new Event("employeesLoaded"));
		}
		
		public function loadUsers():void
		{
			var cmd:GetApplicationUsersCommand = new GetApplicationUsersCommand();
			cmd.addEventListener(ResultEvent.RESULT,getUsersResult);
			cmd.execute();
		}
		
		private function getUsersResult(event:ResultEvent):void
		{
			var users:XMLList = XML(event.result).*;
			for each (var x:XML in users) x.label = String(x.shortName);
			dictionaries.users = users;
			//trace("got users");
			if (dictionariesXML) dictionariesXML.users = <users>{dictionaries.users}</users>;
			this.dispatchEvent(new Event("usersLoaded"));
			/* var copy:Object = {};
			for(var i:String in dictionaries){
				copy[i] = dictionaries[i];
			}
			copy.users = XML(event.result).*;
			dictionaries = copy; */
		}
		
		private var cache:Object = new Object();
		
		public function getById(guid:String):XML
		{
			var val:Object = cache[guid];
			if (val) return val as XML;
			var res:XMLList = dictionariesXML..entry.(valueOf().id == guid);
			if (res.length() == 0) return null;
			else
			{
				cache[guid] = res[0];
				return res[0];
			}
		}

		public function getByName(attrName:String, dictionaryName:String = null):XML
		{
			var l:XMLList;
			if (dictionaryName != null) l = dictionaries[dictionaryName].(valueOf().name == attrName);
			else l = dictionariesXML..entry.(valueOf().name == attrName);
			if (l.length() == 0) return null;
			else return l[0];
			/* var res:XMLList = dictionariesXML..entry.(valueOf().name == attrName);
			if (res.length() == 0) return null;
			else return res[0]; */
		}
		
		public function getIdByName(attrName:String, dictionaryName:String = null):String
		{
			var x:XML = this.getByName(attrName, dictionaryName);
			if (x == null) return null;
			else return String(x.id);
			
		}
		
		public function getBySymbol(attrSymbol:String, dictionaryName:String = null):XML
		{
			var l:XMLList;
			if (dictionaryName != null) l = dictionaries[dictionaryName].(valueOf().symbol == attrSymbol);
			else l = dictionariesXML..entry.(valueOf().symbol == attrSymbol);
			if (l.length() == 0) return null;
			else return l[0];
		}
	}
}