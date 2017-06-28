package com.makolab.fractus.view.finance
{
	import com.makolab.components.inputComponents.CurrencyRenderer;
	import com.makolab.components.inputComponents.DateRenderer;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.view.documents.documentControls.InfoLinkButton;
	
	import flash.display.Sprite;
	
	import flight.binding.Bind;
	
	import mx.collections.ListCollectionView;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;

	public class SalesOrderGrid extends DataGrid
	{
		private const DEFAULT_COLOR:uint = 0xffffff;		 
			 
		public function SalesOrderGrid()
		{
			super();
			createColumns();
		}
		
		protected function rowColorFunction(item:Object):Number
		{
			return DEFAULT_COLOR;
		}
		
		private var _showContractorColumn:Boolean = true;
		
		public function set showContractorColumn(value:Boolean):void
		{
			_showContractorColumn = value;
			 // prowizora, ale nie ma czasu
			if(_showContractorColumn && this.columns){
				this.columns[3].visible = true;
			}else{
				this.columns[3].visible = false;
			}
		}
		
		public function get showContractorColumn():Boolean
		{
			return _showContractorColumn;
		}
			
		override protected function drawRowBackground(s:Sprite, rowIndex:int, y:Number, height:Number, color:uint, dataIndex:int):void
		{
			var dp:ListCollectionView = dataProvider as ListCollectionView;
			if (dp && rowColorFunction != null)
			{
				var item:Object;
				if (dataIndex < dp.length) item = dp.getItemAt(dataIndex);
				color = rowColorFunction(item);
				super.drawRowBackground(s, rowIndex, y, height, color, dataIndex);
			}
			super.drawRowBackground(s, rowIndex, y, height, color, dataIndex);
		}
		
		protected function createColumns():void
		{
			var a:Array = [];
			a.push(createColumn(100, '@issueDate', 'common.date', DateRenderer));
			a.push(createColumn(100, '@fullNumber', 'documents.documentNumber'));
			a.push(createColumn(70, '@grossValue', 'documents.value', CurrencyRenderer));
			a.push(createColumn(-1, '@contractor', 'contractors.contractor'));
			
			//tworzymy kolumne z przyciskiem do otwierania podgladu dokumentu
			var col:DataGridColumn = new DataGridColumn();
			col.width = 50;
			col.itemRenderer = new ClassFactory(InfoLinkButton);
			col.headerText = " ";
			a.push(col);
			
			this.columns = a;
		}
		
		protected static function createColumn(width:int, dataField:String, labelKey:String, rendererClass:Class = null, labelFunction:Function = null):DataGridColumn
		{
			var col:DataGridColumn = new DataGridColumn();
			if(width >= 0)
			col.width = width;
			col.dataField = dataField;
			if (rendererClass) col.itemRenderer = new ClassFactory(rendererClass);
			if (labelFunction != null) col["labelFunction"] = labelFunction;
			Bind.addBinding(col, 'headerText', ModelLocator.getInstance().languageManager.labels, labelKey);
			return col;
		}
	}
}