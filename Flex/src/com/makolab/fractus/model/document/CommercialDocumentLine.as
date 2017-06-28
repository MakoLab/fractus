package com.makolab.fractus.model.document
{
	import com.makolab.fractus.model.ModelLocator;
	
	[Bindable]
	public class CommercialDocumentLine extends BusinessObject
	{
		public var documentObject:DocumentObject;
			
		public var itemId:String;
		public var itemVersion:String;
		public var itemName:String;
		public var itemCode:String;
		
		public var quantity:Number = 1;
		
		public var netPrice:Number = 0;
		public var grossPrice:Number = 0;
		
		public var initialNetPrice:Number = 0;
		public var systemCurrencyNetPrice:Number = 0;
		public var initialGrossPrice:Number = 0;
		
		public var discountRate:Number = 0;
		public var discountNetValue:Number = 0;
		public var discountGrossValue:Number = 0;

		public var initialNetValue:Number = 0;
		public var initialGrossValue:Number = 0;
		
		public var itemPrices:XMLList;
		
		public var netValue:Number = 0;
		public var grossValue:Number = 0;
		public var vatValue:Number = 0;
		
		public var cost:Number = NaN;
		public var purchasePrice:Number = 0;
		
		public var additionalNodes:XMLList = new XMLList();
		
		public var vatRateId:String = null;
		
		public var unitId:String = '2EC9C7C6-C250-41A6-818A-0C1B2B7D0A6C';
		
		public var shifts:Array // WMS
		
		public var warehouseId:String;
		
		public var correctiveLine:CorrectiveCommercialDocumentLine = null;
		
		public var tag:String;
		
		public var itemTypeId:String;
		
		public var priceName:String;
		public function get technologyName():String
		{
			var attr:BusinessObjectAttribute = this.getAttributeByName("LineAttribute_ProductionTechnologyName");
			
			if(attr == null) return "";
			else return String(attr.label);
		}
		
		public function set technologyName(value:String):void
		{
			
		}
		
		/**
		 * Initializes a new instance of the <code>CommercialDocumentLine</code>.
		 * 
		 * @param vtEntry Optional xml element to deserialize from.
		 */
		public function CommercialDocumentLine(line:XML = null, parent:DocumentObject = null)
		{
			super('line', 'documentFieldId');
			if (parent) this.documentObject = parent;
			if (line) this.deserialize(line);
			if (!warehouseId) warehouseId = ModelLocator.getInstance().currentWarehouseId;
		}
		
		/**
		 * Clones the current instance of <code>CommercialDocumentLine</code> object.
		 * 
		 * @return Cloned object instance.
		 */
		override public function copy():BusinessObject
		{
			var newLine:CommercialDocumentLine = super.copy() as CommercialDocumentLine;
		
			newLine.itemId = this.itemId;
			newLine.itemVersion = this.itemVersion;
			newLine.itemName = this.itemName;
			newLine.itemCode = this.itemCode;
			
			newLine.quantity = this.quantity;
			
			newLine.netPrice = this.netPrice;
			newLine.grossPrice = this.grossPrice;
			
			newLine.initialNetPrice = this.initialNetPrice;
			newLine.initialGrossPrice = this.initialGrossPrice;
			
			newLine.discountRate = this.discountRate;
			newLine.discountNetValue = this.discountNetValue;
			newLine.discountGrossValue = this.discountGrossValue;
	
			newLine.initialNetValue = this.initialNetValue;
			newLine.initialGrossValue = this.initialGrossValue;
	
			newLine.netValue = this.netValue;
			newLine.grossValue = this.grossValue;
			newLine.vatValue = this.vatValue;
			
			newLine.vatRateId = this.vatRateId;
			
			newLine.unitId = this.unitId;
			
			newLine.shifts = this.shifts;
			
			newLine.warehouseId = this.warehouseId;
			
			newLine.additionalNodes = this.additionalNodes.copy();
			newLine.priceName=this.priceName;
			
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

		    BusinessObject.serializeSingleValue(this.quantity, xml, "quantity", 6);
		    
		    BusinessObject.serializeSingleValue(this.netPrice, xml, "netPrice", 2);
		    BusinessObject.serializeSingleValue(this.grossPrice, xml, "grossPrice", 2);
		    
		    BusinessObject.serializeSingleValue(this.initialNetPrice, xml, "initialNetPrice", 2);
		    BusinessObject.serializeSingleValue(this.initialGrossPrice, xml, "initialGrossPrice", 2);
		    
		    BusinessObject.serializeSingleValue(this.discountRate, xml, "discountRate", 2);
		    BusinessObject.serializeSingleValue(this.discountNetValue, xml, "discountNetValue", 2);
		    BusinessObject.serializeSingleValue(this.discountGrossValue, xml, "discountGrossValue", 2);

		    BusinessObject.serializeSingleValue(this.initialNetValue, xml, "initialNetValue", 2);
		    BusinessObject.serializeSingleValue(this.initialGrossValue, xml, "initialGrossValue", 2);

		    BusinessObject.serializeSingleValue(this.netValue, xml, "netValue", 2);
		    BusinessObject.serializeSingleValue(this.grossValue, xml, "grossValue", 2);
		    BusinessObject.serializeSingleValue(this.vatValue, xml, "vatValue", 2);
		    
		    BusinessObject.serializeSingleValue(this.vatRateId, xml, "vatRateId");
		    BusinessObject.serializeSingleValue(this.unitId, xml, "unitId");
		    
		    BusinessObject.serializeSingleValue(this.warehouseId, xml, "warehouseId");
		    
		    BusinessObject.serializeSingleValue(this.id, xml, "id");
		    BusinessObject.serializeSingleValue(this.version, xml, "version");
		    
		    if(this.tag)
		    	xml.@tag = this.tag;
		    
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
			super.deserialize(value);
			//UnitOfMeasure nie znajduje sie w xmlu
			
		    for each (var node:XML in value.*)
		 	{
		 		var name:String = node.localName();
		 		switch (name)
		 		{
		 			case "id":
		 			case "version":

		 			case "vatRateId":
		 			case "unitId":
		 			case "warehouseId":

		 			case "itemId":
		 			case "itemVersion":
		 			case "itemName":
		 			case "itemCode":

		 				this[name] = BusinessObject.deserializeString(value[name]);		 			
		 				break;
	 				
		 			case "netPrice":
		 			case "grossPrice":
		 			case "initialNetPrice":
		 			case "initialGrossPrice":
		 			
		 			case "discountRate":
		 			case "discountNetValue":
		 			case "discountGrossValue":
		 			
		 			case "initialNetValue":
		 			case "initialGrossValue":
		 			case "netValue":
		 			case "grossValue":
		 			case "vatValue":

		 			case "quantity":

		 				this[name] = BusinessObject.deserializeNumber(value[name]);
		 				break;
		 				
		 			default:
		 				additionalNodes += node;
		 		}
		 	}
		 	
		 	if(value.@tag.length() > 0 && String(value.@tag) != "")
		 		this.tag = value.@tag;

		}
		
		override public function isEmpty():Boolean
		{
			return !Boolean(this.itemId);
		}

	}
}