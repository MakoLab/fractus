package com.makolab.components.list
{
	import com.makolab.components.inputComponents.CheckBoxListItemRenderer;
	
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;

	public class CheckBoxColumn extends DataGridColumn
	{
		public function CheckBoxColumn(columnName:String=null, visibilityFunction:Function = null)
		{
			super(columnName);
			
			var itemRendererFactory:ClassFactory = new ClassFactory(CheckBoxListItemRenderer);
			itemRendererFactory.properties = {dataField : columnName, visibilityFunction : visibilityFunction};
			itemRenderer = itemRendererFactory;
			
			var headerRendererFactory:ClassFactory = new ClassFactory(DataGridCheckBoxHeader);
			headerRenderer = headerRendererFactory;
			
			width = 30;
		}
	}
}