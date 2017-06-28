package com.makolab.fractus.model.document.quickSales
{
	public class AddItemByCodeResult
	{

		public static const ITEM_COMMITED:int = 0;
		public static const ITEM_ERROR:int = 2;
		public static const CODE_NOT_FOUND:int = 1;
		
		/**
		 * Nazwa fiskalna towaru.
		 */
		public var name:String;
		
		/**
		 * Kod towaru.
		 */
		public var code:String;
		
		/**
		 * Cena jednostkowa brutto.
		 */
		public var unitGrossPrice:Number;
		
		/**
		 * GUID stawki VAT.
		 */
		public var vatRateId:String;
		
		/**
		 * GUID jednostki miary.
		 */
		public var unitId:String;
		
		/**
		 * id linii towaru.
		 */
		public var lineId:String;
		
		/**
		 * Wynik operacji, przyjmujący wartość <code>ITEM_COMMITED</code>, <code>ITEM_ERROR</code, <code>CODE_NOT_FOUND</code>.
		 */
		public var operationResult:int;
		
		/**
		 * Informacje dotyczące towaru (ewentualnie powód niepowodzenia).
		 */
		public var message:String;

	}
}