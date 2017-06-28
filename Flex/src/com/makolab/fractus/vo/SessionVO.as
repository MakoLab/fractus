package com.makolab.fractus.vo
{
	public class SessionVO
	{
		public var userName:String;
		public var password:String;
		public var sessionId:String;
		public var language:String;
		
		public function SessionVO(userName:String = null, password:String = null, language:String = null, nextEvent:String = null)
		{
			this.userName = userName;
			this.password = password;
			this.language = language;
		}

	}
}