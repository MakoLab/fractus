package com.makolab.components.inputComponents
{
	import com.makolab.fractus.model.DictionaryManager;
	
	import mx.controls.Label;

	public class TechnologyNameRenderer extends Label
	{
		private var _data:XML;
		
		public override function set data(value:Object):void
		{
			_data = value as XML;
			
			if(_data)
			{
				var id:String = DictionaryManager.getInstance().getByName("LineAttribute_ProductionTechnologyName", "documentFields").id;
				
				var attr:XMLList = _data.attributes.attribute.(documentFieldId == id);
				
				if(attr.length() != 0)
				{
					this.text = attr[0].label.*;
					this.toolTip = this.text;
				}
				else
				{
					this.text = "";
					this.toolTip = null;	
				}
			}			
		}
		
		public override function get data():Object
		{
			return _data;	
		}
	}
}