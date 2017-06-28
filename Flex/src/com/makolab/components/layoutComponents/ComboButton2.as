package com.makolab.components.layoutComponents
{
	import mx.controls.Button;

	public class ComboButton2 extends Button
	{
		public function ComboButton2()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			graphics.clear();
			graphics.beginFill(0x000000, 1.0);
			var cx:int = unscaledWidth / 2, cy:int = unscaledHeight / 2;
			graphics.moveTo(cx - 4, cy - 3);
			graphics.lineTo(cx + 4, cy - 3);
			graphics.lineTo(cx, cy + 3);
			graphics.endFill();
		}
		
	}
}