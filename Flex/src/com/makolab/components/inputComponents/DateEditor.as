package com.makolab.components.inputComponents
{
	import com.makolab.fractus.model.LanguageManager;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.DateField;
	
	import flight.binding.Bind;

	public class DateEditor extends mx.controls.DateField
	{
		[Bindable] public var allowEmptyDate:Boolean = false;
		
		public static const INTERNAL_DATE_FORMAT:String = "YYYY-MM-DD";
		/**
		 * Constructor.
		 * Sets date format, month and day names to polish.
		 */
		public function DateEditor()
		{
			super();
			formatString = INTERNAL_DATE_FORMAT;
			addEventListener(Event.CHANGE, handleChange);
			editable = true;
			width=110;
			
			this.restrict = "0-9\\-";
		//	Bind.addBinding(this, 'monthNames', LanguageManager.getInstance(), 'monthNames'+LanguageManager.getInstance().currentLanguage);
		//	Bind.addBinding(this, 'dayNames', LanguageManager.getInstance(), 'dayNames'+LanguageManager.getInstance().currentLanguage);
			firstDayOfWeek = 1;
			this.monthNames=LanguageManager.getInstance().monthNames;
			this.dayNames=LanguageManager.getInstance().dayNames;
			
			//monthNames=["January", "February", "March", "April", "May","June", "July", "August", "September", "October", "November","December"];
		}
		
		public function set dataObject(value:Object):void
		{
			_dataObject = value;
			if (_dataObject) selectedDate = stringToDate(String(_dataObject).substr(0, 10), INTERNAL_DATE_FORMAT);
			else selectedDate = null;			
		}
		public function get dataObject():Object
		{
			return _dataObject;
		}
		
		private var _dataObject:Object;
		
		private var _data:Object;
		/**
		 * Lets you pass a value to the editor.
		 * @see #dataObject
		 */
		public override function set data(value:Object):void
		{
			_data = value;
			dataObject = DataObjectManager.getDataObject(data, listData);
		}
		/**
		 * @private
		 */
		public override function get data():Object
		{
			return _data;
		}
		
		private function handleChange(event:Event):void
		{
			if (selectedDate) dataObject = dateToString(selectedDate, INTERNAL_DATE_FORMAT);
			else if (!selectedDate && this.text == "") selectedDate = null;
			else selectedDate = stringToDate(String(dataObject), INTERNAL_DATE_FORMAT);
			text = dateToString(selectedDate, INTERNAL_DATE_FORMAT);
		}
		
		public override function set selectedDate(value:Date):void
		{
			super.selectedDate = value;
			var dateStr:String = dateToString(selectedDate, INTERNAL_DATE_FORMAT);
			if (_dataObject != dateStr) dataObject = dateStr;
		}
		/**
		 * Traps ESCAPE key press event.
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
	        if (event.keyCode != Keyboard.ESCAPE) super.keyDownHandler(event);
		}
		
	}
}