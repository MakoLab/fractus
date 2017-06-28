package com.makolab.components.barcode
{
	import flash.events.Event;

	public class BarcodeEvent extends Event
	{
		public static const BARCODE_READ:String = "barcodeRead";
		public static const BARCODE_READ_START:String = "barcodeReadStart";
		public static const ITEMS_FIND:String = "itemsFind";
		public static const ITEM_NOT_FOUND:String = "itemNotFound";
		
		public function BarcodeEvent(type:String, barcode:String = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.barcode = barcode;
		}
		
		public var barcode:String;
		
	}
}