package com.makolab.fractus.commands
{
	public class GetWarehouseDocumentLinesTreeCommand extends FractusCommand
	{
		private var warehouseDocumentId:String;
		
		public function GetWarehouseDocumentLinesTreeCommand(warehouseDocumentId:String)
		{
			this.warehouseDocumentId = warehouseDocumentId;
			super("kernelService", "GetWarehouseDocumentLinesTree");
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			return <root>
					<documentId>{this.warehouseDocumentId}</documentId>
				</root>.toXMLString();
		}
	}
}