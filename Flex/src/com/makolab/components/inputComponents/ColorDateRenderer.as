package com.makolab.components.inputComponents
{
	import com.makolab.components.util.Tools;
	
	import flash.events.Event;
	
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.*;
	
	public class ColorDateRenderer extends DateRenderer
	{
		public function ColorDateRenderer()
		{
			addEventListener(Event.RENDER, renderListener);
			//this.opaqueBackground = 0xFF0000;	
		}
		
			protected function renderListener(event:Event):void
		{
			if (listData != null) {
				var grid:DataGrid = DataGrid(DataGridListData(listData).owner); 
				if (!grid.isItemHighlighted(this.data) && grid.selectedItem != this.data) { 
	
					if (this.data.@issueDate<Tools.dateToIso(new Date())) { 
						this.opaqueBackground = 0xdb8f8f;         
					}   
					else {  
						this.opaqueBackground = null; 
					} 
				} 
				else {  
					this.opaqueBackground = null;     
				}  
			}
		}
	}
}