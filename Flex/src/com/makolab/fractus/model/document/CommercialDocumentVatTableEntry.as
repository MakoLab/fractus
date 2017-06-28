package com.makolab.fractus.model.document
{
	public class CommercialDocumentVatTableEntry extends BusinessObject
	{
		public var netValue:Number = 0;
		public var grossValue:Number = 0;
		public var vatValue:Number = 0;
		
		public var vatRateId:String;
		
		/**
		 * Initializes a new instance of the <code>CommercialDocumentVatTableEntry</code>.
		 * 
		 * @param vtEntry Optional xml element to deserialize from.
		 */
		public function CommercialDocumentVatTableEntry(vtEntry:XML=null)
		{
			super('vtEntry');
			if (vtEntry) this.deserialize(vtEntry);
		}
		
		/**
		 * Serializes object to XML format.
		 * 
		 * @return Serialized object in XML format.
		 */
		override public function serialize():XML
		{
			var xml:XML = super.serialize();
		     
		    BusinessObject.serializeSingleValue(this.netValue, xml, "netValue", 2);
		    BusinessObject.serializeSingleValue(this.grossValue, xml, "grossValue", 2);
		    BusinessObject.serializeSingleValue(this.vatValue, xml, "vatValue", 2);
		    
		    BusinessObject.serializeSingleValue(this.vatRateId, xml, "vatRateId");
		    
		    BusinessObject.serializeSingleValue(this.id, xml, "id");
		    BusinessObject.serializeSingleValue(this.version, xml, "version");
			
			return xml;
		}
		
		/**
		 * Deserializes object from xml.
		 *
		 * @param value Xml from which to deserialize.
		 */
		override public function deserialize(value:XML):void
		{
			this.netValue = BusinessObject.deserializeNumber(value.netValue);
			this.grossValue = BusinessObject.deserializeNumber(value.grossValue);
			this.vatValue = BusinessObject.deserializeNumber(value.vatValue);
			
			this.vatRateId = BusinessObject.deserializeString(value.vatRateId);
			
			this.id = BusinessObject.deserializeString(value.id);
			this.version = BusinessObject.deserializeString(value.version);
		}
	}
}