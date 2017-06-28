package com.makolab.components.inputComponents.comboEditorClasses
{
	public class ComboEditorItem
	{
		public var label:String;
		public var dataProvider:Object;
		public var dataField:String;
		public var isDefault:Boolean = false;
		public var isSelected:Boolean = false;
		public var isFilled:Boolean = false;		
		
		public function ComboEditorItem(label:String = null, dataProvider:Object = null, dataField:String = null, isDefault:Boolean = false)
		{
			this.label = label;
			this.dataProvider = dataProvider;
			this.dataField = dataField;
			this.isDefault = isDefault;
		}
	}
}