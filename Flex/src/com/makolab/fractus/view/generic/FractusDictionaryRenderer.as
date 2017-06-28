package com.makolab.fractus.view.generic
{
	import com.makolab.components.inputComponents.DataObjectManager;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	
	import mx.controls.Label;
	import mx.controls.listClasses.BaseListData;

	public class FractusDictionaryRenderer extends Label
	{
		public function FractusDictionaryRenderer()
		{
			super();
		} 
		
		public var labelField:String = null;
		public var tooltipField:String = null;
		
		public var unknownLabel:String = '';
		
		// prywatna zmienna do przechowywania wartosci dataObject
		private var _dataObject:Object;
		
		/*
			Musimy przeciazyc setter data by odczytac wartosc do wyswietlenia.
			Poniewaz setter listData jest wywolywany w pierwszej kolejnosci, gdy
			grid wywola setter data, pole listData jest juz ustawione i w oparciu
			o te dwa pola mozna odczytac dana do wyswietlenia.
			Tutaj przypisujemy do dataObject (nie _dataObject!). Powoduje to wywolanie
			settera tej wlasciwosci co umozliwia ustawienie odpowiedniej wartosci
			wyswietlanej przez komponent.
		*/
		[Bindable]
		override public function set data(value:Object):void
		{
			super.data = value;
			var s:String = String(DataObjectManager.getDataObject(data, listData));
			//s="123456789";
			if (dataObject != s) dataObject = s;
		}
		
		override public function set listData(value:BaseListData):void
		{
			super.listData = value;
			var s:String = String(DataObjectManager.getDataObject(data, listData));
			if (dataObject != s) dataObject = s;
		}
		
		/*
			Tutaj nastepuje aktualizacja danych wyswietlanych przez kontrolke. w oparciu
			o wartosc zapisana w dataObject odpowiednio ustawiamy wlasciwosci komponentu
			by wyswietlil to co powinien.
			W tym przypadku text ustawiamy na symbol odpowiedniej pozycji slownikowej.
			W dataObject mamy id tej pozycji i uzyskujemy pozycje slownikowa na podstawie
			tego id.
		*/
		[Bindable]
		public function set dataObject(value:Object):void
		{
			_dataObject = value;
			var item:Object = ModelLocator.getInstance().dictionaryManager.getById(String(_dataObject));
			var lf:String = labelField;
			// by default display symbol if it exists or label otherwise 
			if (item && !lf)
			{
				if (item.symbol.length() > 0) lf = 'symbol';
				else if (item.label.@symbol.length() > 0) lf = 'label.@symbol';
				else lf = 'label';
			}
			var c:XMLList;
			if (item)
			{
				var i:int = lf.indexOf(".");
				
				
				if(i < 0)
				{
					c = item[lf];
					if(c.@lang.length())
					{
						c=c.(@lang==LanguageManager.getInstance().currentLanguage);
						text=c[0].toString();
					}
						else
					text = item[lf];
				}
				else
				{
					c=item[lf.substring(0, i)];
					if(c.@lang.length())
					{
						c=c.(@lang==LanguageManager.getInstance().currentLanguage);
						text=c[0].toString();//[lf.substr(i+1)];
					}
					else
					text = item[lf.substring(0, i)][lf.substr(i+1)];
				}
			}
			else text = unknownLabel;
			if (item) 
			{
				c=item[tooltipField ? tooltipField : 'label'];
				if(c.@lang.length())
				{
					toolTip = c.(@lang==LanguageManager.getInstance().currentLanguage);
				}
				else
				toolTip = c;
			}
			else toolTip = null;
		}
		// tutaj po prostu zwracamy to co zostalo przypisane do dataObject
		public function get dataObject():Object
		{
			return _dataObject;
		}
		
		public static function getTextValue(item:Object,dataField:String):String
		{
			var item:Object = ModelLocator.getInstance().dictionaryManager.getById(String(item[dataField]));
			var lf:String = "label"; 
			var textValue:String = "";
			if (item)
			{
				if (item.symbol.length() > 0) lf = 'symbol';
				else if (item.label.@symbol.length() > 0) lf = 'label.@symbol';
				if(lf == "label")textValue = item.label.(@lang == LanguageManager.getInstance().currentLanguage)[0];
				else if(lf == "symbol") textValue = item.symbol;
				else if(lf == "label.@symbol") textValue = item.label.@symbol;
			}
			return textValue;
		}
		
	}
}