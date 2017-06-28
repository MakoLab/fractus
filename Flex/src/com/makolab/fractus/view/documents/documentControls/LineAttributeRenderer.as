package com.makolab.fractus.view.documents.documentControls
{
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.document.BusinessObject;
	import com.makolab.fractus.model.document.BusinessObjectAttribute;
	import com.makolab.fractus.view.generic.GenericEditor;
	import flash.events.FocusEvent;
	
	import mx.controls.listClasses.BaseListData;
	import mx.core.ClassFactory;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.controls.listClasses.BaseListData;
	import mx.collections.ArrayCollection;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.fractus.view.generic.GenericRenderer;

	public class LineAttributeRenderer extends GenericRenderer implements IDropInListItemRenderer
	{
		public function LineAttributeRenderer()
		{
			super();
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
		override public function set listData(value:BaseListData):void
		{
			this._listData = value;
			this.updateValue();
		}
		override public function get listData():BaseListData
		{
			return this._listData;
		}
		
		public static function getFactory(attributeName:String):ClassFactory
		{
			var cf:ClassFactory = new ClassFactory(LineAttributeRenderer);
			cf.properties = { attributeName : attributeName };
			return cf;
		}
		
		public function get attributes():Object
		{
			
			return this.data.attributes;
		}
	}
}