package com.makolab.fractus.commands
{
	/**
	 * Command that executes WebService method <code>GetRandomWarehouseDocumentLines</code>.
	 */
	public class GetRandomWarehouseDocumentLinesCommand extends FractusCommand
	{
		private var amount:int;
		
		/**
		 * Initializes a new instance of the <code>GetRandomWarehouseDocumentLines</code> class
		 * with specified amount.
		 * 
		 * @param amount The amount of warehouse document lines to get.
		 */ 
		public function GetRandomWarehouseDocumentLinesCommand(amount:int)
		{
			this.amount = amount;
			super("kernelService", "GetRandomWarehouseDocumentLines");
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			return this.amount.toString();
		}
	}
}