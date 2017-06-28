package com.makolab.components.lineList
{
	import flash.display.DisplayObject;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.controls.Button;
	import mx.controls.DataGrid;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;

	public class LineMenu extends Button
	{
		protected var dropdown:LineMenuDropdown;
		
		private var _operations:Array;
		
		private var _data:Object;
		
		public function set operations(value:Array):void
		{
			_operations = value;
		}
		public function get operations():Array
		{
			return _operations;
		}
		
		public function LineMenu()
		{
			minHeight = 10;
			minWidth = 10;
			addEventListener(FlexEvent.HIDE, hideHandler);
		}
		
		override public function set data(value:Object):void
		{
			this._data = value;
			updateOperations();
		}
		
		[Bindable]
		override public function get data():Object
		{
			return this._data;
		}
		
		private function updateOperations():void
		{
			if (operations) for (var i:String in operations)
			{
				var operation:ILineOperation = operations[i] as ILineOperation;
				operation.dataGrid = listData ? listData.owner as DataGrid : null;
				operation.line = data;
			}			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			graphics.clear();
			graphics.beginFill(0x000000, 1.0);
			var cx:int = unscaledWidth / 2, cy:int = unscaledHeight / 2;
			graphics.moveTo(cx - 4, cy - 3);
			graphics.lineTo(cx + 4, cy - 3);
			graphics.lineTo(cx, cy + 3);
			graphics.endFill();
		}
		
		override protected function measure():void
		{
			// zablokowanie mozliwosci ustawienia wiekszych rozmiarow minimalnych	
		}
		
		public function showDropdown():void
		{
			if (!dropdown)
			{
				dropdown = new LineMenuDropdown();
				dropdown.owner = this;
				dropdown.focusEnabled = false;
				dropdown.setStyle("cornerRadius", 4);
				PopUpManager.addPopUp(dropdown, this);
				dropdown.setStyle("backgroundColor", 0xeeeeee);
				dropdown.setStyle("backgroundAlpha", 0.9);
				for (var i:String in operations)
				{
					var operation:ILineOperation = operations[i] as ILineOperation;
					dropdown.addChild(operation as DisplayObject);
				}
				dropdown.addEventListener(MouseEvent.CLICK, dropdownClickHandler);
			}
			updateOperations();
			var bounds:Rectangle = getBounds(dropdown.parent);
			dropdown.right = bounds.right;
			dropdown.top = bounds.bottom;
			dropdown.visible = true;
		}
		
		public function hideDropdown():Boolean
		{
			if (dropdown && dropdown.visible)
			{
				dropdown.visible = false;
				return true;
			}
			else return false;
		}
		
		override protected function clickHandler(event:MouseEvent):void
		{
			if (!enabled) return;
			super.clickHandler(event);
			if (!hideDropdown()) showDropdown();
		}
		
		protected function dropdownClickHandler(event:MouseEvent):void
		{
			hideDropdown();
		}
		
		override protected function focusOutHandler(event:FocusEvent):void
		{
			super.focusOutHandler(event);
			hideDropdown();
		}
		
		protected function hideHandler(event:FlexEvent):void
		{
			hideDropdown();
		}
		
	}
}