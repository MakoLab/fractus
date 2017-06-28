package com.makolab.fractus.commands.items
{
	import com.makolab.fractus.commands.FractusCommand;
	
	import mx.rpc.AsyncToken;
	
	public class ItemUpdateCataloguePricesCommand extends FractusCommand
	{
		public function ItemUpdateCataloguePricesCommand()
		{
			super("kernelService","UpdateItemCataloguePrices");
		}
		
		public var parameter:Object;
		
		override public function execute(data:Object=null,addUser:Boolean=true):AsyncToken
		{
			parameter = data;
			return super.execute(data,addUser);
		}
	}
}