package com.makolab.components.inputComponents
{
	import mx.controls.TextArea;

	public class CSVTextArea extends TextArea
	{
		public function CSVTextArea()
		{
			super();
		}
		
		public var separator:String = "\t";
		
		override public function set data(value:Object):void
		{
			super.data = value;
			if (!value)
			{
				text = "";
				return;
			}
			var a:Array = [];
			var xml:XML = XML(value);
			var headers:XMLList = xml.configuration.*;
			for each (var x:XML in xml.item)
			{
				var b:Array = [];
				for each (var header:XML in headers)
				{
					var s:String = x[header.localName()];
					if (s) b.push(s);
				}
				a.push(b.join(separator));
			}
			this.text = a.join("\n");
		}
	}
}