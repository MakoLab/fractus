package com.makolab.components.inputComponents
{
	import mx.controls.Label;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.core.IFactory;

	public class LabelRenderer extends Label implements IFactory, IDropInListItemRenderer
	{
		public var columnIdent:String;
		private var _data:Object;
		
		public function LabelRenderer()
		{
			super();
		}
		
        public function newInstance():*
        {
           return new LabelRenderer();
        }
	}
}