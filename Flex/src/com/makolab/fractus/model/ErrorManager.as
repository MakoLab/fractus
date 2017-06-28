package com.makolab.fractus.model
{
	import com.makolab.fractus.vo.ErrorVO;
	
	import mx.controls.Alert;
	import mx.core.Application;
	
	public class ErrorManager
	{
		public function ErrorManager()
		{
		}

		public function handleError(error:ErrorVO):void
		{
			var msg1:String, msg2:String;
			msg1 = error.shortMessage;
			msg1 = msg1.replace(/\\n/g, '\n');
			msg2 = error.extendedMessage;
			msg2 = msg2.replace(/\\n/g, '\n');
			if (!msg2) msg2 = msg1;
			if (!isNaN(error.logNumber)) msg2 += "\nLog no: " + error.logNumber; 
			if (error.id == "SessionExpired") 
				ModelLocator.getInstance().applicationObject.logOut(error.shortMessage);
				//Application.application.logOut(/* error.shortMessage */);
			else
				Alert.show(msg2, msg1);
		}
	}
}