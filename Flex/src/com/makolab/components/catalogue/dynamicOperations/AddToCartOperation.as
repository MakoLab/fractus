package com.makolab.components.catalogue.dynamicOperations
{
	import com.makolab.components.catalogue.Clipboard;
	
	public class AddToCartOperation extends DynamicOperation
	{
		public override function invokeOperation(operationIndex:int = -1):void
		{
			for each (var line:XML in this.panel.documentXML.lines.line)
							Clipboard.getInstance().addElement(line);
		}
	}
}