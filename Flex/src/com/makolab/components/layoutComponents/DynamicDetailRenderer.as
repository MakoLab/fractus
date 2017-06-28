package com.makolab.components.layoutComponents
{
	import com.makolab.components.inputComponents.CurrencyRenderer;
	import com.makolab.components.list.CommonGrid;
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.commands.ExecuteCustomProcedureCommand;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.DocumentLabelFunctions;
	import com.makolab.fractus.view.ComponentWindow;
	import com.makolab.fractus.view.catalogue.ItemStockGrid;
	import com.makolab.fractus.view.documents.documentControls.KeyValueAttributeRenderer;
	import com.makolab.fractus.view.generic.GenericRenderer;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Text;
	import mx.rpc.events.ResultEvent;
	
	/* 
	 <detailsPanelConfiguration>
    <configuration>
      <header dataSource="alias1.code" />
      <fields>
        <field label="Numer dokumentu" dataType="string" dataSource="data.@fullNumber" />
        <field label="Jednostka" dataType="string" dataSource="alias1.unit" />
        <field label="Cena sprzedaży (netto)" dataType="string" dataSource="cokolwiek.netPrice" />
        <field dataType="AttributesListRenderer" dataSource="data.attributes.attribute" />
        <field labelKey="common.code" label="Kod" dataType="string" dataSource="cokolwiek.code" />
      </fields>
      <additionalComponents>
        <component dataType="dataGrid" dataSource="alias1.deliveries.delivery" label="Dostawy zawsze wyświetlane:" alwaysVisible="true">
          <columns>
            <column field="@quantity" label="Ilość" width="45" dataType="float" />
            <column field="@warehouseId" label="Magazyn" dataType="dictionary" filter="1" />
            <column field="@incomeDate" labelKey="common.code" width="100" dataType="date" filter="1" />
            <column field="@quantity" labelKey="items.stock" width="45" dataType="float" />
          </columns>
        </component>
        <component dataType="dataGrid" dataSource="alias1.deliveries.delivery" label="Dostawy wyświetlane tylko gdy nie puste:" alwaysVisible="false">
          <columns>
            <column field="@quantity" label="XXX" width="45" dataType="float" />
            <column field="@warehouseId" label="YYY" dataType="dictionary" filter="1" />
            <column field="@incomeDate" labelKey="common.code" width="100" dataType="date" filter="1" />
            <column field="@quantity" labelKey="items.stock" width="45" dataType="float" />
          </columns>
        </component>
        <component name="ItemStockGrid" label="ItemStockGrid:" />
      </additionalComponents>
      <procedures />
    </configuration>
  </detailsPanelConfiguration>
	 */
	

	public class DynamicDetailRenderer extends VBox
	{	
		[Bindable] private var dictionary:DictionaryManager = DictionaryManager.getInstance();
		[Bindable] private var languageManager:LanguageManager = LanguageManager.getInstance();
		
		[Bindable] private var model:ModelLocator = ModelLocator.getInstance();		
		//[Bindable] public var panelConfig:XML;// = model.configManager.getXML("items.panel.detailsConfig");
		
		private var _panelConfig:XML;
		
		public var attributeTypeDictionary:String = null;
		public var attributeTypeIdField:String = 'itemFieldId';
				
		public function set panelConfig(value:XML):void
		{
			_panelConfig = value;
			if(!initialized)createLayout(_panelConfig);
		}
		public function get panelConfig():XML
		{
			return _panelConfig;
		}

		public var labelFunctionsClass:Class = DocumentLabelFunctions;
		
		public function set configKey(value:String):void
		{
			panelConfig = model.configManager.getXML(value);
		}
		
		private var itemId:String;

		private var dynamicForm:Form = new Form();
		private var dynamicFormItem:FormItem;
		
		private var layoutInitialized:Boolean;
		
		private var dynamicComponents:ArrayCollection = new ArrayCollection();
		private var headerObj:Object;
		private var additionalComponents:ArrayCollection = new ArrayCollection();
		
		private var sourceCmdArray:Array = [];
		private var sourceDataArray:Array = [];
		
		private var operationParams:XML = <root />;
		
		private var cmdCount:int = 0;
		private var notEmptyCount:int = 0;
		
		private var dataXMLcopy:XML;
		
		[Bindable] private var _data:Object;
		[Bindable]
		override public function set data(value:Object):void
		{
			_data = value;
			updateControl();
			updateData();
		}
			
		override public function get data(): Object
		{
			return _data;
		}
		
		public function DynamicDetailRenderer()
		{
			init();
		}

		public static function showWindow():ComponentWindow
		{
			var component:DynamicDetailRenderer = new DynamicDetailRenderer();
			var window:ComponentWindow = ComponentWindow.showWindow(component);
			return window;
		}
	
		public function init():void
		{
			if(panelConfig){
				var cmdName:String = "";
				var alias:String = "";
			
				for each (var i:XML in panelConfig.procedures.procedure)
				{
					cmdName = i.procedureName;
					alias = i.alias;	
					sourceCmdArray.push({cmdName : cmdName, alias : alias, params : i.params.*});
				}
				
				if(!initialized)createLayout(panelConfig);
			}
		}
				
		private function updateControl():void
		{
			sourceDataArray = [];
			cmdCount = 0;	
			notEmptyCount = 0;
			
			for each (var i:Object in sourceCmdArray)
			{
				if(_data == null)
				{
					operationParams = <root/>;
				}
				else
				{
					operationParams = XML(setOperationParams(i.params));
					itemId = _data.id;
				}
			
				var cmd:ExecuteCustomProcedureCommand = new ExecuteCustomProcedureCommand(i.cmdName, operationParams);
					sourceDataArray.push({alias : i.alias, cmd : cmd, result : null});
					cmd.addEventListener(ResultEvent.RESULT, handleResultUpdateControl);
					cmd.execute();
			}
		}
				
		private function handleResultUpdateControl(event:ResultEvent):void
		{
			cmdCount++;
					
			for each (var i:Object in sourceDataArray)
			{
				if(i.cmd == event.currentTarget)
				{
					i.result = XMLList(event.result);
					if(i.result.children().toString() != "")
					{
						notEmptyCount++;
					}
				}
			}
			
			if(sourceDataArray.length == cmdCount) 
			{
				if(notEmptyCount > 0) 
				{
					if(dynamicComponents.length == 0)
					{
						createLayout(panelConfig);
					}
					updateData();
				}
				else
				{
					dynamicComponents = new ArrayCollection();
					additionalComponents = new ArrayCollection();
					dynamicForm.removeAllChildren();
					this.removeAllChildren();
				}
			}
		}
					
		public function createLayout(config:XML):void
		{
			if(config != null)
			{
				dynamicComponents = new ArrayCollection();
				dataXMLcopy = XML(_data);
				
				var label:String;
				var spl:Array;
				var dataTxt:XMLList;
				var field:XML;
				var currencySource:String;
				
				//header
				if(config.child("header").attributes().toString() != "")
				{
					var header:HBox = new HBox();
					header.styleName = "header";
					header.percentWidth = 100;
					header.minHeight = 20;
					header.setStyle("backgroundColor", getStyle('themeColor')/* ColorUtil.adjustBrightness2(getStyle('themeColor') , 50)*/);

					var headerText:Text = new Text();
					headerText.styleName="header";
					header.addChild(headerText);
				
					var headerDataSource:Array = (String(config.header.@dataSource)).split(/\./g);
					headerObj = {component : header, chain : headerDataSource};
				
					this.addChild(header);
				}
				
				//fields
				for each (field in config.fields.field)
				{
					label = getLabel(field);
					spl = (String(field.@dataSource)).split(/\./g);
					dataTxt = prepareDataText(spl);
					currencySource = field.@currencySource.length() > 0 ? field.@currencySource.toString() : null;			
					
					if(field.@dataType == "AttributesListRenderer")
					{	
						var attributesArray:Array = [];
						for (var m:int = 0; m<dataTxt.length(); m++)
						{
							var kvAttributeRenderer:KeyValueAttributeRenderer = new KeyValueAttributeRenderer();
							kvAttributeRenderer.idField = this.attributeTypeIdField;
							kvAttributeRenderer.dictionaryName = this.attributeTypeDictionary;
							kvAttributeRenderer.percentWidth = 100;
							kvAttributeRenderer.setStyle("verticalGap", 0);
							dynamicForm.addChild(kvAttributeRenderer);
							attributesArray.push({component : kvAttributeRenderer, name : "AttributesListRenderer", index : m});
						}
						dynamicComponents.addItem({name : "Array", data : attributesArray, chain : spl});
					} 
					else if(field.@dataType == "AttributeRenderer")
					{
						var attributeRenderer:KeyValueAttributeRenderer = new KeyValueAttributeRenderer();
						// TODO: wywalić hardcode typu i pola słownika
						attributeRenderer.idField = this.attributeTypeIdField;
						attributeRenderer.dictionaryName = this.attributeTypeDictionary;
						attributeRenderer.percentWidth = 100;
						attributeRenderer.attributeName = field.@attributeName;
						dynamicForm.addChild(attributeRenderer);
						var showIfEmpty:Boolean = (field.@showIfEmpty.length() > 0 && field.@showIfEmpty == "true") ? true : false;
						
						dynamicComponents.addItem({name : "Attribute", component : attributeRenderer, attributeName : field.@attributeName, chain : spl, showIfEmpty : showIfEmpty});
					}
					else if(field.@functionName.length() > 0)
					{
						if(labelFunctionsClass && labelFunctionsClass.hasOwnProperty(field.@functionName.toString())){
							var text:Text = new Text();
							text.text = "";//(labelFunctionsClass[field.@function] as Function).call(this.);
							text.setStyle("fontWeight","bold");
							dynamicFormItem = new FormItem();
							dynamicFormItem.label = label;
							dynamicFormItem.addChild(text);
							dynamicForm.addChild(dynamicFormItem);
							
							dynamicComponents.addItem({name : "Function", component : text, showIfEmpty : showIfEmpty, functionName : field.@functionName.toString()});
						}
					}
					else 
					{
						var gr:GenericRenderer = new GenericRenderer();
						gr.dataType = field.@dataType;
						gr.setStyle("fontWeight", "bold");
				
						dynamicFormItem = new FormItem();
						dynamicFormItem.label = label;
						dynamicFormItem.addChild(gr);
						dynamicForm.addChild(dynamicFormItem);
						dynamicComponents.addItem({component : gr, chain : spl, name : null, currencySource : currencySource});
					}
				}

				dynamicForm.setStyle("verticalGap", 0);
				dynamicForm.setStyle("paddingTop", 0);
				dynamicForm.setStyle("paddingBottom", 0);
				dynamicForm.percentWidth = 100;
				this.addChild(dynamicForm);
						
				// additional elements
			
				for each (var additionalComponent:XML in config.additionalComponents.component)
				{
					//label
					label = getLabel(additionalComponent);
					var cgHeader:Text = new Text();
					cgHeader.text = label;
					
					if(additionalComponent.@dataType == "dataGrid")
					{
						spl = (String(additionalComponent.@dataSource)).split(/\./g);
						dataTxt = prepareDataText(spl);
					
						var commonGrid:CommonGrid = new CommonGrid();
						commonGrid.percentWidth = 100;
						commonGrid.config = additionalComponent.columns;
						commonGrid.focusEnabled = false;   
						
						additionalComponents.addItem({component : commonGrid, name : "dataGrid", chain : spl, labelComponent : cgHeader, alwaysVisible : additionalComponent.@alwaysVisible});
						
						if((dataTxt.toString() == "") && (additionalComponent.@alwaysVisible != "true"))
						{
						}
						else 
						{
							if(cgHeader.text != ""){
								this.addChild(cgHeader);
							}
							this.addChild(commonGrid);
						}
					}
					else if(additionalComponent.@name == "ItemStockGrid")
					{
						var itemStockGrid:ItemStockGrid = new ItemStockGrid();
						itemStockGrid.showInfoButton = true;
						itemStockGrid.percentWidth = 100;
											
						additionalComponents.addItem({component : itemStockGrid, name : "ItemStockGrid", labelComponent : cgHeader, alwaysVisible : additionalComponent.@alwaysVisible});
					
						if(cgHeader.text != ""){
							this.addChild(cgHeader);
						}
						this.addChild(itemStockGrid);
					}
				}
				initialized = true;
			}
		}
		
		public function getLabel(i:XML):String
		{
			var label:String = "";
			if((i.@labelKey).length() > 0){
				label = languageManager.getLabel(i.@labelKey);
			}else if((i.@label).length() > 0 ){
				label = i.@label;
			}			
			else if((i.labels).length() > 0){
				label = i.labels.label.(@lang == LanguageManager.getInstance().currentLanguage).*; 
			}
						
			return label;
		}
			
		private function updateData():void
		{
			if(!panelConfig)return;
			
			var value:XMLList;
			var valueList:XMLList;
			var i:int;
			var j:int;
			
			//header
			if(panelConfig.header.length() > 0 && (panelConfig.header.attributes() != ""))
			{
				if(panelConfig.header.@label.toString() != "")
				{
					Text(HBox(headerObj.component).getChildAt(0)).text = panelConfig.header.@label.toString();
				}
				else{
					value = /* XML( */prepareDataText(headerObj.chain)/* ) */;
					if(value && XMLList(value).length() > 0)
					Text(HBox(headerObj.component).getChildAt(0)).text = value[0].toString();
				}
			}
			
			
			//form
			for(j = 0; j < dynamicComponents.length; j++)
			{
				if(dynamicComponents[j].name == "Array")
				{
					var start:int = 0;
					var chain:Array = dynamicComponents[j].chain;
					valueList = prepareDataText(chain);						
						
					if(dynamicComponents[j].data.length != 0)
					{
						start = dynamicForm.getChildIndex(dynamicComponents[j].data[0].component);
						
						for (var k:int = 0; k < dynamicComponents[j].data.length; k++)
						{
							dynamicForm.removeChild(dynamicComponents[j].data[k].component);
						}
					}
					
					var attributesArray:Array = [];
					for (var m:int = 0; m<valueList.length(); m++)
					{
						var kvAttributeRenderer:KeyValueAttributeRenderer = new KeyValueAttributeRenderer();
						kvAttributeRenderer.idField = this.attributeTypeIdField;
						kvAttributeRenderer.dictionaryName = this.attributeTypeDictionary;
						kvAttributeRenderer.data = valueList[m];
						kvAttributeRenderer.percentWidth = 100;
						kvAttributeRenderer.setStyle("verticalGap", 0);
						dynamicForm.addChildAt(kvAttributeRenderer, start + m);
						attributesArray.push({component : kvAttributeRenderer, name : "AttributesListRenderer", index : m});
					}
					dynamicComponents[j] = {name : "Array", data : attributesArray, chain : chain};
				}
				else if(dynamicComponents[j].name == "Attribute")
				{
					value = prepareDataText(dynamicComponents[j].chain);
					var component:KeyValueAttributeRenderer = dynamicComponents[j].component;
					component.data = null;
					if (dynamicComponents[j].attributeName){
						var attribute:XML = dictionary.getByName(dynamicComponents[j].attributeName, this.attributeTypeDictionary);
						if (attribute) value = value.(valueOf()[component["idField"]].toString() == attribute["id"].toString());
						if (attribute && value.length() > 0) 
						{
							component.visible = true;
							component.includeInLayout = true;
							component.data = value[0];
						}else{
							if (!dynamicComponents[j].showIfEmpty){
								component.visible = false;
								component.includeInLayout = false;
							}
						}
					}
				}
				else if(dynamicComponents[j].name == "Function")
				{
					var textValue:String = "";
					var hasFunction:Boolean = labelFunctionsClass.hasOwnProperty(dynamicComponents[j].functionName);
					if(labelFunctionsClass && labelFunctionsClass.hasOwnProperty(dynamicComponents[j].functionName))
					{
						textValue = (labelFunctionsClass[dynamicComponents[j].functionName] as Function).call(this,this._data);
						if (textValue)
						{
							dynamicComponents[j].component.visible = true;
							dynamicComponents[j].component.includeInLayout = true;
							dynamicComponents[j].component["text"] = textValue;
						}else{
							if (!dynamicComponents[j].showIfEmpty)
							{
								dynamicComponents[j].component.visible = false;
								dynamicComponents[j].component.includeInLayout = false;
							}
						}
					}
				}
				else
				{
					value = /* XML( */prepareDataText(dynamicComponents[j].chain)/* ) */;
					
					if(value && XMLList(value).length() > 0)
					{
						if (dynamicComponents[j]["currencySource"])
							switch (dynamicComponents[j]["currencySource"])
							{
								case "document" : dynamicComponents[j].component["postfix"] = dictionary.getById(_data.*.documentCurrencyId.toString()).symbol.toString();
									break;
								case "system" : dynamicComponents[j].component["postfix"] = dictionary.getById(model.systemCurrencyId).symbol.toString();
									break;
							}
						dynamicComponents[j].component["dataObject"] = value[0].toString();
					}
					else 
					{
						dynamicComponents[j].component["dataObject"] = null;
					}
					
				}
			}
						
			//additional elements
			for(j = 0; j < additionalComponents.length; j++)
			{				
				if(additionalComponents[j].name == "dataGrid")
				{
					valueList = prepareDataText(additionalComponents[j].chain);
										
					if(valueList && XMLList(valueList).length() > 0)
					{
						if(dynamicForm.contains(additionalComponents[j].component))
						{
							additionalComponents[j].component.dataProvider = valueList;
						}
						else
						{
							var dataTxt:XMLList = prepareDataText(additionalComponents[j].chain);
												
							additionalComponents[j].component.dataProvider = dataTxt;
							this.addChildAt(additionalComponents[j].labelComponent , 2+ (2*j));
							this.addChildAt(additionalComponents[j].component , 2+(2 * j)+1);
						}						
					}
					else 
					{
						if(additionalComponents[j].alwaysVisible == "true")
						{
							additionalComponents[j].component.dataProvider = null;
						}
						else if(this.contains(additionalComponents[j].component))
						{
							this.removeChild(additionalComponents[j].labelComponent);
							this.removeChild(additionalComponents[j].component);
						}						
					}
				}				
				else if(additionalComponents[j].name == "ItemStockGrid")
				{
					additionalComponents[j].component.itemId = itemId;
				}
			}
		}
		
		private function setOperationParams(params:XMLList):XML
		{
			operationParams = <root/>;
			operationParams.appendChild(params);
			
			if(_data == null)
			{
				operationParams = <root/>;
			}
			else
			{
				operationParams = <root/>;
				operationParams.appendChild(params);
				var key:String = params.text().toString();
				operationParams = XML(Tools.replaceParameters(operationParams.toXMLString(), { (key.substr(1, key.length-2)) : _data.id }));
			}
			return operationParams;			
		}
		
		private function prepareDataText(spl:Array):XMLList
		{
			var dataTxt:XMLList = new XMLList();

			if(spl[0] == "data"){
				dataTxt = XMLList(_data);
			}
			else{
				for each (var n:Object in sourceDataArray)
				{
					if(n.alias == spl[0]){
						dataTxt = XMLList(n.result);
						break;
					}
				}
			}
			
			for(var k:int=1;k<spl.length; k++){
				dataTxt = dataTxt.child(spl[k]);
			}
			
			return dataTxt;
		}
	}
}
