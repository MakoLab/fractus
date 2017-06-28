package com.makolab.components.list
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.controls.List;
	import mx.controls.dataGridClasses.DataGridItemRenderer;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;

	public class DataGridComboHeader extends DataGridItemRenderer
	{
		public function DataGridComboHeader()
		{
			super();
			popUp = new List();
			this.addEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT,rollOutHandler);
			this.addEventListener(MouseEvent.CLICK,clickHandler);
		}
		
		private var _popUp:UIComponent;
		public function set popUp(value:UIComponent):void
		{
			_popUp = value;
			addEventListeners();
			if (_popUp) _popUpFactory = new ClassFactory(Class(getDefinitionByName(getQualifiedClassName(_popUp))));
			else _popUpFactory = null;
		}
		public function get popUp():UIComponent
		{
			return _popUp;
		}
		
		private var _popUpFactory:IFactory;
		public function set popUpFactory(factory:IFactory):void
		{
			_popUpFactory = factory;
			if (_popUpFactory)
			{
				var popUpInstance:Object = _popUpFactory.newInstance();
				if (popUpInstance is UIComponent)
				{
					popUp = (popUpInstance as UIComponent);
				}else{
					throw new Error("The popUp generator must be a UIComponent");
				}
			}
		}
		public function get popUpFactory():IFactory
		{
			return _popUpFactory;
		}
		
		private var _events:Array = [];
		public function set events(value:Array):void
		{
			_events = value;
			addEventListeners();
		}
		public function get events():Array
		{
			return _events;
		}
		
		private function addEventListeners():void
		{
			if (events && popUp)
				for (var i:int = 0; i < events.length; i++)
				{
					if (!popUp.hasEventListener(events[i].type)) popUp.addEventListener(events[i].type,events[i].listener);
				}
		}
		
		private var _dataProvider:Object;
		[Bindable]
		public function set dataProvider(value:Object):void
		{
			_dataProvider = value;
			if (popUp && popUp.hasOwnProperty("dataProvider")) popUp["dataProvider"] = _dataProvider;
		}
		public function get dataProvider():Object
		{
			return _dataProvider;
		}
		
		protected function rollOverHandler(event:MouseEvent):void
		{
			if (popUp)
			{
				PopUpManager.addPopUp(popUp,this);
				PopUpManager.centerPopUp(popUp);
				var offsetX:Number = popUp.x;
				var offsetY:Number = popUp.y;
				popUp.move(offsetX,offsetY + (this.measuredHeight / 2));
				popUp.addEventListener(MouseEvent.ROLL_OUT,popUpRollOutHandler);
			}
		}
		
		protected function rollOutHandler(event:MouseEvent):void
		{
			var mouseOverPopUp:Boolean = false;
			var point:Point = localToGlobal(new Point(mouseX,mouseY));
			//var popUpPoint:Point = localToGlobal(new Point(popUp.mouseX,popUp.mouseY));
			if (popUp/*  && !popUp.hitTestPoint(point.x,point.y,true) && !this.hitTestPoint(point.x,point.y,true) */)
			{
				var objects:Array = popUp.getObjectsUnderPoint(point);
				for (var i:int = 0; i < objects.length; i++)
				{
					if (popUp.contains(objects[i])) 
						mouseOverPopUp = true; 
				}
			}
			if (popUp && !mouseOverPopUp)
			PopUpManager.removePopUp(popUp);
		}
		
		protected function popUpRollOutHandler(event:MouseEvent):void
		{
			var mouseOverPopUp:Boolean = false;
			var point:Point = localToGlobal(new Point(popUp.mouseX,popUp.mouseY));
			//var popUpPoint:Point = localToGlobal(new Point(popUp.mouseX,popUp.mouseY));
			if (popUp/*  && !popUp.hitTestPoint(point.x,point.y,true) && !this.hitTestPoint(point.x,point.y,true) */)
			{
				var objects:Array = popUp.getObjectsUnderPoint(point);
				for (var i:int = 0; i < objects.length; i++)
				{
					if (objects[i] == this) 
						mouseOverPopUp = true; 
				}
			}
			if (popUp && !mouseOverPopUp)
				PopUpManager.removePopUp(popUp);
		}
	
		protected function clickHandler(event:MouseEvent):void
		{
			this.removeEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
			if (popUp) PopUpManager.removePopUp(popUp);
		} 
	}
}