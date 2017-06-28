package com.makolab.fractus.view.documents.documentControls
{
	import com.makolab.fractus.model.document.DocumentObject;
	
	import mx.core.IUIComponent;

	public interface IDocumentControl
	{
		function set documentObject(value:DocumentObject):void;
		function get documentObject():DocumentObject;
	}
}