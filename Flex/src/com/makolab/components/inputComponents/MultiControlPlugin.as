package com.makolab.components.inputComponents
{
	import com.makolab.components.util.FPopUpManager;
	import com.makolab.fractus.model.LanguageManager;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.controls.Button;
	import mx.controls.ButtonBar;
	import mx.core.Container;
	import mx.core.IDataRenderer;
	import mx.core.IFactory;
	import mx.core.IFlexDisplayObject;
	import mx.events.ItemClickEvent;
	
	import assets.IconManager;
	

	public class MultiControlPlugin
	{
		public function MultiControlPlugin():void
		{
			createChildren();
		}
		
		private var _container:Container;
		
		[Bindable]
		public function set container(value:Container):void
		{
			_container = value;
			createChildren();
		}
		
		public function get container():Container
		{
			return _container;
		}
		
		[Bindable] public var editor:IFactory;
		
		private var _dataProvider:Object = null;
		
		[Bindable]
		public function set dataProvider(value:Object):void
		{
			if (value is Array) collection = new ArrayCollection(value as Array);
			createChildren();
		}
		
		public function get dataProvider():Object
		{
			return collection;
		}
		
		public var maxElementQuantity:int = 10;
		public var minElementQuantity:int = 0;
		public var defaultElementValue:Object = null;
		
		private var children:Array = [];
		
		private var collection:ListCollectionView;//ICollectionView;
		
		public var allowElementQuantityChange:Boolean = true;
		
		private var popUp:IFlexDisplayObject;
		
		private var popUpRelatedControl:DisplayObject;
		
		private var addButton:Button = new Button();
		
		private var addButtonData:Object = {toolTip : LanguageManager.getLabel('common.add'), icon : IconManager.getIcon('add_small'), name : "add"};
		
		private var removeButtonData:Object = {toolTip : LanguageManager.getLabel('common.Delete'), icon : IconManager.getIcon('cancel_small'), name : "remove"};
		
		private var popUpDataProvider:Array = [];
		
		private function createChildren():void
		{
				
			for(var childIndex:int = 0; childIndex < children.length; childIndex++){
				container.removeChild(children[childIndex]);
			}
			children = [];
			if(collection && _container && editor){
				for (var i:int = 0; i < collection.length; i++){
					var control:DisplayObject = container.addChild(editor.newInstance());
					children.push({control : control, index : i});
					(control as IDataRenderer).data = collection[i];
					control.addEventListener(Event.CHANGE,changeHandler);
					if(allowElementQuantityChange)control.addEventListener(MouseEvent.ROLL_OVER,createPopUp);
				}
				if(allowElementQuantityChange){
					addButton.setStyle("icon",IconManager.getIcon('add_small'));
					container.addChild(addButton);
					addButton.height = 24;
					addButton.addEventListener(MouseEvent.CLICK,function (event:MouseEvent):void{addElement(-1);});
				}
			}
			
			updateChildren();
			
			var buttonBar:ButtonBar = new ButtonBar();
			buttonBar.dataProvider = popUpDataProvider;
			buttonBar.addEventListener(ItemClickEvent.ITEM_CLICK,buttonBarClickHandler);
			popUp = buttonBar;
		}
		
		private function buttonBarClickHandler(event:ItemClickEvent):void
		{
			FPopUpManager.removePopUp(popUp)
			switch(event.item.name)
			{
				case "add":
					addElement(container.getChildIndex(popUpRelatedControl));
					break;
				case "remove":
					removeElement(container.getChildIndex(popUpRelatedControl));
					break;
			}
		}
		
		public function addElement(index:int = -1, value:Object = null):void
		{
			if(!value)value = defaultElementValue; 
			var nextIndex:int = children.length;
			if (isNaN(index) || index == -1)index = nextIndex;
			if (collection && _container && editor){
				collection.addItemAt(value,index);
				var control:DisplayObject = container.addChildAt(editor.newInstance(),index);
				var childrenCopy:Array = [];
				for (var i:int = 0; i < children.length + 1; i++){
					if(i == index)childrenCopy.push({control : control, index : index});
					if(children.length > i){
						if(i >= index)childrenCopy.push({control : children[i].control, index : i+1});
						else childrenCopy.push(children[i]);
					}
				}
				children = childrenCopy;
				(control as IDataRenderer).data = collection[index];
				control.addEventListener(Event.CHANGE,changeHandler);
				control.addEventListener(MouseEvent.ROLL_OVER,createPopUp);
			}
			updateChildren();
		}
		
		public function removeElement(index:int):void
		{ 
			if (collection && _container && editor){
				var control:DisplayObject = container.getChildAt(index);
				control.removeEventListener(Event.CHANGE,changeHandler);
				control.removeEventListener(MouseEvent.ROLL_OVER,createPopUp);
				container.removeChildAt(index);
				collection.removeItemAt(index);
				var childrenCopy:Array = [];
				for (var i:int = 0; i < children.length; i++){
					if (i < index)childrenCopy.push(children[i]);
					if (i > index)childrenCopy.push({control : children[i].control, index : i-1});
				}
				children = childrenCopy;
			}
			updateChildren();
		}
		
		private function updateChildren():void
		{
			var allowAdd:Boolean = (children.length < maxElementQuantity);
			var allowRemove:Boolean = (children.length > minElementQuantity);
			addButton.visible = allowAdd;
			addButton.includeInLayout = allowAdd;
			popUpDataProvider = [];
			if (allowAdd) popUpDataProvider.push(addButtonData);
			if (allowRemove) popUpDataProvider.push(removeButtonData);
			if (popUp)(popUp as ButtonBar).dataProvider = popUpDataProvider;
		}
		
		private function changeHandler(event:Event):void
		{
			for (var i:int = 0; i < children.length; i++){
				if(children[i].control == event.target){
					collection[children[i].index] = event.target.data;
				}
			}
		}
		
		private function createPopUp(event:MouseEvent):void
		{
			if(popUpRelatedControl)return;
				FPopUpManager.addPopUp(popUp,(event.currentTarget as DisplayObject),false);
				popUpRelatedControl = event.currentTarget as DisplayObject;
				(event.currentTarget as DisplayObject).removeEventListener(MouseEvent.ROLL_OVER,createPopUp,true);
				(event.currentTarget as DisplayObject).addEventListener(MouseEvent.ROLL_OUT,removePopUp);
				popUp.addEventListener(MouseEvent.ROLL_OUT,removePopUp);
		}
		
		private function removePopUp(event:MouseEvent):void
		{
			if(!popUpRelatedControl)return;
			var controlRight:Number = popUpRelatedControl.x + popUpRelatedControl.width; 
			var popUpRight:Number = popUp.x + popUp.width; 
			var controlLeft:Number = popUpRelatedControl.x; 
			var popUpLeft:Number = popUp.x;
			var commonFieldRight:Number = controlRight;
			var commonFieldLeft:Number = controlLeft; 
			
			var controlBottom:Number = popUpRelatedControl.y + popUpRelatedControl.height; 
			var popUpBottom:Number = popUp.y + popUp.height; 
			var controlTop:Number = popUpRelatedControl.y; 
			var popUpTop:Number = popUp.y;
			var commonFieldBottom:Number = controlBottom;
			var commonFieldTop:Number = controlTop;
			
			if(popUpRight < controlLeft){commonFieldLeft = popUpRight; commonFieldRight = controlLeft}
			if(controlRight < popUpLeft){commonFieldLeft = controlRight; commonFieldRight = popUpLeft}
			if(popUpBottom < controlTop){commonFieldTop = popUpBottom; commonFieldBottom = controlTop}
			if(controlBottom < popUpTop){commonFieldTop = controlBottom; commonFieldBottom = popUpTop}
			
			if(
				!popUp.hitTestPoint(event.stageX,event.stageY,true) && 
				!popUpRelatedControl.hitTestPoint(event.stageX,event.stageY,true)/*  &&
				(
					(event.stageX < commonFieldLeft || event.stageX > commonFieldRight) &&
					(event.stageY < commonFieldBottom || event.stageY > commonFieldTop)
				) */
			){
				if(popUp)FPopUpManager.removePopUp(popUp);
				popUpRelatedControl.addEventListener(MouseEvent.ROLL_OVER,createPopUp);
				popUpRelatedControl.removeEventListener(MouseEvent.ROLL_OUT,removePopUp);
				popUpRelatedControl = null;
			}
		}
	}
}