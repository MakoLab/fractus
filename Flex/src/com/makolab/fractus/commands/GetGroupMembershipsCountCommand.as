package com.makolab.fractus.commands
{	
	public class GetGroupMembershipsCountCommand extends ExecuteCustomProcedureCommand
	{		
		public static const CONTRACTORS:String = 'contractor.p_getContractorGroupMembershipsCountWrapper';
		public static const ITEMS:String = 'item.p_getItemGroupMembershipsCountWrapper';
		
		public function  GetGroupMembershipsCountCommand(groupId:String, groupType:String)
		{
			operationParams = <root>{groupId}</root>;
			super(groupType);
		}
	}
}