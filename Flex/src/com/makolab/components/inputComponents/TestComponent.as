package com.makolab.components.inputComponents
{
	import mx.controls.TextInput;
	import mx.utils.XMLNotifier;
	
	public class TestComponent extends TextInput implements mx.utils.IXMLNotifiable
	{
		private var _dataProvider:Object;
		private var _dataField:String;
		
		public function set dataProvider(value:XML):void
		{
			if (_dataProvider) XMLNotifier.getInstance().unwatchXML(_dataProvider, this);
			_dataProvider = value;
			if (_dataProvider)
			{
				XMLNotifier.getInstance().watchXML(_dataProvider, this);
				updateText();
			}
		}
		
		private function updateText():void
		{
			if (_dataProvider && _dataField) text = _dataProvider[_dataField];
		}
		
		public function set dataField(value:String):void
		{
			_dataField = value;
			updateText();
		}
				
	    public function xmlNotification(
	                         currentTarget:Object,
                             type:String,
                             target:Object,
                             value:Object,
                             detail:Object):void
		{
			updateText();
		}
		
		
	}
}