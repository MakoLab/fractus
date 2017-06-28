package com.makolab.fractus.business
{
	import mx.rpc.AbstractOperation;
	import mx.rpc.AbstractService;
	import mx.rpc.AsyncToken;

	public class ExternalInterfaceOperation extends AbstractOperation
	{
		final public function ExternalInterfaceOperation(service:AbstractService=null, name:String=null)
		{
			super(service, name);
		}
		
		public override function send(... args):AsyncToken
		{
			return ExternalInterfaceService(service).execute(this, args);
		}
	}
}