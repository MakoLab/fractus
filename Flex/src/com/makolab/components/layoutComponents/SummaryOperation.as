package com.makolab.components.layoutComponents
{
	import mx.collections.XMLListCollection;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	
	public class SummaryOperation
	{
		public function SummaryOperation()
		{
		}
		
		public static const CUSTOM:int = 0;
		public static const SUM:int = 1;
		
		public var type:int = 1;
		public var customFunction:Function = null;
		
		private var _columns:Array = [];
		[Bindable]
		public function set columns(value:Array):void
		{
			_columns = value;
		}
		public function get columns():Array
		{
			return _columns;
		}
		
		private var _source:XMLList;
		[Bindable]
		public function set source(value:XMLList):void
		{
			_source = value;
		}
		public function get source():XMLList
		{
			return _source;
		}
		
		public function get result():XML
		{
			var ret:XML;
			switch(type){
				case SUM:
					ret = sum();
					break;
				case CUSTOM:
					ret = customFunction.call(null,source,columns);
					break;
			}
			return ret;
		}
		
		protected function sum():XML
		{
			var summaryRow:XML = <summary/>;
			var dataFieldName:String;
			var product:Number = 0;
			for(var c:int=0;c<this.columns.length;c++){
				dataFieldName = (columns[c] as AdvancedDataGridColumn).dataField;
				product = 0;
				if(dataFieldName.substr(0,1) == "@"){
					for(var i:int=0;i<source.length();i++){
						product += Number((source[i] as XML).attribute(dataFieldName.substr(1))[0]);
					}
					summaryRow.attribute(dataFieldName.substr(1))[0] = product;
				}else{
					for(var j:int=0;j<source.length();j++){
						product += Number((source[j] as XML)[dataFieldName]);
					}
					summaryRow[dataFieldName] = product;
				}
			}
			return summaryRow;
		}
	}
}