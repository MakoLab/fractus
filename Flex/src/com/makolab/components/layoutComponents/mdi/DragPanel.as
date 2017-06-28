package com.makolab.components.layoutComponents.mdi
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	import mx.core.SpriteAsset;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;

	[Event(name="resizeClick", type="flash.events.MouseEvent")]
	[Event(name="tbMouseDown", type="flash.events.MouseEvent")]
	public class DragPanel extends TitleWindow
	{
		public static const RESIZE_CLICK:String = "resizeClick";
		public static const TB_MOUSE_DOWN:String = "tbMouseDown";
		
		public var parentCanvas:DragCanvas;
		
		// Add the creationCOmplete event handler.
		public function DragPanel()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
			showCloseButton = true;
		}
		
		// Expose the title bar property for draggin and dropping.
		[Bindable]
		public var myTitleBar:UIComponent;
					
		private function creationCompleteHandler(event:Event):void
		{
			myTitleBar = titleBar;	
			myTitleBar.addEventListener(MouseEvent.MOUSE_DOWN, tbMouseHandler);
			// Add the resizing event handler.	
			addEventListener(MouseEvent.MOUSE_DOWN, resizeHandler);
		}

		private function tbMouseHandler(event:MouseEvent):void
		{
			// ignore close button click
			if (event.target is Button || isMaximized) return;
			var newEvent:MouseEvent = new MouseEvent
			(
				TB_MOUSE_DOWN, true, false,
				event.localX, event.localY, event.relatedObject, event.ctrlKey, event.altKey, event.shiftKey, event.buttonDown, event.delta
			);
			dispatchEvent(newEvent);
		}
		
		protected var minShape:SpriteAsset;
		protected var restoreShape:SpriteAsset;

		override protected function createChildren():void
		{
				super.createChildren();
			
			// Create the SpriteAsset's for the min/restore icons and 
			// add the event handlers for them.
			minShape = new SpriteAsset();
			minShape.name = "minSprite";
			minShape.addEventListener(MouseEvent.MOUSE_DOWN, minPanelSizeHandler);
			minShape.addEventListener(MouseEvent.MOUSE_OVER, spriteOverHandler);
			minShape.addEventListener(MouseEvent.MOUSE_OUT, spriteOutHandler);
			titleBar.addChild(minShape);

			restoreShape = new SpriteAsset();
			restoreShape.name = "restoreSprite";
			restoreShape.addEventListener(MouseEvent.MOUSE_DOWN, restorePanelSizeHandler);
			restoreShape.addEventListener(MouseEvent.MOUSE_OVER, spriteOverHandler);
			restoreShape.addEventListener(MouseEvent.MOUSE_OUT, spriteOutHandler);
			titleBar.addChild(restoreShape);
		}
			
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// Create invisible rectangle to increase the hit area of the min icon.
			drawButtonBackground(minShape, false);

			// Draw min icon.
			drawMinShape();
				
			// Create invisible rectangle to increase the hit area of the restore icon.
			drawButtonBackground(restoreShape, false);
			
			// Draw restore icon.
			drawRestoreShape();
		}
					
		private var myRestoreHeight:int;
		private var initialCornerRadius:Number;
		private var isMinimized:Boolean = false;
		private var isMaximized:Boolean = false;
					
		// Minimize panel event handler.
		private function minPanelSizeHandler(event:Event):void
		{
			event.stopImmediatePropagation();
			if (isMinimized != true)
			{
				myRestoreHeight = height;	
				height = titleBar.height;
				isMinimized = true;	
				// Don't allow resizing when in the minimized state.
				removeEventListener(MouseEvent.MOUSE_DOWN, resizeHandler);
			}				
		}
		
		private function spriteOverHandler(event:Event):void
		{
			// Create invisible rectangle to increase the hit area of the min icon.
			drawButtonBackground(SpriteAsset(event.target));
			// Draw icon.
			if(event.target.name == "minSprite")drawMinShape();
			else if (event.target.name == "restoreSprite")drawRestoreShape();
		}
		
		private function spriteOutHandler(event:Event):void
		{
			// Create invisible rectangle to increase the hit area of the min icon.
			drawButtonBackground(SpriteAsset(event.target), false);
			// Draw icon.
			if(event.target.name == "minSprite")drawMinShape();
			else if (event.target.name == "restoreSprite")drawRestoreShape();
		}
		
		private function drawButtonBackground(target:SpriteAsset, visible:Boolean = true):void
		{
			var alphaLine:Number = visible?0.3:0;
			var alphaFill:Number = visible?1:0;
			var drawX:Number = 0;
			if(target.name == "minSprite")drawX = 54;
			else if (target.name == "restoreSprite")drawX = 40;
		
			// Create background
			target.graphics.clear();
			target.graphics.lineStyle(0.1, 0, alphaLine);
			target.graphics.beginFill(0xDDDDDD, alphaFill);
			target.graphics.drawRoundRect(unscaledWidth - drawX, 3, 15, 15, 3);		
		}
		
		private function drawMinShape():void
		{
			// Draw min icon.
			minShape.graphics.lineStyle(2, 0, 0.8);
			minShape.graphics.beginFill(0xFFFFFF, 0.0);
			minShape.graphics.drawRect(unscaledWidth - 50, 14, 8, 2);
		}
		
		private function drawRestoreShape():void
		{
			// Draw restore icon.
			restoreShape.graphics.lineStyle(2, 0, 0.8);
			restoreShape.graphics.beginFill(0xFFFFFF, 0.0);
			restoreShape.graphics.drawRect(unscaledWidth - 36, 8, 8, 8);
			if (isMaximized || isMinimized)
			{
				restoreShape.graphics.moveTo(unscaledWidth - 36, 10);
				restoreShape.graphics.lineTo(unscaledWidth - 28, 10);
			}
			// Draw resize graphics if not minimzed or maximized.				
			graphics.clear()
			if (isMinimized == false && isMaximized == false)
			{
				graphics.lineStyle(2, 0, 0.8);
				graphics.moveTo(unscaledWidth - 6, unscaledHeight - 1)
				graphics.curveTo(unscaledWidth - 3, unscaledHeight - 3, unscaledWidth - 1, unscaledHeight - 6);						
				graphics.moveTo(unscaledWidth - 6, unscaledHeight - 4)
				graphics.curveTo(unscaledWidth - 5, unscaledHeight - 5, unscaledWidth - 4, unscaledHeight - 6);						
			}
		}
		
		private var initialBounds:Rectangle;
		 
		// Restore panel event handler.
		private function restorePanelSizeHandler(event:Event):void
		{
			event.stopImmediatePropagation();
			if (isMinimized == true)
			{
				height = myRestoreHeight;
				isMinimized = false;	
				// Allow resizing in restored state.				
				addEventListener(MouseEvent.MOUSE_DOWN, resizeHandler);
			}
			else if (isMaximized) unMaximize();
			else if (parentCanvas) maximize();
		}
		
		public function maximize(bounds:Rectangle = null):void
		{
			if (isMaximized) return;
			if (bounds) initialBounds = bounds;
			else initialBounds = this.getBounds(parentCanvas);
			//var bounds:Rectangle = parentCanvas.getBounds(parentCanvas);
			//this.width = bounds.width;
			//this.height = bounds.height;
			this.percentHeight = 100;
			this.percentWidth = 100;
			this.move(0, 0);
			initialCornerRadius = getStyle("cornerRadius");
			setStyle("cornerRadius", 0);
			isMaximized = true;
		}
		
		protected function unMaximize():void
		{
			if (!isMaximized) return;
			width = initialBounds.width >= minWidth ? initialBounds.width : minWidth;
			height = initialBounds.height >= minHeight ? initialBounds.height : minHeight;
			move(initialBounds.x, initialBounds.y);
			setStyle("cornerRadius", initialCornerRadius);
			isMaximized = false;
		}
		
		// Resize panel event handler.
		public  function resizeHandler(event:MouseEvent):void
		{
			if (isMaximized) return;
			// Determine if the mouse pointer is in the lower right 7x7 pixel
			// area of the panel. Initiate the resize if so.
			
			// Lower left corner of panel
			var lowerLeftX:Number = x + width; 
			var lowerLeftY:Number = y + height;
				
			// Upper left corner of 7x7 hit area
			var upperLeftX:Number = lowerLeftX-7;
			var upperLeftY:Number = lowerLeftY-7;
				
			// Mouse positionin Canvas
			var panelRelX:Number = event.localX + x;
			var panelRelY:Number = event.localY + y;

			// See if the mousedown is in the lower right 7x7 pixel area
			// of the panel.
			if (upperLeftX <= panelRelX && panelRelX <= lowerLeftX)
			{
				if (upperLeftY <= panelRelY && panelRelY <= lowerLeftY)
				{		
					event.stopPropagation();		
					var rbEvent:MouseEvent = new MouseEvent(RESIZE_CLICK, true);
					// Pass stage coords to so all calculations using global coordinates.
					rbEvent.localX = event.stageX;
					rbEvent.localY = event.stageY;
					dispatchEvent(rbEvent);	
				}
			}				
		}		
	}
}