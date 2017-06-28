package com.makolab.fractus.model.document
{
	import assets.IconManager;
	
	[Bindable]
	public class InventorySheetLine extends BusinessObject
	{
		public var lineXML:XML;
		
		public var itemId:String;
		public var itemName:String;
		public var systemQuantity:Number;
		public var userQuantity:Number = NaN;	
		public var _direction:int = 1; //status 1- aktywna, 0-anulowana
		public var directionSymbol:Class = null; //ikona przypisana do aktualnego direction
		public var userDate:String = null;
		public var unitId:String ='2EC9C7C6-C250-41A6-818A-0C1B2B7D0A6C';
		public var deliveries:XMLList;
		public var value:Number;
		public var lastPurchaseNetPrice:Number;
		
		public function set direction(value:int):void{
			_direction = value;
			directionSymbol = directionSymbolByValue(value);
		}
		
		public function	get direction():int{
			return _direction;
		}
		
		public static function directionSymbolByValue(directionValue:int):Class{
			if(directionValue==0) return IconManager.getIcon('status_canceled');
			else return null;
		}	
		/**
		 * Initializes a new instance of the <code>InventorySheetLine</code>.
		 * 
		 * @param line xml element to deserialize from.
		 * @param fromItem Optional boolean element, if true, then line xml is an item xml, else it's a line xml.
		 */
		public function InventorySheetLine(line:XML, fromItem:Boolean = false)
		{
			super('line');	
			if (line) {
				lineXML = line;
				if(fromItem) this.deserializeFromItem(lineXML);
				else this.deserialize(lineXML);
			}
		}
		
		/**
		 * Serializes object to XML format.
		 * 
		 * @return Serialized object in XML format.
		 */
		override public function serialize():XML
		{
			var xml:XML = this.lineXML;

			if(this.userQuantity>=0){
				delete xml.userQuantity;
				BusinessObject.serializeSingleValue(this.userQuantity, xml, "userQuantity", 4);
			}
			xml.itemId = this.itemId;
		    xml.unitId = this.unitId;
			if(this.userDate != null) xml.userDate = this.userDate;
			xml.direction = this.direction;
			xml.deliveries = this.deliveries;
			return xml;
			
			
			
			/*
			<version>C85B81AF-5094-4733-8AF1-18316ADE1B0A</version>	
			<direction>1</direction>
			<userDate>2010-02-03T10:23:58.000</userDate>		
			<userQuantity>10.000000</userQuantity>		
			<systemQuantity>0.000000</systemQuantity>
			<itemName>155/70/13 75T PASSIO 2 DĘBICA</itemName>
			<itemId>AAE25431-D66C-49CC-83CC-DC6439C22AAF</itemId>
			
			<ordinalNumber>2</ordinalNumber>
			<systemDate>2010-02-03T10:11:46.797</systemDate>
			<id>48349B01-11AD-4727-9CD9-7B8FCD2171F1</id>
			*/
		}
		
		/**
		 * Deserializes object from xml.
		 *
		 * @param value Xml from which to deserialize.
		 */
		override public function deserialize(value:XML):void
		{
		    for each (var node:XML in value.*)
		 	{
		 		var name:String = node.localName();
		 		switch (name)
		 		{
		 			case "itemId":
		 			
		 				this[name] = BusinessObject.deserializeString(value[name]);		 			
		 				break;
		 				
		 			case "version":
		 			
		 				this[name] = BusinessObject.deserializeString(value[name]);		 			
		 				break;
		 				
		 			case "itemName":
		 			
		 				this[name] = BusinessObject.deserializeString(value[name]);		 			
		 				break;

		 			case "systemQuantity":

		 				this[name] = BusinessObject.deserializeNumber(value[name]);		 			
		 				break;
		 				
		 			case "value":
		 			case "lastPurchaseNetPrice":

		 				this[name] = BusinessObject.deserializeNumber(value[name]);		 			
		 				break;
		 				
		 			case "userQuantity":

		 				this[name] = BusinessObject.deserializeNumber(value[name]);
		 				break;
		 			
		 			case "direction":

		 				this[name] = BusinessObject.deserializeInt(value[name]);
		 				break;
		 			
		 			case "userDate":

		 				this[name] = BusinessObject.deserializeString(value[name]);
		 				break;
		 			
		 			case "unitId":
		 			
		 				this[name] = BusinessObject.deserializeString(value[name]);		 			
		 				break;
		 						 			
		 		}
		 	}
		}
		
		public function deserializeFromItem(value:XML):void
		{
			this.lineXML =  <line type="InventorySheetLine"></line>;
			this.version = null;
			this.itemId = value.@id;
			this.itemName = value.@name;
			this.systemQuantity = value.@quantity;
			this.unitId = value.@unitId;
			this.direction = 1; //0 - anulowana	
			this.userDate = null;
			this.deliveries = value.children();
			this.value = value.value;
			this.lastPurchaseNetPrice = value.@lastPurchaseNetPrice;
			//trace(this.deliveries)
		}
	}
}