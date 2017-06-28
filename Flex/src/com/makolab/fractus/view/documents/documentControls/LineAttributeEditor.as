package com.makolab.fractus.view.documents.documentControls
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.document.BusinessObject;
	import com.makolab.fractus.model.document.BusinessObjectAttribute;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.view.generic.GenericEditor;
	import com.makolab.fractus.view.generic.IdSelector;
	
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.core.ClassFactory;
	import mx.core.ScrollPolicy;
	import mx.managers.IFocusManagerComponent;

	public class LineAttributeEditor extends GenericEditor implements IDropInListItemRenderer, IFocusManagerComponent
	{
		public function LineAttributeEditor()
		{
			super();
			this.horizontalScrollPolicy = ScrollPolicy.OFF;
		}
		
		public function set attributeName(value:String):void
		{
			if (value)
			{
				if (!_attributeType || _attributeType.name != value) _attributeType = DictionaryManager.getInstance().getByName(value, 'documentFields');
				if (!_attributeType) throw new Error('Unknown line attribute name: ' + value);
				updateValue();
			}
			else
			{
				_attributeType = null;
			}
		}
		
		private var _attributeType:XML;
		
		protected function updateValue():void
		{
			this.xmlMetadata = _attributeType.metadata[0];
			if (this.data is BusinessObject)
			{
				var attribute:BusinessObjectAttribute = BusinessObject(this.data).getAttributeByFieldId(this._attributeType.id);
				if (attribute) this.dataObject = attribute.value;
				else this.dataObject = null;
			}
			else this.dataObject = null;
		}
		
		private var _data:Object;
		override public function set data(value:Object):void
		{
			this._data = value;
			this.updateValue();
		}
		override public function get data():Object
		{
			return this._data;
		}
		
		private var _listData:BaseListData;
		public function set listData(value:BaseListData):void
		{
			this._listData = value;
			this.updateValue();
		}
		public function get listData():BaseListData
		{
			return this._listData;
		}
		
		protected function saveAttribute():void//(event:FocusEvent):void
		{
			var attribute:BusinessObjectAttribute;
			if (this.data is BusinessObject && this.dataObject)
			{
				var bo:BusinessObject =  BusinessObject(this.data);
				attribute = bo.getAttributeByFieldId(this._attributeType.id);
				if (!attribute) attribute = bo.addAttribute(_attributeType.id);
				if (attribute.value != this.dataObject)
				{
					attribute.value = this.dataObject;
					if(this.editor is IdSelector)attribute.label = (this.editor as IdSelector).text;
					if (this._listData.owner.document is AbstractLinesComponent)
					{
						var documentObject:DocumentObject = AbstractLinesComponent(this._listData.owner.document).documentObject;
						documentObject.dispatchEvent(
							DocumentEvent.createEvent
							(
								DocumentEvent.DOCUMENT_LINE_ATTRIBUTE_CHANGE,
								this._attributeType.name,
								this.data
							)
						);
						
						if(this._attributeType['name'].* == "LineAttribute_SalesOrderGenerateDocumentOption")
							documentObject.dispatchEvent(DocumentEvent.createEvent(DocumentEvent.DOCUMENT_RECALCULATE));
					}
				}
			}
		}
		
		public static function getFactory(attributeName:String):ClassFactory
		{
			var cf:ClassFactory = new ClassFactory(LineAttributeEditor);
			cf.properties = { attributeName : attributeName };
			return cf;
		}
		
		/**
		 * Required in order for DataGrid dataProvider updating to work fine.
		 */
		public function get attributes():Object
		{
			// zapis atrybutu odpalany odczytem wlasciwosci przez DataGrid
			saveAttribute();
			return this.data is BusinessObject ? this.data.attributes : null;
		}
	}
}