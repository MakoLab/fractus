package com.makolab.fractus.business.fiscalPrint
{
	public interface IFiscalPrinterApi
	{
		function calculateBinaryBytes(value:uint):Array;
		
		function calculateBytes(value:uint):String;
		
		function checkErrors():void;
		
		function convertChars(word:String):String;
		
		function prepareSalePositions(salePositionTable:Array):Array;
		
		function printBill(bill:XMLList):void;
		
		function processConfigXML():String;
		
		function processBillXML(bill:XMLList):void;
		
	}
}
