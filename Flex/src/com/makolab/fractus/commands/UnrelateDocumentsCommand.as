package com.makolab.fractus.commands
{
	public class UnrelateDocumentsCommand extends FractusCommand
	{
		public function UnrelateDocumentsCommand(serviceName:String=null, operationName:String=null)
		{
			super("kernelService", "UnrelateCommercialDocumentFromWarehouseDocuments");
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			return String(data);
		}
	}
}