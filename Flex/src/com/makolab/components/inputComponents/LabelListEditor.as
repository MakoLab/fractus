package com.makolab.components.inputComponents
{
	import com.makolab.fractus.model.LanguageManager;
	
	import flash.events.Event;
	
	public class LabelListEditor extends LabelValueEditor
	{
		private var _dataProvider:Object;
		/**
		 * A reference to the selected item in the data provider.
		 */
		[Bindable]
		private var _selectedItem:Object;
		public function set selectedItem(value:Object):void
		{
			_selectedItem = value;
			if (itemEditorInstance) itemEditorInstance['selectedItem'] = _selectedItem;
		}
		public function get selectedItem():Object
		{
			return _selectedItem;
		}
		
		/**
		 * Name of a field in <code>dataProvider</code> child nodes containing value.
		 * For the XML attribute use "@" before name.
		 */
		public var valueField:String = "@id";
		/**
		 * Name of a field in <code>dataProvider</code> child nodes containing label text.
		 * For the XML attribute use "@" before name.
		 */
		public var labelField:String = "*";
		
		private var _dataObject:Object;
		/**
		 * Let's you pass/read values to/form the edior.
		 */
		override public function set dataObject(value:Object):void
		{
			_dataObject = value;
			setSelectedItem();
		}
		/**
		 * @private
		 */
		override public function get dataObject():Object { return _dataObject; }
		/**
		 * Set of data to be viewed.
		 */
		[Bindable]	
		public function set dataProvider(value:Object):void 
		{
			_dataProvider = value;
			if (itemEditorInstance) itemEditorInstance['dataProvider'] = _dataProvider.*;
			setSelectedItem();
		}
		/**
		 * @private
		 */
		public function get dataProvider():Object { return _dataProvider; }
		
		protected function setSelectedItem():void
		{
			var list:XMLList = dataProvider.*;
			for each (var i:XML in list)
			{
				if (String(i[valueField]) == String(dataObject))
				{
					selectedItem = i;
					break;
				}
			}			
		}
		
		public function LabelListEditor()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			if(this.labelField=="labels")
			{
				trace("dd");
				
				itemEditorInstance["labelFunction"] = function(item:Object):String{
					if(item.labels.length())
					return item.labels.label.(@lang==LanguageManager.getInstance().currentLanguage)[0].toString();
					else
						return "";
				}	
				
			}
			else
				itemEditorInstance["labelField"] = this.labelField;
			if (this._dataProvider) itemEditorInstance['dataProvider'] = this._dataProvider.*;
			if (this._selectedItem) itemEditorInstance['selectedItem'] = this._selectedItem;
			setSelectedItem();
		}
		
		override protected function editorChangeHandler(event:Event):void
		{
			selectedItem = itemEditorInstance["selectedItem"];
			dataObject.* = selectedItem[valueField];
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}