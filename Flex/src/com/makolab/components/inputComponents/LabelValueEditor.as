package com.makolab.components.inputComponents
{
	import flash.events.Event;
	
	import mx.binding.utils.BindingUtils;
	import mx.containers.FormItem;
	import mx.controls.TextInput;
	import mx.core.ClassFactory;
	import mx.core.UIComponent;
	
	import flight.binding.Bind;
	
	[Event(name="change", type="Event")]
	public class LabelValueEditor extends FormItem implements IFormBuilderComponent
	{
		public var itemEditor:ClassFactory = new ClassFactory(TextInput);

		public var editorDataField:String = "text";
		
		public var editorTargetField :String = "data";
		
		public var restrict:String;
		
		public var maxChars:Number;
		
		
//		[Bindable]
//		public function get labelN():String
//		{
//			return label;
//		}
//
//		[Bindable]
//		public function set labelN(value:String):void
//		{
//			label = value;
//		}
		[Bindable]
		public function set dataObject(value:Object):void
		{
			itemEditorInstance[editorTargetField] = value;
		}
		public function get dataObject():Object
		{
			if (itemEditorInstance) return itemEditorInstance[editorDataField];
			else return data;
		}
		
		public var itemEditorInstance:UIComponent;
		
		public function LabelValueEditor()
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
			if(itemEditorInstance is TextInput)	{
				itemEditorInstance["restrict"] = restrict;
				itemEditorInstance["maxChars"] = maxChars;
			}
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