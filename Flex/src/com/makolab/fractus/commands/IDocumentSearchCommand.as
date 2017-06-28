package com.makolab.fractus.commands
{
	public interface IDocumentSearchCommand
	{
		
		function setDateSpan(dateFrom:Date,dateTo:Date):void
		
		function setDocumentTypes(id:String):void
		
		function setProcedureTypes(id:String):void
	}
}