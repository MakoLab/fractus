package com.makolab.components.catalogue.dynamicOperations
{
	import com.makolab.fractus.commands.ShowDocumentEditorCommand;
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	
	public class CreateNewBusinessObjectOperation extends DynamicOperation
	{
		public var type:String;
		public var template:String;
		public var source:XML;
		public var nestedOperations:Array;
		
		public override function loadParameters(operation:XML):void
		{
			var replacedOperation:XML = this.replaceDynamicParameters(operation);
			
			if(replacedOperation.type.length() > 0)
				this.type = replacedOperation.type.*;
			else
				this.type = null;
				
			if(replacedOperation.template.length() > 0)
				this.template = replacedOperation.template.*;
			else
				this.template = null;
			
			if(replacedOperation.source.length() > 0)
				this.source = replacedOperation.source[0];
			else
				this.source = null;
				
			if(replacedOperation.nestedOperations.length() > 0)
			{
				nestedOperations = [];
				for each (var o:XML in replacedOperation.nestedOperations.operation)
				{
					replaceDynamicParameters(o);
					nestedOperations.push(o);
				}
			}
		}
		
		public override function invokeOperation(operationIndex:int = -1):void
		{
			var category:int = 0;
			
			if(this.type == "FinancialDocument")
				category = DocumentTypeDescriptor.CATEGORY_FINANCIAL_DOCUMENT;
			
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(category);
			cmd.objectType = this.type;
			if(operationIndex >= 0) cmd.template = extendedOperations[operationIndex].documentTemplate;
			else cmd.template = this.template;
			if (operationIndex >= 0) cmd.source = nestedOperations[operationIndex].source[0];
			else cmd.source = this.source;
			cmd.execute();
			
			if(this.panel.clearSelectionFunction != null)
				this.panel.clearSelectionFunction();
		}
	}
}