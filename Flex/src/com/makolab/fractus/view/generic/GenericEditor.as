package com.makolab.fractus.view.generic
{
	import com.makolab.components.catalogue.CatalogueSearchEditor;
	import com.makolab.components.inputComponents.CheckBoxEditor;
	import com.makolab.components.inputComponents.CheckboxValueEditor;
	import com.makolab.components.inputComponents.CurrencyEditor;
	import com.makolab.components.inputComponents.DateEditor;
	import com.makolab.components.inputComponents.GenericValidator;
	import com.makolab.components.inputComponents.IFormBuilderComponent;
	import com.makolab.components.inputComponents.ValueComboBox;
	import com.makolab.components.util.Tools;
	import com.makolab.fractus.model.LanguageManager;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import mx.containers.Box;
	import mx.controls.ComboBox;
	import mx.controls.TextInput;
	import mx.core.ClassFactory;
	import mx.core.UIComponent;
	import mx.validators.ValidationResult;
	
	[Event(name="focusOut", type="flash.events.FocusEvent")]
	[Event(name="focusIn", type="flash.events.FocusEvent")]
	[Event(name="change", type="flash.events.Event")]
	public class GenericEditor extends Box implements IFormBuilderComponent
	{
		public static const STRING:String = "string";
		public static const DECIMAL:String = "decimal";
		public static const DECIMAL6:String = "decimal6";
		public static const INTEGER:String = "integer";
		public static const CURRENCY:String = "currency"; //nie ma takiego typu danych ale ze od poczatku bylo zle wpisana stala (ktora potem jest gdzies hardcodowana) to musi byc bo sie program sypie inaczej
		public static const MONEY:String = "money";
		public static const DICTIONARY:String = "dictionary";
		public static const DATE:String = "date";
		public static const DATETIME:String = "datetime";
		public static const SELECT:String = "select";
		public static const BOOLEAN:String = "boolean";
		public static const BOOLDATE:String = "booldate";
		
		public static const CONTRACTOR:String = "contractor";
		
		
		private var selectedVal:String="";
		public function GenericEditor()
		{
			super();
			this.addEventListener(FocusEvent.FOCUS_IN, handleFocusIn);
		}

		
		private var _values:XMLList;
		
		public function set values(list:XMLList):void
		{
			_values = list;
			if (dataType == SELECT && editor is ComboBox) 
				setComboData(editor as ComboBox);
		}
		public function get values():XMLList
		{
			return _values;
		}

			
		private var _dataType:String;

		[Bindable]
		public function set dataType(value:String):void
		{
			_dataType = value;
			trace("initialize Component from dataType:", value)
			if(!wait)
			initializeComponent();
		}
		public function get dataType():String
		{
			return _dataType;
		}
		
			private var _dataSubType:String;

		[Bindable]
		public function set dataSubType(value:String):void
		{
			_dataSubType = value;
			
		}
		public function get dataSubType():String
		{
			return _dataSubType;
		}
		
		private var _wait:Boolean=false;
		public function set wait(value:Boolean):void
		{
			_wait = value;
		}
		public function get wait():Boolean
		{
			return _wait;
		}
		
		
		private var _isSelected:String;
		public function set isSelected(value:String):void
		{
			_isSelected = value;
		}
		public function get isSelected():String
		{
			return _isSelected;
		}
		
		private var _isNew:Boolean=false;
		public function set isNew(value:Boolean):void
		{
			_isNew = value;
			if(wait)
			initializeComponent();
		}
		public function get isNew():Boolean
		{
			//if(_isNew==null)//if it is not set
			//	return "true";
			//else
				return _isNew;
		}
		private var _permission:String;
			
			public function set permission(value:String):void
			{
				_permission = value;
			}
			public function get permission():String
			{
				return _permission;
			}
		private var _editorFactory:ClassFactory;
		public function set editorFactory(factory:ClassFactory):void
		{
			_editorFactory = factory;
		}
		
		public function get editorFactory():ClassFactory
		{
			return _editorFactory;
		}
		
		private var _dictionaryName:String;
		[Bindable]
		public function set dictionaryName(value:String):void
		{
			_dictionaryName = value;
			if (editor is FractusDictionarySelector) FractusDictionarySelector(editor).dictionaryName = value;
		}
		public function get dictionaryName():String
		{
			return _dictionaryName;
		}
		
		private var _labelFunction:Function;
		public function set labelFunction(value:Function):void
		{
			_labelFunction = value;
			if (editor && editor.hasOwnProperty("labelFunction"))
				editor["labelFunction"] = _labelFunction;
		}
		public function get labelFunction():Function
		{
			return _labelFunction;
		}
		
		private var _dataSetName:String;
		[Bindable]
		public function set dataSetName(value:String):void
		{
			_dataSetName = value;
			if (editor is IdSelector) IdSelector(editor).dataSetName = value;
		}
		public function get dataSetName():String
		{
			return _dataSetName;
		}
		
		private var _dataObject:Object;
		[Bindable]
		public function set dataObject(value:Object):void
		{
			_dataObject = value;
		
			if (editor) editor["data"] = _dataObject;
		}
		public function get dataObject():Object
		{
			return editor && editorDataField ? editor[editorDataField] : _dataObject;
		}
		
		private var _regExp:String;
		public function set regExp(value:String):void
		{
			_regExp = value;
			if (validator) validator.regExp = value;
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			dataObject = value;
		}

		protected var editor:UIComponent;
		public var editorDataField:String;
		protected var editorDataFunction:Function;
		protected var validator:GenericValidator;
		
		private function initializeComponent():void
		{
			var component:UIComponent;
			var precision:int;
			switch (dataType)
			{
				case STRING:
					if(this.dataSetName){
						component = new IdSelector();
						editorDataField = "selectedId";
						component['labelField'] = "@label";
						component['idField'] = "@id";
						component['dataSetName'] = this.dataSetName;
					}else{
						if(this.dataSubType==CONTRACTOR)
						{
							component= new CatalogueSearchEditor();
							setSearchData(CatalogueSearchEditor(component));
						}
						else
						component = new TextInput();
						if(!editorDataField)editorDataField = "text";
					}
					if(editorFactory){
						component = editorFactory.newInstance();
					}
					break;
				case DECIMAL:
				case INTEGER:
				case CURRENCY:
				case DECIMAL6:
				case MONEY:
					precision = 2;
				
					
					if (dataType == DECIMAL) precision = -4;
					else if (dataType == DECIMAL6) precision = -6;
					else if (dataType == INTEGER) precision = 0;
					component = new CurrencyEditor();
					editorDataField = "dataObject";
					CurrencyEditor(component).precision = precision;
					CurrencyEditor(component).nanVal = "";
					CurrencyEditor(component).nanValues = ["","-","?"];
					CurrencyEditor(component).forceValidValue = true;
					break;
				
				case DICTIONARY:
					component = new FractusDictionarySelector();
					FractusDictionarySelector(component).dictionaryName = _dictionaryName;
					editorDataField = "selectedId";
					break;
				case DATE:
				case DATETIME:
					component = new DateEditor();
					DateEditor(component).allowEmptyDate = true;
					editorDataField = "dataObject";
					break;
				case SELECT:
					component = new ValueComboBox();
					ValueComboBox(component).isNew=isNew;
					editorDataField = "selectedValue";
					setComboData(ComboBox(component));
				
					break;
				
				case BOOLEAN:
					
					component = new CheckBoxEditor();
					editorDataField = "dataObject";
					
					if(this.permission!="" &&this.permission!=undefined&&this.permission!=null)
					{
						component.enabled=false;
					}
					if((this.isSelected=="1" ||this.isSelected=="true") &&this.isNew)
					{	
						//CheckBoxEditor(component).isSelected=true;
						//CheckBoxEditor(component).data=XMLList(<value>1</value>);
						dataObject=XMLList(<value>1</value>);
						//CheckBoxEditor(component).selected=1;
					}
					if(dataObject&&(dataObject as XMLList).length()<1)
					{
						if((this.isSelected=="1" ||this.isSelected=="true"))
						dataObject=XMLList(<value>1</value>);
						else
						dataObject=XMLList(<value>0</value>);
					}
					
					break;
				case BOOLDATE:
					component = new CheckboxValueEditor();
					editorDataField = "dataObject";
					break;
			}
			if (component)
			{
				if (editor)
				{
					editor.removeEventListener(FocusEvent.FOCUS_IN, handleEditorEvent);
					editor.removeEventListener(FocusEvent.FOCUS_OUT, handleEditorEvent);
					editor.removeEventListener(Event.CHANGE, handleEditorEvent);
				}
				removeAllChildren();
				component.percentWidth = 100;// width = getStyle("editorWidth");
				editor = component;
				editor.addEventListener(FocusEvent.FOCUS_IN, handleEditorEvent);
				editor.addEventListener(FocusEvent.FOCUS_OUT, handleEditorEvent);
				editor.addEventListener(Event.CHANGE, handleEditorEvent);
				if (editorDataField)
				{
					validator = new GenericValidator();
					validator.source = editor;
					validator.property = editorDataField;
					validator.required = required;
					validator.regExp = _regExp;
				}
				addChild(editor);
				if (_dataObject != null) editor["data"] = _dataObject;
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if (editor) editor.percentWidth = 100;// = getStyle("editorWidth");
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
		
		private var _required:Boolean;
		public function set required(value:Boolean):void
		{
			_required = value;
			if (validator) validator.required = value;
		}
		public function get required():Boolean
		{
			return _required;
		}
		
		protected function handleEditorEvent(event:Event):void
		{
			dispatchEvent(event);
		}
		
		protected function handleFocusIn(event:FocusEvent):void
		{
			if (editor) editor.setFocus();
		}
		
		public override function setFocus():void
		{
			if (editor) editor.setFocus();
		}
		
		public function validate():Object
		{
			if (!validator) return null;
			var results:Array = validator.validate().results;
			var label:String = null;
			if (parent.hasOwnProperty('label')) label = parent['label'];
			for (var i:String in results) ValidationResult(results[i]).errorMessage = (label ? label + ': ' : '') + ValidationResult(results[i]).errorMessage;
			return results;
		}
		private function setSearchData(component:CatalogueSearchEditor):void
		{
					component.searchCommandType="contractors";
					component.labelField="@fullName";
					//component.setFunction=outerDocument.setContractor;
					component.text="";//outerDocument.contractorFullName;
					component.searchParams=<searchParams>
			<query/>
			<columns>
				<column field="shortName" sortOrder="1" sortType="ASC"/>
				<column field="fullName"/>
				<column field="code"/>
				<column field="nip"/>
				<!--column field="version" sortOrder="3" sortType="ASC"/-->
			</columns>
		</searchParams>;
					component.filterFields=['@shortName', '@fullName', '@code', '@nip'];
		}
		private function setComboData(cb:ComboBox):void
		{
			if (!cb || !values) return;
			var dp:Array = [];
			var selectedId:int=-1;
			
			var i:int=0;
			var lang:String = LanguageManager.getInstance().currentLanguage;
			for each (var x:XML in values) 
			{
				dp.push({ label : String(x.labels.label.(@lang == lang)), value : String(x.name) });
				if(x.isDefault!= undefined)
					{
						if(String(x.isDefault) =="1" || String(x.isDefault) =="true")
						{
					selectedId=i;
					selectedVal=String(x.name);
					//selectedVal=String(x.labels.label.(@lang == lang));
					
					//trace("QLA Selected id:",selectedId," Selected Val:",selectedVal);
						}
					}
				i++;
			}
			cb.dataProvider = dp;
			if(selectedVal!="")
			{
				(cb as ValueComboBox).selectedValue=selectedVal;
			}
		}
		
		public function commitChanges():void
		{
			
		}
		public function reset():void
		{
		}
		private var _xmlMetadata:XML;
		[Bindable]
		public function set xmlMetadata(value:XML):void
		{
			if (value == this._xmlMetadata) return;
			this._xmlMetadata = value;
			if (this._xmlMetadata)
			{
				this.dictionaryName = this._xmlMetadata.dictionaryName;
				this.dataSetName = this._xmlMetadata.dataSetName.toString();
				this.dataType = this.dictionaryName ? DICTIONARY : this._xmlMetadata.dataType;
				this.regExp = this._xmlMetadata.regExp;
				this.required = Tools.parseBoolean(this._xmlMetadata.required);
				this.values = this._xmlMetadata.values.*;
			}
			else
			{
				this.dataType = null;
				this.regExp = null;
				this.required = false;
				this.values = null;
				this.dictionaryName = null;
				this.dataSetName = null;
			}
		}
		public function get xmlMetadata():XML
		{
			return _xmlMetadata;
		} 
		
	}
}