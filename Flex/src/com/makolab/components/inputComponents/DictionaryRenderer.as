package com.makolab.components.inputComponents
{
	import com.makolab.fractus.model.LanguageManager;
	
	import mx.controls.Label;
	import mx.core.IFactory;

	public class DictionaryRenderer extends Label implements IFactory
	{
		public var labelField:String;
		public var valueMapping:Object;		
		public var dataObject:Object;
		public var columnIdent:String;
		
		private var _dataProvider:Object;
		
		public override function set data(value:Object):void
		{
			super.data = value;
			text = "";
			dataObject = DataObjectManager.getDataObject(value, listData);
			if (dataObject)
			{
				for (var itemIndex:String in dataProvider)
				{
					var item:Object = dataProvider[itemIndex];
					var isSelected:Boolean = true;
					for (var i:String in valueMapping)
					{
						if (valueMapping[i] == '*' && typeof(dataObject) != 'object' && typeof(dataObject) != 'xml')
						{
							if (dataObject != item[i].toString()) isSelected = false;
						} 
						else if (dataObject[valueMapping[i]].toString() != item[i].toString()) isSelected = false;
					}
					if (isSelected)
					{
						if(item[labelField].length())
							text=item[labelField].(@lang==LanguageManager.getInstance().currentLanguage)[0];
							else
						text = item[labelField];
						break;
					}
				}
			}
		}
		
		public function set dataProvider(value:Object):void
		{
			_dataProvider = value;
			//data = data;
		}
		
		public function get dataProvider():Object
		{
			return _dataProvider;
		}
		
		public function newInstance():*
		{
			var newInst:DictionaryRenderer = new DictionaryRenderer();
			return newInst;
		}
	}
}