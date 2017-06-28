package com.makolab.fractus.model.document
{
	import mx.core.IDataRenderer;
	import mx.events.FlexEvent;
	import mx.controls.Label;
	
	[Bindable]
	public class WarehouseDocumentLine extends BusinessObject
	{
		// todo WMS
		
		public var documentObject:DocumentObject;
		
		public var itemId:String;
		public var itemVersion:String;
		public var itemName:String;
		public var itemCode:String;
		
		public var shifts:Array; // WMS
		
		public var quantity:Number = 1;
		
		public var price:Number = 0;
		public var value:Number = 0;
		
		public var additionalNodes:XMLList = new XMLList();
		
		public var unitId:String = '2EC9C7C6-C250-41A6-818A-0C1B2B7D0A6C';
		
		/**
		 * Initializes a new instance of the <code>CommercialDocumentLine</code>.
		 * 
		 * @param vtEntry Optional xml element to deserialize from.
		 */
		public function WarehouseDocumentLine(line:XML = null, parent:DocumentObject = null)
		{
			super('line', 'documentFieldId');
			if (parent) this.documentObject = parent;
			if (line) this.deserialize(line);
		}
		
		/**
		 * Clones the current instance of <code>CommercialDocumentLine</code> object.
		 * 
		 * @return Cloned object instance.
		 */
		override public function copy():BusinessObject
		{
			var newLine:WarehouseDocumentLine = new WarehouseDocumentLine();
		
			newLine.itemId = this.itemId;
			newLine.itemVersion = this.itemVersion;
			newLine.itemName = this.itemName;
			newLine.itemCode = this.itemCode;
			
			newLine.shifts = this.shifts; // WMS

			newLine.quantity = this.quantity;
			newLine.unitId = this.unitId;
			
			newLine.price = this.price;
			newLine.value = this.value;
			
			newLine.id = this.id;
			newLine.version = this.version;
			
			newLine.additionalNodes = this.additionalNodes.copy();
			
			return newLine;
		}
		
		/**
		 * Serializes object to XML format.
		 * 
		 * @return Serialized object in XML format.
		 */
		override public function serialize():XML
		{
			//celowo nie ma UnitOfMeasure bo to nie leci do bazy
			var xml:XML = super.serialize();
		    
		    BusinessObject.serializeSingleValue(this.itemId, xml, "itemId");
		    BusinessObject.serializeSingleValue(this.itemVersion, xml, "itemVersion");
		    BusinessObject.serializeSingleValue(this.itemName, xml, "itemName");
		    BusinessObject.serializeSingleValue(this.itemCode, xml, "itemCode");
		    
		    //BusinessObject.serializeSingleValue(this.shifts, xml, "shifts"); // WMS

		    BusinessObject.serializeSingleValue(this.quantity, xml, "quantity", 6);
		    BusinessObject.serializeSingleValue(this.unitId, xml, "unitId");
		    		    
		    BusinessObject.serializeSingleValue(this.id, xml, "id");
		    BusinessObject.serializeSingleValue(this.version, xml, "version");

		    BusinessObject.serializeSingleValue(this.price, xml, "price", 2);
		    BusinessObject.serializeSingleValue(this.value, xml, "value", 2);
		    
		    //BusinessObject.addIfNotExists(String(this.documentObject.xml.warehouseId), xml, "warehouseId");
			
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

		 			case "unitId":

		 			case "itemId":
		 			case "itemVersion":
		 			case "itemName":
		 			case "itemCode":

		 				this[name] = BusinessObject.deserializeString(value[name]);		 			
		 				break;
		 				
		 			case "price":
		 			case "value":
		 			
		 			case "quantity":

		 				this[name] = BusinessObject.deserializeNumber(value[name]);
		 				break;
		 				
		 			default:
		 				additionalNodes += node;
		 		}
		 	}

		}
		
		override public function isEmpty():Boolean
		{
			return !Boolean(this.itemId);
		}
	}
}