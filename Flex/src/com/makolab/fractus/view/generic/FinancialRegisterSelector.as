package com.makolab.fractus.view.generic
{
	import com.makolab.fractus.commands.GetRegistersOpenReportsCommand;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.view.documents.plugins.DocumentValidationPlugin;
	
	import mx.events.ValidationResultEvent;
	import mx.validators.ValidationResult;
	
	public class FinancialRegisterSelector extends FractusDictionarySelector
	{
		public function FinancialRegisterSelector()
		{
			super();
			
			//setDataProvider();
		}
		
		private var _documentObject:DocumentObject;
		public function get documentObject():DocumentObject { return _documentObject; }
		
		public var showExternalRegisters:Boolean = false;
		
		public function set documentObject(value:DocumentObject):void
		{
			if(_documentObject)
				_documentObject.removeEventListener(ValidationResultEvent.INVALID, handleValidationEvent);
			
			_documentObject = value;
			
			if(value)
			{
				value.addEventListener(ValidationResultEvent.INVALID, handleValidationEvent);
			}		
		}
		
		private function handleValidationEvent(event:ValidationResultEvent):void
		{
			this.errorString = "";
			
			for each(var valResult:ValidationResult in event.results)
			{
				if(valResult.subField == DocumentValidationPlugin.FINANCIAL_REGISTER_SUBFIELD)
				{
					if(valResult.errorCode == DocumentValidationPlugin.NO_FINANCIAL_REGISTER_ERRORCODE)
					{
						this.errorString = valResult.errorMessage;						
					}
				}
			}
		}
		
		private var _documentTypeId:String;
		public function set documentTypeId(value:String):void
		{
			_documentTypeId = value;
			if (_documentTypeId) this.dictionaryName = 'financialRegisters';
			setDataProvider();
		}
		public function get documentTypeId():String { return _documentTypeId; }
		
		override protected function getDictionary(dictionaries:Object, dictionaryName:String, showAll:Boolean = false):Object
		{
			/*
			var dct:XMLList = super.getDictionary(dictionaries, dictionaryName) as XMLList;
			var ret:XMLList = new XMLList();
			for each (var x:XML in dct)
			{
				if (
					_documentTypeId &&
					(showExternalRegisters || x.branchId == ModelLocator.getInstance().branchId) &&
					(
						x.xmlOptions.root.register.incomeDocument.documentTypeId == _documentTypeId ||
						x.xmlOptions.root.register.outcomeDocument.documentTypeId == _documentTypeId
					)
				) ret += x;
			}
			*/
			
			return new XMLList();
		}
		
		private function setDataProvider():void {
			var cmd:GetRegistersOpenReportsCommand = new GetRegistersOpenReportsCommand();
			cmd.execute(getFinancialRegistersResult);
		}
		
		private function getFinancialRegistersResult(result:XML):void {
			var dct:XMLList = super.getDictionary(DictionaryManager.getInstance().dictionaries, dictionaryName) as XMLList;
			var ret:XMLList = new XMLList();
			
			var currency:String = documentObject.xml.documentCurrencyId.toString();
			//var currencyId:String = DictionaryManager.getInstance().getById(x.@financialRegisterId).currencyId;
			for each (var x:XML in dct)
			{
				if(x.currencyId.toString() == currency) {
					if (
						_documentTypeId &&
						(showExternalRegisters || x.branchId == ModelLocator.getInstance().branchId) &&
						(
							x.xmlOptions.root.register.incomeDocument.documentTypeId == _documentTypeId ||
							x.xmlOptions.root.register.outcomeDocument.documentTypeId == _documentTypeId
						)
					) {
						if(result.financialRegister.(@financialRegisterId == x.id).@financialReportId != undefined) {
							ret += x;
						}
					}
				}
			}
			
			this.dataProvider = ret;
			if(ret.length() == 1) {
				selectedIndex = 0;
			}
			this.labelFunction=lFunction;
		}
		private function lFunction(item:Object):String
		{
			if(item.label.@lang.length())
				return item.label.(@lang==LanguageManager.getInstance().currentLanguage)[0];
			else
				return item.label;
		}
	}
}