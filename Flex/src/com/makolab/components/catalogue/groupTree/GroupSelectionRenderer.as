package com.makolab.components.catalogue.groupTree
{
	import flash.events.Event;
	
	import mx.containers.Canvas;
	import mx.controls.CheckBox;
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.controls.treeClasses.TreeListData;

	[Event(name="change",type="flash.events.Event")]
	[Event(name="changeSelection",type="flash.events.Event")]
	public class GroupSelectionRenderer extends TreeItemRenderer
	{
		public var multipleSelection:Boolean = true;
		[Bindable] 	public var branchSelectable:Boolean = false;
		public function GroupSelectionRenderer()
		{
			super();
		}
		
		protected var checkBox:CheckBox;
		
		protected var colorSquare:Canvas;
		
		override protected function createChildren():void
		{
			super.createChildren();
			checkBox = new CheckBox();
			addChildAt(checkBox, 1);
			colorSquare = new Canvas();
			colorSquare.setStyle("backgroundColor","blue");
			colorSquare.setStyle("borderStyle","solid");
			colorSquare.setStyle("borderThickness","2");
			colorSquare.width = 16;
			colorSquare.height = 16;
			addChildAt(colorSquare,2);
			checkBox.addEventListener(Event.CHANGE, changeHandler);
		}
		
		protected function changeHandler(event:Event):void
		{
			if(!branchSelectable)
			{
				event.preventDefault();
				event.stopImmediatePropagation();
				event.stopPropagation();
				CheckBox(event.target).selected = !CheckBox(event.target).selected; 
				return;
			}
			var ld:TreeListData = TreeListData(listData);
			if (!ld.hasChildren)
			{
				if (!multipleSelection)
				{
					for each (var x:XML in XML(TreeListData(listData).owner["dataProvider"].source)..group.(hasOwnProperty('@selected') && @selected == 1))
						x.@selected = 0;
				} 
				data.@selected = CheckBox(event.target).selected ? 1 : 0;
			}
			// set children selection only if multiple selection is enabled or if we want to uncheck the child
			else if (multipleSelection)// || !checkBox.selected) 
			{
				var children:XMLList = XML(data)..group;
				for each (var node:XML in children) {
					if(branchSelectable || node.@selected != undefined) node.@selected = checkBox.selected ? 1 : 0;					
				}
				if(branchSelectable) data.@selected = CheckBox(event.target).selected ? 1 : 0;				
			}
			else if (!multipleSelection)
			{
				// don't let the user change branch nodes state if multiple selection is disabled 
				data = data;
			}
			dispatchEvent(new Event("change"));
			dispatchEvent(new Event("changeSelection",true));
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			checkBox.x = label.x + 1;
			checkBox.y = unscaledHeight / 2;
			label.x = label.x + checkBox.measuredWidth + 2;
			//colorSquare.x = label.x + label.measuredWidth + 2;
			colorSquare.x = unscaledWidth - colorSquare.measuredWidth - 20;
			colorSquare.y = unscaledHeight / 2 - 8;
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			var node:XML = XML(value);
			var gray:Boolean = false;
			var selected:Boolean = false;
			//if (node.@selected == undefined)
			if (node.@selected == undefined || node.@selected == '' || node.@selected == null || node.@selected == 0 || node.@selected == "0")
			{
				var children:XMLList = node..group;
				var allSelected:Boolean = true;
				var oneSelected:Boolean = false;
				if (children.length() == 0) allSelected = false;
				for each (var x:XML in children)
				{
					if (x.@selected != undefined)
					{
						if (x.@selected == 1) {
							oneSelected = true;
						} else {
							allSelected = false;
						}
					}
				}
				selected = oneSelected;
				gray = !allSelected && oneSelected;
			} else {
				selected = (node.@selected == 1);
				children = node..group;
				allSelected = true;
				oneSelected = false;
				var noneSelected:Boolean = true;
				if (children.length() == 0) {
					allSelected = false;
					noneSelected = false;
				}
				for each (x in children)
				{
					if (x.@selected != undefined)
					{
						if (x.@selected == 1) {
							oneSelected = true;
							noneSelected = false;
						} else {
							allSelected = false;
						}
					}
				}
				gray = !allSelected && oneSelected;
				if(noneSelected) {
					gray = false;
					selected = false;
				}
			}
			if (checkBox)
			{
				checkBox.alpha = gray && multipleSelection ? 0.5 : 1.0;
				checkBox.selected = selected;
				if(data) {
					if(selected) {
						 data.@selected = 1;
					} else {
						 data.@selected = 0;
					}
				}
				// if multiple selection is disabled enable checkboxes only in the leaves
				checkBox.enabled = multipleSelection || !TreeListData(listData).hasChildren;
			}
			if(colorSquare){
				var xmlList:XMLList = node.attributes.attribute.(valueOf().@name == "color");
				if(xmlList.length() > 0 && xmlList[0].toString() != ""){
					colorSquare.visible = true;
					colorSquare.setStyle("backgroundColor",xmlList.toString());
				}else{
					colorSquare.visible = false;
				}
			}
			//dispatchEvent(new Event("change"));
		}
	}
}