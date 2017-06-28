package com.makolab.fractus.model.document.quickSales
{
	import mx.collections.ArrayCollection;	

	public interface IQuickSalesProxy
	{
	 	/**
	 	 * Funkcja powodująca utworzenie dokumentu, co umożliwia dalsze jego wystawianie. W asynchronicznej
	 	 * odpowiedzi zwraca właściwości dokumentu takie jak id, numer, waluta itp.
	 	 * 
	 	 * @param callback Referencja do funkcji przyjmującej jako argument obiekt klasy <code>OpenDocumentResult</code>
	 	 * 
	 	 * @see com.makolab.fractus.model.document.quickSales.OpenDocumentResult
	 	 */
		function openDocument(callback:Function):void;
		
		/**
		 * Funkcja dodaje do dokumentu nową pozycję na podstawie kodu paskowego. Asynchronicznie zwraca
		 * wynik dodania pozycji, określający, czy operacja się powiodła. Oraz dane dodanego towaru.
		 * 
		 * @param code Kod paskowy dodawanego towaru
		 * @param quantity Ilość na pozycji
		 * @param callback Referencja do funkcji przyjmującej obiekt klasy <code>AddItemByCodeResult</code>
		 * 
		 * @see com.makolab.fractus.model.document.quickSales.AddItemByCodeResult
		 */
		function addItemByCode(code:String, quantity:Number, callback:Function):void;
		
		/**
		 * Funkcja zdejmuje z dokumentu wskazaną przez id pozycję. Asynchronicznie zwraca
		 * wynik zdjęcia pozycji, określający, czy operacja się powiodła.
		 * 
		 * @param lineId id pozycji zdejmowanego towaru
		 * 
		 * @ Boolean: true - operacja się powiodła, false - operacja się nie powiodła
		 */
		function removeLineById(lineId:String, callback:Function):void;
		
		/**
		 * Zamknięcie (zatwierdzenie) dokumentu.
		 * 
		 * @param paymentFormId GUID wybranej formy płatności
		 * @param documentId Identyfikator dokumentu zwrócony wcześniej przez metodę <code>openDocument</code>.
		 * @param callback Referencja do funkcji przyjmującej obiekt klasy <code>CloseDocumentResult</code>.
		 * 
		 * @see com.makolab.fractus.model.document.quickSales.CloseDocumentResult
		 */
		function closeDocument(paymentFormId:String, documentId:String, callback:Function):void;
		
		function addAttribute(attributeName:String, attributeValue:Object):void;
		
		function calculateDiscount(discountValue:Number):ArrayCollection;
		
		function getDocumentValue():Number;
	}
}