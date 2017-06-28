package com.makolab.fractus.commands
{
	public class OpenExternalWebBrowserCommand extends FractusCommand
	{
		private var url:String;
		
		public function OpenExternalWebBrowserCommand(url:String)
		{
			this.url = url;
			super("kernelService", "OpenExternalWebBrowser");
		}
		
		protected override function getOperationParams(data:Object):Object
		{
			return this.url;
		}
	}
}