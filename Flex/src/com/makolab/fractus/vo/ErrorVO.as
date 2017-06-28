package com.makolab.fractus.vo
{
	import mx.rpc.Fault;
	
	public class ErrorVO
	{
		public var logNumber:Number = NaN;
		public var extendedMessage:String;
		public var shortMessage:String;
		public var id:String;
		
		public static var DEFAULT_MESSAGE:String = "Unhandled error";
		
		public function ErrorVO()
		{
		}
		
		public static function createFromFault(fault:Fault):ErrorVO
		{
			var error:ErrorVO = new ErrorVO();
			var xml:XML = null;
			try
			{
				xml = XML(fault.faultString);
			}
			catch (e:Error) {}
			if (xml && xml.localName() == "exception")
			{
				error.shortMessage = xml.customMessage;
				error.extendedMessage = xml.extendedCustomMessage;
				error.logNumber = parseInt(xml.logNumber);
				error.id = xml.@id;
			}
			else
			{
				error.shortMessage = DEFAULT_MESSAGE;
				error.extendedMessage = fault.message;
			}
			return error;
		}

	}
}