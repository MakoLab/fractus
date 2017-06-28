package com.makolab.fractus.commands
{
	/**
	 * Command that executes WebService method <code>GetRandomContractors</code>.
	 */
	public class GetRandomContractorsCommand extends FractusCommand
	{
		private var amount:int;
		
		/**
		 * Initializes a new instance of the <code>GetRandomContractors</code> class
		 * with specified amount.
		 * 
		 * @param amount The amount of contractors to get.
		 */ 
		public function GetRandomContractorsCommand(amount:int)
		{
			this.amount = amount;
			super("kernelService", "GetRandomContractors");
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			return this.amount.toString();
		}
	}
}