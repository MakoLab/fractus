package com.makolab.fractus.view.generic
{
	import assets.IconManager;
	
	import com.makolab.fractus.commands.GetRelatedComercialDocumentsCommand;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	
	import mx.controls.Image;
	import mx.controls.listClasses.BaseListData;
	import mx.rpc.events.ResultEvent;

	public class DocumentRelationRenderer extends Image
	{
		private static var cache:Object;
		private var isAsking:Boolean=false;
		private static function getStatusByNumber(value:Number):Object
		{
			if (!cache)
			{ 
				cache = {};
				for each (var entry:XML in DictionaryManager.getInstance().dictionaries.documentStatus)
				{
					var iconName:String;
					var myLabel:String;
					switch (String(entry.name))
					{
						case 'Saved': iconName = 'status_saved';myLabel="Posiada powiązane dokumenty sprzedażowe"; break;
						case 'Committed': iconName = 'status_commited';myLabel="Posiada powiązane dokumenty sprzedażowe"; break;
						case 'Booked': iconName = 'status_booked';myLabel="Posiada powiązane dokumenty sprzedażowe"; break;
						case 'Canceled': iconName = 'status_canceled'; myLabel="Nie posiada powiązanych dokumentów sprzedażowych";break;
					}
					cache[parseInt(entry.value)] = { label : myLabel, icon : IconManager.getIcon(iconName) };
				}
			}
			return cache[value];
		}
		
		public static function getStatusLabel(number:int):String
		{
			return getStatusByNumber(number).label.(@lang == LanguageManager.getInstance().currentLanguage);
		}
		
		public static function getStatusIcon(number:int):Class
		{
			return getStatusByNumber(number).icon;
		}
		
		public function DocumentRelationRenderer()
		{
			super();
			this.scaleContent = false;
			setStyle('horizontalAlign', 'center');
			setStyle('horizontalAlign', 'center');
		}

		private var _status:Number = NaN;
		public function set isCommercialRelation(value:Number):void
		{
			trace("value:",value);
		}
		public function set status(value:Number):void
		{
			_status = value;
			var item:Object = getStatusByNumber(_status);
			if (item)
			{
				this.toolTip = item.label;//.(@lang = ModelLocator.getInstance().languageManager.currentLanguage);
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
			if(value )
			updateStatus((value as XML).@id);
		}
		
		public override function set listData(value:BaseListData):void
		{
			super.listData = value;
		}
		
		protected function updateStatus(documentId:String):void
		{
			if(!isAsking)
			{
			isAsking=true;
			var cmdCommercial:GetRelatedComercialDocumentsCommand;
			cmdCommercial = new GetRelatedComercialDocumentsCommand(documentId,GetRelatedComercialDocumentsCommand.WAREHOUSE_DOCUMENT);
			cmdCommercial.addEventListener(ResultEvent.RESULT,setRelatedResult);
			cmdCommercial.execute();
			}
		}
		
		public static function getTextValue(item:Object,dataField:String):String
		{
			return DictionaryManager.getInstance().dictionaries.documentStatus.(value.toString() == item[dataField]).label.(@lang == LanguageManager.getInstance().currentLanguage).toString();
		}
		
		private function setRelatedResult(event:ResultEvent):void
			{
				isAsking=false;
				var resultXML:XML = XML(event.result);
//				trace("result:", resultXML.length(),resultXML.children().length());
//				trace("resultXML:",resultXML);
//				trace("ss:",resultXML.children());
				if(resultXML.children().length()>0)
				{
					status=40;
				}
				else
					status=-20;
			}
	}
}