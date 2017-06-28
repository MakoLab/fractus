package com.makolab.fractus.view.payments
{
	import com.makolab.components.inputComponents.CurrencyRenderer;
	import com.makolab.components.inputComponents.DateRenderer;
	import com.makolab.components.inputComponents.DictionaryRenderer;
	import com.makolab.components.inputComponents.FloatRenderer;
	import com.makolab.components.util.ComponentExportManager;
	import com.makolab.components.util.ComponentExportManagerDialog;
	import com.makolab.components.util.IExportableComponent;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.view.documents.documentControls.InfoLinkButton;
	
	import flash.display.Sprite;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;
	import mx.core.IFlexDisplayObject;
	import mx.managers.PopUpManager;
	
	import flight.binding.Bind;

	public class PaymentGrid extends DataGrid implements IExportableComponent
	{
		private const OUT_COLOR:uint = 0xffcccc;
		private const IN_COLOR:uint = 0xccffcc;
		private const OUT_OVERDUE_COLOR:uint = 0xffaaaa;
		private const IN_OVERDUE_COLOR:uint = 0xaaffaa;
		private const DEFAULT_COLOR:uint = 0xffffff;
		private var financialDocumentButtonColumn:DataGridColumn;
		private var model:ModelLocator = ModelLocator.getInstance();
		
		private var _showSettlingColumn:Boolean = false;
		public function set showSettlingColumn(value:Boolean):void
		{
			var exists:Boolean = false;
			var temp:Array = [];
			if (value)
			{
				for (var i:int = 0; i < columns.length; i++)
				{
					temp.push(columns[i]);
					if (columns[i] == financialDocumentButtonColumn) exists = true;
				}
				if (!exists){
					temp.push(financialDocumentButtonColumn);
					columns = temp;
				}
			} 
		}
		
		public function get showSettlingColumn():Boolean
		{
			return _showSettlingColumn;
		}
			 
		public function PaymentGrid()
		{
			super();
			createColumns();
			contextMenu = ComponentExportManager.getInstance().getExportMenu();
		}
		/**
		 * Shows the export dialog window.
		 */
		public function showExportDialog() : void {
			var dialog:IFlexDisplayObject = PopUpManager.createPopUp( this, ComponentExportManagerDialog, true);
			PopUpManager.centerPopUp(dialog);
		}
		
		/**
		 * Exports an XML to a given format.
		 */ 
		 public function exportXmlAll(format:String):XML
		 {
		 	return exportXml(format);
		 }
		public function exportXml(format:String):XML
		{
			var result:XML = <list><details/><columns/><elements/></list>;
			var xmlnsPattern:RegExp;
			var list:XMLList = XMLListCollection(this.dataProvider).copy();
			
			for (var i:int = 0; i < columns.length; i++) {
				if(columns[i].dataField!=null)	{
					var column:XML = <column/>;
					result.columns.appendChild(column);
					column.@label = columns[i].headerText;
					column.@field = columns[i].dataField;
					if((columns[i] as DataGridColumn).itemRenderer)
					switch (((columns[i] as DataGridColumn).itemRenderer as ClassFactory).generator){
						case CurrencyRenderer:
							column.@dataType = "currency";
							break;
						case FloatRenderer:
							column.@dataType = "float";
							break;
					}
				}
				for (var j:int=0;j<list.length();j++){
					if((columns[i] as DataGridColumn).itemRenderer && (((columns[i] as DataGridColumn).itemRenderer) as ClassFactory).generator["getTextValue"]){
						if(!((columns[i] as DataGridColumn).itemRenderer is CurrencyRenderer))
							list[j][columns[i].dataField] = (((columns[i] as DataGridColumn).itemRenderer) as ClassFactory).generator["getTextValue"](list[j],columns[i].dataField);
					}
					else
					{
						if((columns[i] as DataGridColumn).itemRenderer && ((columns[i] as DataGridColumn).itemRenderer as ClassFactory).generator == PaymentLabelRenderer)
							list[j][columns[i].dataField] = list[j]["@documentNumber"];
						else
							list[j][columns[i].dataField] = DataGridColumn(columns[i]).itemToLabel(list[j]); 
					}
					//dodanie koloru wiersza
					//if(rowTextColorFunction != null && !isNaN(Number(rowTextColorFunction(list[j]))))
					//	list[j].@color = "#"+rowTextColorFunction(list[j]).toString(16);//do pdf i html
				}
			}
			result.elements.* = list;//XMLListCollection(this.dataProvider).copy();
			model.exportListXML = result;
			return result;
		}
		
		protected function rowColorFunction(item:Object):Number
		{
			if(item == null) return DEFAULT_COLOR;
			return (item.@direction > 0) ? (item.@isOverdue > 0) ? IN_OVERDUE_COLOR : IN_COLOR : (item.@isOverdue > 0) ? OUT_OVERDUE_COLOR : OUT_COLOR;
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
			a.push(createColumn(110, '@date', 'common.date', DateRenderer));
			a.push(createColumn(110, '@dueDate', 'common.dueDate', DateRenderer));
			a.push(createColumn(200, '@documentInfo', 'documents.documentNumber',PaymentLabelRenderer));
			a.push(createColumn(-1, '@contractorName', 'contractors.contractor'));
			a.push(createColumn(100, '@paymentMethodId', 'documents.paymentMethod',null,getPayement));
//			var col1:DataGridColumn = new DataGridColumn();
//			col1.width = 140;
//			col1.itemRenderer = new ClassFactory(DictionaryRenderer);
//			col1.dataField = '@paymentMethodId';
//			col1.itemRenderer.dataProvider=dictionaryManage.dictionaries.paymentMethod;
//			col1.headerText=ModelLocator.getInstance().languageManager.getLabel('documents.paymentMethod');
//			a.push(col1);
			a.push(createColumn(80, '@amount', 'documents.amount', CurrencyRenderer));
			a.push(createColumn(130, '@unsettledAmount', 'documents.unsettledAmount', CurrencyRenderer));
			a.push(createColumn(50, '@currencySymbol', 'common.currency'));
			a.push(createColumn(80, '@direction', 'common.direction',null, getDirection));
			
			//tworzymy kolumne z przyciskiem do otwierania podgladu dokumentu
			var col:DataGridColumn = new DataGridColumn();
			col.width = 36;
			col.itemRenderer = new ClassFactory(InfoLinkButton);
			col.headerText = " ";
			a.push(col);
			
			//tworzymy kolumne z przyciskiem do wystawiania dokumentu kasowego
			financialDocumentButtonColumn = new DataGridColumn();
			financialDocumentButtonColumn.width = 36;
			var factory:ClassFactory = new ClassFactory(SettlingDocumentButton);
			financialDocumentButtonColumn.itemRenderer = factory;
			financialDocumentButtonColumn.headerText = " ";
			if (showSettlingColumn) a.push(financialDocumentButtonColumn);
			
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
		
		protected function getDirection(item:Object, column:DataGridColumn):String
		{
			return (Number(item.@direction) > 0) ? "+" : "-";
		}
		protected function getPayement(item:Object, column:DataGridColumn):String
		{
			//trace("pl:",item.@paymentMethodId,ModelLocator.getInstance().dictionaryManager.dictionaries.paymentMethod.(id.toString() == item.@paymentMethodId));
			return ModelLocator.getInstance().dictionaryManager.dictionaries.paymentMethod.(id.toString() == item.@paymentMethodId).label.@lang.length()?ModelLocator.getInstance().dictionaryManager.dictionaries.paymentMethod.(id.toString() == item.@paymentMethodId).label.(@lang==LanguageManager.getInstance().currentLanguage)[0]:ModelLocator.getInstance().dictionaryManager.dictionaries.paymentMethod.(id.toString() == item.@paymentMethodId).label;
			
		}
	}
}