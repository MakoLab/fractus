package com.makolab.fractus.commands
{
	import com.makolab.components.util.Tools;
		
	public class GetgetIncomingQueueListCommand extends ExecuteCustomProcedureCommand
	{
		public function GetgetIncomingQueueListCommand( isExecuted :String = null, dateFrom:Date = null, dateTo:Date = null)
		{
			operationParams =  <root/>;
			if(isExecuted)
			{
				operationParams.@isExecuted = isExecuted;
			}
			if(dateFrom)
			{
				operationParams.@dateFrom =Tools.dateToString(dateFrom);
			}
			if(dateTo)
			{
				operationParams.@dateTo = Tools.dateToString(dateTo)+ "T23:59:59.997";
			}
			super('communication.p_getIncomingList');
		}
	}
}