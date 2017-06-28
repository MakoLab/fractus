package com.makolab.fractus.model.document
{
	import com.makolab.components.util.Tools;
		
	[Bindable]
	public class ProtocolComplainDocumentLine extends BusinessObject
	{
		public var documentObject:DocumentObject;
		
		public var itemId:String;
		public var itemVersion:String;
		public var itemName:String;
		
		
		public var itemCode:String;
		
		public var quantity:Number = 1;
		
		public var remarks:String;
		
		public var dateIncom:String= Tools.dateToIso(new Date());
		
		public var unitId:String = '2EC9C7C6-C250-41A6-818A-0C1B2B7D0A6C';
		
		public var issuingPersonContractorId:String;
		
		public function relatedDecisionCount():int
		{
			var count:int = 0;
			for each(var item:DecisionComplainDocumentLine in this.documentObject.decisionComplaint)
			{
				if(item.relatedProtocolLine === this )
					count++;
			}
			return count;
		}
		
		public function ProtocolComplainDocumentLine(line:XML = null, parent:DocumentObject = null)
		{
			super('line', null);
			if (parent) this.documentObject = parent;
			if (line) this.deserialize(line);
		}
		
		
		override public function serialize():XML
		{
			var xml:XML = super.serialize();    
		    BusinessObject.serializeSingleValue(this.itemId, xml, "itemId");
		    BusinessObject.serializeSingleValue(this.itemName, xml, "itemName");
			BusinessObject.serializeSingleValue(this.unitId, xml, "unitId");
		    BusinessObject.serializeSingleValue(this.quantity, xml, "quantity",6);
		    BusinessObject.serializeSingleValue(this.remarks,xml,"remarks");    
		    BusinessObject.serializeSingleValue(this.dateIncom, xml ,"issueDate");
		    BusinessObject.serializeSingleValue(this.issuingPersonContractorId, xml, "issuingPersonContractorId");
		    BusinessObject.serializeSingleValue(this.id, xml ,"id");
		    BusinessObject.serializeSingleValue(this.version, xml, "version");
		     
		    xml.appendChild(<complaintDecisions/>);
			return xml;
		}
		
		override public function deserialize(value:XML):void
		{
			super.deserialize(value);
			this.itemId = BusinessObject.deserializeString(value.itemId);	
			this.itemVersion = BusinessObject.deserializeString(value.itemVersion);	
			this.itemName = BusinessObject.deserializeString(value.itemName);	
			this.quantity = BusinessObject.deserializeNumber(value.quantity);
			this.unitId = BusinessObject.deserializeString(value.unitId);
			this.remarks = BusinessObject.deserializeString(value.remarks);
			this.issuingPersonContractorId = BusinessObject.deserializeString(value.issuingPersonContractorId);
			this.id = BusinessObject.deserializeString(value.id);
			this.version = BusinessObject.deserializeString(value.version);						
		}
		
		/*override public function copy():BusinessObject
		{
			var newLine:ProtocolComplainDocumentLine = new ProtocolComplainDocumentLine();
			
			newLine.itemId = this.itemId;
			newLine.itemVersion = this.itemVersion;
			newLine.itemName = this.itemName;
			
			newLine.quantity = this.quantity;
			newLine.unitId = this.unitId
			newLine.dateIncom = this.dateIncom;
			return newLine;
		}*/

		override public function isEmpty():Boolean
		{
			return !Boolean(this.itemId);
		}
		
		
		public function quantityLeft(q:int,decisionLine :DecisionComplainDocumentLine ):int
		{
			var sumQuantity:int = 0;
			for each(var item:DecisionComplainDocumentLine in this.documentObject.decisionComplaint)
			{
				if(item.relatedProtocolLine === this && decisionLine !=item)
					sumQuantity = sumQuantity + item.quantity;
			}
			return (sumQuantity +q > this.quantity) ? this.quantity - sumQuantity  : q;
		} 
	}
}