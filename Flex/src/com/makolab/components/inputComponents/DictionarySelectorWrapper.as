package com.makolab.components.inputComponents
{
	import com.makolab.fractus.model.DictionaryManager;
	
	import mx.containers.FormItem;
	
	/**
	 * A wrapper for DictionarySelector enabling it to be used inside FormBuilder.
	 */
	public class DictionarySelectorWrapper extends FormItem implements IFormBuilderComponent
	{
		public function DictionarySelectorWrapper()
		{
			super();
			dictionarySelector = new DictionarySelector();
			dictionarySelector.valueMapping = {"id" : "*"};
			dictionarySelector.labelField = "label";
			addChild(dictionarySelector);
		}
		
		private var dictionarySelector:DictionarySelector;
		
		override public function set data(value:Object):void
		{
			super.data = value;
			dictionarySelector.data = value;
		}
		
		public function get dataObject():Object
		{
			var o:Object = dictionarySelector.dataObject;
			return dictionarySelector.dataObject;
		}
		public function set dataObject(value:Object):void
		{
			dictionarySelector.dataObject = value;
		}
		
		private var _dictionaryName:String;
		
		/**
		 * The name of a dictionary set in the instance of DictionaryManager, eg. <code>itemAttributes</code> or <code>vatRates</code>.  
		 */
		public function set dictionaryName(value:String):void
		{
			_dictionaryName = value;
			var dm:DictionaryManager = DictionaryManager.getInstance();
			dictionarySelector.dataProvider = dm.dictionaries[_dictionaryName];
		}
		public function get dictionaryName():String
		{
			return _dictionaryName;
		}
		
		public function commitChanges():void {}
		public function reset():void {}
		public function validate():Object { return null; }
	}
}