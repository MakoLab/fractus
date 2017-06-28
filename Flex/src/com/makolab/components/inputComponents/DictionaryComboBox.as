package com.makolab.components.inputComponents
{
	import mx.controls.ComboBox;
	import flash.events.Event;

	public class DictionaryComboBox extends ComboBox
	{
		public var idNode:String = "id";
		public var nameNode:String = "";
		
		public var dictionaryIdNode:String = "id";
		public var dictionaryNameNode:String = "name";
		
		private var _dataObject:Object;
		private var _dataProvider:Object;
		
		private var idArray:Array;
		
		public function DictionaryComboBox()
		{
			addEventListener(Event.CHANGE, handleChange);
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			_dataObject = DataObjectManager.getDataObject(value, listData);
			var selectedId:String = _dataObject[idNode];
			for (var i:int = 0; i < idArray.length; i++) if (idArray[i] == selectedId) selectedIndex = i;
		}
		
		override public function set dataProvider(value:Object):void
		{
			_dataProvider = value;
			var dp:Array = [];
			idArray = [];
			for (var i:String in _dataProvider)
			{
				var item:Object = _dataProvider[i];
				dp.push(item[dictionaryNameNode].toString());
				idArray.push(item[dictionaryIdNode]);
			}
			super.dataProvider = dp;
		}
		
		private function handleChange(event:Event):void
		{
			if (idArray)
			{
				_dataObject[idNode] = idArray[selectedIndex];
				_dataObject[nameNode] = super.dataProvider[selectedIndex];
			}
		}
	}
}