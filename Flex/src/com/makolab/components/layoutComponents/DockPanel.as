package com.makolab.components.layoutComponents
{
	import flash.events.MouseEvent;
	
	import mx.core.DragSource;
	import mx.managers.DragManager;
	/**
	 * Use <code>DockPanel</code> as a container for components you want to make movable. Using <code>DockPanel</code> you let a user to drag and drop it's content inside the <code>DockingVBox</code> instance (change order) and from one <code>DockingVBox</code> to an another.    
	 * @author Tomek
	 * @see DockingVBox
	 * @see DockManager
	 */
	public class DockPanel extends CollapsablePanel
	{	
			
		public function DockPanel()
		{
			super();
		}
		
		private var _movable:Boolean = true;
		[Bindable]
		public function set movable(value:Boolean):void
		{
			_movable = value;
			if (_movable)
				if(!this.titleBar.hasEventListener(MouseEvent.MOUSE_DOWN))
					this.titleBar.addEventListener(MouseEvent.MOUSE_DOWN,addMoveListener);
			else
				if(this.titleBar.hasEventListener(MouseEvent.MOUSE_DOWN))
					this.titleBar.removeEventListener(MouseEvent.MOUSE_DOWN,addMoveListener);
		}
		public function get movable():Boolean {return _movable;}
		
		override protected function createChildren():void
		{
			super.createChildren();
			if (movable) this.titleBar.addEventListener(MouseEvent.MOUSE_DOWN,addMoveListener);
			if (titleBarControls && panelTitleBar)
				for (var i:int = 0; i < titleBarControls.length; i++) panelTitleBar.addChild(titleBarControls[i]);
		}
		
		private function addMoveListener(event:MouseEvent):void
		{
			this.titleBar.addEventListener(MouseEvent.MOUSE_MOVE,dragMe);
		}
		
		private function dragMe(event:MouseEvent):void
		{
			this.titleBar.removeEventListener(MouseEvent.MOUSE_MOVE,dragMe);
			var dragSource:DragSource = new DragSource();
			dragSource.addData(true,"DockPanel");
			DragManager.doDrag(this,dragSource,event);
		}
		
		private var _titleBarControls:Array = [];
		public function set titleBarControls(value:Array):void
		{
			var i:int;
			if (_titleBarControls && panelTitleBar){
				for (i = 0; i < _titleBarControls.length; i++) panelTitleBar.removeChild(_titleBarControls[i]);
			}
			_titleBarControls = value;
			if (_titleBarControls && panelTitleBar)
				for (i = 0; i < _titleBarControls.length; i++) panelTitleBar.addChild(_titleBarControls[i]);
		}
		public function get titleBarControls():Array
		{
			return _titleBarControls;
		}
	}
}