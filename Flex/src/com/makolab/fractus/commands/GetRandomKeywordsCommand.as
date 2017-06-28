package com.makolab.fractus.commands
{
	public class GetRandomKeywordsCommand extends FractusCommand
	{
		private var type:String;
		private var amount:int;
		
		/**
		 * Initializes a new instance of the <code>GetRandomKeywordsCommand</code> class
		 */ 
		public function GetRandomKeywordsCommand(type:String, amount:int)
		{
			this.type = type;
			this.amount = amount;
			super("kernelService", "GetRandomKeywords");
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			return (<root><type>{this.type}</type><amount>{this.amount}</amount></root>).toXMLString()
		}
	}
}