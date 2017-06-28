package com.makolab.components.catalogue.dynamicOperations
{
	import com.makolab.fractus.model.GlobalEvent;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	import com.makolab.fractus.view.documents.SalesOrderRealizationWindow;
	
	public class SettleSalesOrderOperation extends DynamicOperation
	{
		public override function invokeOperation(operationIndex:int = -1):void
		{
			SalesOrderRealizationWindow.showWindow(this.panel.documentXML, this.clearSelectionFunction);
		}
		
		private function clearSelectionFunction():void
		{
			this.panel.clearSelectionFunction();
			ModelLocator.getInstance().eventManager.dispatchEvent(new GlobalEvent(GlobalEvent.DOCUMENT_CHANGED, (new DocumentTypeDescriptor(this.panel.itemData.*.documentTypeId[0].toString())).categoryNumber.toString()));
		}
	}
}