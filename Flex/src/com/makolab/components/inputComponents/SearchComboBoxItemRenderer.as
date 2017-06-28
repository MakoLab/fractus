package com.makolab.components.inputComponents
{
	import mx.controls.listClasses.ListItemRenderer;
	import mx.controls.listClasses.BaseListData;
	import mx.effects.Resize;

	public class SearchComboBoxItemRenderer extends ListItemRenderer
	{
		private var _listData:BaseListData;
		
		public var filterArray:Array;
		
		private var lbl:String;
		
		/*
		public override function set listData(value:BaseListData):void
		{
			_listData = value;
			var lbl:String = value.label;
			if (filterArray) for (var i:String in filterArray) lbl = lbl.replace(filterArray[i], "<b>" + filterArray[i].source + "</b>");
			label.htmlText = lbl;
		}
		public override function get listData():BaseListData
		{
			return _listData;
		}
		*/
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			lbl = label.text;
			if (filterArray) for (var i:String in filterArray) lbl.toUpperCase().replace(filterArray[i], lambdaFunction);
			label.htmlText = lbl;
			mx.effects.Resize
		}
		
		private function lambdaFunction(str:String, pos:int, s:String):void
		{
			var len:int = str.length;
			lbl = lbl.substr(0, pos) + "<b>" + lbl.substr(pos, len) + "</b>" + lbl.substr(pos + len);
		}
	}
}