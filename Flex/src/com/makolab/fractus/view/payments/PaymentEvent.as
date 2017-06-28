package com.makolab.fractus.view.payments
{
	import flash.events.Event;

	public class PaymentEvent extends Event
	{
		public static const PAYMENT_SELECT:String = "paymentSelect";
		
		public var paymentId:String;
		public var documentInfo:String;
		public var unsettledAmount:Number;
		public var amount:Number;
		public var direction:int;
		public var paymentDate:Date;
		public var dueDate:Date;
		
		public function PaymentEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public static function createEvent(type:String):PaymentEvent
		{
			var event:PaymentEvent = new PaymentEvent(type);
			return event;
		}
		
		public function getDocumentNumber():String
		{
			if (!documentInfo) return null;
			var a:Array = documentInfo.split(/;/);
			if (a.length < 2) return documentInfo;
			return a[0] + ' ' + a[1];
		}
	}
}