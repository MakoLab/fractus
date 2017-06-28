package com.makolab.components.layoutComponents
{
	//import events.ContentChangeEvent;
	
	import com.makolab.components.inputComponents.AddressRenderer;
	import com.makolab.fractus.model.GlobalEvent;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	
	import mx.containers.Panel;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.DataGrid;
	import mx.controls.Label;
	import mx.controls.LinkButton;
	import mx.controls.List;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.utils.ObjectProxy;
	
	import flight.binding.Bind;
	
	[Event(name="sthChange", type="events.ContentChangeEvent")]
	[Event(name="sourceChange", type="flash.events.Event")]
	
	public class XmlItemInfoPanel extends VBox
	{
		public function XmlItemInfoPanel(){
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE,init);
			this.styleName="infoPanelVBox";
			var langManager:LanguageManager = LanguageManager.getInstance();
		}
		
		private var ar:AddressRenderer;
		//private var dataXML:XML = new XML;
		private var objectReferences:Array=new Array();		
		//private var sel:Array = new Array(<item label="item 2" data="" chosen="false"/>,<item label="item 3" data="" chosen="false"/>,<item label="item 4" data="" chosen="true"/>);
		[Bindable]
		private var xmlSource:XML;
		private var _labels:ObjectProxy;
		private var _init:Boolean = false;
		[Bindable]
		public var lm:LanguageManager = LanguageManager.getInstance();
		public var assocArray:Array=new Array();  //1. kolumna- ref do noda
												  //2. kolumna- ref do komponentu
												  //3. kolumna- property komponentu (np. label dla Button'a)
		
		
		private var assocArr:Object = new Object();
		public var model:ModelLocator = ModelLocator.getInstance();
		
		private var watchrs:Array;
		
		private function init(event:Event):void{
			_init = true;
			loadXML();
		}
		
		public function set labels(value:ObjectProxy):void
		{
			if(_labels != value){
				_labels = value;
			}
			if(data)updateValues();
		}
		
		public function get labels():ObjectProxy
		{
			return _labels;
		}
		
		public function set source(val:XML):void{
			dispatchEvent(new Event("sourceChange"));
			this.removeAllChildren();
			Bind.addBinding(this, 'labels', lm, 'labels');
			objectReferences = null;
			objectReferences = new Array();
			assocArray = [];
			xmlSource = val;
			if(_init)loadXML();
			updateValues();
		}
		public function get source():XML{ //?? CZY TO JEST POTRZEBNE ?? //
			return xmlSource;
		}
		override public function set data(value:Object):void{
			if(value != null){
				super.data = value;
				updateValues();
			}
		}
		
		private function loadXML():void{
			if(xmlSource==null || xmlSource==""){
			}else{
				buildComponent(xmlSource,this);
			}
		}
		
		private function buildComponent(node:Object,parentContainer:UIComponent):void{
			var component:UIComponent;
			var component2:XMLList;
			for each(var i:Object in node.*){
				 switch((i.name()).toString()){
				 	case "Component":
				 		var cls:Class = getDefinitionByName(i.@className) as Class;
				 		if (cls)
				 		{
							component = new cls();
							assocArray.push(new Array(i,component));
							addComponent(component,i,parentContainer);				 			
				 		}
				 		break;
					case "CollapsablePanel": 
						component = new CollapsablePanel();
						assocArray.push(new Array(i,component));
						addComponent(component,i,parentContainer);
						break;
					case "Panel": 
						component = new Panel();
						assocArray.push(new Array(i,component));
						addComponent(component,i,parentContainer);
						break;
					case "LinkButton": 
						component = new LinkButton();
						assocArray.push(new Array(i,component,"label"));
						addComponent(component,i,parentContainer);
						break;
					case "VBox": 
						component = new VBox();
						assocArray.push(new Array(i,component));
						addComponent(component,i,parentContainer);
						break;
					case "Label": 
						component = new Label();
						assocArray.push(new Array(i,component,"text"));
						addComponent(component,i,parentContainer);
						break;
					case "DataGrid": 
						component = new DataGrid();
						assocArray.push(new Array(i,component));
						(component as DataGrid).columns = createColumns(i);
						addComponent(component,i,parentContainer);
						break;
					case "List": 
						component=new List();
						assocArray.push(new Array(i,component));
						addComponent(component,i,parentContainer);
						break;
					case "Button": 
						component= new Button();
						assocArray.push(new Array(i,component,"label"));
						addComponent(component,i,parentContainer);
						break;
					case "Text":
						component= new Text();
						assocArray.push(new Array(i,component,"text"));
						addComponent(component,i,parentContainer);
						break;
					case "TextInput":
						component= new TextInput();
						(component as TextInput).addEventListener(Event.CHANGE,eventHandler);
						assocArray.push(new Array(i,component,"text"));
						addComponent(component,i,parentContainer);
						break;						
					case "DataGridRows":
						objectReferences.push({target:parentContainer,value:i});
						break;
					case "row":
						break;
					case "DataGridColumn":
						break;
						/*
					case "ListSelector": 
						assocArray.push(new Array(i,component));
						component=new ListSelector();
						(component as ListSelector).itemList=i.itemList.items;
						component.addEventListener(ListEvent.CHANGE,eventHandler);
						addComponent(component,i,parentContainer);
						break;
						*/
					case "itemList":
						break;
					case "item":
						break;
					case "details":
						break;
					case "items":
						break;
					default:
						Alert.show("",i.name().toString()+" nie zadeklarowany!");
						break;
				}
				buildComponent(i,component);
			}
		}
		
		private function addComponent(tar:UIComponent,xmlNode:Object,parentContainer:UIComponent):void{
			var param:XMLList=xmlNode.@*;
			for(var i:String in param){
				if((param[i].toString()).charAt(0)=="{" && (param[i].toString()).charAt(param[i].toString().length-1)=="}"){
					var path:Array = parsePath(param[i].toString());
					if(path[0] == "LanguageManager")path[0] = "lm";
					Bind.addBinding(tar, param[i].name().toString(), this, path.join('.'));
				}else if((param[i].name()).toString()=="width" && param[i].toString().charAt(param[i].toString().length-1)=="%"){
					tar.percentWidth=(param[i].toString().split("%"))[0];
				}else if((param[i].name()).toString()=="height" && param[i].toString().charAt(param[i].toString().length-1)=="%"){
					tar.percentHeight=(param[i].toString().split("%"))[0];
				}else if((param[i].name()).toString()=="itemRenderer"){
					tar["itemRenderer"] = new ClassFactory(getDefinitionByName(param[i].toString()) as Class);
				}else if((param[i].name()).toString()=="event"){
					addEvent(param[i],tar);
				}else if((param[i].name()).toString()=="className"){
				}else{
					if(tar.hasOwnProperty((param[i].name()).toString())){
						tar[(param[i].name()).toString()]=param[i];
						if(param[i]==true){tar[(param[i].name()).toString()]=true;};
						if(param[i]==false){tar[(param[i].name()).toString()]=false;};
					}else{
						tar.setStyle((param[i].name()).toString(),param[i]);
					}					
				}
			}
			parentContainer.addChild(tar);
		}
		
		private function createColumns(xmlNode:Object):Array{
			var cols:Array=[];
			var component:DataGridColumn;
			for each(var i:Object in xmlNode.*){
				if(i.name().toString()=="DataGridColumn"){
					component=new DataGridColumn();
					for(var j:Object in i.@*){
						if(component.hasOwnProperty(i.@*[j].name().toString())){
							if((i.@*[j].toString()).charAt(0)=="{" && (i.@*[j].toString()).charAt(i.@*[j].toString().length-1)=="}"){
								var path:Array = parsePath(i.@*[j].toString());
								if(path[0] == "LanguageManager")path[0] = "lm";
								Bind.addBinding(component, i.@*[j].name().toString(), this, path.join('.'));
							}else{
								component[i.@*[j].name().toString()] = i.@*[j];
							}
						}else{
							component.setStyle(i.@*[j].name().toString(),i.@*[j]);
						}
					}
					cols.push(component);
				}
				
			}
			return cols;
		}
		
		private function parseObject(obj:Object):Object{
			obj=obj.copy();
			for each(var i:Object in obj.*){
				for each(var j:Object in i.@*){
					if((j.toString()).charAt(0)=="{" && (j.toString()).charAt(j.toString().length-1)=="}"){
						i[j.name()]=getReference(j.toString());
					}
				}
			}
			return obj;
		}
		
		private function parsePath(path:String):Array{
			return path.substring(1,path.length-1).split(".");
		}
		
		private function getReference(value:String):Object{
			var ob:Object=data;
			var tbl:Array=parsePath(value);
			for(var i:int=1;i<tbl.length;i++){
				if(data!=null){
					ob = ob[tbl[i]];
				}
			}
			return ob;
		}
		
		private function getReference2(value:String,rootObj:Object):Object{
			var ob:Object=rootObj;
			var tbl:Array=parsePath(value);
			for(var i:int=1;i<tbl.length;i++){
				if(rootObj!=null){
					ob = ob[tbl[i]];
				}
			}
			return ob;
		}
		
		private function funcReference(value:String):Function{
			var tbl:Array=parsePath(value);
			var ob:Object;
			var fn:Function;
			if(tbl.length==1){
				fn=this[tbl[0]];
			}else{
				ob=this[tbl[0]];
				for(var i:int=1;i<tbl.length;i++){
					if(i==tbl.length-1){
						fn = ob[tbl[i]];
					}else{
						ob = ob[tbl[i]];
					}
				}
			}
			return fn;
		}
		
		private function updateValues():void{
			for(var i:int=0;i<objectReferences.length;i++){
				var dProvider:Object = objectReferences[i].value.copy();
				for each(var obj:Object in dProvider.*)
					{
						if((obj.@label.toString()).charAt(0)=="{" 
							&& ((obj.@label).toString()).charAt((obj.@label).toString().length-1)=="}" 
							&& (((obj.@label).toString()) as String).substr(1,15) == "LanguageManager"
						){
							var key:String = (obj.@label.toString() as String).substring(24,(obj.@label.toString() as String).length-1);
							//BindingUtils.bindProperty(component, i.@*[j].name().toString(), this, path);
							obj.@label = lm.getLabel(key);
						}
					}
				(objectReferences[i].target as DataGrid).dataProvider = parseObject(dProvider).children();
			}
		}
		
		private function addEvent(ev:String,comp:DisplayObject):void{
			ev.replace(" ","");
			var eventProperties:Array=ev.split(",");
			comp.addEventListener(eventProperties[0],funcReference(eventProperties[1]));
		}
		
		private function eventHandler(event:Event):void{
			//change=event;
			//dispatchEvent(new ContentChangeEvent("sthChange",(event.target as DisplayObject)));
		}
	}
}