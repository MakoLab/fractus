package com.makolab.components.catalogue
{
	import mx.controls.Button;
	import mx.controls.CheckBox;

	public class TestFilter extends CheckBox implements ICatalogueFilter
	{
		public function TestFilter()
		{
			super();
		}
		
		private var _config:XML = <filter/>
		
		/**
		 * Filter's configuration.
		 */
		public function set config(value:XML):void
		{
			_config = value;
		}
		
		public function get config():XML
		{
			return _config;
		}
		
		public function setParameters(parameters:Object):void
		{
			if (this.selected) parameters.query += " " + label;
		}
	}
}