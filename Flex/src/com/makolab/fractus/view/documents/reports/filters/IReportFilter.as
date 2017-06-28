package com.makolab.fractus.view.documents.reports.filters
{
	public interface IReportFilter
	{
		function get validationError():String;
		function set parameters(value:XML):void;
		function get parameters():XML;
		function get stringValue():String;
	}
}