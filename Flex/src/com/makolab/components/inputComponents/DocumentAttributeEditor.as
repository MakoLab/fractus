package com.makolab.components.inputComponents
{
	import mx.core.ClassFactory;
	import flash.events.Event;
	import com.makolab.components.inputComponents.AttributeEditor;
	
	[Style(name="headerBackgoundColor", type="uint", inherit="no")]
	[Style(name="subHeaderBackgoundColor", type="uint", inherit="no")]
	[Style(name="labelWidth", type="Number", format="Length", inherit="yes")]
	[Style(name="editorWidth", type="Number", format="Length", inherit="yes")]
	
	public class DocumentAttributeEditor extends AttributeEditor implements IDataObjectComponent, IFormBuilderComponent
	{		
		/**
		 * Set class for <code>itemEditor</code> 
		 */
		public function set itemEditorClass(value:Class):void	
		{
			itemEditor = new ClassFactory(value);
		}
		
		override protected function addAttribute(id:String):void
		{
			super.addAttribute(id);
			updateData();
		}
		
		override protected function deleteAttribute(index:int):void
		{
			super.deleteAttribute(index);
			updateData();
		}
		
		override protected function editorChangeHandler(event:Event):void
		{
			for (var i:String in editors)
			{
				if (editors[i].component == event.target)
					dataObject.*[editors[i].dataIndex] = event.target[editorDataField];
			}
			event.stopImmediatePropagation();
			dispatchEvent(new Event(Event.CHANGE));
		}		
	}
}