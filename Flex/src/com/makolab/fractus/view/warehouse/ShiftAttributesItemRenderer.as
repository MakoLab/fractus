package com.makolab.fractus.view.warehouse
{
	import com.makolab.components.util.CurrencyManager;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.ShiftObject;
	
	import flash.events.MouseEvent;
	
	import mx.containers.TitleWindow;
	import mx.controls.LinkButton;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;

	public class ShiftAttributesItemRenderer extends LinkButton
	{
		public function ShiftAttributesItemRenderer()
		{
			super();
			this.addEventListener(MouseEvent.CLICK,buttonClickHandler);
		}
		
		[Bindable] public var shift:ShiftObject;
		private var window:TitleWindow;
		
		private function buttonClickHandler(event:MouseEvent):void
		{
			if(!shift.attributes)shift.attributes = <attributes/>;
			if(shift) window = ShiftAttributeEditor.showWindow(ModelLocator.getInstance().applicationObject,shift.attributes,saveAttributes);
			
			//window.commitFunction = saveAttributes;
			if(window) window.addEventListener(CloseEvent.CLOSE,windowCloseHandler);
		}
		
		private function saveAttributes():void
		{
			if(data) data.attributes = shift.attributes;
			setLabel();
			//if(window)window.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
			if (closeHandler != null) closeHandler();
			PopUpManager.removePopUp(window);
		}
		
		public var closeHandler:Function;
		
		private function windowCloseHandler(event:CloseEvent):void
		{
			if (closeHandler != null) closeHandler();
		}
		
		private function setLabel():void
		{
			var voltage:String = "";
			var current:String = "";
			if(shift.attributes){
				var voltageFieldId:String = DictionaryManager.getInstance().getByName("Attribute_Voltage", "shiftFields").id.*;
				var currentFieldId:String = DictionaryManager.getInstance().getByName("Attribute_Current", "shiftFields").id.*;
				
				var voltages:XMLList = shift.attributes.*.(shiftFieldId.toString() == voltageFieldId);
				if(voltages.length() > 0){ voltage = CurrencyManager.formatCurrency(Number(voltages[0].value.toString()),"?",null,-2) + "V"};
				
				var currents:XMLList = shift.attributes.*.(shiftFieldId.toString() == currentFieldId);
				if(currents.length() > 0){ current = CurrencyManager.formatCurrency(Number(currents[0].value.toString()),"?",null,-2) + "A"};
			}
			this.label = voltage + " " + current;
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			shift = value as ShiftObject;
			setLabel();
		}
	}
}