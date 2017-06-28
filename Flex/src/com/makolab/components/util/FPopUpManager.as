package com.makolab.components.util
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import mx.core.Application;
	import mx.core.IFlexDisplayObject;
	import mx.events.FlexMouseEvent;
	import mx.managers.PopUpManager;

	public class FPopUpManager
	{
		public function FPopUpManager()
		{
			super();
		}
		
		public static function addPopUp(window:IFlexDisplayObject,
	                    parent:DisplayObject,
	                    modal:Boolean = false,
	                    childList:String = null):void
	    {
	    	PopUpManager.addPopUp(window,parent,modal, childList);
	    	//window.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE,function ():void{PopUpManager.removePopUp(window);});
	    	var point:Point = new Point(0,(parent.height /* + 1 */));
	    	point = parent.localToGlobal(point);
            if (point.y + window.height > Application.application.screen.height/*  && point.y > (parent.height + window.height) */)
            { 
                // PopUp will go below the bottom of the stage
                // and be clipped. Instead, have it grow up.
                point.y -= (parent.height + window.height/*  + 2 */);
                //initY = -_popUp.height;
            }
            if (point.x + window.width > Application.application.screen.width/*  && point.x > (parent.width + window.width) */)
            { 
                // PopUp will go below the bottom of the stage
                // and be clipped. Instead, have it grow up.
                point.x -= (point.x + window.width) - Application.application.screen.width;//(parent.width + window.width + 2);
                //initY = -_popUp.height;
            }
	    	window.x = point.x;
	    	window.y = point.y;
	    }
	    
	    public static function removePopUp(popUp:IFlexDisplayObject):void
	    {
	    	PopUpManager.removePopUp(popUp);
	    }
	}
}