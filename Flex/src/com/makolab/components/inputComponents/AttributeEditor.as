package com.makolab.components.inputComponents
{
	import com.makolab.fractus.model.LanguageManager;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.controls.LinkButton;
	import mx.controls.List;
	import mx.controls.PopUpButton;
	import mx.controls.listClasses.BaseListData;
	import mx.core.ClassFactory;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.DropdownEvent;
	import mx.events.ListEvent;
	
	import flight.binding.Bind;
	
	[Style(name="headerBackgoundColor", type="uint", inherit="no")]
	[Style(name="subHeaderBackgoundColor", type="uint", inherit="no")]
	[Style(name="labelWidth", type="Number", format="Length", inherit="yes")]
	[Style(name="editorWidth", type="Number", format="Length", inherit="yes")]
	public class AttributeEditor extends VBox implements IDataObjectComponent, IFormBuilderComponent
	{
		/**
		 * Contains title label and popup button
		 */
		protected var titleBar:HBox;
		/**
		 * Displays title
		 */
		protected var titleLabel:Label;
		/**
		 * Contains single editors.
		 */
		protected var editorContainer:VBox;
		/**
		 * Displays list of attribute types, that a user can add.
		 */
		protected var popupButton:PopUpButton;
		
		/**
		 * Attribute node template. An XML with empty or filled with default values nodes.
		 */
		public var template:XML = <attribute/>;
		
		/**
		 * Name of the editor's data field.
		 */
		public var editorDataField:String = "dataObject";
		
		/**
		 * Text of the popup button.
		 */
		public var buttonLabel:String = LanguageManager.getInstance().labels.common.add;
		
		/**
		 * The class factory for the item editor to use for the control.
		 */
		public var itemEditor:ClassFactory;
		
		/**
		 * Number that specifies the height of the single attribute, in pixels, in the parent's coordinates.
		 */
		public var attributeHeight:int;
		
		/**
		 * Name of attribute's ID field.
		 */
		public var attributeIdField:String = "id";
		
		/**
		 * Name of the item editor value field
		 */
		public var valueField:String = 'value';
		
		private var _dataObject:Object;
		
		protected var editors:Array = [];
		
		protected var bindingContainers:Array;
		
		private var _editorFields:Array =[];
		
		public function AttributeEditor()
		{
			super();
			setStyle("headerBackgroundColor", 0xdddddd);
			setStyle("subHeaderBackgroundColor", 0xeeeeee);
			setStyle("borderSides", "top bottom left right");
			setStyle("borderColor", 0xeeeeee);
			setStyle("borderThickness", 1);
			setStyle("borderStyle", "solid");
			percentWidth = 100;
		}
		
		/**
		 * Class for <code>itemEditor</code> 
		 */
		
		private var _attributes:Object;
		
		/**
		 * Attributes dictionary
		 */
		public function set attributes(value:Object):void
		{
			_attributes = value;
			updateData();
		}
		/**
		 * @private
		 */
		public function get attributes():Object { return _attributes; }
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			if (!titleBar)
			{
				titleBar = new HBox();
				titleBar.percentWidth = 100;
				titleBar.setStyle("backgroundColor", getStyle("headerBackgroundColor"));
				titleLabel = new Label();
				Bind.addBinding(titleLabel, 'text', this, 'label');
				titleLabel.setStyle("fontWeight", "bold");
				titleLabel.percentWidth = 80;
				titleBar.addChild(titleLabel);
				popupButton = new PopUpButton();
				popupButton.label = buttonLabel;
				popupButton.percentWidth = 40;
				popupButton.addEventListener(DropdownEvent.OPEN, openHandler);
				popupButton.openAlways = true;
				titleBar.addChild(popupButton);
				addChild(titleBar);
				editorContainer = new VBox();
				editorContainer.percentWidth = 100;
				editorContainer.setStyle("verticalGap", 4);
				addChild(editorContainer);
			}
		}
		
		protected function createPopUp():UIComponent
		{
			var list:List = new List();
			var visibleAttributes:Array = [];
			for (var s:String in attributes) if (attributes[s].metadata.disabled.length() == 0 || attributes[s].metadata.disabled == 0) visibleAttributes.push(attributes[s]);
			list.dataProvider = visibleAttributes;
			//list.labelField = "label";
			list.labelFunction=labelFunction;
			list.setStyle("fontWeight", "normal");
			list.minWidth = popupButton.width;
			list.rowCount = (visibleAttributes.length <= 7) ? visibleAttributes.length : 7;
			list.addEventListener(ListEvent.ITEM_CLICK, handleItemClick);
			popupButton.popUp = list;
			return list;
		}
		private function labelFunction(item:Object):String
		{
			return item.label.(@lang==LanguageManager.getInstance().currentLanguage)[0];
		}
		private function openHandler(event:DropdownEvent):void
		{
			if (!popupButton.popUp)
			{
				popupButton.popUp = createPopUp();
				popupButton.open();
			}
			List(popupButton.popUp).selectedItem = null;
		}
		
		protected function handleItemClick(event:ListEvent):void
		{
			addAttribute(event.itemRenderer.data["id"]);
		}
		
		protected function addAttribute(id:String):void
		{
			var newNode:XML = XML(template.*).copy();
			newNode[attributeIdField] = id;
			_dataObject.appendChild(newNode);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		protected function deleteAttribute(index:int):void {
			delete(XMLList(_dataObject).children()[index]);
			dispatchEvent(new Event(Event.CHANGE));
			validateAll();
			
		}
		
		protected function validateAll():void {
			if(editors.length) {
				for each (var item:Object in editors) {
					item.component.validate();				
				}
			}
		}
		
		/**
		 * Lets you pass a value to the editor.
		 * the <code>data</code> property doesn't change while editing values in editor. The value of <code>data</code> is copied to <code>dataObject</code>. To read modified values use <code>dataObject</code> property.
		 * @see #dataObject
		 */
		[Bindable]
		override public function set data(value:Object):void
		{
			dataObject = value;
		}
		
		/**
		 * @private
		 */
		override public function get data():Object
		{
			return dataObject;
		}
		
		/**
		 * Lets you pass a value to the editor.
		 * @see #data
		 */
		[Bindable]
		public function set dataObject(value:Object):void
		{
			var pdo:Object = _dataObject;
			//if (!_dataObject || String(pd) != String(_dataObject))
			//if (pdo != value)// || (value && editors.length != value.*.length()))
			//{
				_dataObject = value;
				updateData();
			//}
		}
		/**
		 * @private
		 */
		public function get dataObject():Object
		{
			return _dataObject;
		}
		
		protected function updateData():void
		{
			if (!_dataObject || !_attributes) return;
			//editorContainer.removeAllChildren();
			//editors = [];
			var n:int = _dataObject.*.length();
			var i:int = 0;	// current editor index
			for (var j:int = 0; j < n; j++)	// current attribute index
			{
				var value:Object = _dataObject.*[j];
				var attributeTypeId:String = value[attributeIdField];
				var attributeTypeList:XMLList = attributes.(id == attributeTypeId);
				var attributeType:XML = null;
				if (attributeTypeList.length() == 1) attributeType = XML(attributeTypeList.toXMLString());
				if (attributeType)	// if the type belongs to this editor
				{
					if (editors.length - 1 < i) addEditor();
					if (editors[i].label) editors[i].label.text = attributeType.label.(@lang==lm.currentLanguage)[0];
					editors[i].attributeType = attributeType;
					editors[i].component["data"] = value;
					editors[i].dataIndex = j;
					var aec:IAttributeEditorComponent = editors[i].component as IAttributeEditorComponent;
					if (aec) aec.attributeType = attributeType;
					i++;
				}
			}
			while (editors.length > i) removeEditor();
		}
		
		protected function addEditor():UIComponent
		{
			var editor:UIComponent = itemEditor.newInstance() as UIComponent;
			if (!(editor is GenericAttributeEditorComponent))
			{
				var newEditor:GenericAttributeEditorComponent = new GenericAttributeEditorComponent();
				newEditor.itemEditor = this.itemEditor;
				newEditor.editorDataField = this.editorDataField;
				newEditor.valueField = this.valueField;
				editor = newEditor;
			}

			editor.percentWidth = 100;
			if (attributeHeight) editor.height = attributeHeight;
			editor.addEventListener(Event.CHANGE, editorChangeHandler);
			var hBox:HBox = null;
			var deleteBtn:LinkButton = null;
			var lbl:Label;
						
			if (editor is GenericAttributeEditorComponent)
			{
				editorContainer.addChild(editor);
				deleteBtn = (editor as GenericAttributeEditorComponent).deleteButton;
			}
			else
			{
				hBox = new HBox();
				hBox.percentWidth = 100;
				hBox.setStyle("verticalAlign", "middle");
				hBox.setStyle("backgroundColor", getStyle("subHeaderBackgroundColor"));
				lbl = new Label();
				lbl.percentWidth = 100;
				lbl.setStyle("fontWeight", "bold");
				hBox.addChild(lbl);
				deleteBtn = new LinkButton();
				deleteBtn.label = "["+LanguageManager.getInstance().labels.common.deleteAll+"]";
				hBox.addChild(deleteBtn);
				editorContainer.addChild(hBox);
				editorContainer.addChild(editor);
			}
	
			for each(var j:Object in _editorFields)
			{
				var editorFieldValue:Object =j.value;
				if(editor is GenericAttributeEditorComponent)
					(editor as GenericAttributeEditorComponent).itemEditorInstance[j.property]= editorFieldValue;
			}
			deleteBtn.addEventListener(MouseEvent.CLICK, handleDeleteClick);
			editors.push( { component : editor, label : lbl, deleteBtn : deleteBtn, header : hBox, dataIndex : null, attributeType : null } );
			return editor;
		}
		
		protected var attributeToDelete:int = -1;
		
		protected function handleDeleteClick(event:MouseEvent):void
		{
			for (var i:String in editors) if (editors[i].deleteBtn == event.target)
			{
				attributeToDelete = editors[i].dataIndex;
				Alert.show(LanguageManager.getInstance().labels.alert.realyDelete + " \"" + editors[i].attributeType.label.(@lang==LanguageManager.getInstance().currentLanguage)[0] + "\"?", LanguageManager.getInstance().labels.alert.deletingAttribute, Alert.YES | Alert.NO, this, handleConfirmDialogClose);
				return;
			}
		}
		
		protected function handleConfirmDialogClose(event:CloseEvent):void
		{
			if (event.detail == Alert.YES) deleteAttribute(attributeToDelete);
			attributeToDelete = -1;
		}
		
		protected function removeEditor():void
		{
			var e:Object = editors.pop();
			IEventDispatcher(e.component).removeEventListener(Event.CHANGE, editorChangeHandler);
			editorContainer.removeChild(DisplayObject(e.component));
			if (e.header) editorContainer.removeChild(DisplayObject(e.header));
		}
		
		public function set listData(value:BaseListData):void {}
		public function get listData():BaseListData { return null; }
		
		protected function editorChangeHandler(event:Event):void
		{
			for (var i:String in editors)
			{
				if (editors[i].component == event.target)
				{
					//_dataObject.*[editors[i].dataIndex][valueField] = event.target[editorDataField];
					_dataObject.*[editors[i].dataIndex] = event.target[editorDataField];
				}
			}
			event.stopImmediatePropagation();
			dispatchEvent(new Event(Event.CHANGE)); 
		}
		
		/**
		 * Validates values for this component and returns array of error messages.
		 */
		public function validate():Object
		{
			var result:Array = [];
			for (var i:String in editors) if (editors[i].component is IFormBuilderComponent)
			{
				var component:IFormBuilderComponent = IFormBuilderComponent(editors[i].component);
				var componentResult:Object = component.validate();
				if (componentResult is Array)
				{
					for (var j:String in componentResult) result.push(componentResult[j]);	
				}
				else if (componentResult)
				{
					result.push(componentResult);
				}
			}
			return result;
		}
		
		//lista parametrów dla edytora
		/**
		 * Parameters list for the editor
		 */
		public function set editorFields (s:String):void
		{
			var xml:XML = new XML(s);
			for each (var k:XML in xml.*)
			{
				_editorFields.push({property:k.localName(),value: k})
			}
		}
		/**
		 * @private
		 */
		public function get editorsFields():Array
		{
			return _editorFields;
		}
		
		public function commitChanges():void { ; }
		public function reset():void {}
	}
}