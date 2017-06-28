package com.makolab.components.inputComponents
{
	import com.makolab.components.util.Tools;
	
	import mx.controls.DateField;
	import mx.controls.Label;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;

	public class DateRenderer extends Label implements IDropInListItemRenderer
	{
		/**
		 * Date format.
		 */
		public var formatString:String = "DD/MM/YYYY"; 
		
		/**
		 * An array of month names. Starts from january.
		 */
		public var monthNames:Array = [
			"stycznia",
			"lutego",
			"marca",
			"kwietnia",
			"maja",
			"czerwca",
			"lipca",
			"sierpnia",
			"września",
			"października",
			"listopada",
			"grudnia"
		];
		
		public var displayTime:Boolean = false;
		private var _listData:BaseListData;
		
		private var _dataObject:Object;
		/**
		 * WTF?
		 */
		public var columnIdent:String;
		/**
		 * Lets you pass a value to the renderer.
		 * @see #data
		 */
		[Bindable]
		public function set dataObject(value:Object):void
		{
			_dataObject = value;
			var date:Date = null;
			if (value is Date)
			{
				date = value as Date;
				value = Tools.dateToIso(date);
			}
			else if (value)
			{
				value = String(value);
				date = Tools.isoToDate(value as String);
			}
			if (date && !isNaN(date.time))
			{
				toolTip =
					mx.controls.DateField.dateToString(date, "DD-MM-YYYY").replace(/(\d+)-(\d+)-(\d+)/, replaceMonth) +
					"\n" + value.substr(11, 5);
				text = displayTime ? value.replace(/T([0-9:]*).*/, ' $1') : value.substr(0, 10);
			}
			else toolTip = text = null;
		}
		/**
		 * @private
		 */
		public function get dataObject():Object { return _dataObject; }
		/**
		 * Lets you pass a value to the renderer.
		 * @see #dataObject
		 */
		public override function set data(value:Object):void
		{
			super.data = value;
			dataObject = "";//dodane ze względu na to, że dataObject nie chce się przeładować jeśli podstawia się tam null i zachodzi zjawisko wyświetlania wtedy zawartości super.data w tym polu
			dataObject = DataObjectManager.getDataObject(data, _listData);
		}
		
		private function replaceMonth(str:String, d:String, m:String, y:String, offset:int, s:String):String
		{
			return parseInt(d, 10) + " " + monthNames[parseInt(m, 10) - 1] + " " + y;
		}
		
		override public function set listData(value:BaseListData):void
		{
			_listData = value;
			dataObject = DataObjectManager.getDataObject(data, listData);
		}
		
		override public function get listData():BaseListData
		{
			return _listData
		}
		
		public static function getTextValue(item:Object,dataField:String):String
		{
			return item[dataField].toString().substr(0, 10);
			//return item[dataField].replace(/T([0-9:]*).*/, ' $1');
		}
	}
}