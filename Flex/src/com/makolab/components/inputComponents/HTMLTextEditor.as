package com.makolab.components.inputComponents
{
	import com.makolab.components.util.WatcherManager;
	
	import flash.events.MouseEvent;
	
	import flight.binding.Bind;
	
	import mx.containers.HBox;
	import mx.controls.Button;
	import mx.controls.ComboBox;
	import mx.controls.RichTextEditor;
	import mx.controls.textClasses.TextRange;
	
	public class HTMLTextEditor extends RichTextEditor
	{
		[Bindable]
		public var  tagsDataProvider:Object;
		
		public var  tagsLabelField:String ="@label";
		public var  tagsValueField:String ="@value";
		public var  tagsAddButtonLabel:String = "Add";
		
		public var tagsCombo:ComboBox = new ComboBox();
		public var tagsButtonAdd:Button = new Button();
		
		private var _dataObject:Object;
		
		private var watcherManager:WatcherManager = new WatcherManager();
		
		public function HTMLTextEditor() 
		{
			super();
			tagsCombo.labelField = tagsLabelField;	
			tagsButtonAdd.addEventListener(MouseEvent.CLICK,clickButton);
			watcherManager.setListener(this);
		}
		
		override protected function initializationComplete():void
		{
			
			var box:HBox = new HBox();
			box.setStyle("horizontalGap",0);
			box.addChild(tagsCombo);
			box.addChild(tagsButtonAdd);
			this.toolbar.addChild(box);
			
			Bind.addBinding(tagsCombo, "dataProvider", this, ["tagsDataProvider","*"]);
			
			tagsCombo.width= 140;
			tagsButtonAdd.width = 60;
			box.width=200;
			
			Bind.addBinding(tagsButtonAdd, "label", this, "tagsAddButtonLabel");

			super.initializationComplete();		
				
		}
		
		
		private function clickButton(event:MouseEvent):void
		{	
			var selIndx:int = this.tagsCombo.selectedIndex;
			var val:String = this.tagsDataProvider.*[selIndx][this.tagsValueField].toString();
			this.setValueToText(val);
		}
		private function setValueToText(s:String):void
		{
			 var sel:TextRange = this.selection;
			 sel.text = s ;
			 data = htmlText;
			 dispatchEvent(new Event(Event.CHANGE));
			 this.textArea.setFocus();
		}
		
		public override function  set data(value:Object):void
		{	
			super.data = value;
			if(htmlText.toString() != value.toString())
				htmlText = value.toString();
		}		
	}
}