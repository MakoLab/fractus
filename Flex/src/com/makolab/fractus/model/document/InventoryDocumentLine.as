package com.makolab.fractus.model.document
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class InventoryDocumentLine extends BusinessObject
	{
		//id
		public var sheetXML:XML;
		public var ordinalNumber:String;
		public var inventoryDocumentFullNumber:String;	
		public var status:String;
		public var warehouseId:String=null;
				
		/**
		 * Initializes a new instance of the <code>MartaDocumentLine</code>.
		 * 
		 * @param vtEntry Optional xml element to deserialize from.
		 */
		public function InventoryDocumentLine(sheet:XML,fullNumber:String)
		{
			super('sheet');
			inventoryDocumentFullNumber = fullNumber;
			if (sheet){
				sheetXML = sheet;
				this.deserialize(sheetXML);
			} 
		}
		
		public function getFullXML():XML
		{
			return serialize();
		}
		
		/**
		 * Serializes object to XML format.
		 * 
		 * @return Serialized object in XML format.
		 */
		override public function serialize():XML
		{
			var xml:XML = sheetXML;
			//var xml:XML = <sheet></sheet>;
		    //zbedne bo przeciez tych danych sie nie zmienia, wiec zawsze beda takie same
		  	//delete xml.status;
		    //BusinessObject.serializeSingleValue(this.status, xml, "status");     
		    xml.status = this.status;
		    //var xml:XML = sheetXML;
			return xml;
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
		 			case "id":
		 			
		 				this[name] = BusinessObject.deserializeString(value[name]);		 			
		 				break;
		 				
		 			case "ordinalNumber":
		 			
		 				this[name] = BusinessObject.deserializeString(value[name]);		 			
		 				break;
		 			
		 			case "status":
		 			
		 				this[name] = BusinessObject.deserializeString(value[name]);		 			
		 				break;
		 				
		 			case "warehouseId":
		 			
		 				this[name] = BusinessObject.deserializeString(value[name]);		 			
		 				break;
		 					 			
		 		}
		 	}
		}
	}
}