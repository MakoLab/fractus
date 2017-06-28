package com.makolab.fractus.model.document.quickSales
{
	public class OpenDocumentResult
	{
			/**
			 * id dokumentu
			 */
			public var id:String;
			
			/**
			 * numer pełny
			 */
			public var fullNumber:String;
			
			/**
			 * GUID domyślnej formy płatności
			 */
			public var paymentFormId:String;
			
			/**
			 * Tablica 3 GUID-ów dostępnych form płatności
			 */
			public var availablePaymentForms:Array;
			
			/**
			 * GUID typu dokumentu
			 */
			public var documentTypeId:String;
			
			/**
			 * GUID waluty domyślnej
			 */
			public var currencyId:String;
	}
}