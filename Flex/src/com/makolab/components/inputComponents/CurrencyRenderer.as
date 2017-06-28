package com.makolab.components.inputComponents
{
	import com.makolab.components.util.CurrencyManager;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.ModelLocator;
	
	import mx.controls.Label;

	public class CurrencyRenderer extends Label
	{
		public var columnIdent:String;
		/**
		 * Constructor
		 */
		public function CurrencyRenderer()
		{
			setStyle("textAlign", "right");
		}
		
		private var systemCurrencyId:String = ModelLocator.getInstance().systemCurrencyId;
		
		public var zeroText:String = null;
		public var nanText:String = '-';
		
		public var postfix:String = "";
		
		public var precision:int =2;// -6;
		
		private var _currencyId:String;
		public function set currencyId(value:String):void
		{
			_currencyId = value;
			updateText();
		}
		public function get currencyId():String
		{
			return _currencyId;
		}
		
		private var _showCurrency:String;
		public function set showCurrency(value:String):void
		{
			_showCurrency = value;
			
		}
		public function get showCurrency():String
		{
			return _showCurrency;
		}
		
		private var _value:Number;
		public function set value(value:Number):void
		{
			this._value = value;
			updateText();
		}
		public function get value():Number
		{
			return _value;
		}
		
		/**
		 * Lets you pass a value to the control.
		 */
		public override function set data(value:Object):void
		{
			super.data = value;
			var val:Object = DataObjectManager.getDataObject(data, listData);
			this.value = (val is Number) ? Number(val) : parseFloat(String(val));
			
			if(showCurrency) 
			{
				currencyId = data.@documentCurrencyId;
				
			}
		}
		
		protected function updateText():void
		{
			if (isNaN(value)) text = nanText;
			else if (showCurrency == "all")
			{
				text = CurrencyManager.formatCurrency(value, nanText, zeroText, precision) +
					(currencyId ? ' ' + DictionaryManager.getInstance().getById(currencyId).symbol : '') +
					(postfix ? postfix : '');
			}
			else if (showCurrency == "notSystem")
			{
				if(systemCurrencyId != currencyId)
				{
					text = CurrencyManager.formatCurrency(value, nanText, zeroText, precision) +
					(currencyId ? ' ' + DictionaryManager.getInstance().getById(currencyId).symbol : '') +
					(postfix ? postfix : '');
				}
				else 
				{
					text = CurrencyManager.formatCurrency(value, nanText, zeroText, precision) +
					(postfix ? postfix : '');
				}
			}
			else if (showCurrency == "none")
			{
				text = CurrencyManager.formatCurrency(value, nanText, zeroText, precision);
			}
			else
			{
				text = CurrencyManager.formatCurrency(value, nanText, zeroText, precision) +
					(currencyId ? ' ' + DictionaryManager.getInstance().getById(currencyId).symbol : '') +
					(postfix ? postfix : '');
			}
		}
	}
}