package com.makolab.components.catalogue.dynamicOperations
{
	import com.makolab.fractus.view.documents.DocumentRenderer;
	
	public class PreviewOperation extends DynamicOperation
	{
		public override function invokeOperation(operationIndex:int = -1):void
		{
			DocumentRenderer.showWindow(this.panel.objectType, this.panel.documentId);
		}
	}
}