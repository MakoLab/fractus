package com.makolab.fractus.view.payments
{
	import com.makolab.components.inputComponents.DataObjectManager;
	
	import mx.controls.Label;
	import mx.controls.listClasses.BaseListData;
	import mx.events.ToolTipEvent;

	public class PaymentLabelRenderer extends Label
	{
		private var labelComponents:Array;
		
		public function PaymentLabelRenderer()
		{
			super();
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			updateData();
		}
		
		override public function set listData(value:BaseListData):void
		{
			super.listData = value;
			updateData();
		}
		
		private function updateData():void
		{
			var s:String = String(DataObjectManager.getDataObject(data, listData));
			
			if (!s || data == null||s=="") {text=s;labelComponents = null;}
			else
			{
				labelComponents = s.split(/;/g);
				if (labelComponents.length < 4) text = s;
				else text = labelComponents[0] + " " + labelComponents[1];
				if(XML(data).attribute("supplierDocumentNumber").length() > 0)text = text + " (" + data.@supplierDocumentNumber + ")";
				toolTip = labelComponents.join("\n");
			}
		}
	}
}