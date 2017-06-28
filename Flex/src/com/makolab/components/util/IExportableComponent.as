package com.makolab.components.util
{
	public interface IExportableComponent
	{
		function exportXml(target:String):XML;
		function exportXmlAll(target:String):XML;
		function showExportDialog():void;
	}
}