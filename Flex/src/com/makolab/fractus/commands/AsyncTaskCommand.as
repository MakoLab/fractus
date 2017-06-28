package com.makolab.fractus.commands
{
	import mx.rpc.events.ResultEvent;
	
	public class AsyncTaskCommand extends FractusCommand
	{
		public static const CREATE_TASK:String = "CreateTask";
		public static const QUERY_TASK:String = "QueryTask";
		public static const TERMINATE_TASK:String = "TerminateTask";
		public static const GET_TASK_RESULT:String = "GetTaskResult";
		
		public static const STORED_PROCEDURE_TASK:String = "StoredProcedureTask";
		
		public var progress:Number = NaN;
		public var status:String = null;
		public var taskResult:XML = null;
		public var error:Boolean = false;
		public var taskId:String = null;
		
		protected var taskName:String = null;
		protected var procedureName:String = null;
		
		public function AsyncTaskCommand(type:String, taskName:String = null, procedureName:String = null)
		{
			super('kernelService', type);
			if (type == CREATE_TASK && !taskName) throw new Error("No task name passed");
			else if (taskName == STORED_PROCEDURE_TASK && !procedureName) throw new Error("No stored procedure name passed");
			this.taskName = taskName;
			this.procedureName = procedureName;
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			switch (this.operationName)
			{
				case CREATE_TASK:
					if (this.taskName == STORED_PROCEDURE_TASK) return (
						<root>
							<taskName>{STORED_PROCEDURE_TASK}</taskName>
							<parameterXml>
								<procedureName>{this.procedureName}</procedureName>
								<parameterXml>{XMLList(data)}</parameterXml>
							</parameterXml>
						</root>
					).toXMLString();
					else return (
						<root>
							<taskName>{this.taskName}</taskName>
							<parameterXml>{XMLList(data)}</parameterXml>
						</root>
					).toXMLString();
				default: return (<root><taskId>{String(data)}</taskId></root>).toXMLString(); 
			}
		}
		
		override public function result(data:Object):void
		{
			var r:XML = XML(data.result);
			switch (this.operationName)
			{
				case CREATE_TASK: this.taskId = r.taskId; break;
				case QUERY_TASK: this.progress = r.progress; this.status = r.status; break;
				case GET_TASK_RESULT: this.taskResult = r; break;
			}			
			super.result(data);
		}

	}
}