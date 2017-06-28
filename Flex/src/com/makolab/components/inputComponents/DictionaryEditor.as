package com.makolab.components.inputComponents
{
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.validators.StringValidator;
	import mx.validators.Validator;

	public class DictionaryEditor extends VBox
	{
		private var _data:Object;
		public var error:Boolean;
		/**
		 * Lets you pass a value to the editor.
		 * @see #data
		 */
		[Bindable]
		public var dataObject:Object;
		
		public var dictionaryType:String;
		/**
		 * If set to "Edit" the editor fields will be filled out with assigned to <code>dataObject</code> values. If set to "Add" you creates a blank editor instance.
		 */
		public var action:String;
		public static const EDIT:String = "Edit";
		public static const ADD:String = "Add";
		
		private var _valId:int=0;
		[Bindable]
		public var dictConfig:XML = ModelLocator.getInstance().configManager.getXML("dictionaries.configuration");
		private var lang:XMLList = LanguageManager.getLanguages().langs;
		/**
		 * Constructor.
		 */
		public function DictionaryEditor()	
		{
			
		}
		/**
		 * Lets you pass a value to the editor.
		 * the <code>data</code> property doesn't change while editing values in editor. The value of <code>data</code> is copied to <code>dataObject</code>. To read modified values use <code>dataObject</code> property.
		 * @see #dataObject
		 */
		[Bindable]
		override public function set data(value:Object):void
		{
			_data = value;
			if(value)	{
				{
				dataObject=value;

				}
				if(this.action == ADD) removeEmptyTags();
	
				createNewEditor(this.action==ADD);
			}			
		}
		
		private function removeEmptyTags():void 
		{
			delete dataObject.id;
			delete dataObject.version;
			delete dataObject.order;
		}
		/**
		 * @private
		 */
		override public function get data():Object	
		{
			return _data;
		}
		private function createNewEditor(rem:Boolean=false):void
		{
			var xmll:XMLList=dictConfig.child(dictionaryType);
			var xmllCheck:XMLList=dictConfig.child(dictionaryType);
			this.removeAllChildren();
			
			var lab:Label;
			var inp:ExTextInput;
			var dict:DictionarySelector;
			var ta:ExTextArea;
			var hb:HBox;
			var vb:VBox;
			
			var val:ExValInput;
			var name:String;
			var type:String;
			var j:int;
			var addBtn:Button;
			
			this.removeAllChildren();

			for(var i:int=0; i<_data.*.length(); i++)	{
				name = _data.*[i].name().toString();

				if(name!="id" && name!="version" && name!="order" && name!="xmlLabels" && name!="xmlMetadata")	{
					lab = new Label();
					lab.width = 100;
					if(name!="xmlOptions") inp = new ExTextInput();
					else { ta = new ExTextArea(); ta.width = 300; ta.height = 100;}
					hb = new HBox();
					lab.data = _data.*[i].name();
					if(rem)
						dataObject.*[i] = "";
					else
						if(name!="xmlOptions") inp.text = _data.*[i];
						else ta.text = _data.*[i];
						 
					if(name!="xmlOptions")	{
						inp.nodeName = _data.*[i].name();
						inp.level = 1;					
						inp.addEventListener(Event.CHANGE,changeHandler);										
						hb.addChild(lab);
						hb.addChild(inp);
					}
					else	{
						ta.nodeName = _data.*[i].name();
						ta.level = 1;					
						ta.addEventListener(Event.CHANGE,changeHandler);										
						hb.addChild(lab);
						hb.addChild(ta);
					}
					this.addChild(hb);
				}
				else 
					if( name=="xmlMetadata")	{
					//_data.xmlMetadata.metadata.*[i].name().toString()
					for(j=0; j<_data.*[i].*.*.length(); j++)
					{
						lab = new Label();
						lab.width = 100;
						lab.data = _data.*[i].*.*[j].name() + " " + _data.*[i].*.*[j].@lang;
						
						var sn:String=_data.*[i].*.*[j].name();
						if(sn=="values")
							continue;
						if(sn=="dataType")
							type=xmll.xmlMetadata.metadata[sn].@type;
						else
							if(sn=="template")
								type="textArea";
								else
							type="";
						vb = new VBox();
						vb.setStyle("paddingLeft", "10");
						//vb.setStyle("paddingRight", "10");
						vb.setStyle("paddingTop", "10");
						//vb.setStyle("paddingBottom", "10");
						switch(type){
							case "select":
								dict=new DictionarySelector();
								dict.width=200;
								dict.dataProvider=XMLList(xmll.xmlMetadata.metadata[sn].*);
								
								dict.valueMapping={ name : '*' };
								dict.labelField="name";
								dict.level=2;
								if(this.action == EDIT||this.action==ADD)
								{
									dict.selectedItem=<entry><name>{data.xmlMetadata.metadata[sn].toString()}</name></entry>;
								}
								dict.nodeName = data.*[i].*.*[0].name();
								dict.addEventListener(Event.CHANGE,changeHandler);
								
								vb.addChild(lab);
								vb.addChild(dict);
								if(data.xmlMetadata.metadata[sn].toString()=="select")
								{
									for(var k:int=0;k<data.xmlMetadata.metadata.values.value.length();k++)
									{
										var vi:int=data.xmlMetadata.metadata.values.value[k].@id;
										
										val=new ExValInput(data.xmlMetadata.metadata.values.value[k].labels,data.xmlMetadata.metadata.values.value[k].name,vi);
										val.dataObject="values";
										val.addEventListener(Event.CHANGE,changeHandler);
										
										vb.addChild(val);
										if(vi>_valId)
											_valId=vi;
										_valId++;
									}
									if(this.action == EDIT)
									{
										addBtn=new Button();
										addBtn.label=LanguageManager.getInstance().labels.common.add;
										vb.addChild(addBtn);
										addBtn.addEventListener(MouseEvent.CLICK, addVal);
									}
								}
								break;
							case "textArea":
								ta = new ExTextArea(); ta.width = 300; ta.height = 100;
								if(this.action == EDIT)
								{
									ta.text = _data.*[i].*.*[j];
								}
								ta.nodeName = _data.*[i].*.*[j].name();
								ta.attributeName = "lang";
								ta.attributeValue = _data.*[i].*.*[j].@[ta.attributeName];
								ta.level = 2;
								ta.addEventListener(Event.CHANGE,changeHandler);	
								vb.addChild(lab);
								vb.addChild(ta);
								break;
							default:
								inp = new ExTextInput();
								if(this.action == EDIT)
								{
									inp.text = _data.*[i].*.*[j];
								}
									inp.nodeName = _data.*[i].*.*[j].name();
									inp.attributeName = "lang";
									inp.attributeValue = _data.*[i].*.*[j].@[inp.attributeName];
									inp.level = 2;
									inp.addEventListener(Event.CHANGE,changeHandler);	
									vb.addChild(lab);
									vb.addChild(inp);
								
							}
						if(vb)
							this.addChild(vb);
						
					}				
				}
				if(name=="xmlLabels" )	{
					var extraLang:Array=new Array();
					for(j=0; j<_data.*[i].*.*.length(); j++)	{
						lab = new Label();
						lab.width = 100;
						
							inp = new ExTextInput();
						
						hb = new HBox();
						
						lab.data = _data.*[i].*.*[j].name() + " " + _data.*[i].*.*[j].@lang;
						extraLang.push(_data.*[i].*.*[j].@lang);
					//	if(this.action == EDIT)
						if(rem) 
								dataObject.*[i].*.*[j] = "";
						else
							inp.text = _data.*[i].*.*[j];
						
							inp.nodeName = _data.*[i].*.*[j].name();
							inp.attributeName = "lang";
							inp.attributeValue = _data.*[i].*.*[j].@[inp.attributeName];
							inp.level = 2;
							inp.addEventListener(Event.CHANGE,changeHandler);	
							hb.addChild(lab);
							hb.addChild(inp);
						
						this.addChild(hb);
					}
					if((this.action == EDIT||this.action==ADD)&&_data.*[i].*.*.length()&&extraLang.length)
					{
						
						for(j=0; j<lang.length();j++)
						{
							var add:Boolean=true;
							for(var k:int=0; k<extraLang.length;k++)
							{
								if(lang[j].toString()==extraLang[k])
								{
									add=false;
								}
							}
							if(add)
							{
								lab = new Label();
								lab.width = 100;
								
								inp = new ExTextInput();
								
								hb = new HBox();
								
								lab.data = _data.*[i].*.*[0].name() + " " + lang[j];
									inp.text = "";
								
								inp.nodeName = _data.*[i].*.*[0].name();
								inp.attributeName = "lang";
								inp.attributeValue = lang[j];
								inp.level = 2;
								inp.addEventListener(Event.CHANGE,changeHandler);	
								hb.addChild(lab);
								hb.addChild(inp);
								this.addChild(hb);
							}
						}
					}
				}
				else if((name=="id" || name=="version" || name=="order") && this.action == ADD)	{
					dataObject.*[i] = "";
				}
			}
			if(this.action == ADD) 
					removeEmptyTags();
			
		}
		
		public var validatorArr:Array;
		
		private function changeHandler(event:Event, addValidator:Boolean = false):void	
		{
			if(addValidator) {
				addValidatorToComponent(event.target);
			}
			var ob:Object = event.target;
			if(ob.dataObject=="values")
			{
				if(this.dataObject.xmlMetadata.metadata.values.length()==0)
					this.dataObject.xmlMetadata.metadata.child[this.dataObject.xmlMetadata.metadata.child.length()]=<values></values>;
				if(this.dataObject.xmlMetadata.metadata.values.*.(@id==ob.mId).length())
				{
					if(ob.text)
						this.dataObject.xmlMetadata.metadata.values.*.(@id==ob.mId)[0]=ob.text;
					else
						delete this.dataObject.xmlMetadata.metadata.values.*.(@id==ob.mId)[0];
				}
				else
				{
					if(ob.text)
						this.dataObject.xmlMetadata.metadata.values.child[this.dataObject.xmlMetadata.metadata.values.child.length()]=ob.text;
				}
					
			}
			else
			if(ob.level == 1)	{ 
				try	{
					this.dataObject[ob.nodeName] = XML(ob.text);
					error = false;
				}
				catch(err:Error)	{
					if(ob.selectedItem) 
						this.dataObject[ob.nodeName] = ob.selectedItem.id.text();						
					else	{
						this.dataObject[ob.nodeName] = ob.text;
						error = true;
					}
				}
			}
			else
				if(ob.className=='DictionarySelector')
				{
					this.dataObject.*.*[ob.nodeName].* = ob.selectedItem.*.*.toString();
				}
				else if(ob.attributeValue)
					{
					if(this.dataObject.*.*[ob.nodeName].(attribute("lang")==ob.attributeValue).length())
						this.dataObject.*.*[ob.nodeName].(attribute("lang")==ob.attributeValue).* = ob.text;
					else
						this.dataObject.*.*[ob.nodeName][this.dataObject.*.*[ob.nodeName].length()]=<{ob.nodeName} lang={ob.attributeValue}>{ob.text}</{ob.nodeName}>;
					}
					else
					{
						this.dataObject.*.*[ob.nodeName].* = ob.text;
					}
			if(ob.nodeName=="dataType")
			{
				createNewEditor();
			}
		}
		
		private function addValidatorToComponent(comp:*):void {
			//if(comp as TextInput) {
				var val:StringValidator = new StringValidator();
				val.required = true;
				val.requiredFieldError = LanguageManager.getInstance().labels.login.error.required;
				val.property = 'text';
				val.source = comp;
				val.trigger = comp;
				val.triggerEvent = 'eventKtoregoNieMa';
				validatorArr.push(val);
			//}
			
			/*rozwiazanie na dodanie walidacji checkboxa lub Comboboxa
			if(comp as PopUpButton) {
				
			}*/
		}
		
		public function validateForm():Boolean {
			if(!validatorArr)validatorArr=new Array();
			var validatorErrorArray:Array = Validator.validateAll(validatorArr);
			var isValidForm:Boolean = validatorErrorArray.length == 0;
			if (isValidForm) {
				return true;
			} else {
				return false;
			}
		}
		private function addVal(e:MouseEvent):void{
			var val:ExValInput=new ExValInput(new XMLList(),"",_valId);
			_valId++;
			val.dataObject="values";
			val.level=1;
			var hb:VBox=e.currentTarget.parent;
			var btn:Button=e.currentTarget as Button;
			hb.addChild(val);
			val.addEventListener(Event.CHANGE,changeHandler);
			hb.removeChild(btn);
			hb.addChild(btn);
		}
	}
}