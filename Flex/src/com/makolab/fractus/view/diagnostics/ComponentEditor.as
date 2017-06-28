package com.makolab.fractus.view.diagnostics
{
	import com.makolab.components.inputComponents.DictionaryEditor;
	import com.makolab.components.inputComponents.DictionarySelector;
	import com.makolab.components.inputComponents.ExTextArea;
	import com.makolab.components.inputComponents.ExTextInput;
	import com.makolab.components.inputComponents.ExValInput;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.BusinessObject;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.HBox;
	import mx.containers.HDividedBox;
	import mx.containers.VBox;
	import mx.containers.VDividedBox;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.TextArea;
	import mx.controls.Tree;
	import mx.core.ScrollPolicy;
	import mx.events.ListEvent;
	import mx.validators.StringValidator;
	import mx.validators.Validator;

	
	public class ComponentEditor extends VBox
	{
		private var _data:XML;
		public var error:Boolean;
		private var left:VBox;
		private var right:VBox;
		private var tr:Tree;
		private var tabs:Array;
		private var currI:int=-1;
		private var currJ:int=-1;
		private var btn:Button;
		/**
		 * Lets you pass a value to the editor.
		 * @see #data
		 */
		public var t:TextArea;
		
		private var mode:String;
		private const TAB:String="tab";
		private const COMPONENT:String="component";
		
		
		public const classNames:XML=
			<root><item name="com.makolab.components.inputComponents.SingleAttributeEditor" label="SingleAttributeEditor"/>
		<item name="mx.containers.FormHeading" label="FormHeading"/>
		<item name="com.makolab.components.inputComponents.AttributeEditor" label="AttributeEditor"/>
		<item name="com.makolab.components.inputComponents.EquivalentEditor" label="EquivalentEditor"/>
		<item name="com.makolab.components.inputComponents.GroupSelectionEditor" label="GroupSelectionEditor"/></root>
			;
		
		public const attributes:XML=
			<root><item name="{dictionaryManager.dictionaries.itemAttributes}"/>
<item name="{dictionaryManager.dictionaries.itemImage}"/></root>
			;
		public var attributeName:Object=DictionaryManager.getInstance().dictionaries.itemFields.name.*;
		public var itemFields:Object=DictionaryManager.getInstance().dictionaries.itemFields;
		public const editorAttributes:Array=[
			];
		public const itemEditor=[
			{value:"com.makolab.components.inputComponents.GenericAttributeEditorComponent",label:"GenericAttributeComponent"},
				{value:"com.makolab.components.inputComponents.ImageAttributeEditorNoDesc",label:"ImageAttributeEditorNoDecs"},
					{value:"com.makolab.components.inputComponents.ValueUnitEditor",label:"ValueUnitEditor"},
						{value:"com.makolab.components.inputComponents.SearchItemEditor",label:"SearchItemEditor"},
							{value:"mx.controls.TextArea",label:"TextArea"}
		];
		
	public const dataType:XML=<root><item name="currency"/>
<item name="dictionary"/><item name="string"/><item name="xml"/></root>;
	public const dataField:XML=<root><item name="dataObject"/>
<item name="text"/><item name="data"/></root>;
	public const required:XML=<root><item name="1"/>
	<item name="0"/></root>;
	public const dataSource:XML=<root>
<item name="data.item.attributes"/>
<item name="data.item.vatRateId"/>
<item name="data.item.defaultPrice"/>
<item name="data.item.unitId"/>
<item name="data.item.code"/>
<item name="data.item.name"/>
<item name="data.item.version"/>
<item name="data.item.defaultPrice"/>
<item name="data.item.unitGrossPric"/>
<item name="data.item.itemTypeId"/>
<item name="data"/>
<item name="data.item"/>
<item name="data.item.groupMemberships"/></root>
		
public const dictionaryName:XML=<root>
<item name="itemType"/>
<item name="units"/>
<item name="vatRates"/></root>
		
		
		
		/**
		 * Constructor.
		 */
		public function ComponentEditor()	
		{
				this.setStyle("marginLeft",5);
					this.setStyle("marginRight", 5);
						this.setStyle("marginTop",10);
							this.setStyle("marginBottom", 10);
		}
		/**
		 * Lets you pass a value to the editor.
		 * the <code>data</code> property doesn't change while editing values in editor. The value of <code>data</code> is copied to <code>dataObject</code>. To read modified values use <code>dataObject</code> property.
		 * @see #dataObject
		 */
		public var i,j:int;
		[Bindable]
		override public function set data(value:Object):void
		{
			this.removeAllChildren();
			_data = XML(value);
			
			var lab:Label;
			var vB:VBox;
			var vBP:VBox;
			if(value)	{
				switch(_data.localName())
				{
					case "tab":
						vB=new VBox();
						lab=new Label();
						lab.text=LanguageManager.getInstance().labels.common.label;
						var exT:ExTextInput=new ExTextInput();
						exT.level=1;
						exT.text=_data.@label;
						exT.nodeName="tab";
						exT.attributeName="label";
						exT.attributeValue=_data.@label;
						exT.addEventListener(Event.CHANGE,onInputChange);
						vB.addChild(lab);
						vB.addChild(exT);
						addChild(vB);
						break;
					case "component":
						vB=new VBox();
						vB.percentWidth=100;
						vB.setStyle("border","true");
						lab=new Label();
						lab.text=LanguageManager.getInstance().labels.common.attributes;
						addChild(lab);
						for(var i:int=0;i<_data.attributes().length();i++)
						{
							var ldt:Label=new Label();
							ldt.text=_data.attributes()[i].localName()+":";
							vB.addChild(ldt);
							if(_data.attributes()[i].localName()=="dataType"||
								_data.attributes()[i].localName()=="dataSource"||
								_data.attributes()[i].localName()=="dictionaryName"||
								_data.attributes()[i].localName()=="required"||
								_data.attributes()[i].localName()=="className"||
								_data.attributes()[i].localName()=="dataField")
							{	
								var dt:DictionarySelector=new DictionarySelector();
								dt.width=200;
								dt.valueMapping={ name : '*' };
								dt.labelField="@name";
								switch(_data.attributes()[i].localName())
								{	
									case "dataType":
									dt.dataProvider=dataType.*;
									break;
									case "required":
										dt.dataProvider=required.*;
										break;
									case "className":
										dt.dataProvider=classNames.*;
										break;
									case "dataField":
										dt.dataProvider=dataField.*;
										break;
									case "dataSource":
										dt.dataProvider=dataSource.*;
										break;
									case "dictionaryName":
										dt.dataProvider=dictionaryName.*;
										break;
								}
							
								dt.level=1;
								dt.percentWidth=100;
								dt.selectedItem=<item name={_data.@[_data.attributes()[i].localName()]}/>;
								dt.nodeName = "component";
								dt.idField=_data.attributes()[i].localName();
								
								
								vB.addChild(dt);
								dt.addEventListener(ListEvent.CHANGE,onSelectorChange);
							}
							else
							{
								var ex:ExTextInput=new ExTextInput();
								ex.level=1;
								ex.text=_data.attributes()[i].toString();
								ex.nodeName="component";
								ex.attributeName=_data.attributes()[i].localName();
								ex.attributeValue=_data.attributes()[i].toString();
								ex.addEventListener(Event.CHANGE,onInputChange);
								vB.addChild(ex);
							}
						}
						addChild(vB);
						if(_data.*.length())
						{
							var lab1:Label=new Label();lab1.text=LanguageManager.getInstance().labels.common.parameters;
							addChild(lab1);
							vBP=new VBox();
							vBP.setStyle("PaddingTop",10);
							addChild(vBP);
							
							for(var j:int=0;j<_data.*.length();j++)
							{
								var ldt:Label=new Label();
								ldt.text=_data.*[j].localName()+":";
								vBP.addChild(ldt);
								if(_data.*[j].localName()=="itemEditor"||_data.*[j].localName()=="attributes"||_data.*[j].localName()=="attributeName")
								{	
									var dt:DictionarySelector=new DictionarySelector();
									dt.width=200;
									dt.valueMapping={ name : '*' };
									dt.labelField="@name";
									
									switch(_data.*[j].localName())
									{	
										case "itemEditor":
											dt.dataProvider=itemEditor;
											dt.valueMapping={ value : '*' };
											dt.labelField="label";
											var str:String=_data.*[j].toString();
											var arr:Array=str.split(".");
											dt.selectedItem= {value:str,label:arr[arr.length-1]};
											break;
										case "attributes":
											dt.dataProvider=attributes.*;
											dt.selectedItem=<item name={_data.*[j].toString()}/>;
											break;
										case "attributeName":
											dt.dataProvider=itemFields;
											dt.valueMapping={ name : '*' };
											dt.labelField="name";
											for(var k:int=0;k<itemFields.length();k++)
											{
												if(itemFields[k].name.toString()==_data.*[j].toString())
												{
													dt.selectedItem=itemFields[k];
												}
											}
											break;
										case "dataField":
											dt.dataProvider=dataField.*;
											break;
										case "dataSource":
											dt.dataProvider=dataSource.*;
											break;
										case "dictionaryName":
											dt.dataProvider=dictionaryName.*;
											break;
									}
									
									dt.level=2;
									dt.percentWidth=100;
									dt.nodeName = _data.*[j].localName();
									dt.idField=_data.*[j].localName();
									
									
									vBP.addChild(dt);
									dt.addEventListener(ListEvent.CHANGE,onSelectorChange);
								}
								else if(_data.*[j].localName()=="editorAttributes"||_data.*[j].localName()=="template")
								{
									var exA:ExTextArea=new ExTextArea();
									exA.level=2;
									exA.percentWidth=100;
									exA.height=60;
									exA.text=_data.*[j].*.toString();
									exA.nodeName="component";
									exA.attributeName=_data.*[j].localName();
									exA.attributeValue=_data.*[j].*.toString();
									exA.addEventListener(Event.CHANGE,onInputAreaChange);
									vBP.addChild(exA);
								}
								else
								{
									var ex:ExTextInput=new ExTextInput();
									ex.level=2;
									ex.text=_data.*[j].toString();
									ex.nodeName="component";
									ex.attributeName=_data.*[j].localName();
									ex.attributeValue=_data.*[j].toString();
									ex.addEventListener(Event.CHANGE,onInputChange);
									vBP.addChild(ex);
								}

							}
						}
						
						break;
				
					default:
						t=new TextArea();
						t.percentHeight=t.percentWidth=100;
						
						addChild(t);
						
						t.text=_data.toXMLString();
				}
			}	
			btn=new Button();
			btn.label=LanguageManager.getInstance().labels.common.save;
			btn.width=100;
			addChild(btn);
			btn.addEventListener(MouseEvent.CLICK,onKlik);
			this.verticalScrollPolicy=ScrollPolicy.ON;
		}
		
		/**
		 * @private
		 */
		override public function get data():Object	
		{
			return _data;
		}
		private function onKlik(e:MouseEvent):void
		{
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function onInputChange(e:Event):void
		{
			var ex:ExTextInput=(e.currentTarget as ExTextInput);
			if(ex.level==1)
			{
				data.@[ex.attributeName]=ex.text;
			}
			else if(ex.level==2)
			{
				data[ex.attributeName]=ex.text;
			}
				
		}
		private function onInputAreaChange(e:Event):void
		{
			var ex:ExTextArea=(e.currentTarget as ExTextArea);
			if(ex.level==1)
			{
				data.@[ex.attributeName]=ex.text.toString();
			}
			else if(ex.level==2)
			{
				data[ex.attributeName]=ex.text.toString();
			}
			
		}
		private function onSelectorChange(e:ListEvent):void
		{
			var ex:DictionarySelector=(e.currentTarget as DictionarySelector);
			if(ex.level==1)
			{
				data.@[ex.idField]=ex.label;
			}
			else if(ex.level==2)
			{
				if(ex.idField=="itemEditor")
					data[ex.idField]=ex.selectedItem.value.toString();
				else
					data[ex.idField]=ex.label;
			}
			
		}
		
	}
}