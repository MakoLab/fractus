package com.makolab.components.document
{
	import com.makolab.fractus.model.document.CommercialDocument;
	
	/**
	 * Provides the capabilities for an object to be a plugin for <code>GenericDocument</code>.
	 */
	public interface IDocumentPlugin
	{
		/**
		 * Initializes plugin for the specified <code>GenericDocument</code>
		 * 
		 * @param document Owner document for the plugin.
		 */
		function initialize(document:CommercialDocument, documentEditor:GenericDocument):void;
	}
}