package com.makolab.fractus.view.catalogue
{
	import com.makolab.components.catalogue.CatalogueItemWindowEvent;
	import com.makolab.components.catalogue.CatalogueSearchWrapper;
	import com.makolab.fractus.model.ModelLocator;
	
	import flash.events.Event;
	
	import flight.binding.Bind;
	
	import mx.events.ListEvent;
	import com.makolab.fractus.commands.SearchCommand;
	import mx.rpc.events.ResultEvent;

	[Event(name="itemReload", type="flash.events.Event")]
	public class ServicedObjectSearchEditor extends CatalogueSearchWrapper
	{
		private var defaultConfig:XML = ModelLocator.getInstance().configManager.getXMLValue('service.lists.servicedObjectSearchEditor');
			
		private var _config:XML;

		public var autoLoadName:Boolean = false;

		public function ServicedObjectSearchEditor()
		{
			super();
			searchCommandType = SearchCommand.SERVICED_OBJECTS;
			config = defaultConfig;
			comboData = XML(config.searchModes);
			menuItems = config.operations.*;
			cs.labelField = "@identifier";
		}
		
		override protected function itemClickHandler(event:ListEvent):void
		{
			var item:Object = event.itemRenderer.data;
			switch (String(item.@name))
			{
				case "showCatalogue":
					break;
				case "newItem":
						ServicedObjectEditor.showWindow(null, reloadData, this.contractorId);
					break;
				case "editItem":
					if (itemId)
					{
						ServicedObjectEditor.showWindow(itemId, reloadData);
					}
					break;
				case "itemDetails":
					if (itemId)
					{
						CatalogueItemInfo.showWindow(itemId,null,CatalogueItemInfo.ITEM_DETAILS);
					}
					break;
			}
		}
		
		private function reloadData(id:String):void
		{
			if (cs.setFunction != null) cs.setFunction(id);
		}
		
		private function reloadData2(id:String):void
		{
			if (id) data.itemId = id;
			dispatchEvent(new Event("itemReload"));
		}
		
		public override function get itemId():String
		{
			return this.cs.itemId;
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
						SearchCommand.SERVICED_OBJECTS,
						<searchParams>
							<columns>
								<column field="identifier"/>
								<column field="ownerContractorId"/>
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
			this.text = String(XML(event.result)..@identifier[0]);
		}
		
		private var _contractorId:String;
		public function set contractorId(value:String):void
		{
			if (value != _contractorId) this.cs.dataProvider = null;
			_contractorId = value;
			this.cs.config.searchParams.filters = '';
			if (value) this.cs.config.searchParams.filters.appendChild(<column field="contractorId">{value}</column>);
			this.cs.autoSearch = Boolean(value);
		}
		public function get contractorId():String
		{
			return _contractorId;
		}
		
		public function clear():void
		{
			this.itemId = null;
			this.cs.text = '';
			this.cs.dataProvider = null;
		}
	}
}