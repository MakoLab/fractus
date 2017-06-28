package com.makolab.components.layoutComponents
{
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.view.ComponentWindow;
	import com.makolab.fractus.view.generic.GenericEditor;
	
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.controls.Button;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	//import flash.events.MouseEvent;
	//import flash.events.Event;
	
	[Event(name="commit", type="flash.events.Event")]
	[Event(name="change", type="flash.events.Event")]
	
	public class DynamicFormBuilder extends Form
	{
		
		
		[Bindable] private var dictionary:DictionaryManager = DictionaryManager.getInstance();
		[Bindable] private var languageManager:LanguageManager = LanguageManager.getInstance();
		
		
		[Bindable] private var resetButton:Button;
		[Bindable] private var commitButton:Button;
		
		/**
		 * Decides if the commit button appears and changes are commited after button click or each time a single editor loses focus.
		 */		
		public var liveEdit:Boolean;
		
		private var dynamicForm:Form = new Form();
		private var dynamicFormItem:FormItem;
		private var dynamicComponents:Array = [];
		
		
		private var resultXML:XML;
	
		private var _configXML:XML;
			
		[Bindable]
		public function set configXML(value:XML):void
		{
			if(_configXML == value)return;
			_configXML = value;
				
			if((_configXML && _configXML != "")/*  && (_dataXML && _dataXML != "") */){
				createLayout(_configXML);
			}
				
		}
			
		public function get configXML():XML
		{
			return _configXML;
		}
		
		
		private var _dataXML:XML;
		private var dataXMLcopy:XML;
			
		[Bindable]
		public function set dataXML(value:XML):void
		{
			if(_dataXML === value)return;
			_dataXML = value;
			dataXMLcopy = value.copy();
				
			if((dataXMLcopy) && (_configXML)){
				//createLayout(_configXML);
				updateData();
			}
		}
			
		public function get dataXML():XML
		{
			return _dataXML;
		}
			
			
		public function DynamicFormBuilder()
		{
			createLayout(configXML);
		}

		public static function showWindow(config:XML):ComponentWindow
		{
			var component:DynamicFormBuilder = new DynamicFormBuilder();
			var window:ComponentWindow = ComponentWindow.showWindow(component);
			return window;
		}
		
		
		public function createLayout(config:XML):void
		{
			if(config != null){
				
				dynamicComponents = [];
				
			for each (var i:XML in config.component)
			{
				var label:String = getLabel(i);
					
				var spl:Array = (String(i.@dataSource)).split(/\./g);
				
				var dataTxt:XMLList = XMLList(dataXMLcopy);
								
				for(var k:int=0;k<spl.length; k++){
					dataTxt = dataTxt.child(spl[k]);
				}				
								
				var ge:GenericEditor = new GenericEditor();
				ge.dataType = i.dataType;
				ge.addEventListener(Event.CHANGE,handleChange);
				
				
				if(i.dataType == "select") {
					var xmlll:XMLList = new XMLList();
					ge.values = i.dataProvider.item;
				}
				
				ge.dataObject = dataTxt.toString();	
				
				dynamicFormItem = new FormItem();
				dynamicFormItem.label = label;
				dynamicFormItem.addChild(ge);
					
			
				dynamicForm.addChild(dynamicFormItem);
				dynamicComponents.push({component : ge, chain : spl});
			}
			
			
			
			this.addChild(dynamicForm);
			resetButton = new Button();
			resetButton.label = "Resetuj dane";
			resetButton.addEventListener(MouseEvent.CLICK, resetForm);
			this.addChild(resetButton);
			
			if(!liveEdit){
				commitButton = new Button();
				commitButton.label = "Commit";
				commitButton.addEventListener(MouseEvent.CLICK, commitChanges);
				this.addChild(commitButton);
			}
		}
		}
		
		private function updateData():void
		{
			for(var i:int = 0; i < dynamicComponents.length; i++){
				var value:XML = _dataXML;
				for(var j:int = 0; j < dynamicComponents[i].chain.length; j++){
					if(value[dynamicComponents[i].chain[j]].length() > 0) value = value[dynamicComponents[i].chain[j]][0];
					else value = null;
				}
				if(value && XMLList(value).length() > 0)
					dynamicComponents[i].component["dataObject"] = value[0].toString();
				else dynamicComponents[i].component["dataObject"] = null;
				//trace(dynamicComponents[i].component["dataObject"] ? dynamicComponents[i].component["dataObject"].toString() : "null", value ? XML(value).toXMLString() : "null");
			}
		}
		
		private function handleChange(event:Event):void
		{
			if(liveEdit)commitChanges();
		}
		
		public function getLabel(i:XML):String
		{
			var label:String = "";
			
			if((i.label).length() > 0 ){
				label = i.label;
			}
			else if((i.labelKey).length() > 0){
				label = languageManager.getLabel(i.labelKey);
			}
			else if((i.labels).length() > 0){
				label = i.labels.label.(@lang == LanguageManager.getInstance().currentLanguage).*; 
			}
			
			return label;
		}
		
		public function resetForm(e:MouseEvent):void
		{
			dataXML = new XML();
		}
		
		private function commitButtonClickHandler(event:MouseEvent):void
		{
			commitChanges();
		}
		
		public function commitChanges():void
		{
			for(var i:int = 0; i < dynamicComponents.length; i++){
				var value:XML = dataXMLcopy;
				for(var j:int = 0; j < dynamicComponents[i].chain.length - 1; j++){
					if(value[dynamicComponents[i].chain[j]].length() == 0)value[dynamicComponents[i].chain[j]] = new XML();
					value = value[dynamicComponents[i].chain[j]][0]; 
				}
				if(dynamicComponents[i].component["dataObject"]){
					if(value)value[dynamicComponents[i].chain[dynamicComponents[i].chain.length - 1]] = dynamicComponents[i].component["dataObject"].toString();
				}else{
					if(value && value[dynamicComponents[i].chain[dynamicComponents[i].chain.length - 1]])
					delete value[dynamicComponents[i].chain[dynamicComponents[i].chain.length - 1]];
				}
			}
			this._dataXML.* = dataXMLcopy.*;
			
			if(!liveEdit)this.dispatchEvent(new Event("commit"));
			if(liveEdit)this.dispatchEvent(new Event("change"));
		}
}
}