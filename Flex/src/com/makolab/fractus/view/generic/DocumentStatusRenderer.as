package com.makolab.fractus.view.generic
{
	import com.makolab.components.inputComponents.DataObjectManager;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	
	import mx.controls.Image;
	import mx.controls.listClasses.BaseListData;
	
	import assets.IconManager;

	public class DocumentStatusRenderer extends Image
	{
		private static var cache:Object;
		
		private static function getStatusByNumber(value:Number):Object
		{
			if (!cache)
			{ 
				cache = {};
				for each (var entry:XML in DictionaryManager.getInstance().dictionaries.documentStatus)
				{
					var iconName:String;
					switch (String(entry.name))
					{
						case 'Saved': iconName = 'status_saved'; break;
						case 'Committed': iconName = 'status_commited'; break;
						case 'Booked': iconName = 'status_booked'; break;
						case 'Canceled': iconName = 'status_canceled'; break;
					}
//					var lab:String;
//					if(entry.label.@lang.length())
//					{
//						lab=entry.label.(@lang==LanguageManager.getInstance().currentLanguage)[0];
//					}
//					else
//						lab=entry.label
					cache[parseInt(entry.value)] = { label : entry.label, icon : IconManager.getIcon(iconName) };
				}
			}
			return cache[value];
		}
		
		public static function getStatusLabel(number:int):String
		{
			var obj:Object=getStatusByNumber(number);
			if(obj.label.(hasOwnProperty('@lang')))
				return obj.label.(@lang == LanguageManager.getInstance().currentLanguage)[0];
			else
				return getStatusByNumber(number).label;
		}
		
		public static function getStatusIcon(number:int):Class
		{
			return getStatusByNumber(number).icon;
		}
		
		public function DocumentStatusRenderer()
		{
			super();
			this.scaleContent = false;
			setStyle('horizontalAlign', 'center');
			setStyle('horizontalAlign', 'center');
		}

		private var _status:Number = NaN;
		public function set status(value:Number):void
		{
			_status = value;
			var item:Object = getStatusByNumber(_status);
			if (item)
			{
//				if(item.label.@lang.length())
//					this.toolTip = item.label.(@lang == LanguageManager.getInstance().currentLanguage)[0];
//				else
					this.toolTip = item.label;
				this.source = item.icon;
			}
			else
			{
				this.toolTip = _status.toString();
				this.source = null;
			}
		}
		public function get status():Number
		{
			return _status;
		}
				
		public override function set data(value:Object):void
		{
			super.data = value;
			updateStatus();
		}
		
		public override function set listData(value:BaseListData):void
		{
			super.listData = value;
			updateStatus();
		}
		
		protected function updateStatus():void
		{
			var s:Number = parseInt(String(DataObjectManager.getDataObject(data, listData)));
			if (s != status) status = s;
		}
		
		public static function getTextValue(item:Object,dataField:String):String
		{
			return DictionaryManager.getInstance().dictionaries.documentStatus.(value.toString() == item[dataField]).label.(@lang == LanguageManager.getInstance().currentLanguage).toString();
		}
		
	}
}