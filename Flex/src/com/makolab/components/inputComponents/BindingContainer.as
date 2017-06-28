package com.makolab.components.inputComponents
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.Label;
	import mx.controls.TextInput;
	import mx.core.ClassFactory;
	import mx.core.Container;
	import mx.core.IFactory;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.utils.XMLNotifier;


	[Style(name="fontSize", type="Number", format="Length", inherit="yes")]
	[Style(name="fontFamily", type="String", inherit="yes")]
	[Style(name="fontStyle", type="String", inherit="yes")]
	[Style(name="fontWeight",  type="String", inherit="yes")]
	
	/**
	 * Dispatched when editor's value changes.
	 */
	[Event(name="change", type="flash.events.Event")]
	public class BindingContainer extends Container implements mx.utils.IXMLNotifiable
	{
		/**
		 * Specifies a property of editor, the value should be assign to.
		 */
		public var editorDataField:String = "text";
		/**
		 * Determines if the KeyDown event for ENTER key should be interpreted as changes confirmation.
		 * For example if you use TextArea control as editor, you should set this property to <code>true</code>.
		 * Otherwise you will not be able to type multiline text.
		 */
		public var editorUsesEnterKey:Boolean = false;
		
		private var _dataProvider:Object;
		private var _dataField:String;

		private var initialBackgroundColor:Number;
		
		private var _dataObject:Object;
		
		override public function set data(value:Object):void
		{
			super.data = value;
			this.dataObject = value;
		}
		
		/**
		 * Use this property to pass values to editor
		 */
		[Bindable]
		public function set dataObject(value:Object):void
		{
			_dataObject = value;
			if (_dataProvider && _dataField )
			{
				if (_dataProvider[_dataField] != _dataObject) _dataProvider[_dataField] = _dataObject;
			}
			if (itemRendererInstance) itemRendererInstance['data'] = _dataObject;
		}
		/**
		 * @private
		 */
		public function get dataObject():Object
		{
			return _dataObject;
		}	
		/**
		 * Class used as item editor.
		 */
		public var itemEditor:IFactory = new ClassFactory(TextInput);
		private var _itemRenderer:IFactory = new ClassFactory(Label);
		
		/**
		 * Class used as item renderer.
		 */
		public function set itemRenderer(value:IFactory):void
		{
			_itemRenderer = value;
			if (itemRendererInstance)
			{
				removeChild(itemRendererInstance);
				itemRendererInstance = null;
			}
			showRenderer();
		}
		/**
		 * @private
		 */
		public function get itemRenderer():IFactory
		{
			return _itemRenderer;
		}
		
		/**
		 * Set this property to <code>true</code> to use the editor class as renderer as well.
		 */
		public var editorIsRenderer:Boolean = false;
		
		private var itemEditorInstance:UIComponent;
		/**
		 * Instance of item renderer.
		 */
		public var itemRendererInstance:UIComponent;
		
		/**
		 * Use this property to set a dataProvider for the control.
		 */
		[Bindable]
		public function set dataProvider(value:Object):void
		{
			if (itemEditorInstance) endEdit(true);
			if (_dataProvider is XML) XMLNotifier.getInstance().unwatchXML(_dataProvider, this);
			try
			{
				_dataProvider = value;
			}
			catch (e:Error)
			{
				_dataProvider = null;
			}
			if (_dataProvider)
			{
				if (_dataProvider is XML)
				{
					XMLNotifier.getInstance().watchXML(_dataProvider, this);
					updateDataObject();
				}
				else this.dataObject = dataProvider[dataField];
			}
		}
		/**
		 * @private
		 */
		public function get dataProvider():Object
		{
			return _dataProvider;
		}
		/**
		 * A dataObject's field that you use to pass data to item renderer or editor.
		 */
		[Bindable]
		public function set dataField(value:String):void
		{
			if (itemEditorInstance) endEdit(true);
			_dataField = value;
			updateDataObject();
		}
		/**
		 * @private
		 */
		public function get dataField():String
		{
			return _dataField;
		}
		
		private function showRenderer():void
		{
			if (!itemRendererInstance)
			{
				if (editorIsRenderer)
				{
					itemRendererInstance = itemEditor.newInstance();
				}
				else
				{
					itemRendererInstance = itemRenderer.newInstance();
				}
				if (itemRendererInstance)
				{
					itemRendererInstance.width = 200;
					itemRendererInstance.height = this.height;
					itemRendererInstance.visible = true;
					itemRendererInstance.setActualSize(width, height);
					itemRendererInstance['data'] = this.dataObject;
					addChild(itemRendererInstance);
				}
			}
		}
		/**
		 * Respond to size changes by setting the positions and sizes of this container's children. 
		 *
		 * See the UIComponent.updateDisplayList() method for more information about the updateDisplayList() method.
		 */
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if (itemRendererInstance) itemRendererInstance.setActualSize(unscaledWidth, unscaledHeight);
			if (itemEditorInstance) itemEditorInstance.setActualSize(unscaledWidth, unscaledHeight);
		}
		/**
		 * Create child objects of the component.
		 */
		protected override function createChildren():void
		{
			super.createChildren();
			showRenderer();
		}
		/**
		 * Constructor.
		 */
		public function BindingContainer()
		{
			super();
			focusEnabled = true;
			addEventListener(MouseEvent.CLICK, handleClick);
			useHandCursor = true;
			width = 150;
			height = 25;
			addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
			addEventListener(MouseEvent.MOUSE_OUT, mouseHandler);
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}
		/**
		 * Called on control's creationComplete event.
		 */
		public function creationCompleteHandler(event:FlexEvent):void
		{
			initialBackgroundColor = getStyle("backgroundColor");
		}

		private function handleClick(event:MouseEvent):void
		{
			if (!itemEditorInstance) startEdit();
		}
		
		private function startEdit():void
		{
			endEdit();
			if (!editorIsRenderer)
			{
				itemEditorInstance = itemEditor.newInstance();
				addChild(itemEditorInstance);
				itemEditorInstance.width = width;
				itemEditorInstance.height = height;
				itemEditorInstance["data"] = dataObject is XML ? dataObject.copy() : dataObject;
				itemEditorInstance.styleName = this;
				itemEditorInstance.setStyle("backgroundColor", 0xe0e0ff);
				itemEditorInstance.visible = true;
			}
			else
			{
				itemEditorInstance = itemRendererInstance;
			}
			if (itemEditorInstance)
			{
				itemEditorInstance.addEventListener(FocusEvent.FOCUS_OUT, handleFocusOut);
				itemEditorInstance.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			}
			itemEditorInstance.setFocus();
		}
		
		private function endEdit(updateData:Boolean = true):void
		{
			if (itemEditorInstance)
			{
				if (updateData)
				{
					dataProvider[dataField] = itemEditorInstance[editorDataField];
					//if (!(dataProvider is XML)) updateDataObject();
					dispatchEvent(new FlexEvent(Event.CHANGE));
				}
			}
			if (itemEditorInstance)
			{
				itemEditorInstance.removeEventListener(FocusEvent.FOCUS_OUT, handleFocusOut);
				itemEditorInstance.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
				if (!editorIsRenderer) removeChild(itemEditorInstance);
				itemEditorInstance = null;
			}
		}
		
		private function handleFocusOut(event:FocusEvent):void
		{
			if (itemEditorInstance == event.currentTarget && !(event.relatedObject && itemEditorInstance.contains(event.relatedObject))) endEdit();
		}
		
		private function handleKeyDown(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.ESCAPE) endEdit(false);
			else if (event.keyCode == Keyboard.ENTER && !editorUsesEnterKey && !event.shiftKey) endEdit(true);
		}
		
		/**
		 * Updates the dataObject value.
		 */
		public function updateDataObject():void
		{
			if (_dataProvider && _dataField)
			{
				dataObject = _dataProvider[_dataField];
			}
		}
		
		/**
		 * A method IXMLNotifiable interface.
		 * @see mx.utils.IXMLNotifiable
		 */
	    public function xmlNotification(
	                         currentTarget:Object,
                             type:String,
                             target:Object,
                             value:Object,
                             detail:Object):void
		{
			var upd:Boolean = false;
			var dpValue:XML = _dataProvider[_dataField].length() == 1 ? XML(_dataProvider[_dataField]) : null;
			switch (type)
			{
				case "textSet":
					if (target.parent() === dpValue) upd = true;
					break;
				case "nodeChanged":
					if (value === dpValue) upd = true;
					break;
			}
			if (upd) updateDataObject();
		}
		/**
		 * Called on MouseOver and MouseOut events of the control.
		 * Sets the background color.
		 */
		protected function mouseHandler(event:MouseEvent):void
		{
			if (event.type == MouseEvent.MOUSE_OVER)
			{
				setStyle("backgroundColor", 0xeeeeff);
			}
			else if (event.type == MouseEvent.MOUSE_OUT)
			{
				setStyle("backgroundColor", initialBackgroundColor);
			}
		}
	}
}