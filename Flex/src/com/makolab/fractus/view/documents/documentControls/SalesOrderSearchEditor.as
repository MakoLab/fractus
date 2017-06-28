package com.makolab.fractus.view.documents.documentControls
{
	import com.makolab.components.catalogue.CatalogueItemWindowEvent;
	import com.makolab.components.catalogue.CatalogueSearchWrapper;
	import com.makolab.fractus.commands.SearchCommand;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.view.finance.SalesOrderEvent;

	public class SalesOrderSearchEditor extends CatalogueSearchWrapper
	{
		private var defaultConfig:XML = ModelLocator.getInstance().configManager.getXMLValue('documents.lists.salesOrderSearchEditor');
		
		private var _config:XML;

		public function SalesOrderSearchEditor()
		{
			super();
			searchCommandType = SearchCommand.DOCUMENTS;
			config = defaultConfig;
			comboData = XML(config.searchModes);
			menuItems = config.operations.*;
			//cs.labelField = "@fullNumber"; 
			this.showItemOperations = false;
		}
	}
}