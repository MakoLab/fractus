package com.makolab.fractus.view.documents.documentControls
{
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	
	import mx.controls.dataGridClasses.DataGridColumn;

	public class LineAttributeColumn extends DataGridColumn
	{
		public function LineAttributeColumn(columnName:String=null)
		{
			super(columnName);
			this.editorDataField = 'attributes';
			this.dataField = 'attributes';
			this.headerWordWrap = true;
			this.editorUsesEnterKey = true;
		}
		
		[Bindable]
		private var _attributeName:String;
		public function set attributeName(value:String):void
		{
			this._attributeName = value;
			this.itemRenderer = LineAttributeRenderer.getFactory(this._attributeName);
			this.itemEditor = LineAttributeEditor.getFactory(this._attributeName);
			updateHeader();
		}
		public function get attributeName():String
		{
			return this._attributeName;
		}
		
		private var _headerText:String = null;
		[Bindable]
		override public function set headerText(value:String):void
		{
			_headerText = value;
			updateHeader();
		}
		override public function get headerText():String
		{
			return super.headerText;
		}

		protected function updateHeader():void
		{
			if (_headerText != null) super.headerText = _headerText;
			else
			{
				var item:XML = DictionaryManager.getInstance().getByName(_attributeName, 'documentFields');
				if (item) super.headerText = String(item.label.@lang.length()?item.label.(@lang==LanguageManager.getInstance().currentLanguage)[0]:item.label);
				else super.headerText = null;
			}
		}
	}
}