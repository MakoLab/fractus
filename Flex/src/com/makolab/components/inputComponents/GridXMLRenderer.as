package com.makolab.components.inputComponents
{
	import mx.controls.Label;
	import mx.core.IFactory;

	public class GridXMLRenderer extends Label implements IFactory
	{
		public var columnIdent:String;
		private var _data:Object;
		
		public function GridXMLRenderer()
		{
			super();
		}
		
        public function newInstance():*
        {
           return new GridXMLRenderer();
        }
        
        override public function set data(value:Object):void
        {
        	_data = value;
        	this.text = "XML";
        	this.toolTip = value.toString();
        }
        
        override public function get data():Object
        {
        	return _data;
        }
	}
}