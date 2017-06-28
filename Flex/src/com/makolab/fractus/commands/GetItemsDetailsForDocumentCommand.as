package com.makolab.fractus.commands
{
	public class GetItemsDetailsForDocumentCommand extends ExecuteCustomProcedureCommand
	{
		public var documentTypeId:String;
		public var source:XML;
		public var contractorId:String;
		public var items:Array; 
		public var barcode:String;
		public var itemsBarcodes:Array;
		
		public function GetItemsDetailsForDocumentCommand()
		{
			this.documentTypeId = documentTypeId;
			this.contractorId = contractorId;
			this.source = source;
			this.items = items;
			super("item.p_GetItemsDetailsForDocument", null);
		}
				
		override protected function getOperationParams(data:Object):Object
		{
			var xml:XML = <root></root>;
			
			if(this.documentTypeId)
				xml.appendChild(<documentTypeId>{this.documentTypeId}</documentTypeId>);
				
			if(this.source)
				xml.appendChild(<source>{this.source}</source>);
				
			if(this.contractorId)
				xml.appendChild(<contractorId>{this.contractorId}</contractorId>);
			
			if(this.barcode)
				xml.appendChild(<item barcode={this.barcode} id="00000000-0000-0000-0000-000000000000"/>);
				
			for each(var itemId:String in items)
			{
				xml.appendChild(<item id={itemId}/>);
			}
			
			for each(var barcode:String in itemsBarcodes)
			{
				xml.appendChild(<item barcode={barcode}/>);
			}
			
			return String(xml);
		}
		
	}
}