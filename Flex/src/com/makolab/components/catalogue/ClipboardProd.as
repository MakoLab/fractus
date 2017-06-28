package com.makolab.components.catalogue
{
	import com.makolab.fractus.commands.SaveConfigurationCommand;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ICollectionView;
	import mx.collections.XMLListCollection;
	import mx.events.CollectionEvent;
	
	[Event("change","flash.events.Event")]
	
	public class ClipboardProd extends EventDispatcher
	{
		[Bindable]
		protected var _clipboardXML:XML;
		
		[Bindable]
		public var quantities:Boolean = false;
		
		private var _elementCount:int = 0;
		[Bindable]
		public function get elementCount():int { return _elementCount; }
		public function set elementCount(value:int):void { _elementCount = value; }

		private var _totalQuantity:Number = 0;
		[Bindable]
		public function get totalQuantity():Number { return _totalQuantity; }
		public function set totalQuantity(value:Number):void { _totalQuantity = value; }
		
		private  var model:ModelLocator = ModelLocator.getInstance();
		
		public function get clipboardXML():XML
		{
			return _clipboardXML;
		}
		
		/**
		 * Constuctor.
		 */
		public function ClipboardProd(enforcer:SingletonEnforcer)
		{
			// hard text
			if (enforcer == null) throw new Error("You Can Only Have One Clipboard Instance");
		}
		
		private static var instance:ClipboardProd;
		
		public static function getInstance():ClipboardProd
		{
			if (!instance)
			{
				instance = new ClipboardProd(new SingletonEnforcer);
				instance._clipboardXML = <clipboard><columns/><elements/></clipboard>;
				instance.elementsCollection = new XMLListCollection(instance._clipboardXML.elements.*);
				instance.elementsCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, instance.handleCollectionChange);
				ModelLocator.getInstance().configManager.requestList(["cardProd","cart.content"],instance.configurationLoaded);
			}
			return instance;
		}
		
		private function configurationLoaded():void
		{
			var config:XML = ModelLocator.getInstance().configManager.getXML("cardProd");
			if (config != null)
			{
				if (config.columns){
					this.columns = config.columns.*;
				}
				this.quantities = Boolean(parseInt(config.quantities));
				if (config.documentTemplates.length() > 0)
					setDocumentTemplates(config.documentTemplates[0]);
				else
					documentTemplates = getDocumentTemplates();
			}
		}
			
		private function getDocumentTemplates():XMLList
		{
			var result:XMLList = new XMLList();
			//permission hard coded
			if (model.permissionManager.isEnabled("service.add")) result += model.serviceDocumentTemplates;
			if (model.permissionManager.isEnabled("sales.add")) result += model.salesDocumentTemplates;
            if (model.permissionManager.isEnabled("sales.add")) result += model.salesOrderDocumentTemplates;
			if (model.permissionManager.isEnabled("purchase.add")) result += model.purchaseDocumentTemplates;
			if (model.permissionManager.isEnabled("warehouse.add")) result += model.warehouseDocumentTemplates;
			if (model.permissionManager.isEnabled("warehouse.orders.add")) result += model.orderDocumentTemplates;
			return result;
		}
		
		private function setDocumentTemplates(templatesConfig:XML):void
		{
			if (templatesConfig)
			{
				var templates:XMLList = new XMLList();
				for each (var template:XML in templatesConfig.template)
				{
					var chain:Array = template.toString().split(".");
					//permission hard coded
					if ( model.permissionManager.isEnabled(chain[0] + ".add") )
					{
						var categoryTemplates:XMLList = model[chain[0] + "DocumentTemplates"].copy();
						if (chain[1] == "*") templates += categoryTemplates;
						else templates += categoryTemplates.(@id.toString() == chain[1]);
					}
				}
				documentTemplates = templates;
			}
		}
		
		[Bindable]
		public var documentTemplates:XMLList;
		
		public function set columns(value:XMLList):void
		{
			var columnsCopy:XMLList = value.copy();
			for each(var column:XML in columnsCopy){
				if(column.@labelKey.valueOf() != undefined){
					column.@label = LanguageManager.getInstance().getLabel(column.@labelKey);
				}
			}
			_clipboardXML.columns.* = columnsCopy;
		}
		
		public function get columns():XMLList
		{
			return _clipboardXML.columns.*;
		}
		
		protected function handleCollectionChange(event:CollectionEvent):void
		{
			updateTotals();
		}
		
		public function addElement(element:Object, index:int = -1, quantity:Number = NaN):void
		{
			var original:XML = XML(element).copy();
			element = <item/>;
			
			if (original["@id"].length() == 0)
			{ 
				if (original["id"].length() != 0) element["@id"] = original["id"].toString();
				if (original["itemId"].length() != 0) element["@id"] = original["itemId"].toString();
				if (original["@itemId"].length() != 0) element["@id"] = original["@itemId"].toString();
			}
			else element["@id"] = original["@id"].toString();
			
			if (original["@name"].length() == 0) 
			{
				if (original["name"].length() != 0) element["@name"] = original["name"].toString();
				else if (original["itemName"].length() != 0) element["@name"] = original["itemName"].toString();
				else if (original["@itemName"].length() != 0) element["@name"] = original["@itemName"].toString();
			}
			else element["@name"] = original["@name"].toString();
			
			if (original["@ResponsiblePerson"].length() == 0)
			{ 
					element["@ResponsiblePerson"] ="";
			}
			else 
				element["@ResponsiblePerson"] = original["@ResponsiblePerson"].toString();
			
			
			if (original["@quantity"].length() == 0)
			{
				if (original["quantity"].length() != 0) element["@quantity"] = original["quantity"].toString();
			}
			else element["@quantity"] = original["@quantity"].toString();
			
			
			
			
			quantity = (isNaN(quantity) && (XML(element).attribute("quantity").length() != 0)) ? element.@quantity : quantity;
			if (quantity < 0) quantity = 0; 
			
			if (!quantities || !incQuantity(element.@id,quantity))
			{
				if (quantities && XML(element).attribute("quantity").length() == 0) element.@quantity = 1;
				else element.@quantity = quantity;
				if (index < 0) XMLListCollection(elements).addItem(element);
				else XMLListCollection(elements).addItemAt(element, index);
			}
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function deleteElement(element:Object):void
		{
			elementsCollection.removeItemAt(elementsCollection.getItemIndex(element));
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		protected function updateTotals():void
		{
			elementCount = elementsCollection.length;
			if (quantities)
			{
				var q:Number = 0;
				for each (var x:XML in elementsCollection) q += parseFloat(x.@quantity);
				totalQuantity = parseFloat(q.toFixed(4));	// zabezpieczenie przed bledami zaokraglen JS/AS
			}
		}
		
		protected var elementsCollection:XMLListCollection;
		
		public function get elements():ICollectionView
		{
			return elementsCollection;
		}
		
		public function contains(id:String):Boolean
		{
			return _clipboardXML.elements.*.(@id == id).length();
		}
		
		protected function saveContent():void
		{
			var cmd:SaveConfigurationCommand = new SaveConfigurationCommand();
			cmd.execute();
		}
		
		public function incQuantity(id:String,quantity:Number):int
		{
			var element:Object = getElementById(id);
			if (element)
			{
				if (element.@quantity == undefined) return element.@quantity = quantity;
				else return element.@quantity = (Number(element.@quantity) + quantity);//Bylo: (element.@quantity) + quantity //Zmienione przez Martę, z powodu wczesniejszego braku dzialania zwiekszania ilosci przy kazdorazowym dodaniu tego samego towaru (B2B)
			}
			else return 0;
		}
		
		public function getElementById(id:String):Object
		{
			var elements:XMLList = _clipboardXML.elements.*.(@id == id);
			if (elements.length() > 0) return elements[0];
			else return null;
		}
		
		public function clear():void
		{
			elementsCollection.removeAll();
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}

class SingletonEnforcer {}