package com.makolab.fractus.view.diagnostics
{
	import com.makolab.components.inputComponents.DictionarySelector;
	import com.makolab.components.inputComponents.ExTextArea;
	import com.makolab.components.inputComponents.ExTextInput;
	import com.makolab.components.inputComponents.ExValInput;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import mx.containers.HBox;
	import mx.containers.HDividedBox;
	import mx.containers.VBox;
	import mx.containers.VDividedBox;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.ButtonBar;
	import mx.controls.Label;
	import mx.controls.TextArea;
	import mx.controls.Tree;
	import mx.events.ItemClickEvent;
	import mx.events.ListEvent;
	import mx.validators.StringValidator;
	import mx.validators.Validator;
	
	import assets.IconManager;

	public class ConfigurationXmlEditor extends VBox
	{
		private var _data:Object;
		public var error:Boolean;
		private var left:VBox;
		private var right:VBox;
		private var tr:Tree;
		private var tabs:Array;
		private var currI:int=-1;
		private var currJ:int=-1;
		private var ce:ComponentEditor;
		private var bb:ButtonBar;
		/**
		 * Lets you pass a value to the editor.
		 * @see #data
		 */
		[Bindable]
		public var dataObject:Object;
		/**
		 * Constructor.
		 */
		private var dp:Array =
			[{id:"addBranchBtn",
				name:"addBranchBtn",
				toolTip:LanguageManager.getInstance().labels.diagnostics.components.addTab,
				icon:IconManager.getIcon('group_add_small')},
				
				{
					id:"addLeafBtn",
					name:"addLeafBtn",
					toolTip:LanguageManager.getInstance().labels.diagnostics.components.addComponentDataType,
					icon:IconManager.getIcon('group_addSubgroup_small')},
				{
					id:"addLeafBtn1",
					name:"addLeafBtn1",
					toolTip:LanguageManager.getInstance().labels.diagnostics.components.addComponentClass,
					icon:IconManager.getIcon('group_addSubgroup_small')},
				
				{	id:"rmvElementBtn",
					name:"rmvElementBtn",
					toolTip:LanguageManager.getInstance().labels.diagnostics.components.remElement,
					icon:IconManager.getIcon('group_remove_small')}];
		
		public function ConfigurationXmlEditor()	
		{
			bb=new ButtonBar();
			bb.styleName="groupsConfigurationButton";
			bb.percentWidth=100;
			bb.addEventListener(ItemClickEvent.ITEM_CLICK, buttonBarClickHandler);
			bb.dataProvider=dp;
			left=new VBox();
			right=new VBox();
			//var vdb:VDividedBox=new VDividedBox();
			var hdb:HDividedBox=new HDividedBox();
//			vdb.setStyle("width","100%");
//			vdb.setStyle("height","100%");
//			vdb.setStyle("borderColor","#7BAFE5");
//			vdb.setStyle("horizontalAlign","left");
//			vdb.setStyle("verticalAlign","middle")
//				
			hdb.percentWidth=100
			hdb.percentHeight=100;
			hdb.setStyle("borderColor","#7BAFE5");
			hdb.setStyle("horizontalAlign","left");
			hdb.setStyle("verticalAlign","middle")
			
			left.percentWidth=40
			left.percentHeight=100;
			left.setStyle("borderColor","#7BAFE5");
			left.setStyle("horizontalAlign","left");
			left.setStyle("verticalAlign","bottom")
			right.percentWidth=60
			right.percentHeight=100;
			right.setStyle("borderColor","#7BAFE5");
			right.setStyle("horizontalAlign","right");
			right.setStyle("verticalAlign","bottom");
			addChild(hdb);
			
			hdb.addChild(left);
			hdb.addChild(right);
		
			tr=new Tree();
			left.addChild(bb);
			left.addChild(tr);
			
			tr.labelField="@label";
			tr.percentHeight=100;
			tr.percentWidth=100;
			tr.addEventListener(ListEvent.ITEM_CLICK,onKlik);
			ce=new ComponentEditor();
			ce.addEventListener(Event.CHANGE,changeHandler);
			ce.percentWidth=90
			ce.height=400;
			right.addChild(ce);
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
				dataObject=createData();
				tr.dataProvider=dataObject;
			}			
		}
		private function buttonBarClickHandler(eventObj:ItemClickEvent):void
		{
			var question:Boolean = false;
			currI=-1;
			currJ=-1;
			if(tr.selectedItem)
			if(tr.selectedItem.@j.length())
			{
				currI=tr.selectedItem.@i;
				currJ=tr.selectedItem.@j;
			}
			else
			{
				currI=tr.selectedItem.@i;
				currJ=-1;
				
			}
			switch(eventObj.item.name){
				case 'addBranchBtn':
					var str:String="label"+String(Math.random()*100).slice(0,3);
					_data.*.*.appendChild(<tab label={str}></tab>)
					dataObject=createData();
					tr.dataProvider=dataObject;
					currI=data.*.*.tab.length()-1;
					ce.data=tabs[currI];
					tr.selectable=true;
					tr.setFocus();
					
					
					setTimeout(function(){
					//tr.expandItem(tr.dataProvider[currI],true);
					tr.selectedIndex=currI;
					tr.selectedItem=tr.dataProvider[currI];
					},300);
				
			
					break;
				case 'addLeafBtn':
					if(currI>-1)
					{
						_data.*.*.tab[currI].appendChild(<component dataType="dictionary" dataSource="data.item.itemTypeId" label="" dictionaryName="itemTypes" required="1"/>)
						dataObject=createData();
						tr.dataProvider=dataObject;
						currJ=_data.*.*.tab[currI].component.length()-1;
						tr.selectedIndex=currI;
						
						ce.data=tabs[currI].component[currJ];
						setTimeout(function(){
							tr.expandItem(tr.dataProvider[currI],true);
							tr.selectedIndex=currJ;
							tr.selectedItem=tr.dataProvider[currI].component[currJ];
						},300);
						
					}else
						Alert.show(LanguageManager.getInstance().labels.common.chooseRootNode,LanguageManager.getInstance().labels.alert.alert);
					
				break;
				case 'addLeafBtn1':
					if(currI>-1)
					{
						_data.*.*.tab[currI].appendChild(<component className="com.makolab.components.inputComponents.AttributeEditor" dataField="dataObject" dataSource="data.item.attributes">
<label></label>
<itemEditor>com.makolab.components.inputComponents.GenericAttributeEditorComponent</itemEditor>
<attributeIdField>itemFieldId</attributeIdField>
<template>
<attribute/>
</template>
<attributes></attributes>
</component>)
						dataObject=createData();
						tr.dataProvider=dataObject;
						currJ=_data.*.*.tab[currI].component.length()-1;
						tr.selectedIndex=currI;
						
						ce.data=tabs[currI].component[currJ];
						setTimeout(function(){
							tr.expandItem(tr.dataProvider[currI],true);
							tr.selectedIndex=currJ;
							tr.selectedItem=tr.dataProvider[currI].component[currJ];
						},300);
					}else
						Alert.show(LanguageManager.getInstance().labels.common.chooseRootNode,LanguageManager.getInstance().labels.alert.alert);
					
					break;
				case 'rmvElementBtn':
					if(tr.selectedItem)
					{
						if(currJ>=0)
						{
							delete _data.*.*.tab[currI].component[currJ];
						}
						else
						{
							delete _data.*.*.tab[currI];
						}
						dataObject=createData();
						tr.dataProvider=dataObject;
						currI=currJ=-1;
						tr.selectedIndex=-1;
						
					}
					break;
				
			}
		}
		private function onKlik(e:ListEvent):void
		{
			if(tr.selectedItem.@j.length())
			{
				currI=tr.selectedItem.@i;
				currJ=tr.selectedItem.@j;
				ce.data=tabs[currI].component[currJ];
			}
			else
			{
				currI=tr.selectedItem.@i;
				currJ=-1;
				ce.data=tabs[currI];
			}
			
		}
		private function createData():XMLList{
			var xml:XMLList=new XMLList();
			
			tabs=new Array();
			var _tab:XMLList=data.*.*.tab;
			for(var i:int=0;i<_tab.length();i++)
			{
				tabs.push(_tab[i]);
				
				xml[xml.length()]=<tab label={_tab[i].@label} i={i} ></tab>
				for(var j:int=0;j<_tab[i].component.length();j++)
				{
					xml[xml.length()-1].appendChild(<component label="component" i={i} j={j}></component>);
				}
			}
			
			return xml;
		}
		/**
		 * @private
		 */
		override public function get data():Object	
		{
			return _data;
		}
		
		
		private function changeHandler(event:Event):void	
		{
			if(tr.selectedItem)
			{
				var str:String=ce.data.toString();
				var myPatern1:RegExp = /&lt;/gi; 
				var myPatern2:RegExp = /&gt;/gi; 
				str=str.replace(myPatern1,"<");
				str=str.replace(myPatern2,">");
				
				if(tr.selectedItem.@j.length())
			
				{
					currI=tr.selectedItem.@i;
					currJ=tr.selectedItem.@j;
					_data.*.*.tab[currI].component[currJ]=XML(str);
				}
				else
				{
					currI=tr.selectedItem.@i;
					currJ=-1;
					_data.*.*.tab[currI]=XML(str);
				}
				createData();
				dispatchEvent(new Event(Event.CHANGE));
			}
			else
			{
				Alert.show(LanguageManager.getInstance().labels.common.chooseRootNode,LanguageManager.getInstance().labels.alert.alert);
			}
		}
	}
}