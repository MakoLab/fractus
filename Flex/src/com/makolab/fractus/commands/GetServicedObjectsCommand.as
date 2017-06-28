package com.makolab.fractus.commands
{
	public class GetServicedObjectsCommand extends ExecuteCustomProcedureCommand
	{
		public function GetServicedObjectsCommand(contractorId:String)
		{
			super
			(
				'service.p_GetServicedObjects',
				<params>
					<filters>
						<column field='contractorId'>{contractorId}</column>
					</filters>
					<columns>
						<column field="identifier"/>
					</columns>
				</params>
			);
		}
		
	}
}