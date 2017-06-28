package com.makolab.fractus.view.generic
{
	import com.makolab.fractus.model.CacheDataManager;
	
	import mx.events.FlexEvent;
	
	public class IdSelector extends FilteredSelector
	{
		public function IdSelector()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE,handleCreationComplete);
		}
		
		private var _dataSetName:String;
		
		public var parameters:Object = null;
		
		public var ignoreCache:Boolean = false;
		
		public var procedure:String;
		
		public function set dataSetName(value:String):void
		{
			_dataSetName = value;
			updateProvider();
		}
		public function get dataSetName():String
		{
			return _dataSetName;
		}
		
		[Bindable]
		public override function set enabled(value:Boolean):void
		{
			super.enabled = value;
			updateProvider();
		}
		public override function get enabled():Boolean
		{
			return super.enabled;
		}
		
		private function handleCreationComplete(event:FlexEvent):void
		{
			updateProvider();
		}
		
		private var loadedDataSetName:String = null;
		
		private function updateProvider():void
		{
			
			if(dataSetName && (ignoreCache || dataSetName != loadedDataSetName) && enabled)
			{
				//pocztek hardkodzika
				if(dataSetName=="salesmen"&&(dataSetName != loadedDataSetName)) ignoreCache=true;
				 // koniec hardkodzika 
				CacheDataManager.getInstance().getData(dataSetName, this, "dataProvider", ignoreCache, procedure, parameters);
				//pocztek hardkodzika
				if(dataSetName=="salesmen")ignoreCache=false;
				// koniec hardkodzika
				loadedDataSetName = dataSetName;
				 
			}
		}
			
	}
}