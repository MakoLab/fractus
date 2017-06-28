package com.makolab.components.catalogue.dynamicOperations
{
	import com.makolab.components.util.ComponentExportManager;
	
	public class PrintPdfOperation extends DynamicOperation
	{
		private var profileName:String;
		
		public function PrintPdfOperation()
		{
			super();
		}
		
		public override function loadParameters(operation:XML):void
		{
			if(operation.profileName.length() != 0)
				this.profileName = operation.profileName.*; 
		}
		
		public override function invokeOperation(operationIndex:int = -1):void
		{
			var fileName:String = panel.documentTypeDescriptor.symbol + "_" + String(panel.itemData.*.number.fullNumber);
			fileName = fileName.replace(new RegExp("[^a-zA-Z0-9]+","g"),"_");
			ComponentExportManager.getInstance().exportObject(this.profileName ? this.profileName : this.panel.documentTypeDescriptor.getDefaultPrintProfile(), this.panel.documentId, fileName);
		}
	}
}