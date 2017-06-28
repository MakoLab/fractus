package com.makolab.components.catalogue.groupTree
{
	import flash.events.Event;
	import flight.binding.Bind;
	import mx.containers.Canvas;
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.controls.treeClasses.TreeListData;

	public class GroupRenderer extends TreeItemRenderer
	{
		public function GroupRenderer()
		{
			super();
		}

		protected var colorSquare:Canvas;
		
		override protected function createChildren():void
		{
			super.createChildren();
			//getChildAt(0).percentWidth = 100;
			colorSquare = new Canvas();
			colorSquare.setStyle("backgroundColor","blue");
			colorSquare.setStyle("borderStyle","solid");
			colorSquare.setStyle("borderThickness","2");
			colorSquare.width = 16;
			colorSquare.height = 16;
			addChildAt(colorSquare, 1);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			colorSquare.x = unscaledWidth - colorSquare.measuredWidth - 20;
			colorSquare.y = unscaledHeight / 2 - 8;
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			var node:XML = XML(value);
			
			if(colorSquare){
				var xmlList:XMLList = node.attributes.attribute.(valueOf().@name == "color");
				if(xmlList.length() > 0 && xmlList[0].toString() != ""){
					colorSquare.visible = true;
					colorSquare.setStyle("backgroundColor",xmlList.toString());
				}else{
					colorSquare.visible = false;
				}
			}
		}
	}
}