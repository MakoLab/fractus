package com.makolab.fractus.commands
{
	/**
	 * Command that executes WebService method <code>CheckNumberExistence</code>.
	 */
	public class CheckNumberExistenceCommand extends FractusCommand
	{
		private var seriesValue:String;
		private var number:int;
		
		/**
		 * Initializes a new instance of the <code>CheckNumberExistenceCommand</code> class
		 * with specified seriesValue and number.
		 * 
		 * @param seriesValue Computed series value.
		 * @param number Document sequential number to check.
		 */ 
		public function CheckNumberExistenceCommand(seriesValue:String, number:int)
		{
			this.seriesValue = seriesValue;
			this.number = number;
			super("kernelService", "CheckNumberExistence");
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			return <root>
					<seriesValue>{this.seriesValue}</seriesValue>
					<number>{this.number}</number>
				</root>.toXMLString();
		}
	}
}