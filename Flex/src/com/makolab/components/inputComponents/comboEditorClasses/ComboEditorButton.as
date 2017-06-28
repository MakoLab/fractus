package com.makolab.components.inputComponents.comboEditorClasses
{
	import mx.controls.Button;
	import mx.controls.ComboBox;
	import mx.controls.ComboBase;
	import flash.events.MouseEvent;

	public class ComboEditorButton extends Button
	{
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			graphics.beginFill(0x000000, 1.0);
			var cx:int = unscaledWidth / 2, cy:int = unscaledHeight / 2;
			graphics.moveTo(cx - 4, cy - 3);
			graphics.lineTo(cx + 4, cy - 3);
			graphics.lineTo(cx, cy + 3);
			graphics.endFill();
		}
	}
}