package com.makolab.fractus.commands
{
	public class OfflinePrintCommand extends FractusCommand
	{
		private var id:String;
		private var xml:XML;
		private var profileName:String;
		
		public function OfflinePrintCommand(id:String, xml:XML, profileName:String)
		{
			this.id = id;
			this.xml = xml;
			this.profileName = profileName;
			super("kernelService", "OfflinePrint");
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			var inputXml:XML =  <root>
					<profileName>{this.profileName}</profileName>
				</root>;
			
			if(this.id) inputXml.appendChild(<id>{this.id}</id>);
			if(this.xml) inputXml.appendChild(<xml>{this.xml}</xml>);
			
			return inputXml.toXMLString();
		}
	}
}