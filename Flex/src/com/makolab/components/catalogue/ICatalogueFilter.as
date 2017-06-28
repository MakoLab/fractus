package com.makolab.components.catalogue
{
	public interface ICatalogueFilter
	{
		function setParameters(parameters:Object):void;
		
		function set config(value:XML):void;
		
		function get config():XML;
		
		function set template(value:XMLList):void;
		
		function clear():void;
		
		function restore():void;
	}
}