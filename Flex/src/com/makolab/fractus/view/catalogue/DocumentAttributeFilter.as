package com.makolab.fractus.view.catalogue
{
	import com.makolab.components.catalogue.ICatalogueFilter;
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	
	import mx.containers.FormItem;
	import mx.containers.HBox;
	import mx.controls.CheckBox;
	import mx.controls.ComboBox;
	import mx.controls.Label;
	import mx.controls.TextInput;

	public class DocumentAttributeFilter extends FormItem implements ICatalogueFilter
	{
		public var attributeName:String;
		// wartosc range pozwala wybrac zakres, partial dopasowuje ze znakiem % z dwoch stron
		public var type:String;
		public var dictionary:String;
		public var subtype:String;
		private var input:TextInput;
		private var combo:ComboBox;
		private var check:CheckBox;
		//private var checkEnable:CheckBox;

		private var hBox:HBox;
		private var lbl:Label;
		private var input1:TextInput;
		private var input2:TextInput;
		
		private const QUERY_TEMPLATE:String =
			".id IN (" +
				"SELECT V.itemId " +
				"FROM item.ItemAttrValue V " +
				"JOIN dictionary.ItemField F ON F.id = V.itemFieldId " +
				"WHERE F.name = '{attributeName}' AND V.textValue = '{attributeValue}'" +
			")"; 

		private const QUERY_TEMPLATE_PARTIAL:String =
			"Item.id IN (" +
				"SELECT V.itemId " +
				"FROM item.ItemAttrValue V " +
				"JOIN dictionary.ItemField F ON F.id = V.itemFieldId " +
				"WHERE F.name = '{attributeName}' AND V.textValue LIKE '%{attributeValue}%'" +
			")"; 

		private const QUERY_TEMPLATE_BOOL:String =
			"Item.id IN (" +
				"SELECT V.itemId " +
				"FROM item.ItemAttrValue V " +
				"JOIN dictionary.ItemField F ON F.id = V.itemFieldId " +
				"WHERE F.name = '{attributeName}' AND V.decimalValue = {attributeValue}" +
			")"; 	

		private const QUERY_TEMPLATE_RANGE:String =
			"Item.id IN ( " +
				"SELECT V.itemId " +
				"FROM item.ItemAttrValue V " +
				"JOIN dictionary.ItemField F ON F.id = V.itemFieldId " +
				"WHERE F.name = '{attributeName}' AND {conditions}" +
			")"; 

		private const QUERY_TEMPLATE_BOOL_COMMDOC:String =
			" IN ( " +
				"SELECT V.commercialDocumentHeaderId " +
				"FROM document.DocumentAttrValue V " +
				"JOIN dictionary.DocumentField F ON F.id = V.documentFieldId " +
				"WHERE F.name = '{attributeName}' AND {conditions}" +
			")"; 
			
		private const QUERY_TEMPLATE_BOOL_WARDOC:String =
			" IN ( " +
				"SELECT V.warehouseDocumentHeaderId " +
				"FROM document.DocumentAttrValue V " +
				"JOIN dictionary.DocumentField F ON F.id = V.documentFieldId " +
				"WHERE F.name = '{attributeName}' AND {conditions}" +
			")"; 
			
			
			
		public function DocumentAttributeFilter()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			var values:Array = DictionaryManager.getInstance().attributeValues[this.attributeName];
			if (type == 'range')
			{
				hBox = new HBox();
				hBox.setStyle('horizontalGap', 0);
				input1 = new TextInput();
				input1.restrict = '0-9,.';
				input1.width = 60;
				input2 = new TextInput();
				input2.restrict = '0-9,.';
				input2.width = 60;
				lbl = new Label();
				lbl.text = ' - ';
				hBox.addChild(input1);
				hBox.addChild(lbl);
				hBox.addChild(input2);
				this.addChild(hBox);
			}
			else if (type == 'boolean')
			{
 			
				//DictionaryManager.getInstance().getByName(this.attributeName, null);
				this.combo = new ComboBox();
				this.combo.percentWidth = 100;
				combo.dataProvider =_config.values.*;
				combo.labelFunction=function (o:Object):String{
					return o.labels.label.(@lang==LanguageManager.getInstance().currentLanguage)[0].toString();
				}
					if(_config.@value.length())
					{
						combo.selectedItem=_config.values.value.(name==_config.@value);
					}
				this.addChild(combo);


			}	

			else if (values)
			{
				this.combo = new ComboBox();
				this.combo.percentWidth = 100;
				combo.dataProvider = [''].concat(values);
				this.addChild(combo);
			}
			else
			{
				this.input = new TextInput();
				this.percentWidth = 100;
				this.addChild(input);
			}
			trace(attributeName,LanguageManager.getInstance().currentLanguage,DictionaryManager.getInstance().dictionaries.documentAttributes.(name == attributeName).label.(@lang == LanguageManager.getInstance().currentLanguage)[0]);
				
			this.label = DictionaryManager.getInstance().dictionaries.documentAttributes.(name == attributeName).label.(@lang == LanguageManager.getInstance().currentLanguage)[0];
		}
	
		public function setParameters(parameters:Object):void
		{
			var condition:String;
			var value:String;
			if (this.type == 'range')
			{
				var value1:Number = parseFloat(input1.text.replace(',', '.'));
				var value2:Number = parseFloat(input2.text.replace(',', '.'));
				var conditions:Array = [];
				// kombinacje zeby nie przekazac znaku < albo > do condition bo przejdzie jako &lt; albo &gt;
				// do poprawy w procedurze
				if (!isNaN(value1)) conditions.push('SIGN(decimalValue - ' + value1 + ') IN (0, 1)');
				if (!isNaN(value2)) conditions.push('SIGN(decimalValue - ' + value2 + ') IN (0, -1)');
				if (conditions.length > 0)
				{
					condition = Tools.replaceParameters(
							QUERY_TEMPLATE_RANGE,
							{ 'attributeName' : this.attributeName, 'conditions' : conditions.join(' AND ') }
						);
				}				
			}
			else
			{
				if (combo) 
					value = String(combo.selectedItem);
				else if(check) 
							value=check.selected?"1":"0";
				else if (input) value = input.text;

					if (value && attributeName&&!check)
					if(type=="boolean")
					{
						if(combo.selectedItem.name.toString()!="-1")
						{ /*Tutaj dodaję wybierak rodzajów słownika dictionary
							- item - itemAttrValue
							- documentCommercial - documentAttrValue - commercialDocuemntHeaderId
							- documentWarehouse - documentAttrValue - warehouseDocumentHeaderId							
						*/
							if(dictionary=="documentCommercial")
								condition = Tools.replaceParameters( QUERY_TEMPLATE_BOOL_COMMDOC, { 'attributeName' : this.attributeName, 'attributeValue' : combo.selectedItem.name.toString() } );
							if(dictionary=="documentWarehouse")	
								condition = Tools.replaceParameters( QUERY_TEMPLATE_BOOL_WARDOC, { 'attributeName' : this.attributeName, 'attributeValue' : combo.selectedItem.name.toString() } );
 
						}
							//parameters.filters=<filters><column field={attributeName}>{combo.selectedItem.name.toString()}</column></filters>;
					}
					else
					{
					condition = Tools.replaceParameters(
							(type == 'partial' ? QUERY_TEMPLATE_PARTIAL : QUERY_TEMPLATE),
							{ 'attributeName' : this.attributeName, 'attributeValue' : value.replace(new RegExp("'", "g"), "''") }
						);
					}
				
			}
			if (condition)
			{
				if (parameters.sqlConditions.length() == 0)
				{
					parameters.sqlConditions = '';
				
					parameters.sqlConditions.* += <condition>{condition}</condition>;
				}
				else
				{
					var hasIt:Boolean=false;
					var str:String=XML(<condition>{condition}</condition>).toString();
					for each( var cond:XML in parameters.sqlConditions.*)
					{
					if(cond.toString()==str)
						hasIt=true;
					}
					if(!hasIt)
					parameters.sqlConditions.* += <condition>{condition}</condition>;
				}
				
			} 
		}
		
		private var _config:XML;
		
		public function set config(value:XML):void
		{
			this._config = value;
			
			this.attributeName = _config ? _config.attributeName : null;
			this.type = _config ? _config.type : null;
			this.dictionary = config ? _config.dictionary : null;
			this.subtype = _config.@subtype.length() ? _config.@subtype : null;
		}
		
		public function get config():XML
		{
			return this._config;
		}
		
		public function set template(valueList:XMLList):void{
				for each (var value:XML in valueList){
				//todo: jesli filtr ma rozpoznawac, ktory elem. z listy jest dla niego, trzeba to tu dodać
				
				// todo
				}
		}
		
		public function clear():void{
			// todo
		}
		
		public function restore():void{
				//todo
				//trzeba dopisac cialo funkcji, jesli inny filtr ma miec mozliwosc przywracania stanu tego filtra sprzed wyczyszczenia go
				//filtry mogą mieć wpływ na inne filtry poprzez wypelnienie w konfiguracji parametru 'disableFilterType', przyklad w DocNumberFilter
		}
		
	}
}