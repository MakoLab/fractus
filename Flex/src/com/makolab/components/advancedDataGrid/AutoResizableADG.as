package com.makolab.components.advancedDataGrid
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.AdvancedDataGrid;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;

	public class AutoResizableADG extends AdvancedDataGrid
	{
		private var seperatorsArr:Array = new Array();
		private var _autoSize:Array = new Array();
		
		public function AutoResizableADG()
		{
			super();
			addEventListener(CollectionEvent.COLLECTION_CHANGE, dcHandler);
			//addEventListener("viewChanged", dcHandler);
		}
		
		private function dcHandler(e:Event):void 
		{
			//addEventListener("viewChanged", dcHandler);
			for each (var item:String in _autoSize) {
				//trace(item);
				callLater(columnChangeSize, new Array(seperatorsArr[int(item)]));
			}
		}
		
		override public function set dataProvider(value:Object):void
		{
			super.dataProvider = value;
		}
		
		public function set autoSize(value:String):void {
			_autoSize = value.split(',');
		}
		
		override protected function getSeparator(i:int, seperators:Array, headerLines:UIComponent):UIComponent
		{
			var sep:UIComponent = super.getSeparator(i, seperators, headerLines);
			sep.doubleClickEnabled = true;
			
			DisplayObject(sep).addEventListener(MouseEvent.DOUBLE_CLICK, columnResizeDoubleClickHandler);
			
			seperatorsArr.push(DisplayObject(sep));
			
			return sep;
		}
		
		private function columnResizeDoubleClickHandler(event:MouseEvent):void {
			columnChangeSize(DisplayObject(event.target));
		}
		
		private function columnChangeSize(event:DisplayObject):void
		{
			if (!enabled || !resizableColumns)
				return;
			
			var target:DisplayObject = DisplayObject(event);
			var index:int = target.parent.getChildIndex(target);
			var optimumColumns:Array = getOptimumColumns();
			
			if (!optimumColumns[index].resizable)
				return;
			
			var field:String = optimumColumns[index].dataField;
			var maxWidthT:int = 0;
			var hasWidth:Boolean = false;
			if (optimumColumns[index].width) {
				maxWidthT = (optimumColumns[index].width);
			} else {
				maxWidthT = 20;
			}
			
			//var lineMetrics:TextLineMetrics = measureText("12345");
			for each (var item:Object in dataProvider) 
			{
				if (item[field]) {
					if(measureText(item[field]).width > maxWidthT) {
						maxWidthT = measureText(item[field]).width;
						hasWidth = true;
					}
				}
			}
			
			if(listItems)
			{
				if(listItems[0][index] is IDropInListItemRenderer)
				{
					
					//var temp:IDropInListItemRenderer = IDropInListItemRenderer(listItems[0][index]);
					//var lineMetrics:TextLineMetrics = measureText("12345");
						
					//trace(lineMetrics);
				}
				/*
				var len:int = listItems.length;
				var maxWidth:int = 0;
				for(var i:int=0;i<len;i++)
				{
					if(listItems[i][index] is IDropInListItemRenderer)
					{
						var lineMetrics:TextLineMetrics = measureText(IDropInListItemRenderer(listItems[i][index]).listData.label);
						if(lineMetrics.width > maxWidth)
						maxWidth = lineMetrics.width ;
					}
				}
				trace(maxWidth);
				if (maxWidth == 0) {
					maxWidth = (optimumColumns[index].width);
				}
				*/
			}
			if(hasWidth) {
				optimumColumns[index].width = maxWidthT + getStyle("paddingLeft") + getStyle("paddingRight") + 24;
			} else {
				optimumColumns[index].width = maxWidthT;
			}
		}
	}
}



/*
package com.makolab.components.advancedDataGrid
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextLineMetrics;
	
	import mx.controls.AdvancedDataGrid;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;

	public class AutoResizableADG extends AdvancedDataGrid
	{
		private var seperatorsArr:Array = new Array();
		private var _autoSize:Array = new Array();
		
		public function AutoResizableADG()
		{
			super();
			addEventListener(CollectionEvent.COLLECTION_CHANGE, dcHandler);
			//addEventListener("viewChanged", dcHandler)
		}
		
		private function dcHandler(e:Event):void 
		{
			for each (var item:String in _autoSize) {
				callLater(columnChangeSize, new Array(seperatorsArr[int(item)]));
			}
		}
		
		override public function set dataProvider(value:Object):void
		{
			super.dataProvider = value;
		}
		
		public function set autoSize(value:String):void {
			_autoSize = value.split(',');
		}
		
		override protected function getSeparator(i:int, seperators:Array, headerLines:UIComponent):UIComponent
		{
			var sep:UIComponent = super.getSeparator(i, seperators, headerLines);
			sep.doubleClickEnabled = true;
			
			DisplayObject(sep).addEventListener(MouseEvent.DOUBLE_CLICK, columnResizeDoubleClickHandler);
			
			seperatorsArr.push(DisplayObject(sep));
			
			return sep;
		}
		
		private function columnResizeDoubleClickHandler(event:MouseEvent):void {
			columnChangeSize(DisplayObject(event.target));
		}
		
		private function columnChangeSize(event:DisplayObject):void
		{
			if (!enabled || !resizableColumns)
			return;
			
			var target:DisplayObject = DisplayObject(event);
			var index:int = target.parent.getChildIndex(target);
			var optimumColumns:Array = getOptimumColumns();
			
			if (!optimumColumns[index].resizable)
			return;
			
			if(listItems)
			{
				var len:int = listItems.length;
				var maxWidth:int = 0;
				for(var i:int=0;i<len;i++)
				{
					if(listItems[i][index] is IDropInListItemRenderer)
					{
						var lineMetrics:TextLineMetrics = measureText(IDropInListItemRenderer(listItems[i][index]).listData.label);
						if(lineMetrics.width > maxWidth)
						maxWidth = lineMetrics.width ;
					}
				}
				
				if (maxWidth == 0) {
					maxWidth = (optimumColumns[index].width);
				}
			}
			
			optimumColumns[index].width = maxWidth + getStyle("paddingLeft") + getStyle("paddingRight") + 12;
		}
	}
}

*/