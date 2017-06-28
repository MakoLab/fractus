package com.makolab.components.inputComponents
{
	/**
	 * Checked by default if a value is provided. Unchecked if the value is empty or null.
	 * When checked and no value has previously been provided, returns '?'. If it has, returns that value.
	 * When unchecked, returns an empty string.
	 */
	public class CheckboxValueEditor extends CheckBoxEditor
	{
		private var _dataObject:Object;
		private var initialValue:Object;
		
		public override function set dataObject(value:Object):void
		{
			if (_dataObject == String(value)) return;
			if (initialValue == null || String(initialValue) == '') initialValue = value; 
			var boolVal:String;
			if (String(value) != '') boolVal = '1';
			else boolVal = '0';
			super.dataObject = boolVal; 
		}
		
		public override function get dataObject():Object
		{
			if (super.dataObject == '1')
			{
				if (initialValue != null && String(initialValue) != '') return initialValue;
				else return '?';
			}
			else return '';
		}

	}
}