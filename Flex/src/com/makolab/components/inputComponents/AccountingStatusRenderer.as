package com.makolab.components.inputComponents
{
	import com.makolab.fraktus2.utils.DynamicAssetsInjector;
	
	import mx.controls.Image;

	public class AccountingStatusRenderer extends Image
	{
		public function AccountingStatusRenderer()
		{
			super();
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			var val:String = String(DataObjectManager.getDataObject(data, listData));
			
			if(val == "exportedAndChanged" || val == "exportedAndUnchanged" || val == "1")
				this.source = DynamicAssetsInjector.currentIconAssetClassRef.tick;
			else
				this.source = null;
		}
		
	}
}