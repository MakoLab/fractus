package com.makolab.components.layoutComponents
{
	public class DragElementProxy
	{
		public function DragElementProxy(value:Object, type:String = null)
		{
			data = value;
			if (type) this.type = type;
		}
		
		public var id:String = "";
		public var itemXML:XML;
		public var dataXML:XML;
		public var type:String = "";
		
		public function set data(value:Object):void
		{
			var _data:Object = value;
			// item from a list
			if (_data is XML && _data.@id.length() > 0 )
			{
				itemXML = XML(_data);
				id = _data.@id;
				type = _data.name();
			}
			// details of an object
			else if (_data is XML)
			{
				dataXML = XML(_data);
				id = _data.id;
				type = _data.name();
			}
			else if (_data is String)
			{
				id = String(value);
				this.type = type;
			}
			else throw new Error("Unrecognized input format.");
		} 
	}
}