package com.makolab.components.lineList
{
	import mx.controls.DataGrid;
	
	public interface ILineOperation
	{
		function invoke():void;
		
		function set dataGrid(value:DataGrid):void;
		function get dataGrid():DataGrid;
		
		function set line(value:Object):void;
		function get line():Object;
	}
}