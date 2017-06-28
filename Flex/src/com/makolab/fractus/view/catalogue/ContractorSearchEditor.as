package com.makolab.fractus.view.catalogue
{
	import com.makolab.components.catalogue.CatalogueItemWindowEvent;
	import com.makolab.components.catalogue.CatalogueSearchWrapper;
	import com.makolab.fractus.commands.SearchCommand;
	import com.makolab.fractus.model.ModelLocator;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.ListEvent;
	import mx.rpc.events.ResultEvent;

	[Event(name="itemReload", type="flash.events.Event")]
	[Event(name="searchResult", type="flash.events.Event")]
	public class ContractorSearchEditor extends CatalogueSearchWrapper
	{
		
		protected var model:ModelLocator = ModelLocator.getInstance();
		
		public var autoLoadName:Boolean = false;
		
		private var defaultConfig:XML = ModelLocator.getInstance().configManager.getXMLValue('contractors.lists.contractorSearchEditor');
		
		public function ContractorSearchEditor()
		{
			super();
			searchCommandType = "contractors";
			config = defaultConfig;
			comboData = XML(config.searchModes);
			
			var menuItemsTemp:XMLList = config.operations.*;
			
			var menuItemsT:XMLList = new XMLList();
			
			for each (var item:XML in menuItemsTemp) 
			{
				//permission hard coded
				var t:String = item.@name;
				switch (t)
				{
					case 'newItem':
						if(!model.permissionManager.isHidden('catalogue.contractors.add')){
							menuItemsT += item;
						}
						break;
					case 'editItem':
						if(!model.permissionManager.isHidden('catalogue.contractors.edit')){
							menuItemsT += item;
						}
						break;
					case 'itemDetails':
						if(!model.permissionManager.isHidden('catalogue.contractors.relatedDocuments')){
							menuItemsT += item;
						}
						break;
					default:
						menuItemsT += item;
					}
			}
			cs.labelField = "@fullName";
			
			if(!menuItemsT.length()) {
				menuItems = null;
			} else {
				menuItems = menuItemsT;
			}
		}
		
		/*
		newContractor
		catalogue.contractorsList.newContractor
		edit
		catalogue.contractorsList.edit
		relatedDocuments
		catalogue.contractorsList.relatedDocuments
		*/
		
		override protected function itemClickHandler(event:ListEvent):void
		{
			var item:Object = event.itemRenderer.data;
			switch (String(item.@name))
			{
				case "showCatalogue":
					break;
				case "newItem":
						ContractorsCatalogue.showContractorWindow(null, null, ModelLocator.getInstance().getDefaultTemplate("contractor")).addEventListener(CatalogueItemWindowEvent.DATA_SAVE_COMPLETE, reloadData);
					break;
				case "editItem":
					if (itemId)
					{
						ContractorsCatalogue.showContractorWindow(itemId).addEventListener(CatalogueItemWindowEvent.DATA_SAVE_COMPLETE, reloadData);
					}
					break;
				case "itemDetails":
					if (itemId)
					{
						//ContractorRenderer.showWindow(itemId);
						CatalogueContractorInfo.showWindow(itemId, CatalogueContractorInfo.CONTRACTOR_DETAILS);
					}
					break;
			}
		}
		
		public function reloadData(event:CatalogueItemWindowEvent):void
		{
			if (event && event.itemId && event.itemId != itemId)
			{
				itemId = event.itemId;
			}
			dispatchEvent(new Event("itemReload"));
		}
		
		public override function set itemId(value:String):void
		{
			if (this.autoLoadName && value != this.itemId)
			{
				this.text = '';
				if (value)
				{
					var cmd:SearchCommand =	new SearchCommand
					(
						SearchCommand.CONTRACTORS,
						<searchParams>
							<columns>
								<column field="shortName"/>
							</columns>
							<filters>
								<column field="id">{value}</column>
							</filters>
						</searchParams>
					);
					cmd.addEventListener(ResultEvent.RESULT, handleSearchResult);
					cmd.execute();
				}
			}
			super.itemId = value;
		}
		
		protected function handleSearchResult(event:ResultEvent):void
		{
			this.text = String(XML(event.result)..@shortName);
			dispatchEvent(new Event("searchResult"));
		}
		
	}
}