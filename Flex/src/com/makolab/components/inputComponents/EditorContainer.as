package com.makolab.components.inputComponents
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.containers.Canvas;
	import mx.controls.Label;
	import mx.controls.TextInput;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;

	[Event(name="change", type="flash.events.Event")]
	public class EditorContainer extends Canvas
	{
		/**
		 * Editor factory for the container
		 */
		public var itemEditor:IFactory = new ClassFactory(TextInput);
		
		/**
		 * Renderer factory for the container.
		 */
		private var _itemRenderer:IFactory = new ClassFactory(Label);
		
		/**
		 * Sets the renderer factory.
		 */
		public function set itemRenderer(value:IFactory):void
		{
			this._itemRenderer = value;
			
			if (this.itemRendererInstance)
			{
				this.removeChild(itemRendererInstance);
				this.itemRendererInstance = null;
			}
			
			this.showRenderer();
		}
		
		/**
		 * Set to false disables switching to editor mode.
		 */
		public var editable:Boolean = true;
		
		/**
		 * Gets the renderer factory.
		 */
		public function get itemRenderer():IFactory
		{
			return _itemRenderer;
		}
		
		/**
		 * Specifies whether container should use editor as a renderer.
		 */
		public var editorIsRenderer:Boolean = false;
		
		/**
		 * Specifies whether editor uses enter key so that pressing it won't end editing process.
		 */
		public var editorUsesEnterKey:Boolean = false;
		
		/**
		 * Specifies the editor field from witch to read changed data.
		 */
		public var editorDataField:String = "text";
		
		/**
		 * Specifies destination where to put modified data by editor.
		 */
		public var editorDestination:Object;
		
		/**
		 * Editor instance.
		 */
		public var itemEditorInstance:UIComponent;
		
		/**
		 * Renderer instance.
		 */
		public var itemRendererInstance:UIComponent;
		
		/**
		 * Initial background color what renderer has.
		 */
		private var initialBackgroundColor:Number;
		
		/**
		 * Initializes a new instance of the <code>EditorContainer</code> class.
		 */
		public function EditorContainer()
		{
			super();
			this.focusEnabled = true;
			this.addEventListener(MouseEvent.CLICK, handleClick);
			this.useHandCursor = true;
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseHandler);
			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			this.showRenderer();
		}
		
		/**
		 * Event handler for the <code>FlexEvent.CREATION_COMPLETE</code> event.
		 * 
		 * @param event FlexEvent containing event info.
		 */
		public function creationCompleteHandler(event:FlexEvent):void
		{
			this.initialBackgroundColor = getStyle("backgroundColor");
		}
		
		/**
		 * Event handler for the <code>MouseEvent.MOUSE_OVER</code> and <code>MouseEvent.MOUSE_OUT</code> event.
		 * 
		 * @param event MouseEvent containing event info.
		 */
		protected function mouseHandler(event:MouseEvent):void
		{
			if (event.type == MouseEvent.MOUSE_OVER)
			{
				if (this.editable) this.setStyle("backgroundColor", 0xeeeeff);
			}
			else if (event.type == MouseEvent.MOUSE_OUT)
			{
				this.setStyle("backgroundColor", this.initialBackgroundColor);
			}
		}
		
		/**
		 * Event handler for the <code>MouseEvent.Click</code> event.
		 * 
		 * @param event MouseEvent containing event info.
		 */
		private function handleClick(event:MouseEvent):void
		{
			if (!this.itemEditorInstance) this.startEdit();
		}
		
		/**
		 * Creates editor instance nad starts editing process.
		 */
		private function startEdit():void
		{
			this.endEdit();
			
			if (!editable) return;
			
			if (!this.editorIsRenderer)
			{
				this.itemEditorInstance = this.itemEditor.newInstance();
				this.addChild(itemEditorInstance);
				this.itemEditorInstance.styleName = this;
				this.itemEditorInstance.setStyle("backgroundColor", 0xe0e0ff);
				this.itemEditorInstance.visible = true;
				this.itemEditorInstance.owner = this;
				this.hideRenderer();
			}
			else
			{
				this.itemEditorInstance = this.itemRendererInstance;
			}
			
			this.itemEditorInstance.addEventListener(FocusEvent.FOCUS_OUT, handleFocusOut);
			this.itemEditorInstance.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);			
			this.itemEditorInstance.setFocus();
		}
		
		/**
		 * Hides renderer.
		 */
		private function hideRenderer():void
		{
			this.itemRendererInstance.visible = false;
			this.removeEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
			this.removeEventListener(MouseEvent.MOUSE_OUT, mouseHandler);
			this.setStyle("backgroundColor", this.initialBackgroundColor);
		}
		
		/**
		 * Restores previously hidden renderer using <code>hideRenderer()</code> method.
		 */
		private function restoreHiddenRenderer():void
		{
			this.itemRendererInstance.visible = true;
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseHandler);
		}
		
		/**
		 * Ends editing process and updates data to the specified <code>editorDestination</code>.
		 * 
		 * @param updateData Specifies whether to update data to the <code>editorDestination</code>.
		 */
		private function endEdit(updateData:Boolean = true):void
		{
			if (this.itemEditorInstance)
			{
				if (updateData && this.editorDestination)
				{
					var src:Object = this.itemEditorInstance[this.editorDataField];
					var dst:Object = this.editorDestination;

					if(src is XML)
					{
						if(XML(dst).toXMLString() != XML(src).toXMLString())
						{
							if(String(src.*) != "")
								dst.* = src.*;
							else
								delete dst.*;
						}
					}
					else if (src is XMLList)
					{
						if(XMLList(dst).toXMLString() != XMLList(src).toXMLString())
						{
							if(String(src.*) != "")
								dst.* = src.*;
							else
								delete dst.*;
						}
					}
					else
					{
						if((dst.*).toString() != src.toString())
						{
							dst.* = src;
						}
					}
				}

				this.dispatchEvent(new FlexEvent(Event.CHANGE));
								
				if (!this.editorIsRenderer)
				{
					this.removeChild(itemEditorInstance);
					this.restoreHiddenRenderer();
				}
				
				this.itemEditorInstance.removeEventListener(FocusEvent.FOCUS_OUT, handleFocusOut);
				this.itemEditorInstance.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
				this.itemEditorInstance = null;
			}
		}
		
		/**
		 * Event handler for the <code>FocusEvent.FOCUS_OUT</code> event.
		 * 
		 * @param event FocusEvent containing event info.
		 */
		private function handleFocusOut(event:FocusEvent):void
		{
			if (itemEditorInstance == event.currentTarget && !(event.relatedObject && itemEditorInstance.contains(event.relatedObject))) 
				this.endEdit();
		}
		
		/**
		 * Event handler for the <code>KeyboardEvent.KEY_DOWN</code> event.
		 * 
		 * @param event KeyboardEvent containing event info.
		 */
		private function handleKeyDown(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.ESCAPE)
				this.endEdit(false);
			else if (event.keyCode == Keyboard.ENTER && !editorUsesEnterKey && !event.shiftKey)
				this.endEdit(true);
		}
		
		/**
		 * Creates renderer instance if it doesn't exist.
		 */
		private function showRenderer():void
		{
			if (!this.itemRendererInstance)
			{
				if (this.editorIsRenderer)
				{
					this.itemRendererInstance = this.itemEditor.newInstance();
				}
				else
				{
					this.itemRendererInstance = this.itemRenderer.newInstance();
				}
				
				if (this.itemRendererInstance)
				{
					this.addChild(itemRendererInstance);
				}
			}
		}
	}
}