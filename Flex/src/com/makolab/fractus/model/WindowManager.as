package com.makolab.fractus.model
{
	import com.makolab.fractus.view.ComponentWindow;
	
	import mx.core.UIComponent;
	
	public class WindowManager
	{
		private static var instance:WindowManager;
		
		public function WindowManager()
		{
		}
		
		public static function getInstance():WindowManager
		{
			if (!instance) instance = new WindowManager();
			return instance;
		}
		
		public function bringToFront(parent: UIComponent, window:ComponentWindow):void
		{
			window.maximize();
			parent.setChildIndex(window, parent.numChildren-1);
			window.parentCanvas.setActiveWindow(window);
		}
	}
}