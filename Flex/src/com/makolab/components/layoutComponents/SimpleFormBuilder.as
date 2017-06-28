package com.makolab.components.layoutComponents
{
	import flash.events.MouseEvent;
	
	import mx.containers.Form;
	import mx.containers.FormHeading;
	import mx.containers.FormItem;
	import mx.controls.Button;
	import mx.controls.CheckBox;
	import mx.controls.ComboBox;
	import mx.controls.DateField;
	import mx.controls.TextInput;
	import mx.core.UIComponent;

	[Event(name="submit", type="com.makolab.components.layoutComponents.FormEvent")]
	public class SimpleFormBuilder extends Form
	{
		public function SimpleFormBuilder()
		{
			super();
		}
		
		private var fields:Object;
		
		private var _config:XMLList;
		
		public var monthNames:Array;
		public var dayNames:Array;
		
		public function set config(value:XMLList):void
		{
			_config = value;
			fields = {};
			removeAllChildren();
			for each (var x:XML in _config)
			{
				var field:UIComponent;
				var dataField:String = null;
				var dataFunction:Function = null;
				switch (String(x.@type))
				{
					case "date":
						field = new DateField();
						var df:DateField = DateField(field);
						df.formatString = "YYYY-MM-DD";
						if (this.monthNames) df.monthNames = this.monthNames;
						if (this.dayNames) df.dayNames = this.dayNames; 
						dataFunction = function(field:DateField):String { return DateField.dateToString(field.selectedDate, "YYYY-MM-DD"); }
						if (x.@value != undefined) df.selectedDate = DateField.stringToDate(x.@value, "YYYY-MM-DD");
						break;
					case "text":
						field = new TextInput();
						dataField = "text";
						if (x.@value != undefined) TextInput(field).text = x.@value;
						break;
					case "select":
						field = new ComboBox();
						dataField = "selectedItem";
						var cb:ComboBox = ComboBox(field);
						cb.dataProvider = x.option;
						cb.labelField = "@label";
						dataFunction = function (field:ComboBox):String { return field.selectedItem.@value; }
						if (x.@value != undefined) cb.selectedItem = x.option.(String(@value) == String(x.@value));
						break;
					case "checkbox":
						field = new CheckBox();
						var checkBox:CheckBox = CheckBox(field);
						dataFunction = function (field:CheckBox):String { return field.selected ? "1" : "0"; }
						if (x.@value != undefined) checkBox.selected = (x.@value == 1);
						break;
					case "label":
						field = new FormHeading();
						break;
					case "submit":
					case "button":
						field = new Button();
						field.addEventListener(MouseEvent.CLICK, handleSubmitClick);
						break;
				}
				if (!field) continue;
				fields[String(x.@name)] = { field : field, dataField : dataField, dataFunction : dataFunction };
				field.percentWidth = 100;
				
				if (field is FormHeading)
				{
					addChild(field);
				}
				else
				{
					var formItem:FormItem = new FormItem();
					formItem.percentWidth = 100;
					formItem.addChild(field);
					addChild(formItem);
				}

				if (field is Button || field is FormHeading)
				{
					field["label"] = x.@label;
				}
				else formItem.label = x.@label;				
			}
		}
		public function get config():XMLList { return _config; }
		
		private function handleSubmitClick(event:MouseEvent):void
		{
			var name:String;
			for (var i:String in fields) if (fields[i].field == event.target) name = i;
			dispatchEvent(FormEvent.createSubmitEvent(getFieldValues(), name));
		}
		
		private function getFieldValues():Object
		{
			var obj:Object = {};
			for (var i:String in fields)
			{
				var f:Object = fields[i];
				if (f.dataFunction)
				{
					obj[i] = String(f.dataFunction(f.field));
				}
				else if (f.dataField)
				{
					obj[i] = String(f.field[f.dataField]);
				}
				//if (obj[i] != undefined) trace(i + "=" + obj[i]);
			}
			return obj;
		}
		
	}
}