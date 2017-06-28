package com.makolab.components.inputComponents
{
	import mx.controls.CheckBox;
	import mx.controls.ComboBox;
	
	import mx.core.ClassFactory;
	
	public class SingleAttributeEditor extends GenericAttributeEditorComponent
	{
		/**
		 * On base of <code>template</code> the SingleAttributeEditor builds <code>dataObject</code> XML.
		 */
		public var template:XML = <attribute/>;
		
		/**
		 * Name of the attribute's id field.
		 */
		public var attributeIdField:String = "itemFieldId";
		
		/**
		 * Constuctor
		 */
		public function SingleAttributeEditor()
		{
			super();
			dispatchChange = true;
			showDeleteButton = false;
		}
		private var _attributeName:String;
		
		/**
		 * Name of an attribute the <code>SingleAttributeEditor</code> creates, modifies or removes.
		 */
		public function set attributeName(value:String):void
		{
			_attributeName = value;
			updateAttributeData();
		}
		
		/**
		 * @private
		 */
		public function get attributeName():String { return _attributeName; }
		 
		private var _attributes:Object;
		
		/**
		 * Attributes dictionary.
		 */
		public function set attributes(value:Object):void
		{
			_attributes = value;
			updateAttributeData();
		}
		/**
		 * @private
		 */
		public function get attributes():Object { return _attributes; }

		private var _dataObject:Object;
		
		/**
		 * Lets you pass a value to the editor.
		 */
		[Bindable]
		override public function set dataObject(value:Object):void
		{
			if (value is XML) _dataObject = value as XML;
			else if (value is XMLList && value.length() > 0) _dataObject = value[0];
			else _dataObject = null;
			updateData();
		}
		/**
		 * @private
		 */
		override public function get dataObject():Object
		{
			return _dataObject;
		}
		
		private var _editorAttributes:Object;
		
		/**
		 * Editor configuration.
		 */
		public function set editorAttributes(value:Object):void
		{
			_editorAttributes = value;
		}
		/**
		 * @private
		 */
		public function get editorAttributes():Object
		{
			return _editorAttributes;
		}
		
		/**
		 * Creates an editor instance using <code>editorAttributes</code>
		 */
		override protected function createEditorInstance(factory:ClassFactory):void
		{
			super.createEditorInstance(factory);
			
			if(editorAttributes){
				for each(var o:Object in editorAttributes.*){
					itemEditorInstance[o.name()] = o.toString();
				}
			}
		}
		/**
		 * Updates control when you set new editor configuration (called when <code>attributes</code> or <code>attributeName</code> changes).
		 */
		protected function updateAttributeData():void
		{
			if (!attributes) attributeType = null;
			else attributeType = attributes.(name == attributeName);

		}
		
		/**
		 * Updates control when you pass new values to it (Called on <code>dataObject</code> change).
		 */
		protected function updateData():void
		{
			if (!attributeType || !_dataObject) return;
			super.dataObject = getAttributeNode();
		}

		/**
		 * @copy GenericAttributeEditorComponent#commitChanges
		 */
		override public function commitChanges():void { }
		
		/**
		 * Returns an XML of an attribute.
		 */
		protected function getAttributeNode():XML
		{
			var res:XMLList = _dataObject.*.(valueOf()[attributeIdField] == String(attributeType.id));
			return res.length() > 0 ? res[0] : null;
		}
		
		/**
		 * @copy GenericAttributeEditorComponent#reset
		 */
		override public function reset():void
		{
			if (!getAttributeNode())
			{

				var node:XML = template.copy();
				node[attributeIdField] = String(attributeType.id);
				_dataObject.* += node;
				//updateData();
			}

			if(!(itemEditorInstance is IFormBuilderComponent) && !(itemEditorInstance is CheckBox) )
			{
				if(validator)
					validator.required = false;
			}	
		}
	}
}