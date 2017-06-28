package com.makolab.components.inputComponents
{
	import mx.controls.TextInput;
	import flash.events.Event;

	public class TestEditor extends TextInput implements IDataObjectComponent
	{
		/**
		 * obiekt do przechowywania danych
		 */		
		private var _dataObject:Object;
		/**
		 * getter i setter dla property dataObject
		 */
		[Bindable]
		public function get dataObject():Object { return _dataObject; }
		public function set dataObject(value:Object):void { _dataObject = value; }
		/**
		 * przeciążony setter korzystający z DataComponentManager
		 */
		public override function set data(value:Object):void
		{
			super.data = value;
			DataObjectComponentManager.updateComponent(this);
		}		
		/**
		 * Funkcja odpowiedzialna za wizualizację przypisanego obiektu danych
		 */
		public function displayData():void { text = _dataObject.toString(); }		
		/**
		 * Handler odpowiedzialny za aktualizacje obiektu danych
		 */
		private function handleChange(event:Event):void
		{
			_dataObject.dupa.@a = text;
		}
		/**
		 * Konstruktor przypisujacy handler do zdarzenia
		 */
		public function TestEditor()
		{
			addEventListener(Event.CHANGE, handleChange);
		}

		
		
	}
}