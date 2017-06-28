package com.makolab.components.inputComponents
{
	import com.makolab.fraktus2.utils.DynamicAssetsInjector;
	
	import mx.controls.Image;

	public class TickRenderer extends Image
	{
		public function TickRenderer()
		{
			super();
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			var val:String = String(DataObjectManager.getDataObject(data, listData));
			this.selected = val && parseInt(val) != 0;
		}
		
		private var _selected:Boolean;
		
		public function set selected(value:Boolean):void
		{
			_selected = value;
			this.source = _selected ? DynamicAssetsInjector.currentIconAssetClassRef.tick : null;
		}
		public function get selected():Boolean
		{
			return _selected;
		}
		
	}
}