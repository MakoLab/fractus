package com.makolab.fractus.view.administration
{
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.commands.GetPermissionProfilesCommand;	
	import mx.rpc.events.ResultEvent;
	import mx.controls.Alert;
	
	public class ChangeCurrentUserPassword
	{
		private var model:ModelLocator = ModelLocator.getInstance();
		
		public var profiles:XML;
		public var userData:XML;

		
		public function ChangeCurrentUserPassword()
		{	
			var currentUserId:String = model.sessionManager.userId;
			userData = model.dictionaryManager.getById(currentUserId);
			
			getProfiles();
		}

		private function getProfiles():void
		{
			var cmd:GetPermissionProfilesCommand = new GetPermissionProfilesCommand();
			cmd.addEventListener(ResultEvent.RESULT,getProfilesResult);
			cmd.execute();
		}
			
		private function getProfilesResult(event:ResultEvent):void
		{
			profiles = XML(event.result);
			openUserPanel(userData, profiles);
		}
		
		public function openUserPanel(item:XML, profiles:XML):void
		{
			if(item && profiles) UserPanel.showWindow(profiles,item);
			else if(profiles) UserPanel.showWindow(profiles);
			else Alert.show(LanguageManager.getInstance().labels.error.getData);
		}
	}
}