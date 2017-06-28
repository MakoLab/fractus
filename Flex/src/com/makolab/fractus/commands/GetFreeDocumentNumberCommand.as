package com.makolab.fractus.commands
{
	/**
	 * Command that executes WebService method <code>GetFreeDocumentNumber</code>.
	 */
	public class GetFreeDocumentNumberCommand extends FractusCommand
	{
		private var requestXml:XML;
		private var documentTypeId:String;
		private var issueDate:String;
		private var numberSettingId:String;
		private var financialRegisterSymbol:String;
		
		/**
		 * Initializes a new instance of the <code>GetFreeDocumentNumberCommand</code> class
		 * with specified documentTypeId, issueDate, numberSettingId.
		 * 
		 * @param documentTypeId Document's documentTypeId.
		 * @param issueDate Document's issue date.
		 * @param numberSettingId numberSettingId.
		 */
		public function GetFreeDocumentNumberCommand(documentTypeId:String, issueDate:String, numberSettingId:String, financialRegisterSymbol:String)
		{
			this.documentTypeId = documentTypeId;
			this.issueDate = issueDate;
			this.numberSettingId = numberSettingId;
			this.financialRegisterSymbol = financialRegisterSymbol;
			super("kernelService", "GetFreeDocumentNumber");
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			var xml:XML = <root>
					<documentTypeId>{this.documentTypeId}</documentTypeId>
					<issueDate>{this.issueDate}</issueDate>
					<numberSettingId>{this.numberSettingId}</numberSettingId>
				</root>;
			
			if(this.financialRegisterSymbol != null)
				xml.appendChild(<financialRegisterSymbol>{this.financialRegisterSymbol}</financialRegisterSymbol>);
				
			return xml.toXMLString();
		}
	}
}