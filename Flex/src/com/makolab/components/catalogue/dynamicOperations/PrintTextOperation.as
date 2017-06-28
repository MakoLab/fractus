package com.makolab.components.catalogue.dynamicOperations
{
	import com.makolab.fractus.view.documents.TextPrintPreviewWindow;
	
	public class PrintTextOperation extends DynamicOperation
	{
		private var profileName:String;
		
		public function PrintTextOperation()
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
			TextPrintPreviewWindow.showWindow(this.panel.documentId, this.profileName ? this.profileName : this.panel.documentTypeDescriptor.xmlOptions.@defaultTextPrintProfile.toString());
		}
	}
}