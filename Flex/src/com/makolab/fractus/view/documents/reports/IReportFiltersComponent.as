package com.makolab.fractus.view.documents.reports
{
	public interface IReportFiltersComponent
	{
		function get errors():Array;
		function set customFilters(filters:Array):void;
		function get customFilters():Array;
	}
}