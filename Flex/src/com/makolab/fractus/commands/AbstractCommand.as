package com.makolab.fractus.commands
{
	import com.makolab.fractus.business.Services;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.view.LogInWindow;
	import com.makolab.fractus.view.diagnostics.CommandExecutionLog;
	import com.makolab.fractus.vo.ErrorVO;
	
	import mx.rpc.AbstractOperation;
	import mx.rpc.AbstractService;
	import mx.rpc.Fault;
	import mx.rpc.IResponder;

	public class AbstractCommand implements ICommand, IResponder
	{
		protected var serviceName:String;
		protected var operationName:String;
		protected var invokingEvent:CairngormEvent;
		
		public function AbstractCommand(serviceName:String = null, operationName:String = null)
		{
			this.serviceName = serviceName;
			this.operationName = operationName;
		}

		public function execute(event:CairngormEvent):void {
			if (CommandExecutionLog.instance) CommandExecutionLog.instance.logCommand(this.operationName, { event : event }, this);
			invokingEvent = event;
		}
		
		public function result(data:Object):void {}
		
		public function fault(info:Object):void
		{
			var error:ErrorVO = ErrorVO.createFromFault(info.fault as Fault);
			error.command = this;
			try
			{
				var exceptionXML:XML = XML(info.fault.faultString);
				if (exceptionXML.@id == "SessionExpired")
				{
					model.pendingEvent = invokingEvent;
					LogInWindow.show(ModelLocator.getInstance().applicationObject);
					return;
				}
			}
			catch (e:Error) { ; }
			ModelLocator.getInstance().errorManager.handleError(error);
		}
				
		protected function get operation():AbstractOperation
		{
			return service.getOperation(operationName);
		}
		
		protected function get model():ModelLocator
		{
			return ModelLocator.getInstance();
		}
		
		protected function get service():AbstractService
		{
			return Services(ServiceLocator.getInstance()).getKernelService();
		}
	}
}