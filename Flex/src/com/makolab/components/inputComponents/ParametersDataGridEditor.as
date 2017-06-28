package com.makolab.components.inputComponents
{
		import flash.events.KeyboardEvent;
		import flash.ui.Keyboard;
		import mx.controls.DataGrid;
	
	public class ParametersDataGridEditor extends DataGrid
	{
 	
 			public  var text:String = "";   
 			 
            public function ParametersDataGridEditor()
            {      
            	super(); 			
            }   
 
 			override protected function keyDownHandler(event:KeyboardEvent):void
 			{  
 				if(event.keyCode ==  Keyboard.ENTER)
 				{
 					event.stopImmediatePropagation();
 					return;
 				} 
 				super.keyDownHandler(event);
 				
 			}
	}
}