package com.makolab.fractus.view.generic
{
	import com.makolab.components.inputComponents.GenericValidator;
	import com.makolab.components.util.CurrencyManager;
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	
	import mx.controls.Label;
	import mx.core.UIComponent;
	
	public class GenericRenderer extends Label
	{
		
		public function GenericRenderer()
		{
			super();
		}

		private var _dataType:String;

		private var _values:XMLList;
		public function set values(list:XMLList):void
		{
			_values = list;
		}
		public function get values():XMLList
		{
			return _values;
		}

		[Bindable]
		public function set dataType(value:String):void
		{
			_dataType = value;
			updateText();
		}
		public function get dataType():String
		{
			return _dataType;
		}
		
		private var _dictionaryName:String;
		[Bindable]
		public function set dictionaryName(value:String):void
		{
			_dictionaryName = value;
			if (editor is FractusDictionarySelector) FractusDictionarySelector(editor).dictionaryName = value;
		}
		public function get dictionaryName():String
		{
			return _dictionaryName;
		}
		
		private var _dataObject:Object;
		[Bindable]
		public function set dataObject(value:Object):void
		{
			_dataObject = value;
			updateText();
		}
		public function get dataObject():Object
		{
			return editor && editorDataField ? editor[editorDataField] : _dataObject;
		}
		
		private var _regExp:String;
		public function set regExp(value:String):void
		{
			_regExp = value;
			if (validator) validator.regExp = value;
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			dataObject = value;
		}
		[Bindable]
		public var postfix:String = "";

		protected var editor:UIComponent;
		protected var editorDataField:String;
		protected var editorDataFunction:Function;
		protected var validator:GenericValidator;
		
		private function updateText():void
		{
			var component:UIComponent;
			var precision:int;
			var value:String = '';
			if (dataObject) switch (dataType)
			{
				case GenericEditor.STRING:
					value = String(dataObject);
					break;
				case GenericEditor.DECIMAL:
				case GenericEditor.DECIMAL6:
				case GenericEditor.INTEGER:
				case GenericEditor.CURRENCY:
					precision = 2;
					if (dataType == GenericEditor.DECIMAL) precision = -4;
					else if (dataType == GenericEditor.DECIMAL6) precision = -6;
					else  if (dataType == GenericEditor.INTEGER) precision = 0;
					value = CurrencyManager.formatCurrency(parseFloat(String(dataObject)), '?', null, precision);
					break;
				case GenericEditor.DICTIONARY:
					var item:XML = DictionaryManager.getInstance().getById(String(dataObject));
					if (item) value = item.label;
					break;
				case GenericEditor.DATE:
				case GenericEditor.DATETIME:
				case GenericEditor.BOOLDATE:
					value = Tools.dateToString(Tools.isoToDate(String(dataObject)));
					break;
				case GenericEditor.SELECT:
					for each (var x:XML in this.values) if (x.name == String(dataObject))
					{
						value = LanguageManager.getLabelFromXML(x.labels[0]);
						break; 
					}
					break;
				case GenericEditor.BOOLEAN:
					if (Tools.parseBoolean(dataObject)) value = '\u2714';
					break;
			}
			this.text = value + " " + postfix;
		}
		/*
		private function setComboData(cb:ComboBox):void
		{
			if (!cb || !values) return;
			var dp:Array = [];
			var lang:String = LanguageManager.getInstance().currentLanguage;
			for each (var x:XML in values) dp.push({ label : String(x.labels.label.(@lang == lang)), value : String(x.name) });
			cb.dataProvider = dp;
		}
		*/
		
		private var _xmlMetadata:XML;
		[Bindable]
		public function set xmlMetadata(value:XML):void
		{
			if (value == this._xmlMetadata) return;
			this._xmlMetadata = value;
			if (this._xmlMetadata)
			{
				this.dictionaryName = this._xmlMetadata.dictionaryName;
				this.dataType = this.dictionaryName ? GenericEditor.DICTIONARY : this._xmlMetadata.dataType;
				this.values = this._xmlMetadata.values.*;
			}
			else
			{
				this.dataType = null;
				this.values = null;
				this.dictionaryName = null;
			}
		}
		public function get xmlMetadata():XML
		{
			return _xmlMetadata;
		} 
		
	}
}