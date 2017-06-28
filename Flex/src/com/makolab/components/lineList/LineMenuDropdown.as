package com.makolab.components.lineList
{
	import mx.containers.VBox;

	public class LineMenuDropdown extends VBox
	{
		private var _top:int = 0;
		private var _right:int = 0;
		
		public function set top(value:int):void
		{
			_top = value;
			y = _top;
		}
		
		public function set right(value:int):void
		{
			_right = value;
			x = _right - measuredWidth;
		}
		
		override protected function measure():void
		{
			super.measure();
			x = _right - measuredWidth;
			y = _top;
		}
	}
}