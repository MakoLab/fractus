package com.makolab.fractus.commands
{
	import com.makolab.components.util.ErrorReport;
	
	import mx.rpc.events.ResultEvent;
	
	public class GetReportCommand extends FractusCommand
	{
		public var procedureName:String;
		
		public function GetReportCommand(procedureName:String)
		{
			this.procedureName = procedureName;
			super("kernelService", "ExecuteCustomProcedure");
		}
				
		override public function execute(data:Object = null):Object
		{
			var param:String = XML(data).toXMLString();
			logExecution({ param : param });
			if (operation) operation.send(procedureName, param).addResponder(this);
			return null;
		}

		override protected function resultHandler(event:ResultEvent):void
		{
			super.resultHandler(event);
			if (targetObject && targetField)
			{
				try
				{
					targetObject[targetField] = XML(event.result);
				}
				catch (e:Error)
				{
					ErrorReport.showWindow("XML processing error", event.result.toString(), "Report error");
				}
			}
		}

	}
}