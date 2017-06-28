package com.makolab.fractus.commands
{
	public class BindDocumentsCommand extends FractusCommand
	{
		public function BindDocumentsCommand()
		{
			super("kernelService", "RelateCommercialDocumentToWarehouseDocuments");
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			return String(data);
		}

	}
}