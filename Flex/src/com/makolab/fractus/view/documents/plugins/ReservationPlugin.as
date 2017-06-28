package com.makolab.fractus.view.documents.plugins
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.fractus.commands.GetItemsDetailsCommand;
	import com.makolab.fractus.model.document.CommercialDocumentLine;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	import com.makolab.fractus.view.documents.documentControls.IDocumentControl;
	
	import mx.rpc.events.ResultEvent;

	public class ReservationPlugin implements IDocumentControl
	{
		public function ReservationPlugin()
		{
		}
		
		private var _documentObject:DocumentObject;
		public function set documentObject(value:DocumentObject):void
		{
			_documentObject = value;
			
			if(_documentObject)
				_documentObject.addEventListener(DocumentEvent.DOCUMENT_LOAD, handleDocumentLoad, false, 0, true);
		}
		
		public function get documentObject():DocumentObject
		{
			return _documentObject;
		}
	
		private function handleDocumentLoad(event:DocumentEvent):void
		{
			if(this.documentObject.xml.@source.length() > 0)
			{
				var source:XML = XML(String(this.documentObject.xml.@source));
				
				if(this.documentObject.typeDescriptor.categoryNumber == DocumentTypeDescriptor.CATEGORY_WAREHOUSE_ORDER
					&& source.@type == "order" && this.documentObject.isNewDocument)
				{
					var lines:Array = [];
					for each(var line:CommercialDocumentLine in this.documentObject.lines)
					{
						lines.push(line.itemId);	
					}
					
					var cmd:GetItemsDetailsCommand = new GetItemsDetailsCommand(this.documentObject.typeDescriptor.typeId,
						documentObject.xml.contractor.contractor.id, source, lines);
					
					cmd.addEventListener(ResultEvent.RESULT, this.handleGetLinePrice, false, 0, true);
					cmd.execute();
				}
			}
		}
		
		private function handleGetLinePrice(event:ResultEvent):void
		{
			var response:XML = XML(event.result);
			
			for each(var line:CommercialDocumentLine in this.documentObject.lines)
			{
				var item:XML = response.item.(@id == line.itemId)[0];
				
				if(item)
				{
					line.initialNetPrice = parseFloat(item.@initialNetPrice);
					//documentObject.editor['calcPlugin'].calculateLine(line, "initialNetPrice");
					documentObject.dispatchEvent(DocumentEvent.createEvent(DocumentEvent.DOCUMENT_LINE_CHANGE, "initialNetPrice", line));
					
					if(item.@netPrice.length() > 0)
					{
						line.netPrice = parseFloat(item.@netPrice);
						documentObject.dispatchEvent(DocumentEvent.createEvent(DocumentEvent.DOCUMENT_LINE_CHANGE, "netPrice", line));
					}
				}	
			}
		}
	}
}