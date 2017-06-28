package com.makolab.fractus.commands
{
	/**
	 * Command that executes WebService method <code>GetRandomCommercialDocumentLines</code>.
	 */
	public class GetRandomCommercialDocumentLinesCommand extends FractusCommand
	{
		private var amount:int;
		
		/**
		 * Initializes a new instance of the <code>GetRandomCommercialDocumentLines</code> class
		 * with specified amount.
		 * 
		 * @param amount The amount of commercial document lines to get.
		 */ 
		public function GetRandomCommercialDocumentLinesCommand(amount:int)
		{
			this.amount = amount;
			super("kernelService", "GetRandomCommercialDocumentLines");
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			return this.amount.toString();
		}
	}
}