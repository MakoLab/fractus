package com.makolab.fractus.model.document.quickSales
{
	public class CloseDocumentResult
	{
			public static const DOCUMENT_SAVED:int = 0;
			public static const DOCUMENT_ERROR:int = 1;
			
			/**
			 * Wynik operacji zatwierdzenia dokumentu
			 */
			public var operationResult:int;
			
			/**
			 * Ewentualny komunikat błędu.
			 */
			public var errorMessage:String;
		}
}