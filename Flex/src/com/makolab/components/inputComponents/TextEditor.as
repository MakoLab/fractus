package com.makolab.components.inputComponents
{
	import mx.controls.TextInput;

	public class TextEditor extends TextInput
	{
		private var _dataObject:String;
		public var columnIdent:String;
		
		public function set dataObject(value:Object):void
		{
			_dataObject = String(value);
			text = String(value);
		}
		public function get dataObject():Object
		{
			_dataObject = text;
			return _dataObject;
		}
		
		public override function set data(value:Object):void
		{
			super.data = value;
			_dataObject = DataObjectManager.getDataObject(value, listData).toString();
		}
		
		public function TextEditor()
		{
			super();
		}			
	}
}