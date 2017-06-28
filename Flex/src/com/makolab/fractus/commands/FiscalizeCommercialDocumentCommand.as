package com.makolab.fractus.commands
{
	public class FiscalizeCommercialDocumentCommand extends FractusCommand
	{
		private var commercialDocumentId:String;
		
		public function FiscalizeCommercialDocumentCommand(commercialDocumentId:String)
		{
			this.commercialDocumentId = commercialDocumentId;
			super("kernelService", "FiscalizeCommercialDocument");
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			return <root>
					<id>{this.commercialDocumentId}</id>
				</root>.toXMLString();
		}
	}
}