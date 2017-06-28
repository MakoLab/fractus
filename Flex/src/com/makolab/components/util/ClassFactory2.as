package com.makolab.components.util
{
	import mx.core.ClassFactory;

	public class ClassFactory2 extends ClassFactory
	{
		public function ClassFactory2(generator:Class=null, properties:Object=null)
		{
			super(generator);
			this.properties = properties;
		}
		
		public function addProperty(name:String, value:Object):void
		{
			if (!this.properties) this.properties = {};
			this.properties[name] = value;
		}
		
	}
}