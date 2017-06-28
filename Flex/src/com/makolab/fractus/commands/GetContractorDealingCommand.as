package com.makolab.fractus.commands
{
	public class GetContractorDealingCommand extends FractusCommand
	{
		private var contractorId:String;
		private var days:String;
		
		public function GetContractorDealingCommand(contractorId:String, days:String)
		{
			this.contractorId = contractorId;
			this.days = days;
			super("kernelService", "GetContractorDealing");
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			return <root>
					<contractorId>{this.contractorId}</contractorId>
					<days>{this.days}</days>
				</root>.toXMLString();
		}
		
	}
}