package com.makolab.fractus.commands
{
	import com.makolab.components.util.Tools;
		
	public class GetOutgoingQueueListCommand extends ExecuteCustomProcedureCommand
	{
		public function GetOutgoingQueueListCommand( isSend :String = null, dateFrom:Date = null, dateTo:Date = null)
		{
			operationParams =  <root/>;
			if(isSend)
			{
				operationParams.@isSend = isSend;
			}
			if(dateFrom)
			{
				operationParams.@dateFrom =Tools.dateToString(dateFrom);
			}
			if(dateTo)
			{
				operationParams.@dateTo = Tools.dateToString(dateTo)+ "T23:59:59.997";
			}
			super('communication.p_getOutgoingList');
		}
	}
}