package com.makolab.components.inputComponents
{
	import mx.controls.RadioButton;

	public class RadioButtonEditor extends RadioButton implements IDataObjectComponent
	{
		public function RadioButtonEditor()
		{
			super();
		}
		
		public function set dataObject(value:Object):void
		{
			selected = (String(value) == String(this.value));
		}
		public function get dataObject():Object
		{
			return selected ? String(value) : null;
		}
	}
}