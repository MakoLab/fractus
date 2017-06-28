package com.makolab.fractus.commands
{
	/**
	 * Loads data of a given object.
	 * XML of the selected object (without the <code>&lt;root&gt;</code> tag) is assigned to the given field.
	 */ 
	import mx.rpc.events.ResultEvent;
	import flash.events.Event;
	
	public class LoadBusinessObjectCommand extends FractusCommand
	{
		public function LoadBusinessObjectCommand(type:String = null, id:String = null)
		{
			super("kernelService", "LoadBusinessObject");
			this.type = type;
			this.id = id;
			this.replaceNewline = true;
		}
		
		public var type:String;
		public var id:String;
		public var noRoot:Boolean = false;
		public var source:XML;

		public static const TYPE_CONTRACTOR:String = "Contractor";
		public static const TYPE_ITEM:String = "Item";
		public static const TYPE_COMMERCIAL_DOCUMENT:String = "CommercialDocument";
		public static const TYPE_SERVICE_DOCUMENT:String = "ServiceDocument";
		public static const TYPE_WAREHOUSE_DOCUMENT:String = "WarehouseDocument";
		public static const TYPE_FINANCIAL_DOCUMENT:String = "FinancialDocument";
		public static const TYPE_PAYMENT:String = "Payment";
		public static const TYPE_APPLICATION_USER:String = "ApplicationUser";
		public static const TYPE_SERVICED_OBJECT:String = "ServicedObject";
		
		override protected function getOperationParams(data:Object):Object
		{
			if (data)
			{
				if (data.type) this.type = data.type;
				if (data.id) this.id = data.id;
				if (data.source) this.source = data.source;
			}
			return String(<params><type>{this.type}</type><id>{this.id}</id>{this.source}</params>);
		}
		
		override protected function resultHandler(event:ResultEvent):void
		{
			if (targetObject && targetField)
			{
				if (noRoot) targetObject[targetField] = XML(event.result).*[0];
				else targetObject[targetField] = XML(event.result);
			}
		}

	}
}