package com.makolab.fractus.commands
{
	import com.makolab.fractus.business.Services;
	
	import mx.controls.Alert;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	
	public class AssignItemToGroupCommand extends FractusCommand
	{
		public function AssignItemToGroupCommand(itemType:String)
		{
			this.itemType = itemType;
		}
		
		private var itemType:String = "";
		
		public static var CONTRACTOR:String = "Contractor";
		public static var ITEM:String = "Item";
		
		private var operationParams:Object;
		
		override public function execute(data:Object = null,addUser:Boolean=true):AsyncToken
		{
			logExecution({data : data});
			operationParams = data;
			var loadCommand:LoadBusinessObjectCommand = new LoadBusinessObjectCommand();
			// 1 - load business object
			loadCommand.addEventListener(ResultEvent.RESULT, loadResult);
			loadCommand.execute( { type : itemType, id : operationParams.itemId },addUser );
			return null;
		}
		
		private function loadResult(event:ResultEvent):void
		{
			// 2 - check conditions and update data
			Services.getInstance().resetHeaders();
			var resultXML:XML = XML(event.result);
			if(itemType == CONTRACTOR){
				if (resultXML.contractor.groupMemberships.groupMembership.(String(contractorGroupId) == operationParams.groupId).length() > 0)
				{
					Alert.show("Kontrahent należy już do tej grupy");
				}
				else
				{
					var groupMembership:XML = <groupMembership><contractorGroupId>{operationParams.groupId}</contractorGroupId></groupMembership>;
					XML(resultXML.contractor.groupMemberships).appendChild(groupMembership);
					new SaveBusinessObjectCommand().execute(String(resultXML));
				}
			}else{
				if (resultXML.item.groupMemberships.groupMembership.(String(itemGroupId) == operationParams.groupId).length() > 0)
				{
					Alert.show("Towar/usługa należy już do tej grupy");
				}
				else
				{
					groupMembership = <groupMembership><itemGroupId>{operationParams.groupId}</itemGroupId></groupMembership>;
					XML(resultXML.item.groupMemberships).appendChild(groupMembership);
					new SaveBusinessObjectCommand().execute(String(resultXML));
				}
			}
		}
		
		
		
	}
}