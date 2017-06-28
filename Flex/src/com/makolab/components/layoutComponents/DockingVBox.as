package com.makolab.components.layoutComponents
{
	import flash.geom.Point;
	
	import mx.containers.VBox;
	import mx.core.IUIComponent;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	/**
	 * <code>DockingVBox</code> is a container that in cooperation with <code>DockPanel</code> class and <code>DockManager</code> class lets you support visual components drag and drop.
	 * 
	 * @author Tomek
	 * @see DockManager
	 * @see DockPanel
	 */
	
	public class DockingVBox extends VBox
	{
		
		public function DockingVBox()
		{
			super();
			this.setStyle("backgroundColor","white");
			this.setStyle("backgroundAlpha", 0);
			this.setStyle("borderColor","blue");
			this.setStyle("borderStyle","solid");
			this.setStyle("borderThickness",0);
			this.addEventListener(DragEvent.DRAG_ENTER,dragEnterHandler);
			this.addEventListener(DragEvent.DRAG_EXIT,dragExitHandler);
			this.addEventListener(DragEvent.DRAG_DROP,dragDropHandler);
			this.addEventListener(DragEvent.DRAG_OVER,dragOverHandler);
		}
		
		private var childAddIndex:int = 0;
		private var showDropLine:Boolean = false;
		
		private function dragOverHandler(event:DragEvent):void
		{
			var point:Point = this.localToGlobal(new Point(this.mouseX,this.mouseY));
			var children:Array = this.getChildren();
			var index:int = 0;
			for(var i:int=0;i<children.length;i++){
				if(point.y < children[i].localToGlobal(new Point(0,children[i].height / 2)).y && (i > 0 && (point.y >= children[i-1].localToGlobal(new Point(0,children[i-1].height / 2)).y))){index = i;break}
			}
			if(children.length > 0 && point.y >= (children[children.length-1].y + (children[children.length-1].height / 2)))index = children.length;
			if(childAddIndex != index){childAddIndex = index;invalidateDisplayList()};
		}
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			this.graphics.clear();
			if(showDropLine){
				var lineY:Number = 0;
				if(childAddIndex < this.getChildren().length)lineY = this.contentToLocal(new Point(0,this.getChildAt(childAddIndex).y)).y - (this.getStyle("verticalGap") / 2);
				else lineY = childAddIndex > 0 ? this.contentToLocal(new Point(0,this.getChildAt(childAddIndex-1).y)).y + this.getChildAt(childAddIndex-1).height + (this.getStyle("verticalGap") / 2) : 0;
				if(lineY >= 0){
					this.graphics.lineStyle(3,0x00BB00,1);
					this.graphics.moveTo(0,lineY);
					this.graphics.lineTo(unscaledWidth,lineY);
					this.graphics.endFill();
				}
			}
		}
		private function disableChildren():void
		{
			var children:Array = this.getChildren();
			for(var i:int=0;i<children.length;i++){
				children[i].enabled = false;
			}
		}
		private function enableChildren():void
		{
			var children:Array = this.getChildren();
			for(var i:int=0;i<children.length;i++){
				children[i].enabled = true;
			}
		}
		private function dragEnterHandler(event:DragEvent):void
		{
			if(event.dragSource.hasFormat('DockPanel')){
				disableChildren();
				this.setStyle("borderThickness",1);
				showDropLine = true;
				DragManager.acceptDragDrop(this);
			}
		}
		private function dragExitHandler(event:DragEvent):void
		{
			enableChildren();
			this.setStyle("borderThickness",0);
			showDropLine = false;
			this.graphics.clear();
		}
		private function dragDropHandler(event:DragEvent):void
		{
			enableChildren();
			showDropLine = false;
			this.graphics.clear();
			var point:Point = new Point(this.mouseX,this.mouseY);
			var children:Array = this.getChildren();
			var index:int = 0;
			var newElement:Boolean = true;
			for(var i:int=0;i<children.length;i++){
				if(children[i] === event.dragInitiator){newElement = false};
				if(point.y < (children[i].y + (children[i].height / 2)) && (i > 0 && (point.y >= children[i-1].y + (children[i-1].height / 2)))){index = i;break}
			}
			if(children.length > 0 && point.y >= (children[children.length-1].y + (children[children.length-1].height / 2)))index = children.length;
			this.setStyle("borderThickness",0);
			var dockElement:IUIComponent = event.dragInitiator;
			
			if(index > this.getChildren().length)index = this.getChildren().length;
			if(index > 0 && dockElement !== this.getChildAt(index -1)){
				this.addChildAt(dockElement as DockPanel,index < this.getChildren().length ? index : (newElement ? this.getChildren().length : this.getChildren().length - 1));
			}
			if(index == 0)this.addChildAt(dockElement as DockPanel,0);
		}
	}
}