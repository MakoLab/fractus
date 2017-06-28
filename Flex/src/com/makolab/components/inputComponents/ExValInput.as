package com.makolab.components.inputComponents
{
	import com.greensock.easing.Strong;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.remoteInterface.Int;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.accessibility.ButtonAccImpl;
	import mx.containers.FormItem;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.messaging.channels.StreamingAMFChannel;

	public class ExValInput extends VBox
	{
		public var level:int;
		public var nodeName:String;
		public var attributeName:String;
		public var attributeValue:String;
		public var dataObject:Object;
		
		public var lab:Label;
		public var val:TextInput;
		public var labels:Object;
		public var btn:Button;
		public var text:XML;
		public var mId:int;
		private var lang:XMLList = LanguageManager.getLanguages().langs;
		public function ExValInput(l:XMLList,_name:String,_id:int)
		{
			this.setStyle("borderThickness", "1");
			this.setStyle("borderStyle", "solid");
			this.setStyle("borderColor", "0x888888");
			this.setStyle("paddingLeft", "10");
			this.setStyle("paddingTop", "10");
			
			text=<value><name></name><labels></labels></value>;
			mId=_id;
			text.@id=_id;
			lab=new Label();
			lab.text=LanguageManager.getInstance().labels.common.itemNameShort;
			val=new TextInput();
			val.text=_name;
			text.name=_name;
			val.addEventListener(Event.CHANGE,onChange);
			var hb:HBox=new HBox();
			hb.addChild(lab);
			hb.addChild(val);
			this.addChild(hb);
			var ile:int=2;
			for(var i:int=0;i<lang.length();i++)
			{
				var fi:FormItem=new FormItem();
				fi.label=LanguageManager.getInstance().labels.common.label+" "+lang[i].toString()+":";
				var ti:ExTextInput=new ExTextInput();
				ti.text=l.label.(@lang==lang[i]).toString();
				var str:String=lang[i].toString();
				text.labels.child[text.labels.child.length()]=<label lang={str}>{ti.text}</label>;
				ti.attributeValue=lang[i].toString();
				ti.addEventListener(Event.CHANGE,onChangeLabel)
				fi.addChild(ti);
				fi.width=300;
				fi.setStyle("horizontalAlign","right");
				this.addChild(fi);
				ile++;
			}

			btn=new Button();
			btn.label=LanguageManager.getInstance().labels.common.deleteAll;
			btn.addEventListener(MouseEvent.CLICK,onKlik);
			this.addChild(btn);
			this.height=ile*30;
		}

		private function onKlik(e:MouseEvent):void
		{
			btn.removeEventListener(MouseEvent.CLICK,onKlik);
			this.removeAllChildren();
			this.parent.removeChild(this);
			text=null;
			dispatchEvent(new Event(Event.CHANGE));
		}
		private function onChange(e:Event):void
		{
			trace("value changed");
			text.name=e.currentTarget.text;
			dispatchEvent(new Event(Event.CHANGE));
		}	
		private function onChangeLabel(e:Event):void
		{
			trace("label changed");
			var ln:String=e.currentTarget.attributeValue;
			text.labels.label.(@lang==ln)[0]=e.currentTarget.text;
			dispatchEvent(new Event(Event.CHANGE));
		}	

	}
}