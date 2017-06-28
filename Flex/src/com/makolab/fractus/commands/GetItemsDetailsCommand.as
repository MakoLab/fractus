package com.makolab.fractus.commands
{
	public class GetItemsDetailsCommand extends FractusCommand
	{
		public var documentTypeId:String;
		public var source:XML;
		public var contractorId:String;
		public var items:Array; 
		
		public function GetItemsDetailsCommand(documentTypeId:String, contractorId:String, source:XML, items:Array)
		{
			this.documentTypeId = documentTypeId;
			this.contractorId = contractorId;
			this.source = source;
			this.items = items;
			super("kernelService", "GetItemsDetails");
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
				
			for each(var itemId:String in items)
			{
				xml.appendChild(<item id={itemId}/>);
			}
			
			return String(xml);
		}
		
	}
}