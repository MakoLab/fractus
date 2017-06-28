package com.makolab.components.lineList
{
	import com.makolab.fractus.model.ModelLocator;
	
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ListCollectionView;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.listClasses.ListBaseContentHolder;
	import mx.events.DataGridEventReason;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	import mx.utils.ColorUtil;

	[Event(name="itemFieldChange", type="mx.events.DataGridEvent")]
	[Event(name="addLine", type="mx.events.DataGridEvent")]
	public class LineList extends AutoSizeDataGrid
	{
		import mx.controls.TextInput;
		import mx.core.EventPriority;
		import mx.events.DataGridEvent;
		
		public var autoAddLines:Boolean = false;
		//public var newLineTemplate:Object = null;
		public var newLineTemplateFunction:Function = null;
		public var enterLeavesEditor:Boolean = true;
		private var keyDownEvent:KeyboardEvent = null;
		
		public var rowColorFunction:Function;
		
		private var temporaryLine:Object;
		private var createLinePending:Boolean = false;
		
		public var rowTextColorFunction:Function;
		
		public function LineList()
		{
			super();
			sortableColumns = false;
			dragEnabled = true;
			addEventListener(DragEvent.DRAG_ENTER, dragHandler);
			addEventListener(DragEvent.DRAG_DROP, dragHandler);
			addEventListener(DataGridEvent.ITEM_EDIT_END,itemEditEndHandler,false,EventPriority.DEFAULT_HANDLER - 1);
			addEventListener(DataGridEvent.ITEM_EDIT_BEGINNING,beginningHandler,false,EventPriority.DEFAULT_HANDLER - 1);
			addEventListener(FocusEvent.KEY_FOCUS_CHANGE,keyFocusChangeHandler);
		}
		
		private function beginningHandler(event:DataGridEvent):void
		{
			if (event.isDefaultPrevented() && keyDownEvent) moveNext(keyDownEvent,event.columnIndex,event.rowIndex);
		}
		
		public function updateDocument():void
		{
			updateList();
		}
		
/*
  		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			if (keyboardNavigate(event))
			{
				event.stopImmediatePropagation();
				return;	
			}
			var newEvent:KeyboardEvent;
			var newCode:int;
			var shift:Boolean;
			switch (event.keyCode) {
				case Keyboard.UP: newCode = Keyboard.ENTER; shift = true; 
				case Keyboard.DOWN: newCode = Keyboard.ENTER; shift = false;
				case Keyboard.LEFT: newCode = Keyboard.TAB; shift = false;
				case Keyboard.RIGHT: newCode = Keyboard.TAB; shift = true;
				case Keyboard.ENTER: newCode = Keyboard.TAB; shift = false;
			}
			if (newCode) super.
			
			super.keyDownHandler(event);
		}
*/

  		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			if (keyboardNavigate(event))
			{
				event.stopImmediatePropagation();
				event.preventDefault();
			}
			else super.keyDownHandler(event);
		}
		
		override protected function focusInHandler(event:FocusEvent):void
		{
			super.focusInHandler(event);
		}
		
		override protected function focusOutHandler(event:FocusEvent):void
		{
			super.focusOutHandler(event);
		}
		
		private function keyFocusChangeHandler(event:FocusEvent):void
		{
			// Mialo wychodzic tabulatorwm z grida, ale nie dziala, bo Flex...
			//if (event.keyCode == Keyboard.TAB) event.stopImmediatePropagation(); 
		}
		
		private function itemEditEndHandler(event:DataGridEvent):void
		{
			var event:DataGridEvent = new DataGridEvent(
				"itemFieldChange",
				event.bubbles,
				event.cancelable,
				event.columnIndex,
				event.dataField,
				event.rowIndex,
				event.reason,
				event.itemRenderer,
				event.localX
				)
			dispatchEvent(event);
		}

		private function keyboardNavigate(event:KeyboardEvent):Boolean
		{
			keyDownEvent = event;
			
			var dr:int = 0, dc:int = 0;
			switch (event.keyCode) {
				case Keyboard.UP: dr--; break;
				case Keyboard.DOWN: dr++; break;
				case Keyboard.LEFT: dc--; break;
				case Keyboard.RIGHT: dc++; break;
				case Keyboard.ENTER: event.shiftKey ? dc-- : dc++; break;
				//case Keyboard.TAB: event.shiftKey ? dc-- : dc++; break;
				case Keyboard.PAGE_UP: dr -= rowCount - 1; break;
				case Keyboard.PAGE_DOWN: dr += rowCount - 1; break;
			}
			
			if (editedItemPosition && (dc || dr) )
			{
				return moveNext(event,editedItemPosition.columnIndex,editedItemPosition.rowIndex);
				/* var r:int = editedItemPosition.rowIndex + dr, c:int = editedItemPosition.columnIndex + dc;
				endEdit(DataGridEventReason.NEW_ROW);
				
				//idziemy w prawo az do napotkania pierwszej edytowalnej kolumy lub wyjdziemy poza zakres
				if (dc > 0)
				{
					while(columns[c] && !columns[c].editable)
						c++;
				}
				else if (dc < 0)
				{
					while(c>0 && columns[c] && !columns[c].editable)
						c--;
				}
					
				//jezeli wyszlismy za zakres to przechodzimy do pierwszej edytowalnej kolumny
				//w nowym wierszu
				if (c >= columnCount || (c == 0 && !columns[c].editable))
				{
					c = 0;
					
					while(columns[c] && !columns[c].editable)
						c++;
					
					if(dc>0) r++;
				}
				
				if (c >= 0 && c < columnCount && columns[c].editable)
				{
					if (r < 0)
					{
						if (autoAddLines)
						{
							addLine(null, 0);
						}
						dispatchEvent(new DataGridEvent(DataGridEvent.ITEM_EDIT_BEGINNING, false, true, c, DataGridColumn(this.columns[c]).dataField, 0));
					}
					else if (r < dataProvider.length)
					{
				        dispatchEvent(new DataGridEvent(DataGridEvent.ITEM_EDIT_BEGINNING, false, true, c, DataGridColumn(this.columns[c]).dataField, r));
				        return true;
					}
					else
					{
						if (autoAddLines)
						{
							addLine();
						}
						dispatchEvent(new DataGridEvent(DataGridEvent.ITEM_EDIT_BEGINNING, false, true, c, DataGridColumn(this.columns[c]).dataField, dataProvider.length - 1));
						return true;
					}
				} */
			}
			return false;
		}
		
		private function moveNext(keyboardEvent:KeyboardEvent,column:int,row:int):Boolean
		{
			var dr:int = 0, dc:int = 0;
			switch (keyboardEvent.keyCode) {
				case Keyboard.UP: dr--; break;
				case Keyboard.DOWN: dr++; break;
				case Keyboard.LEFT: dc--; break;
				case Keyboard.RIGHT: dc++; break;
				case Keyboard.ENTER: keyboardEvent.shiftKey ? dc-- : dc++; break;
				case Keyboard.TAB: keyboardEvent.shiftKey ? dc-- : dc++; break;
				case Keyboard.PAGE_UP: dr -= rowCount - 1; break;
				case Keyboard.PAGE_DOWN: dr += rowCount - 1; break;
			}
			var r:int = row + dr, c:int = column + dc;
			endEdit(DataGridEventReason.NEW_ROW);
			
			//idziemy w prawo az do napotkania pierwszej edytowalnej kolumy lub wyjdziemy poza zakres
			if (dc > 0)
			{
				while(columns[c] && !columns[c].editable)
					c++;
			}
			else if (dc < 0)
			{
				while(c>0 && columns[c] && !columns[c].editable)
					c--;
			}
				
			//jezeli wyszlismy za zakres to przechodzimy do pierwszej edytowalnej kolumny
			//w nowym wierszu
			if (c >= columnCount || (c == 0 && !columns[c].editable))
			{
				c = 0;
				
				while(columns[c] && !columns[c].editable)
					c++;
				
				if(dc>0) r++;
			}
			
			if (c >= 0 && c < columnCount && columns[c].editable)
			{
				if (r < 0)
				{
					if (autoAddLines)
					{
						addLine(null, 0);
					}
					dispatchEvent(new DataGridEvent(DataGridEvent.ITEM_EDIT_BEGINNING, false, true, c, DataGridColumn(this.columns[c]).dataField, 0));
				}
				else if (r < dataProvider.length)
				{
			        dispatchEvent(new DataGridEvent(DataGridEvent.ITEM_EDIT_BEGINNING, false, true, c, DataGridColumn(this.columns[c]).dataField, r));
			        return true;
				}
				else
				{
					if (autoAddLines)
					{
						addLine();
					}
					dispatchEvent(new DataGridEvent(DataGridEvent.ITEM_EDIT_BEGINNING, false, true, c, DataGridColumn(this.columns[c]).dataField, dataProvider.length - 1));
					return true;
				}
			}
			return false;	
		}
		
		private function dragHandler(event:DragEvent):void
		{
			if (event.type == DragEvent.DRAG_ENTER)
			{
				if (event.dragInitiator == this) DragManager.acceptDragDrop(this);
			}
			else if (event.type == DragEvent.DRAG_DROP)
			{
				var o:Object = event.dragSource.dataForFormat("items");
				var item:XML = o[0] as XML;
				if (item is XML)
				{
					deleteLine(item);
					var n:int = Math.round((event.localY - headerHeight) / rowHeight);
					var len:int = ListCollectionView(dataProvider).length;
					if (n < 0) n = 0;
					if (n > len) n = len;
					addLine(item, n);
				}
				
			}
		}
		
		public function addLine(newLine:Object = null, index:int = -1):Object
		{
			if (!newLine)
			{
				if(this.newLineTemplateFunction != null)
					newLine = this.newLineTemplateFunction();
				//else
				//	newLine = ObjectUtil.copy(newLineTemplate);
			}
			if (index >= 0)
			{
				(dataProvider as ListCollectionView).addItemAt(newLine, index);
			}
			else
			{
				(dataProvider as ListCollectionView).addItem(newLine);
			}
			updateList();
			var rowIndex:int = index == -1 ? ((dataProvider as ListCollectionView).length - 1) : index;  
			dispatchEvent(new DataGridEvent("addLine",false,false,-1,null,rowIndex));

			return newLine;
		}
		
		public function editLine(line:Object, field:String):void
		{
			var row:int = -1, col:int = -1;
			for (var i:int = 0; i < (dataProvider as ListCollectionView).length; i++)
			{
				if (dataProvider[i] == line) row = i;
			}
			for (var j:int = 0; j < columns.length; j++) if (columns[j].dataField == field) col = j;
			if (row >=0 && col >= 0)
			{
				editedItemPosition = { columnIndex : col, rowIndex : row };
			}
		}
		
		public function deleteLine(line:XML):void
		{
			if (line && line.parent()) delete line.parent().children()[line.childIndex()];
		}
		
		public function clear():void
		{
			(dataProvider as ListCollectionView).removeAll();
		}
		
		override protected function drawRowBackground(s:Sprite, rowIndex:int, y:Number, height:Number, color:uint, dataIndex:int):void
		{
			var dp:ListCollectionView = dataProvider as ListCollectionView;
			if (dp && rowColorFunction != null)
			{
				var item:Object;
				if (dataIndex < dp.length) item = dp.getItemAt(dataIndex);
				var c:Number = NaN;
				if (item != null) c = rowColorFunction(item);
				if (!isNaN(c)) color = ColorUtil.rgbMultiply(color, c);
				super.drawRowBackground(s, rowIndex, y, height, color, dataIndex);
			}
			super.drawRowBackground(s, rowIndex, y, height, color, dataIndex);
		}

	    private function endEdit(reason:String):Boolean
	    {
	        // this happens if the renderer is removed asynchronously ususally with FDS
	        if (!editedItemRenderer)
	            return true;
	        //inEndEdit = true;
	
	        var dataGridEvent:DataGridEvent =
	            new DataGridEvent(DataGridEvent.ITEM_EDIT_END, false, true);
	            // ITEM_EDIT events are cancelable
	        dataGridEvent.columnIndex = editedItemPosition.columnIndex;
	        dataGridEvent.dataField = columns[editedItemPosition.columnIndex].dataField;
	        dataGridEvent.rowIndex = editedItemPosition.rowIndex;
	        dataGridEvent.itemRenderer = editedItemRenderer;
	        dataGridEvent.reason = reason;
	        dispatchEvent(dataGridEvent);
	        // set a flag to not open another edit session if the item editor is still up
	        // this means somebody wants the old edit session to stay.
	        //dontEdit = itemEditorInstance != null;
	        // trace("dontEdit", dontEdit);
	
			/*
	        if (reason == DataGridEventReason.CANCELLED)
	        {
	            losingFocus = true;
	            setFocus();
	        }
			*/
			
	        //inEndEdit = false;
	
	        return !(dataGridEvent.isDefaultPrevented())
	    }
	    
	    private var _permissionKey:String;
			
		public function get permissionKey():String {
			return _permissionKey;
		}
		
		public function set permissionKey(value:String):void {
			_permissionKey = value;
			
			if(ModelLocator.getInstance().permissionManager.isHidden(value) || value == null) {
				this.visible = false;
				this.includeInLayout = false;
			} else {
				this.visible = true;
				this.includeInLayout = true;
			}
		}
	    
		override protected function makeRow(contentHolder:ListBaseContentHolder, rowNum:int, left:Number, right:Number, yy:Number, data:Object, uid:String):Number
		{
			var ret:Number = super.makeRow(contentHolder, rowNum, left, right, yy, data, uid);
			if (rowTextColorFunction != null)
			{
				var color:Number = rowTextColorFunction(data);
				var row:Array = contentHolder.listItems[rowNum];
				for (var i:String in row)
				{
					if (row[i].getStyle('color') != color) row[i].setStyle('color', color);
				} 
			}
			return ret;
		}
	}
}