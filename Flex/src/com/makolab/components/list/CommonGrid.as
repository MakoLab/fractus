package com.makolab.components.list
{
	import com.makolab.components.catalogue.CatalogueEvent;
	import com.makolab.components.inputComponents.CurrencyRenderer;
	import com.makolab.components.inputComponents.DateRenderer;
	import com.makolab.components.inputComponents.FloatRenderer;
	import com.makolab.components.inputComponents.OrdinalNumberRenderer;
	import com.makolab.components.inputComponents.PercentageRenderer;
	import com.makolab.components.layoutComponents.DragElementProxy;
	import com.makolab.components.util.ComponentExportManager;
	import com.makolab.components.util.ComponentExportManagerDialog;
	import com.makolab.components.util.IExportableComponent;
	import com.makolab.fractus.commands.SearchCommand;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.view.catalogue.AddToClipboardButton;
	import com.makolab.fractus.view.catalogue.AddToOfferButton;
	import com.makolab.fractus.view.catalogue.AvailableStockRenderer;
	import com.makolab.fractus.view.catalogue.BooleanRenderer;
	import com.makolab.fractus.view.catalogue.ColumnColorRenderer;
	import com.makolab.fractus.view.catalogue.FakeRenderer;
	import com.makolab.fractus.view.catalogue.MultiLineTextRenderer;
	import com.makolab.fractus.view.documents.documentControls.OrderRealizationStatusRenderer;
	import com.makolab.fractus.view.generic.DocumentRelationRenderer;
	import com.makolab.fractus.view.generic.DocumentStatusRenderer;
	import com.makolab.fractus.view.generic.DocumentTypeRenderer;
	import com.makolab.fractus.view.generic.FractusDictionaryRenderer;
	import com.makolab.fractus.view.generic.ImageLabelRenderer;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.listClasses.ListBaseContentHolder;
	import mx.core.ClassFactory;
	import mx.core.IFlexDisplayObject;
	import mx.events.DataGridEvent;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import assets.IconManager;
	
	import pl.cadera.debug.logToConsole;
	
	/// Komponent bazowy dla list.
	/// Kolumny grida mogą być zdefiniowane albo poprzez 'columns' (Array) 
	/// albo poprzez 'config' (XMLList)

	public class CommonGrid extends DataGrid implements IExportableComponent
	{
		public var rowTextColorFunction:Function;
		
		public var rowFontWeightFunction:Function;
		public var showExportDialogV:Boolean=true;
		private var _config: XMLList;
		private var model:ModelLocator = ModelLocator.getInstance();
		
		public var labelFunctions:Object = null;
		
		public var headerWordWrap:Boolean = false;
		
		public var searchParams:Object;
		public var searchEventType:String;
		
		private var _data:Object;
		
		/**
		 * Set of data to be viewed. In this case control's <code>dataProvider</code>.
		 * &lt;columns&gt;<br/>
		 *	  &nbsp;&nbsp;&lt;column field=&quot;@code&quot; label=&quot;Kod&quot; width=&quot;50&quot;/&gt;<br/>
		 *	  &nbsp;&nbsp;&lt;column field=&quot;@name&quot; label=&quot;Nazwa&quot; width=&quot;100&quot;/&gt;<br/>
		 *	&lt;/columns&gt;
		 */
		[Bindable]
		override public function set data(value:Object):void{
			_data = value;
			dataProvider = _data;
			//Alert.show("Data: " + _data.toString());
		}
		/**
		 * @private
		 */
		override public function get data(): Object	{
			return _data;
		}
		[Bindable]
		public var dragItemType:String = "";
		/**
		 * Constructor.
		 */
		public function CommonGrid()
		{
			super();
			setStyle("alternatingItemColors",[IconManager.CELL_COLOR_1 ,IconManager.CELL_COLOR_2]);
			alpha=IconManager.CELL_ALPHA;
			//// szukaj mnie tytajthis.setStyle("color",0xFF0000);
			this.addEventListener(DataGridEvent.HEADER_RELEASE,handleHeaderRelease);
			this.addEventListener(ListEvent.CHANGE,handleChange); 
			//this.addEventListener(DragEvent.DRAG_DROP,createProxyObjects);
			contextMenu = ComponentExportManager.getInstance().getExportMenu();
			
			
			//header = new CommonGridHeader();
		}
		
		private function handleHeaderRelease(event:DataGridEvent):void
		{
			//event.preventDefault();
			//sortSearch(event.columnIndex);
		}
		public function removeHandleHeaderRelease():void
		{
			this.removeEventListener(DataGridEvent.HEADER_RELEASE, handleHeaderRelease);
		}
		/**
		 *	 display rows grouping with selected item
		 */ 
		public var showGroupingField :String;  
		
		/**
		 * Determines if the column's sort arrow should be visible or not.
		 */
		public function showSortArrow():void
		{
			CommonGridHeader(header).showSortArrow();
		}
		/**
		 * Conrol's configuration.
		 */
		public function set config(value:XMLList):void	{
			_config = value;
			//Alert.show("Config: " + _config.toString());
			createColumns();
		}
		/**
		 * @private
		 */
		public function get config():XMLList	{
			return _config;
		}
		/**
		 * Shows the export dialog window.
		 */
		public function showExportDialog() : void {
		logToConsole("commongrid showExportDialog");
			//var dialog:IFlexDisplayObject = PopUpManager.createPopUp( this, ComponentExportManagerDialog, true);
			//PopUpManager.centerPopUp(dialog);
		}
		public function showExportDialog_() : void {
			logToConsole("commongrid showExportDialog1");
			var dialog:IFlexDisplayObject = PopUpManager.createPopUp( this, ComponentExportManagerDialog, true);
			PopUpManager.centerPopUp(dialog);
		}
		/**
		 * Exports an XML to a given format.
		 */ 
		public function exportXml(format:String):XML
		{
			logToConsole("commongrid exportXml");
		
			if(showExportDialogV)
			showExportDialog_();
			else
			showExportDialogV=true;
			var result:XML = <list><details/><columns/><elements/></list>;
			var xmlnsPattern:RegExp;
			var list:XMLList = XMLListCollection(this.dataProvider).copy();
			
			for each( var r:XML in _config.attributes()){
				var detail:XML = <detail/>;
				result.details.appendChild(detail);
				detail.@[r.name().toString()] = r;
			}
			
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
						list[j][columns[i].dataField] = DataGridColumn(columns[i]).itemToLabel(list[j]); 
					}
					//dodanie koloru wiersza
					if(rowTextColorFunction != null && !isNaN(Number(rowTextColorFunction(list[j]))))
						list[j].@color = "#"+rowTextColorFunction(list[j]).toString(16);//do pdf i html
				}
			}
			result.elements.* = list;//XMLListCollection(this.dataProvider).copy();
			model.exportListXML = result;
			return result;
		}
		
		private function parsePath(path:String):Array
		{
			if (!path.match(/^\{.+\}$/)) return null;
			return path.substring(1,path.length-1).split(".");
		}
		
		private function tipCreat(event:ListEvent):void 
		{
			var colName:String = event.target.columns[event.columnIndex].dataTipField;
			if(colName) toolTip = event.itemRenderer.data[colName];
        }

        private function tipDestroy(event:ListEvent):void {
			toolTip = null;
        }
		
		private function createColumns():void
		{			
			var toolTipAdded:Boolean = false;
			
			var columnDef: ArrayCollection = prepareColumnsDefinition();
			var columns:Array = new Array();
			for(var i:int = 0; i<columnDef.length; i++)	{
				var column:DataGridColumn = new DataGridColumn();
				column.headerWordWrap = this.headerWordWrap;
				column.headerText = columnDef[i].headerText;
				column.dataField = columnDef[i].dataField;
				column.dataTipField = columnDef[i].dataTipField;
				if(columnDef[i].dataTipField && !toolTipAdded) {
					addEventListener(ListEvent.ITEM_ROLL_OVER,tipCreat);
					addEventListener(ListEvent.ITEM_ROLL_OUT,tipDestroy);
					toolTipAdded = true;
				}
				column.sortable = columnDef[i].sortable;
				column.editable = columnDef[i].editable;
				column.rendererIsEditor = columnDef[i].rendererIsEditor;
				if (columnDef[i].textAlign) column.setStyle("textAlign",columnDef[i].textAlign);
				if (columnDef[i].width) column.width = columnDef[i].width;
				column.itemRenderer = getRenderer(columnDef[i].dataType, columnDef[i].dependencyField);
				if (
					columnDef[i].labelFunctionName &&
					this.labelFunctions &&
					this.labelFunctions[columnDef[i].labelFunctionName]
				) column.labelFunction = this.labelFunctions[columnDef[i].labelFunctionName];
				
				columns.push(column);
			}
			this.columns = columns;
		}
		
		override protected function addDragData(ds:Object):void
		{
			ds.addHandler(createProxyObjects,dragItemType);
		}
		
		private function createProxyObjects():Array
		{
			var tmp:Array = [];
			for(var i:int=0;i<selectedItems.length;i++){
				var itemProxy:DragElementProxy = new DragElementProxy(selectedItems[i]);
				tmp.push(itemProxy);
			}
			return tmp;
		}
		
		private function getRenderer(dataType:String, dependencyField:String = null):ClassFactory
		{
			var rendererClass:Class;
			switch (dataType)
			{
				case "isCommercialRelation":
				 rendererClass = DocumentRelationRenderer;
				break;
				case "percentage":
					rendererClass = PercentageRenderer;
					break;
				case "currency":
					rendererClass = CurrencyRenderer;
					break;
				case "date":
				case "dateTime":
					rendererClass = DateRenderer;
					break; 
				case "dictionary":
				case "dictionaryLabel":
				case "dictionarySymbol":
					rendererClass = FractusDictionaryRenderer;
					break;
				case "documentType":
					rendererClass = DocumentTypeRenderer;
					break;
				case "orderRealizationStatus":
					rendererClass = OrderRealizationStatusRenderer;
					break;
				case "documentStatus":
					rendererClass = DocumentStatusRenderer;
					break;
				case "float":
					rendererClass = FloatRenderer;
					break;
				case "availableStock":
					rendererClass = AvailableStockRenderer;
					break;
				case "color":
					rendererClass = ColumnColorRenderer;
					break;
				case "ordinalNumber":
					rendererClass = OrdinalNumberRenderer;
					break;
				case "boolean":
					rendererClass = BooleanRenderer;
					break;
				case "fake":
					rendererClass = FakeRenderer;
					break;
				case "addToClipboardButton":
					rendererClass = AddToClipboardButton;
					break;
				case "addToOfferButton":
					rendererClass = AddToOfferButton;
					break;
				case "imageLabel":
					rendererClass = ImageLabelRenderer;
					break;
				case "multiLineText":
					rendererClass = MultiLineTextRenderer;
					break;
				default:
					return null;
			}
			var cf:ClassFactory = new ClassFactory(rendererClass);
			switch (dataType)
			{
				case "dictionaryLabel": cf.properties = { labelField : 'label' }; break;
				case "dictionarySymbol": cf.properties = { labelField : 'symbol' }; break;
			//	case "isCommercialRelation": cf.properties = { labelField : 'symbol' }; break;
				case "dateTime": cf.properties = { displayTime : true }; break;
				case "color": 
				cf.properties = { colorField : dependencyField }; break;
				case "currency": cf.properties = {showCurrency: dependencyField}; break;
				case "boolean": cf.properties = {checkBoxColor: dependencyField}; break;
				case "imageLabel": cf.properties = {iconName: dependencyField}; break;			
				case "multiLineText": cf.properties = {textFontColor: dependencyField}; break;				
			}
			return cf;
		}
		
		private function prepareColumnsDefinition():ArrayCollection
		{
			var columnArray:ArrayCollection = new ArrayCollection();
			var columnObject:Object;
			var columnXMLList:XMLList = _config.children();
			for(var i:int = 0; i<columnXMLList.length(); i++)
			{
				if (columnXMLList[i].@hidden == 1) continue;
				columnObject = new Object();
				columnObject.headerText =
						columnXMLList[i].@labelKey.length() > 0 ?
						LanguageManager.getLabel(columnXMLList[i].@labelKey) :
						columnXMLList[i].@label;
				columnObject.rendererIsEditor = columnXMLList[i].attribute("rendererIsEditor").toString();
				columnObject.dataField = columnXMLList[i].attribute("field").toString();
				columnObject.dependencyField = columnXMLList[i].attribute("dependencyField").toString();
				columnObject.width = columnXMLList[i].attribute("width").toString();
				columnObject.labelFunctionName = columnXMLList[i].attribute("labelFunction").toString();
				columnObject.textAlign = columnXMLList[i].attribute("textAlign").toString();
				columnObject.dataTipField = columnXMLList[i].attribute("dataTipField").toString();
				
				//columnObject.showCurrency = columnXMLList[i].attribute("showCurrency").toString();
				 
				if(columnXMLList[i].@sortable != null &&
						columnXMLList[i].@sortable.length() > 0 &&
						columnXMLList[i].@sortable == "false")
					columnObject.sortable = false;
				else
					columnObject.sortable = true;
					
				if(columnXMLList[i].@editable != null &&
						columnXMLList[i].@editable.length() > 0 &&
						columnXMLList[i].@editable == "true")
						columnObject.editable = true;
				else
					columnObject.editable = false;
					
				
				columnObject.dataType = columnXMLList[i].attribute("dataType").toString();
				if (columnXMLList[i].@dictionaryName) columnObject.dictionaryName = String(columnXMLList[i].@dictionaryName);
				columnArray.addItem(columnObject);
			}
			return columnArray;
		}
		
		override protected function makeRow(contentHolder:ListBaseContentHolder, rowNum:int, left:Number, right:Number, yy:Number, data:Object, uid:String):Number
		{
			var ret:Number =super.makeRow(contentHolder, rowNum, left, right, yy, data, uid);
			var row:Array = contentHolder.listItems[rowNum];
			var i:String;
			if (rowTextColorFunction != null)
			{
				var color:Number = rowTextColorFunction(data);
				for (i in row)
				{
					if (row[i].getStyle('color') != color) row[i].setStyle('color', color);
				} 
			}
			if (rowFontWeightFunction != null)
			{
				var fontWeight:String = rowFontWeightFunction(data);
				for (i in row)
				{
					if (row[i].getStyle('fontWeight') != fontWeight) row[i].setStyle('fontWeight', fontWeight);
				} 
			}
			return ret;
		}
			
		protected function defaultRowColorFunction(item:Object):Number
		{
			if (item && showGroupingField && selectedItem  && item[showGroupingField].toString() == selectedItem[showGroupingField].toString() ) return 0xccccff;
			else return NaN;
		}
		
		protected function handleChange(event:Event):void
		{
			if(showGroupingField)updateList();
		}
		
		override protected function drawRowBackground(s:Sprite, rowIndex:int, y:Number, height:Number, color:uint, dataIndex:int):void
		{
			var dp:ListCollectionView = dataProvider as ListCollectionView;
			if (dp && rowColorFunction != null)
			{
				var item:Object;
				if (dataIndex < dp.length) item = dp.getItemAt(dataIndex);
				var c:Number = NaN;
				if (item != null) c = rowColorFunction(item);
				if (!isNaN(c)) color = c;
				super.drawRowBackground(s, rowIndex, y, height, color, dataIndex);
			}
			super.drawRowBackground(s, rowIndex, y, height, color, dataIndex);
		}
	
		public var rowColorFunction:Function = defaultRowColorFunction;
		public function exportXmlAll(format:String):XML
		{
			logToConsole("commongrid exportXmlAll");
			 searchItems();
			 return new XML();
		}
		private function searchItems():void
		{
			logToConsole("commongrid searchItems");
			if(searchParams && searchEventType)
			{
				var cmd:SearchCommand = new SearchCommand(searchEventType);
				cmd.searchParams = XML(searchParams);
				delete cmd.searchParams.pageSize;
				delete cmd.searchParams.page;
				cmd.searchParams.appendChild(<pageSize>1000000</pageSize>);
				cmd.searchParams.appendChild(<page>1</page>);
				cmd.addEventListener(ResultEvent.RESULT,handleSearchResult);
				cmd.addEventListener(FaultEvent.FAULT,handleSearchFault);
				cmd.execute();
				
			}	
		}
		
		private function handleSearchResult(event:ResultEvent):void
			{
			logToConsole("commonGrid handleSearchResult");
			var result:XML = <list><details/><columns/><elements/></list>;
			var xmlnsPattern:RegExp;
			var list:XMLList = XML(event.result).children();			
			for each( var r:XML in _config.attributes()){
				var detail:XML = <detail/>;
				result.details.appendChild(detail);
				detail.@[r.name().toString()] = r;
			}
			
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
						list[j][columns[i].dataField] = DataGridColumn(columns[i]).itemToLabel(list[j]); 
					}
					//dodanie koloru wiersza
					if(rowTextColorFunction != null && !isNaN(Number(rowTextColorFunction(list[j]))))
						list[j].@color = "#"+rowTextColorFunction(list[j]).toString(16);//do pdf i html
				}
			}
			result.elements.* = list;//XMLListCollection(this.dataProvider).copy();
			model.exportListXML = result;
			
				showExportDialog_();
				//searchResults = getSearchResults(event.result);
			}
			
		private function handleSearchFault(event:FaultEvent):void
		{
			logToConsole("commonGrid handleSearchFault");
		dispatchEvent(new CatalogueEvent(CatalogueEvent.ITEM_SEARCH_ERROR, null, null, event.fault));
		}
	}
}