package com.makolab.fractus.view.generic
{
	import com.makolab.fractus.model.DictionaryManager;
	
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.IFactory;
	import mx.core.UIComponent;

	public class ImageLabelRenderer extends UIComponent implements IDropInListItemRenderer, IListItemRenderer, IFactory
	{ 
		import mx.controls.listClasses.ListData;
		import mx.controls.listClasses.BaseListData;
		import com.makolab.components.inputComponents.DataObjectManager;
		import com.makolab.fractus.model.ModelLocator;
		import com.makolab.fractus.model.document.DocumentTypeDescriptor;
		import assets.IconManager;

		protected var lbl:Label;
		protected var img:Image;
		
		public var iconName:String;

		public function newInstance():*
		{
			return new ImageLabelRenderer();
		}

		public function ImageLabelRenderer()
		{
			super();
			img = new Image();
			lbl = new Label();
			lbl.styleName = this;
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			addChild(img);
			addChild(lbl);
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			img.move(2, 0);
			img.setActualSize(30, unscaledHeight);
			lbl.move(34, 0);
			lbl.setActualSize(unscaledWidth - 30, unscaledHeight);
		}
			
			protected static var cache:Object = null;
			
			private var _dataObject:Object;
			public var _listData:BaseListData;
			
			//implements listData in HBox
			public function set listData(value:BaseListData):void	
			{
				_listData = value;
				dataObject = DataObjectManager.getDataObject(data, listData);
			}
			public function get listData():BaseListData	
			{
				return _listData;
			}
			
			private var _data:Object;
			[Bindable]
			public function set data(value:Object):void
			{
				_data = value;
				dataObject = DataObjectManager.getDataObject(data, listData);
			}
			public function get data():Object
			{
				return _data;
			}
			
			[Bindable]
			public function set dataObject(value:Object):void
			{
				if (_dataObject == value) return;
				_dataObject = value;
				img.source = IconManager.getIcon(iconName);
				lbl.text = value.toString();
				this.toolTip = value.toString();
			}
			public function get dataObject():Object
			{
				return _dataObject;
			}

			protected function buildCache():void
			{
				cache = {};
				for each (var x:XML in ModelLocator.getInstance().dictionaryManager.dictionaries.documentTypes)
				{
					var id:String = x.id;
					var typeDescriptor:DocumentTypeDescriptor = new DocumentTypeDescriptor(id);
					var item:Object = {
						icon : IconManager.getIcon(typeDescriptor.iconDocumentListName),
						symbol : String(typeDescriptor.symbol),
						label : String(typeDescriptor.label)
					}
					cache[id] = item;
				}
				cache['financialReport'] = {
					icon : IconManager.getIcon('list_financial_report'),
					symbol : 'Raport',
					label : 'Raport finansowy'
				}
			}
		
			public static function getTextValue(item:Object,dataField:String):String
			{
				return DictionaryManager.getInstance().dictionaries.documentTypes.(id.toString() == item[dataField]).symbol;
			}
		
	}
}