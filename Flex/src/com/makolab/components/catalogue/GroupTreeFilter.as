package com.makolab.components.catalogue
{
	import com.makolab.components.util.WatcherManager;
	
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import flight.binding.Bind;
	
	import mx.containers.HBox;
	import mx.controls.CheckBox;
	import mx.controls.LinkButton;
	import mx.managers.PopUpManager;
	import mx.rpc.AbstractOperation;

	public class GroupTreeFilter extends HBox implements ICatalogueFilter
	{
		protected var myTree:GroupTree;
		protected var checkBox:CheckBox;
		protected var button:LinkButton;
		
		[Bindable]
		public var getGroupsOperation:AbstractOperation;
		[Bindable]
		public var saveGroupsOperation:AbstractOperation;
	
		private var showingPopup:Boolean = false;
		
		private var watcherManager:WatcherManager = new WatcherManager();
		
		public function GroupTreeFilter()
		{
			super();
			checkBox = new CheckBox();
			addChild(checkBox);
			button = new LinkButton();
			addChild(button);
			Bind.addBinding(button, "label", this, "label");
			button.addEventListener(MouseEvent.CLICK, handleClick);
			button.focusEnabled = true;
			focusEnabled = true;
		}
		
		private function handleClick(event:MouseEvent):void
		{
			if (showingPopup) hidePopup();
			else showPopup();
		}
		
		public function showPopup():void
		{
			if (!myTree)
			{
				myTree = new GroupTree();
				myTree.labelField = "@name";
				myTree.showRoot = false;
				myTree.width = 200;
				myTree.height = 200;
				PopUpManager.addPopUp(myTree, this);
				myTree.owner = this;
				myTree.getGroupsOperation = getGroupsOperation;
				myTree.saveGroupsOperation = saveGroupsOperation;
				myTree.addEventListener(FocusEvent.FOCUS_OUT, handlePopupFocusOut);
				myTree.focusEnabled = true;
			}
			var bounds:Rectangle = getBounds(myTree.parent);
			myTree.x = bounds.x;
			myTree.y = bounds.bottom;
			myTree.visible = true;
			showingPopup = true;
			myTree.setFocus();
			checkBox.selected = true;
		}
		
		public function hidePopup():void
		{
			if (myTree)
			{
				myTree.visible = false;
				myTree.saveFilter(checkBox.selected);
			}
			showingPopup = false;
		}
		
		public function setParameters(parameters:Object):void
		{
			if (checkBox.selected) parameters.groupFilter = "T";
		}
		
		protected function handlePopupFocusOut(event:FocusEvent):void
		{
			if (showingPopup && event.currentTarget == myTree) hidePopup();
		}
		
	}
}