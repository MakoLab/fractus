package com.makolab.fractus.view.payments
{
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.commands.GetPaymentsCommand;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.view.documents.documentControls.InfoLinkButton;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.PopUpButton;
	import mx.events.DropdownEvent;
	import mx.events.ListEvent;

	[Event(name="paymentSelect", type="com.makolab.fractus.view.payments.PaymentEvent")]
	public class PaymentPopUp extends PopUpButton
	{
		public var contractorId:String;
		
		/**
		 * 1 - incomes
		 * -1 - outcomes
		 * 0 - both
		 */
		public var direction:int = 0;
		
		private var _currencyId:String;
		public function set currencyId(value:String):void
		{
			_currencyId = value;
		}
		public function get currencyId():String
		{
			return _currencyId;
		}
		
		public var showSettled:Boolean = false;
		
		public function PaymentPopUp()
		{
			super();
			this.addEventListener(DropdownEvent.OPEN, openHandler);
			this.openAlways = true;
			//LanguageManager.bindLabel(this, 'label', 'finance.selectPayment');
			BindingUtils.bindProperty(this,"label",LanguageManager.getInstance(),["labels","finance","selectPayment"]);
			this.popUp = new PaymentGrid();
			this.popUp.width = 700;
			this.popUp.height = 200;
			this.popUp.addEventListener(ListEvent.ITEM_CLICK, itemClickHandler);
		}
		
		protected function openHandler(event:DropdownEvent):void
		{
			loadData();
		}
		
		protected function itemClickHandler(event:ListEvent):void
		{
			if(!(event.itemRenderer is InfoLinkButton))
			{
				var item:XML = event.itemRenderer.data as XML;
				var paymentEvent:PaymentEvent = PaymentEvent.createEvent(PaymentEvent.PAYMENT_SELECT);
				paymentEvent.paymentId = item.@id;
				paymentEvent.unsettledAmount = parseFloat(item.@unsettledAmount);
				paymentEvent.amount = parseFloat(item.@amount);
				paymentEvent.documentInfo = item.@documentInfo;
				paymentEvent.dueDate = Tools.isoToDate(item.@dueDate);
				paymentEvent.paymentDate = Tools.isoToDate(item.@date);
				paymentEvent.direction = parseInt(item.@direction);
				dispatchEvent(paymentEvent);
			}
		}
		
		protected function loadData():void
		{
			var params:XML = <params/>;
			if (direction != 0) params.direction = this.direction;
			if (contractorId) params.contractorId = this.contractorId;
			if (currencyId) params.paymentCurrencyId = this.currencyId;
			if (!showSettled) params.settled = 0;
			var cmd:GetPaymentsCommand = new GetPaymentsCommand(params);
			cmd.execute(setPayments);
		}
		
		protected function setPayments(result:XML):void
		{
			for each(var payment:XML in result.payment)
			{
				payment.@currencySymbol = DictionaryManager.getInstance().getById(payment.@currencyId).symbol;					
			}
			
			PaymentGrid(this.popUp).dataProvider = result.*;
			
		}
	}
}