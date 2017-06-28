package com.makolab.fractus.commands
{
	public class LoadShiftTransactionByShiftIdCommand extends FractusCommand
	{
		private var shiftId:String;
		
		public function LoadShiftTransactionByShiftIdCommand(shiftId:String)
		{
			this.shiftId = shiftId;
			super("kernelService", "LoadShiftTransactionByShiftId");
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			return <root>
					<shiftId>{this.shiftId}</shiftId>
				</root>.toXMLString();
		}
	}
}