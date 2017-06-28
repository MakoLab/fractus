package com.makolab.fractus.model.document
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class FinancialDocumentLine extends BusinessObject
	{
		public var documentObject:DocumentObject;
		
		public var amount:Number = 0;		
		public var description:String = '';
		
		public var relatedLines:ArrayCollection;
				
		public var additionalNodes:XMLList = new XMLList();
		
		public var salesOrderId:String;
		
		/**
		 * Initializes a new instance of the <code>FinancialDocumentLine</code>.
		 * 
		 * @param vtEntry Optional xml element to deserialize from.
		 */
		public function FinancialDocumentLine(line:XML = null, parent:DocumentObject = null)
		{
			super('payment');
			if (parent) this.documentObject = parent;
			if (line) this.deserialize(line);
		}
		
		/**
		 * Clones the current instance of <code>FinancialDocumentLine</code> object.
		 * 
		 * @return Cloned object instance.
		 */
		override public function copy():BusinessObject
		{
			var newLine:FinancialDocumentLine = new FinancialDocumentLine();
		
			newLine.amount = this.amount;
			newLine.description = this.description;
			
			return newLine;
		}
		
		/**
		 * Serializes object to XML format.
		 * 
		 * @return Serialized object in XML format.
		 */
		override public function serialize():XML
		{
			var xml:XML = super.serialize();
		    
		    BusinessObject.serializeSingleValue(this.id, xml, "id");
		    BusinessObject.serializeSingleValue(this.version, xml, "version");

		    BusinessObject.serializeSingleValue(this.amount, xml, "amount", 2);
		    BusinessObject.serializeSingleValue(this.description, xml, "description");
		    BusinessObject.serializeSingleValue(this.salesOrderId, xml, "salesOrderId");
		    
			xml.appendChild(additionalNodes);		    
		    
			return xml;
		}
		
		/**
		 * Deserializes object from xml.
		 *
		 * @param value Xml from which to deserialize.
		 */
		override public function deserialize(value:XML):void
		{
			//UnitOfMeasure nie znajduje sie w xmlu
			
		    for each (var node:XML in value.*)
		 	{
		 		var name:String = node.localName();
		 		switch (name)
		 		{
		 			case "id":
		 			case "version":
					case "salesOrderId":
		 			case "description":
		 				this[name] = BusinessObject.deserializeString(value[name]);		 			
		 				break;
		 			case "amount":
		 				this[name] = BusinessObject.deserializeNumber(value[name]);
		 				break;
		 			default:
		 				additionalNodes += node;
		 		}
		 	}

		}
		
		override public function isEmpty():Boolean
		{
			return this.amount == 0 && !Boolean(this.description);
		}

	}
}