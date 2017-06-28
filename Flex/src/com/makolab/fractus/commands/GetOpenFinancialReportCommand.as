package com.makolab.fractus.commands
{
	public class GetOpenFinancialReportCommand extends FractusCommand
	{
		public var registerId:String;
		
		public function GetOpenFinancialReportCommand(registerId:String)
		{
			super('kernelService', 'GetOpenedFinancialReport');
			this.registerId = registerId;
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			return (<root><financialRegisterId>{this.registerId}</financialRegisterId></root>).toXMLString();
		}

	}
}