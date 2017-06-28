package com.makolab.fractus.commands
{
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.vo.SessionVO;
	
	import flash.net.SharedObject;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import assets.Version;

	public class LogInCommand extends FractusCommand
	{
		public static var handleLoginFunction:Function;
		
		public function LogInCommand()
		{
			super("kernelService", "LogOn");
		}

		private var login:String;
		
		override public function execute(data:Object = null,addUser:Boolean=true):AsyncToken
		{
			var vo:SessionVO = data as SessionVO;
			login = data.userName;
			
			var reqXml:XML = <root>
					<username>{login}</username>
					<password>{vo.password}</password>
					<language>{vo.language}</language>
					<appVersion>{Version.releaseVersion}</appVersion>
					<buildTime>{Version.buildTime}</buildTime>
					<revision>{Version.repositoryRevision}</revision>
				</root>;
				
			var so:SharedObject = SharedObject.getLocal("fractusData", "/");
			
			if(so.data.profile && so.data.profile != null && so.data.profile != "")
				reqXml.appendChild(<profile>{so.data.profile}</profile>);
			
			var param:String = reqXml.toXMLString();
			logExecution({ param : param });
			operation.send(param).addResponder(this);
			return null;
		}
		
		override public function result(data:Object):void
		{
			logResult(data.result);
			var result:XML = XML(data.result);
			var sessionId:String = result.sessionId;
			var userId:String = result.userId;
			if (service is WebService) service.httpHeaders = { SessionID : sessionId };
			model.sessionManager.sessionId = sessionId;
			model.sessionManager.userId = result.userId;
			model.sessionManager.login = this.login;
			model.branchId = result.branchId;
			model.companyId = result.companyId;
			model.headquarters = (result.isHeadquarter == "True");
			model.permissionProfile = result.permissionProfile;
			
			if(result.userProfileId.length() > 0)
				model.userProfileId = result.userProfileId;
			
			if (model.applicationObject) model.applicationObject['initializeApplication'](data as ResultEvent);
			if (LogInCommand.handleLoginFunction != null) LogInCommand.handleLoginFunction(data);
			
			super.result(data);
		}

		public function get model():ModelLocator
		{
			return ModelLocator.getInstance();
		}
	}
}