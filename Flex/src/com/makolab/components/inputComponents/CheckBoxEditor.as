package com.makolab.components.inputComponents
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.fractus.view.documents.documentEditors.DocumentEditor;
	
	import mx.controls.CheckBox;
	import mx.controls.listClasses.BaseListData;
	
	public class CheckBoxEditor extends CheckBox implements IDataObjectComponent
	{
		
		private var _isSelected:Boolean;
		/**
		 * Constructor.
		 */
		 public function set isSelected(a:Boolean):void
		 {
		 	_isSelected=a;
		 }
		 public function get isSelected():Boolean// only initial state, real select val is from select
		 {
		 	return _isSelected;
		 }
		public function CheckBoxEditor()
		{
			super();
		}
		
		private var _dataObject:String;
		/**
		 * Use this property to pass value to the editor.
		 */
		[Bindable]
		public function set dataObject(value:Object):void
		{
			if (_dataObject == String(value)) return;
			var val:Number = parseInt(String(value));
			if(isNaN(val)||val == 0 )
			{
				if(isSelected)
				{
					val=1;
					isSelected=false;
				}
			}
			selected = (!isNaN(val) && val != 0);
			_dataObject = String(value);
		}
		/**
		 * @private
		 */
		public function get dataObject():Object
		{
			return selected ? "1" : "0";
		}
		/**
		 * Lets you pass a value to the editor.
		 * @see #dataObject
		 */
		[Bindable]
		override public function set data(value:Object):void
		{
			super.data = value;
			dataObject = DataObjectManager.getDataObject(data, listData);
			//dispatchEvent(new DocumentEvent(DocumentEvent.DOCUMENT_ATTRIBUTE_CHANGE));
		}
		
		override public function set listData(value:BaseListData):void
		{
			super.listData = value;
			dataObject = DataObjectManager.getDataObject(data, listData);
		}
		
	}
}