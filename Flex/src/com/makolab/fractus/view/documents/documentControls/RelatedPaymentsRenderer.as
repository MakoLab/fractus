package com.makolab.fractus.view.documents.documentControls
{
	import com.makolab.fractus.model.document.FinancialDocumentLine;
	import com.makolab.fraktus2.utils.DynamicAssetsInjector;
	
	import mx.controls.Image;
	import mx.controls.listClasses.BaseListData;
	
	public class RelatedPaymentsRenderer extends Image
	{
		public function RelatedPaymentsRenderer()
		{
			this.scaleContent = false;
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			updateValue();
		}
		
		override public function set listData(value:BaseListData):void
		{
			super.listData = value;
			updateValue();
		}
		
		private function updateValue():void
		{
			if (!data) return;
			var line:FinancialDocumentLine = FinancialDocumentLine(data);
			var settlements:XMLList = line.additionalNodes.settlement;
			this.source = settlements.length() > 0 || line.salesOrderId != null ? DynamicAssetsInjector.currentIconAssetClassRef.tick : null;
		}
	}
}