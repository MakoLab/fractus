package com.makolab.components.inputComponents
{
	import flash.events.Event;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.*;
	import mx.controls.Alert;
	
	public class ColorCurrencyRenderer extends CurrencyRenderer
	{
		public function ColorCurrencyRenderer()
		{
			addEventListener(Event.RENDER, renderListener);
			//this.opaqueBackground = 0xFF0000;	
		}
		
			protected function renderListener(event:Event):void
		{
			if (listData != null) {
				var grid:DataGrid = DataGrid(DataGridListData(listData).owner); 
				if (!grid.isItemHighlighted(this.data) && grid.selectedItem != this.data) { 
	
					if (this.data.kolor=="T") { 
						this.opaqueBackground = 0xFF0000;         
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