package com.makolab.fractus.model.document
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class InventoryDocumentObject extends BusinessObject
	{
		public var inwentaryzacjaXML:XML;
		
		public var warehouseId:String=null;
		public var fullNumber:String;
		public var issueDate:String;
		public var creationApplicationUserId:String;
		public var status:String;
		public var type:String;
		public var sheets:ArrayCollection = new ArrayCollection();
		public var header:String;
		public var footer:String;
		
		//public var modificationDate:String;
		//public var modifyingUser:String;
		//public var kind:String;		
		//public var ratifyingUser:String;
		//public var ratifyDate:String;	
				
		/**
		 * Initializes a new instance of the <code>MartaDocument</code>.
		 * 
		 * @param vtEntry Optional xml element to deserialize from.
		 */
		public function InventoryDocumentObject(xml:XML)
		{
			super('root');
			if(xml!=null) {
				//this.warehouseId = warehouseId;
				inwentaryzacjaXML = xml;
				deserialize(inwentaryzacjaXML);
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
			
			var x:XML;
		    var xml:XML = inwentaryzacjaXML;
		    
		    delete xml.warehouseId;
		    BusinessObject.serializeSingleValue(this.warehouseId, xml, "warehouseId");
		    delete xml.status;
		    BusinessObject.serializeSingleValue(this.status, xml, "status");   
		    delete xml.type;
		    BusinessObject.serializeSingleValue(this.type, xml, "type");
		    delete xml.header;
		    BusinessObject.serializeSingleValue(this.header, xml, "header");
		    delete xml.footer;
		    BusinessObject.serializeSingleValue(this.footer, xml, "footer");
		    delete xml.issueDate;
		    BusinessObject.serializeSingleValue(this.issueDate, xml, "issueDate");
		    delete xml.sheets;
		    x = <sheets></sheets>;
		    for(var i:int=0;i<sheets.length;i++){
					var newXml:XML = (sheets[i] as InventoryDocumentLine).serialize();
					x.appendChild(newXml);
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
			sheets = new ArrayCollection();
			
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
		 			case "id":
		 			
		 				this[name]=BusinessObject.deserializeString(value[name]);	
		 				break;
		 				
		 			case "sheets":
		 				for each (var n:XML in value[name].*)
		 				{
		 					sheets.addItem(new InventoryDocumentLine(n,fullNumber));
		 				}		 			
		 				break;
		 			
		 			case "type":
		 			
		 				this[name]=BusinessObject.deserializeString(value[name]);	
		 				break;
		 			
		 			case "status":
		 			
		 				this[name]=BusinessObject.deserializeString(value[name]);	
		 				break;
		 			
		 			case "number":
		 					 			
		 				fullNumber=BusinessObject.deserializeString(value[name]["fullNumber"]);	
		 				break;
		 			
		 			case "creationApplicationUserId":
		 			
		 				this[name]=BusinessObject.deserializeString(value[name]);	
		 				break;
		 			
		 			case "issueDate":
		 			
		 				this[name]=BusinessObject.deserializeString(value[name]);	
		 				break;
		 			
		 			case "header":
		 			
		 				this[name]=BusinessObject.deserializeString(value[name]);	
		 				break;
		 			
		 			case "footer":
		 			
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
		public function addLinesFromXML(value:XML):void
		{
			addDeserialize(value);
		}
	}
}