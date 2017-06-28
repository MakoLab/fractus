package com.makolab.fractus.model.document
{
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.model.ModelLocator;
		
	[Bindable]
	public class DecisionComplainDocumentLine extends BusinessObject
		{
		public var documentObject:DocumentObject;
		
		// definjuje dostępność pól
		public var editableRow:Boolean = true;
		public var editableItem:Boolean =  true; 
		
		//data podjecia decyzji
		public var date:String= Tools.dateToIso(new Date());		
		//pozycja z protokołu		
		public var itemIdOrg:String;
		public var itemNameOrg:String;
		
		public var warehouseId:String;
		//pozycja z decyzji
		public var itemId:String;
		public var itemName:String;

		//powiązanei z protokołem
		public var relatedProtocolLine:ProtocolComplainDocumentLine; 

		// treść decyzji reklamacyjnej  (uzasadnienie)
		public var decisionText:String = "";
		//ilosc
		public var _quantity:Number = 0;
		public function  set quantity(value:int):void
		{
			_quantity = relatedProtocolLine.quantityLeft(value, this)
		}
		public function get quantity():int
		{
			return this._quantity;
		}
			
		public var issuingPersonContractorId:String;
		
		// typ podjętej decyzji
		private var _typeDecision:int
		private var _realizeOption:int = 0;
		
		public function set realizeOption(value:int):void
		{
			this._realizeOption = value;
			
			if(value == 2)
				this.editableRow = false;
		}
		
		public function get realizeOption():int
		{
			return this._realizeOption;
		}
		
		public function set typeDecision(value:int):void
		{
			switch (value)
			{
				case 1: // korekta faktury wartosciowa
				case 2:  // korekta faktury ilosciowej
				case 0: //Nie uznana towar bez zmian zwrot
					this.itemId = this.itemIdOrg;
					this.itemName =  this.itemNameOrg;
					this.editableItem = false;
					break;
				case 3: // uznana utylizacja
				case 4: // uznana zwrot do dostawcy
					this.editableItem = true;
					break;	
				default	:
					this.editableItem = true;
					break;	
			}
			_typeDecision = value
		}
		public function get  typeDecision():int
		{
			return _typeDecision;
		}
		
		public var unitId:String = '2EC9C7C6-C250-41A6-818A-0C1B2B7D0A6C';
		
		
		public function DecisionComplainDocumentLine(line:XML = null, parent:DocumentObject = null, relatedProtocolLine:ProtocolComplainDocumentLine = null)
		{
			super('complaintDecision', null);
			this.relatedProtocolLine = relatedProtocolLine;
			if (parent) this.documentObject = parent;
			if (line) this.deserialize(line);
			if (!warehouseId) warehouseId = ModelLocator.getInstance().currentWarehouseId;
		}
		
		
		override public function serialize():XML
		{
			var xml:XML = super.serialize();
			    
		    BusinessObject.serializeSingleValue(this.itemId, xml, "replacementItemId");
		    BusinessObject.serializeSingleValue(this.itemName, xml, "replacementItemName");realizeOption
 			BusinessObject.serializeSingleValue(this.unitId, xml, "replacementUnitId");
 			
 			BusinessObject.serializeSingleValue(this.quantity, xml, "quantity", 4);
 			  
 		 	BusinessObject.serializeSingleValue(this.decisionText, xml, "decisionText");
 		 	BusinessObject.serializeSingleValue(this.typeDecision.toString(), xml, "decisionType"); 
 			 
 		 	BusinessObject.serializeSingleValue(this.warehouseId, xml, "warehouseId");
 			
 			BusinessObject.serializeSingleValue(this.date, xml, "issueDate");
 		//	BusinessObject.serializeSingleValue(this.issuingPerson, xml, "issuingPerson");
 			BusinessObject.serializeSingleValue(this.realizeOption.toString(), xml, "realizeOption");
 			BusinessObject.serializeSingleValue(this.issuingPersonContractorId, xml, "issuingPersonContractorId");
	 			  
	 		BusinessObject.serializeSingleValue(this.id, xml, "id");
		    BusinessObject.serializeSingleValue(this.version, xml, "version");
			return xml;
		}
		
		override public function deserialize(value:XML):void
		{
			super.deserialize(value);
			
			this.itemId = BusinessObject.deserializeString(value.replacementItemId);	
			this.itemName = BusinessObject.deserializeString(value.replacementItemName);
		
			this.itemIdOrg = BusinessObject.deserializeString(value.parent().parent().itemId);	
			this.itemNameOrg = BusinessObject.deserializeString(value.parent().parent().itemName);
					
			this.quantity = BusinessObject.deserializeNumber(value.quantity);
			this.unitId = BusinessObject.deserializeString(value.replacementUnitId);	
			this.decisionText = BusinessObject.deserializeString(value.decisionText);
			this.typeDecision = BusinessObject.deserializeInt(value.decisionType);
			
			this.warehouseId =  BusinessObject.deserializeString(value.warehouseId);	
			
			this.issuingPersonContractorId =  BusinessObject.deserializeString(value.issuingPersonContractorId);	
			this.date =  BusinessObject.deserializeString(value.issueDate);
			this.realizeOption = BusinessObject.deserializeInt(value.realizeOption);
			
			this.id = BusinessObject.deserializeString(value.id);
			this.version = BusinessObject.deserializeString(value.version);
		}
		
		override public function copy():BusinessObject
		{
			var newLine:DecisionComplainDocumentLine = new DecisionComplainDocumentLine();
				
			newLine.itemId = this.itemId;
			newLine.itemName = this.itemName;
			
			newLine.itemIdOrg = this.itemIdOrg;
			newLine.itemNameOrg = this.itemNameOrg;
			
			newLine._quantity = this._quantity;
			newLine.unitId = this.unitId
			
			newLine.decisionText = this.decisionText;
			newLine._typeDecision = this._typeDecision;
			return newLine;
		}
		
		public function createFromProtocol(line:ProtocolComplainDocumentLine):void
		{
			this.relatedProtocolLine = line
			
			this.itemId = line.itemId;
			this.itemName = line.itemName;
			
			this.itemIdOrg = line.itemId;
			this.itemNameOrg = line.itemName;
			
			this.quantity = line.quantity;
			this.unitId = line.unitId;
			this.decisionText = "";
			
		} 

		override public function isEmpty():Boolean
		{
			return !Boolean(this.itemIdOrg);
		}
	}
}