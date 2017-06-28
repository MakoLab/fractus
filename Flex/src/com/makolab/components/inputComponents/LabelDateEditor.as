package com.makolab.components.inputComponents
{
	import flash.events.Event;
	
	import mx.containers.FormItem;
	import mx.controls.TextInput;
	import mx.core.ClassFactory;
	import mx.core.UIComponent;
	
	[Event(name="change", type="Event")]
	public class LabelDateEditor extends FormItem 
	{
		public var itemEditor:ClassFactory = new ClassFactory(TextInput);

		public var editorDataField:String = "text";
		public var editorTargetField :String = "data";
		public var displayTime:Boolean = false;
		[Bindable]
		public function set dataObject(value:Object):void
		{
			if(value&& value.length())
			itemEditorInstance[editorTargetField] = displayTime ? value.replace(/T([0-9:]*).*/, ' $1') : value.substr(0, 10);
		}
		public function get dataObject():Object
		{
			if (itemEditorInstance) return itemEditorInstance[editorDataField];
			else return data;
		}
		
		public var itemEditorInstance:UIComponent;
		
		public function LabelDateEditor()
		{
			super();
			
		}

		override public function set data(value:Object):void
		{
			super.data = value;
			dataObject = value;
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			itemEditorInstance = itemEditor.newInstance();
			itemEditorInstance[editorTargetField] = this.data;
	
				(itemEditorInstance as TextInput).editable=false;
				(itemEditorInstance as TextInput).enabled =false;
			
			addChild(itemEditorInstance);
			itemEditorInstance.addEventListener(Event.CHANGE, editorChangeHandler);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			//itemEditorInstance.width = getStyle("editorWidth")+40;
			//zmienione na 100% aby pasowało do okna itemów
			itemEditorInstance.percentWidth=100;
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
		
		protected function editorChangeHandler(event:Event):void
		{
			dispatchEvent(event);
		}
		
		public function validate():Object
		{
			if (itemEditorInstance is IFormBuilderComponent) return IFormBuilderComponent(itemEditorInstance).validate();
			else return null;
		}
		
		public function commitChanges():void
		{
			if (itemEditorInstance is IFormBuilderComponent) IFormBuilderComponent(itemEditorInstance).commitChanges();
		}
		
		public function reset():void
		{
			if (itemEditorInstance is IFormBuilderComponent) IFormBuilderComponent(itemEditorInstance).reset();
		}	
	}
}