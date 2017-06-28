package com.makolab.fractus.commands
{
	public class CreateBusinessObjectCommand extends FractusCommand
	{
		public function CreateBusinessObjectCommand(type:String = null)
		{
			super("kernelService", "CreateNewBusinessObject");
			this.type = type;
		}
		
		public var type:String;
		
		override protected function getOperationParams(data:Object):Object
		{
			if (data && data.type) type = data.type;
			var params:XML = <params><type>{type}</type></params>;
			if (data)
			{
				if (data.template) params.template = data.template;
				if (data.paymentMethodId) params.paymentMethodId = data.paymentMethodId;
				if (data.source) params.source = data.source;
			}
			return params.toXMLString();
		}

	}
}