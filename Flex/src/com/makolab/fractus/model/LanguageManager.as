package com.makolab.fractus.model
{
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.utils.ObjectProxy;
	
	import flight.binding.Bind;
	
	public class LanguageManager
	{
		static private var instance:LanguageManager = new LanguageManager();
		
		private var labelsXML:XML;
		[Bindable]
		public var languagesList:Array = [
			"PL",
			"EN"
		];
		
		[Bindable]
		public function get monthNames():Array{
			switch(LanguageManager.instance.currentLanguage.toLocaleUpperCase())
			{
				case "PL":
					return LanguageManager.instance.monthNamesPL;break;
				default: 
					return LanguageManager.instance.monthNamesEN;
			}
		}
		
		[Bindable]
		public var monthNamesPL:Array = [
				"Styczeń",
				"Luty",
				"Marzec",
				"Kwiecień",
				"Maj",
				"Czerwiec",
				"Lipiec",
				"Sierpień",
				"Wrzesień",
				"Październik",
				"Listopad",
				"Grudzień"
			];
		[Bindable]
		public var monthNamesEN:Array = [
			"January",
			"February",
			"March",
			"April",
			"May",
			"June",
			"July",
			"August",
			"September",
			"October",
			"November",
			"December"
		];
			
		[Bindable]
		public function get dayNames():Array{
			switch(LanguageManager.instance.currentLanguage.toLocaleUpperCase())
			{
				case "PL":return LanguageManager.instance.dayNamesPL;break;
				default: return LanguageManager.instance.dayNamesEN;
			}
		}
		[Bindable]
		public var dayNamesPL:Array = ["Nd", "Pn", "Wt", "Śr", "Cz", "Pt", "So"];
		
		[Bindable]
		public var dayNamesEN:Array = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
		
		[Bindable]
		public var labels:ObjectProxy;
		
		[Bindable]
		public var languages:Object = new Object();
		
		
		public function LanguageManager()
		{
		}
		
		public static function getInstance():LanguageManager
		{
			return instance;
		}
		
		public function getLabel(key:String, defaultValue:String = null):String
		{
			var value:Object = labels;
			
			if(key)
			{
				var arr:Array = key.split(".");
				for each (var item:String in arr) {
					value = value[item];
				}
			}
			
			if (!value && defaultValue) return defaultValue;
			else return value.toString();
		}
		
		public static function getLabel(key:String):String { 
			return LanguageManager.getInstance().getLabel(key);
			
		}
		
		public static function getLanguages():Object { 
			return LanguageManager.getInstance().languages;
		}
		
		public function setLangueges(xml:XML):void 
		{
			languages = {langs: xml.configValue.root.availableLanguages.*, defaultLang: xml.configValue.root.defaultLanguage.text()};
		}
		
		public function setLabelsXML(xml:XML):void
		{
			labelsXML = xml;
			labels = new ObjectProxy();
			for each (var label:XML in xml.*) parseLabel(label.@key, label.*.toString());
			Alert.yesLabel = labels.alert.yes;
			Alert.noLabel = labels.alert.no;
			Alert.cancelLabel = labels.common.cancel;
			Alert.okLabel = labels.common.ok;
			
			DocumentTypeDescriptor.FIELD_LABELS=new ArrayCollection([
				{key: "issueDate", value: LanguageManager.getInstance().labels.documents.entryDate, category: DocumentTypeDescriptor.CATEGORY_PURCHASE},
				{key: "issueDate", value: LanguageManager.getInstance().labels.documents.entryDate, category: DocumentTypeDescriptor.CATEGORY_PURCHASE_CORRECTION},
				{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: DocumentTypeDescriptor.CATEGORY_SALES},
				{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: DocumentTypeDescriptor.CATEGORY_SALES_ORDER_DOCUMENT},
				{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: DocumentTypeDescriptor.CATEGORY_SALES_CORRECTION},
				{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: DocumentTypeDescriptor.CATEGORY_WAREHOUSE},
				{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: DocumentTypeDescriptor.CATEGORY_WAREHOUSE_RESERVATION},
				{key: "issueDate", value: LanguageManager.getInstance().labels.documents.orderDate, category: DocumentTypeDescriptor.CATEGORY_WAREHOUSE_ORDER},
				{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: DocumentTypeDescriptor.CATEGORY_WAREHOUSE_OUTCOME_CORRECTION},
				{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: DocumentTypeDescriptor.CATEGORY_WAREHOUSE_INCOME_CORRECTION},
				{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: DocumentTypeDescriptor.CATEGORY_FINANCIAL_DOCUMENT},
				{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: DocumentTypeDescriptor.CATEGORY_SERVICE_DOCUMENT},
				{key: "issueDate", value: LanguageManager.getInstance().labels.common.creationDate, category: DocumentTypeDescriptor.CATEGORY_TECHNOLOGY_DOCUMENT},
				{key: "issueDate", value: LanguageManager.getInstance().labels.documents.issueDate, category: DocumentTypeDescriptor.CATEGORY_PRODUCTION_ORDER_DOCUMENT},
				{key: "eventDate", value: LanguageManager.getInstance().labels.documents.receptionDate, category: DocumentTypeDescriptor.CATEGORY_PURCHASE},
				{key: "eventDate", value: LanguageManager.getInstance().labels.documents.receptionDate, category: DocumentTypeDescriptor.CATEGORY_PURCHASE_CORRECTION},
				{key: "eventDate", value: LanguageManager.getInstance().labels.documentRenderer.salesDate, category: DocumentTypeDescriptor.CATEGORY_SALES},
				{key: "eventDate", value: LanguageManager.getInstance().labels.documentRenderer.salesDate, category: DocumentTypeDescriptor.CATEGORY_SALES_CORRECTION},
				{key: "eventDate", value: LanguageManager.getInstance().labels.documents.realizationDate, category: DocumentTypeDescriptor.CATEGORY_WAREHOUSE_RESERVATION},
				{key: "eventDate", value: LanguageManager.getInstance().labels.documents.realizationDeadline, category: DocumentTypeDescriptor.CATEGORY_WAREHOUSE_ORDER},
				{key: "eventDate", value: LanguageManager.getInstance().labels.documents.recordDate, category: DocumentTypeDescriptor.CATEGORY_SERVICE_DOCUMENT},
				{key: "plannedEndDate", value: LanguageManager.getInstance().labels.documents.plannedEndDate, category: DocumentTypeDescriptor.CATEGORY_SERVICE_DOCUMENT}]
			);
			
			ModelLocator.getInstance().eventManager.dispatchEvent(new GlobalEvent(GlobalEvent.LANGUAGE_CHANGED));
		}
		
		public function get currentLanguage():String
		{
			return labelsXML.@language.toString();
		}
		
		private function parseLabel(key:String, value:String):void
		{
			var spl:Array = key.split(/\./g);
			var obj:ObjectProxy = labels;
			for (var i:int = 0; i < spl.length - 1; i++)
			{
				var s:String = spl[i];
				if (!obj[s]) obj[s] = new ObjectProxy();
				obj = obj[s];
			}
			obj[spl[i]] = value;
		}
		
		public static function bindLabel(object:Object, property:String, labelKey:String):void
		{
			//var chain:Array = (['labels']).concat(labelKey.split(/\./g));
			Bind.addBinding(object, property, LanguageManager.getInstance().labels,  labelKey);
		}
		
		public static function getLabelFromXML(xmlLabels:XML):String
		{
			var l:XMLList = xmlLabels.label.(@lang == instance.currentLanguage);
			if (l.length() > 0) return String(l[0]);
			else if (xmlLabels.label.length() > 0) return xmlLabels.label[0];
			else return '???';
		}
		/*
		private var watchers:Object = {};
		
		private function getObjectWatchers(obj:Object):Array
		{
			if (!watchers[obj])
			{
				watchers[obj] = new Array();
				if (obj is IEventDispatcher) IEventDispatcher(obj).addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage, false, EventPriority.DEFAULT, true);
			}
			return watchers[obj]; 
			
		}
		
		public function unbindLabels(obj:Object):Boolean
		{
			if (watchers[obj])
			{
				for each (var watcher:ChangeWatcher in watchers[obj]) watcher.unwatch();
				delete watchers[obj];
				return true;
			}
			else return false;
		}

		private function handleRemovedFromStage(event:Event):void
		{
			unbindLabels(event.target);
		}
		*/
	}
}