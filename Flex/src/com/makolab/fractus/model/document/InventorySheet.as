package com.makolab.fractus.model.document
{
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	import com.makolab.fractus.model.ModelLocator;
	
	[Bindable]
	public class InventorySheet extends BusinessObject
	{
		public var arkuszSpisowyXML:XML;
		
		public var ordinalNumber:String;
		public var inventoryDocumentFullNumber:String;
		public var creationDate:String;
		public var creationApplicationUserId:String;
		public var warehouseId:String = ModelLocator.getInstance().currentWarehouseId;
		public var status:String;
		public var value:Number;
		
		/*
		public var modificationDate:Date;
		public var modifyingUser:String;
		public var receiveUser:String;
		public var receivingDate:Date;
		public var ratifyingUser:String;
		public var ratifyDate:Date;
		*/
		
		public var lines:ArrayCollection = new ArrayCollection();	
				
		/**
		 * Initializes a new instance of the <code>MartaDocument</code>.
		 * 
		 * @param vtEntry Optional xml element to deserialize from.
		 */
		public function InventorySheet(xml:XML = null)
		{
			super('root');
			if(xml!=null) {
				arkuszSpisowyXML = xml;
				deserialize(arkuszSpisowyXML);
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
			var xml:XML = arkuszSpisowyXML;
			
			xml.warehouseId = this.warehouseId;
			xml.status = this.status;
		    
		    delete xml.lines;
		    var x:XML = <lines></lines>;

			for each (var l:InventorySheetLine in lines)
 			{
				x.appendChild(l.serialize());
 			} 
		    xml.appendChild(x);
		     
			return xml;
		}
		
		/**
		 * Deserializes object from xml.
		 *
		 * @param value Xml from which to deserialize.
		 */
		override public function deserialize(value:XML):void
		{
			lines = new ArrayCollection();
			
		    addDeserialize(value);
		}
		
		/**
		 * Deserializes object from xml and adds it to this object.
		 *
		 * @param value Xml from which to deserialize.
		 */
		private function addDeserialize(value:XML):void
		{		
		    for each (var node:XML in value.*)
		 	{
		 		var name:String = node.localName();
		 		switch (name)
		 		{
		 			case "lines":
		 			
		 				for each (var n:XML in value[name].*)
		 				{
		 					lines.addItem(new InventorySheetLine(n));
		 				}	 			
		 				break;
		 			
		 			case "status":
		 			
		 				this[name]=BusinessObject.deserializeString(value[name]);	
		 				break;
		 			
		 			case "id":
		 			
		 				this[name]=BusinessObject.deserializeString(value[name]);	
		 				break;
		 			
		 			case "ordinalNumber":
		 					 			
		 				this[name]=BusinessObject.deserializeString(value[name]);	
		 				break;
		 			
		 			case "inventoryDocumentFullNumber":
		 					 			
		 				this[name]=BusinessObject.deserializeString(value[name]);	
		 				break;
		 			
		 			case "creationApplicationUserId":
		 			
		 				this[name]=BusinessObject.deserializeString(value[name]);	
		 				break;
		 			
		 			case "creationDate":
		 			
		 				this[name]=BusinessObject.deserializeString(value[name]);	
		 				break;
		 			
		 			case "warehouseId":
		 			
		 				this[name]=BusinessObject.deserializeString(value[name]);	
		 				break;
			 			
		 		}
		 	}
		}
		
		/**
		 * Adds new lines to existing ones.
		 * 
		 * @param vtEntry xml element to deserialize from.
		 */
		public function addLinesFromXML(value:XMLListCollection):void
		{		
		    for each (var node:XML in value)
		 	{
		 		var line:InventorySheetLine = new InventorySheetLine(node, true);
		 		if(!containsLine(line))lines.addItem(line);
		 		//else Alert.show("Towar: "+line.itemName+" jest już na arkuszu spisowym.","Uwaga!");
		 	}
		}
		
		public function containsLine(child:InventorySheetLine):Boolean
		{
			var ret:Boolean = false;
			for each (var line:InventorySheetLine in lines)
		 	{
		 		if(line.itemId == child.itemId && line.direction == 1) ret=true;
		 	}
		 	
		 	return ret;
		}
	}
}