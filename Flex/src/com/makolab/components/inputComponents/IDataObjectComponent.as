package com.makolab.components.inputComponents
{
	import mx.core.IDataRenderer;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.controls.listClasses.IDropInListItemRenderer;
	
	public interface IDataObjectComponent extends IDataRenderer, IListItemRenderer, IDropInListItemRenderer
	{
		function set dataObject(value:Object):void;
		function get dataObject():Object;
	}
}