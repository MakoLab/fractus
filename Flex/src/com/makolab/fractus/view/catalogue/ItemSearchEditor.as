package com.makolab.fractus.view.catalogue
{
	import com.makolab.components.catalogue.CatalogueItemWindowEvent;
	import com.makolab.components.catalogue.CatalogueSearchWrapper;
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.fractus.commands.SearchCommand;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.CommercialDocumentLine;
	
	import flash.events.Event;
	
	import flight.binding.Bind;
	
	import mx.events.ListEvent;

	[Event(name="itemReload", type="flash.events.Event")]
	public class ItemSearchEditor extends CatalogueSearchWrapper
	{
		private var defaultConfig:XML = ModelLocator.getInstance().configManager.getXMLValue('items.lists.itemSearchEditor');
		
		private var _config:XML;
		
		private var _sortByItemQuantity:Boolean = false;
		
		private var _warehouseId:String;
		public function set warehouseId(value:String):void
		{
			_warehouseId = value;
			if (this.config) this.config.searchParams.currentWarehouse = _warehouseId;
		}
		public function get warehouseId():String
		{
			return _warehouseId;
		}
		override public function set config(value:XML):void
		{
			if (value && warehouseId) 
				value.searchParams.currentWarehouse = warehouseId;
			if (value && ModelLocator.getInstance().currentItemPriceId) 
				value.searchParams.currentItemPriceId = ModelLocator.getInstance().currentItemPriceId;
			super.config = value;
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			// wyswietlanie informacji o stanie na oddziale docelowym.
			if (value && value is CommercialDocumentLine && (value as CommercialDocumentLine).documentObject.typeDescriptor.isIncomeShiftOrder)
			{
				var line:CommercialDocumentLine = value as CommercialDocumentLine;
				var fieldId:String = DictionaryManager.getInstance().getIdByName("Attribute_TargetBranchId","documentFields");
				var targetBranchAttributes:XMLList = line.documentObject.attributes.source.(documentFieldId.toString() == fieldId);
				if (targetBranchAttributes.length() > 0) 
				{
					//line.documentObject.addEventListener(DocumentEvent.DOCUMENT_ATTRIBUTE_CHANGE,documentAttributeChangeHandler);
					var branch:String = targetBranchAttributes[0].value.toString();
					var foreignWarehouses:XMLList = DictionaryManager.getInstance().dictionaries.foreignWarehouses;
					var warehouses:XMLList = foreignWarehouses.(branchId.toString() == branch);
					if (warehouses.length() > 0)
						warehouseId = warehouses[0].id.toString();
				}
			}
		}
		
		/* private function documentAttributeChangeHandler(event:DocumentEvent):void
		{
			if (event.fieldName == "Attribute_TargetBranchId")
			{
				var branch:String = event.line.documentObject.attributes.(@documentFieldId.toString() == DictionaryManager.getInstance().getIdByName("Attribute_TargetBranchId","documentField"))[0].value.toString();
				warehouseId = DictionaryManager.getInstance().dictionaries.foreignWarehouses.(branchId.toString() == branch)[0].id;
			}
		} */
		
		[Bindable]
		public function set sortByItemQuantity(value:Boolean):void
		{
			this._sortByItemQuantity = value;
//			if(_sortByItemQuantity)
//			{
//				for each (var c:XML in config.searchParams.columns.column)
//				{
//					if(c.@field == "quantity")
//					{
//						c.@sortOrder = "1";
//						c.@sortType = "DESC";
//					}
//					else if(c.@sortOrder.length() > 0)
//						delete c.@sortOrder;
//				}
//			}
		}
		
		public function get sortByItemQuantity():Boolean
		{
			return this._sortByItemQuantity;
		} 

		public function ItemSearchEditor()
		{
			super();
			searchCommandType = SearchCommand.ITEMS;
			config = defaultConfig;
			comboData = XML(config.searchModes);
			menuItems = config.operations.*;
			cs.labelField = "@name";
			updateWarehouse();
			Bind.addListener(updateWarehouse, ModelLocator.getInstance(), 'currentWarehouseId'); 
		}
		
		private function updateWarehouse(arg:Object = null):void
		{
			if (!warehouseId)
				this.config.searchParams.currentWarehouse = ModelLocator.getInstance().currentWarehouseId;
			else 
				this.config.searchParams.currentWarehouse = warehouseId;
		}
		
		override protected function itemClickHandler(event:ListEvent):void
		{
			var item:Object = event.itemRenderer.data;
			var itemId:String;
			if (this.data) itemId = this.data.itemId;
			switch (String(item.@name))
			{
				case "showCatalogue":
					break;
				case "newItem":
						ItemsCatalogue.showItemWindow(null, null, ModelLocator.getInstance().getDefaultTemplate("item")).addEventListener(CatalogueItemWindowEvent.DATA_SAVE_COMPLETE, reloadData);
					break;
				case "editItem":
					if (itemId)
					{
						ItemsCatalogue.showItemWindow(itemId,null, ModelLocator.getInstance().getDefaultTemplate("item")).addEventListener(CatalogueItemWindowEvent.DATA_SAVE_COMPLETE, reloadData);
					}
					break;
				case "duplicateItem":
					if (itemId)
					{
						ItemsCatalogue.showItemWindow(itemId,null, ModelLocator.getInstance().getDefaultTemplate("item"),true).addEventListener(CatalogueItemWindowEvent.DATA_SAVE_COMPLETE, reloadData);
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
		
		private function reloadData(event:CatalogueItemWindowEvent):void
		{
			if (event && event.itemId && event.itemId != data.itemId) data.itemId = event.itemId;
			dispatchEvent(new Event("itemReload"));
		}
		
	}
}