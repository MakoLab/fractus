package com.makolab.fractus.commands
{
	public class RegisterFractusCommand extends FractusCommand
	{
		private var licenseKey:String;
		
		public function RegisterFractusCommand(licenseKey:String)
		{
			this.licenseKey = licenseKey;
			super("kernelService", "RegisterFractus");
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			return this.licenseKey;
		}
	}
}