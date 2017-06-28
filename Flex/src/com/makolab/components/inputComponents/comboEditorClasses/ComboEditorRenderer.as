package com.makolab.components.inputComponents.comboEditorClasses
{
	import mx.containers.HBox;
	import mx.controls.CheckBox;
	import mx.controls.Label;
	import flash.events.MouseEvent;

	public class ComboEditorRenderer extends HBox
	{
		private var checkBox:CheckBox = new CheckBox();
		private var lbl:Label = new Label();
		
		public function ComboEditorRenderer()
		{
			addChild(checkBox);
			addChild(lbl);
			checkBox.setStyle("marginLeft", 0);
			checkBox.setStyle("marginRight", 0);
			checkBox.selected = true;
			checkBox.enabled = false;
			//checkBox.addEventListener(MouseEvent.CLICK, handleClick);
			setStyle("horizontalGap", 0);
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			var item:ComboEditorItem = value as ComboEditorItem;
			if (item)
			{
				lbl.text = item.label;
				lbl.setStyle("fontWeight", item.isSelected ? "bold" : "normal");
				checkBox.visible = item.isFilled;
			}
		}
	}
}