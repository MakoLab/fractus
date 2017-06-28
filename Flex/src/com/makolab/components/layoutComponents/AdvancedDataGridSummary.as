package com.makolab.components.layoutComponents
{
	import flash.events.Event;
	
	import mx.controls.AdvancedDataGrid;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.events.AdvancedDataGridEvent;
	import mx.events.FlexEvent;
	import mx.events.IndexChangedEvent;

	public class AdvancedDataGridSummary extends DataGrid
	{
		public function AdvancedDataGridSummary()
		{
			super();
			updateColumnWidth();
			//this.height = this.headerHeight + (Number(operations.length) * this.rowHeight);
		}
		
		private var _source:AdvancedDataGrid;
		
		public function set source(value:AdvancedDataGrid):void
		{
			_source = value;
			if(value){
				this.columns = [];
				var tempColumns:Array = [];
				var columnsWidth:Number = 0;
				for(var i:int=0;i<_source.columnCount;i++){
					tempColumns.push(new DataGridColumn(_source.columns[i].headerText));
					tempColumns[i].width = _source.columns[i].width;
					(tempColumns[i] as DataGridColumn).dataField = _source.columns[i].dataField;
					tempColumns[i].labelFunction = _source.columns[i].labelFunction;
					columnsWidth += _source.columns[i].width;
				}
				this.columns = tempColumns;
				_source.addEventListener(IndexChangedEvent.HEADER_SHIFT,columnLocationChange);
				_source.addEventListener(AdvancedDataGridEvent.COLUMN_STRETCH,columnWidthChange);
				_source.addEventListener(FlexEvent.UPDATE_COMPLETE,updateColumnWidth);
			}
		}
		
		public function get source():AdvancedDataGrid
		{
			return _source;
		}
		
		private function columnLocationChange(event:IndexChangedEvent):void
		{
			var newColumnOrder:Array = [];
			for(var i:int=0;i<this.columns.length;i++){
				newColumnOrder.push(this.columns[i]);
			}
			var column:DataGridColumn = this.columns[event.newIndex];
			newColumnOrder[event.newIndex] = newColumnOrder[event.oldIndex];
			newColumnOrder[event.oldIndex] = column;
			this.columns = newColumnOrder;
			this.columns[event.newIndex].width = _source.columns[event.newIndex].width;
			this.columns[event.oldIndex].width = _source.columns[event.oldIndex].width;
		}
		
		private function columnWidthChange(event:AdvancedDataGridEvent):void
		{
			this.columns[event.columnIndex].width = _source.columns[event.columnIndex].width;
		}
		
		private function updateColumnWidth(event:Event = null):void
		{
			for(var i:int=0;i<this.columns.length;i++){
				this.columns[i].width = _source.columns[i].width;
			}
		}
		
		private var _operations:Array = [];
		[Bindable]
		public function set operations(value:Array):void
		{
			_operations = value;
			var xmlList:XMLList = new XMLList();
			for(var i:int=0;i<value.length;i++){
				if(value[i] is SummaryOperation){
					xmlList = xmlList + (value[i] as SummaryOperation).result;
				}
			}
			dataProvider = xmlList;
			this.rowCount = value.length;
		}
		
		public function get operations():Array
		{
			return _operations;
		}
	}
}