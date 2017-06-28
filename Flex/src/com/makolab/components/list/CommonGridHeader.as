package com.makolab.components.list
{
	import flash.display.DisplayObject;
	
	import mx.controls.dataGridClasses.DataGridHeader;

	public class CommonGridHeader extends DataGridHeader
	{
		public function CommonGridHeader()
		{
			super();
		}
		
		protected var sortArrow:DisplayObject;
		
		public function showSortArrow():void
		{
			var sortArrowClass:Class = getStyle("sortArrowSkin");
			sortArrow = DisplayObject(new sortArrowClass());
			addChild(sortArrow);
		}
		
		public function hideSortArrow():void
		{
			
		}
		
	}
}