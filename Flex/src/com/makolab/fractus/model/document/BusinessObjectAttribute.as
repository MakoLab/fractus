package com.makolab.fractus.model.document
{
	import org.un.cava.birdeye.ravis.graphLayout.data.Node;
	
	public class BusinessObjectAttribute
	{
		public function BusinessObjectAttribute(idFieldName:String, xml:XML = null)
		{
			this.idFieldName = idFieldName;
			if (xml) this.deserialize(xml);
		}
		
		/**
		 * Name of the field containing id eg. documentFieldId
		 */
		public var idFieldName:String;
		
		/**
		 * Idenifier from Dictionary.*Field
		 */
		public var fieldId:String;
		
		public var order:int;
		
		public var value:Object;
		
		public var id:String;
		public var version:String;
		public var label:String;
		
		public function serialize():XML
		{
			var ret:XML = <attribute><value/></attribute>;
			ret[idFieldName] = this.fieldId;
			if (this.id) ret.id = this.id;
			if (this.version) ret.version = this.version;
			if (this.value) ret.value.* = this.value;
			if (this.label) ret.label.* = this.label;
			return ret;
		}
		
		public function deserialize(xml:XML):void
		{
			this.id = xml.id;
			this.version = xml.version;
			this.fieldId = xml[idFieldName];
			if (xml.value.* == String(xml.value)) this.value = String(xml.value);	// text
			else this.value = xml.value.*[0];	// XML
			this.label = xml.label.toString();
		}
		
	}
}