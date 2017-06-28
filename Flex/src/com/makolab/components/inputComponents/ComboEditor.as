package com.makolab.components.inputComponents
{
	import mx.containers.HBox;
	import mx.controls.Label;
	import mx.controls.Button;
	import mx.core.UIComponent;
	import mx.core.IFactory;
	import mx.core.ClassFactory;
	import mx.controls.TextInput;
	import mx.managers.PopUpManager;
	import mx.controls.List;
	import mx.collections.ArrayCollection;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import mx.events.ListEvent;
	import inputComponents.comboEditorClasses.ComboEditorItem;
	import inputComponents.comboEditorClasses.ComboEditorButton;
	import inputComponents.comboEditorClasses.ComboEditorRenderer;

	public class ComboEditor extends HBox
	{
		private var lbl:Label;
		private var button:Button;
		private var bindingContainer:BindingContainer;

		public var itemEditor:IFactory = new ClassFactory(TextInput);
		public var itemRenderer:IFactory = new ClassFactory(TextInput);
		public var editorDataField:String = "text";
		
		public var editorIsRenderer:Boolean = true;
		
		public var dataProvider:Object;
		
		private var _items:Array;
		
		public var checkFillFunction:Function = defaultCheckFill;
		
		private var selectedItem:ComboEditorItem;
		
		public function set items(value:Array):void
		{
			_items = value;
			showDefaultItem();
		}
		public function get items():Array
		{
			return _items;
		}
		
		private var list:List;

		private function showDefaultItem():void
		{
			var defaultItem:ComboEditorItem;
			for (var i:String in items)
			{
				var currentItem:ComboEditorItem = items[i] as ComboEditorItem;
				if (currentItem.isDefault)
				{
					defaultItem = currentItem;
					break;
				}
			}
			if (!defaultItem) defaultItem = items[0];
			showItem(defaultItem);
		}
		
		public function ComboEditor()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			lbl = new Label();
			lbl.text = "Etykieta";
			lbl.setStyle("paddingTop", 3);
			lbl.width = 100;
			lbl.setStyle("fontWeight", "bold");
			button = new ComboEditorButton();
			button.width = 22;
			button.setStyle("textAlign", "center");
			addChild(lbl);
			addChild(button);
			bindingContainer = new BindingContainer();
			bindingContainer.itemEditor = this.itemEditor;
			bindingContainer.itemRenderer = this.itemRenderer;
			bindingContainer.editorIsRenderer = this.editorIsRenderer;
			bindingContainer.editorDataField = this.editorDataField;
			bindingContainer.percentWidth = 100;
			addChild(bindingContainer);
			button.addEventListener(MouseEvent.CLICK, handleClick);
			showDefaultItem();
		}
		
		private function showItem(item:ComboEditorItem):void
		{
			if (item && bindingContainer)
			{
				selectedItem = item;
				bindingContainer.dataField = item.dataField;
				bindingContainer.dataProvider = XML(item.dataProvider ? item.dataProvider : this.dataProvider);
				lbl.text = item.label;
			}
		}
		
		private function showPopup():void
		{
			list = new List();
			list.itemRenderer = new ClassFactory(ComboEditorRenderer);
			list.dataProvider = items;
			PopUpManager.addPopUp(list, this);
			var bounds:Rectangle = button.getBounds(list.parent);
			list.x = bounds.x;
			list.y = this.y + bounds.height + 3;
			list.setStyle("backgroundAlpha", 0.8);
			list.setStyle("cornerRadius", 4);
			list.setStyle("paddingLeft", 6);
			list.setStyle("paddingRight", 6);
			list.height = list.rowHeight * items.length + 4;
			list.addEventListener(MouseEvent.CLICK, handleListClick);
			list.addEventListener(ListEvent.CHANGE, handleListChange);
			for (var i:String in items)
			{
				var currentItem:ComboEditorItem = items[i] as ComboEditorItem;
				currentItem.isSelected = (currentItem == selectedItem);
				currentItem.isFilled = checkFillFunction(currentItem.dataProvider[currentItem.dataField]);
			}
		}
		
		private function hidePopup():void
		{
			PopUpManager.removePopUp(list);
			list.visible = false;
			list.removeEventListener(MouseEvent.CLICK, handleListClick);
			list = null;
		}
		
		private function handleClick(event:MouseEvent):void
		{
			if (list)
			{
				showItem(list.selectedItem as ComboEditorItem);
				hidePopup();
			}
			else showPopup();
		}
		
		private function handleListChange(event:ListEvent):void
		{
			showItem(list.selectedItem as ComboEditorItem);
		}
		
		private function handleListClick(event:MouseEvent):void
		{
			showItem(list.selectedItem as ComboEditorItem);
			hidePopup();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			bindingContainer.height = this.height;
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
		
		private function defaultCheckFill(dataObject:Object):Boolean
		{
			return (dataObject.toString().length > 0);
		}
	}
}