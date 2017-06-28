package com.makolab.components.layoutComponents
{
	import com.makolab.components.inputComponents.ClipboardCheckBox;
	import com.makolab.components.inputComponents.IFormBuilderComponent;
	import com.makolab.components.inputComponents.LabelValueEditor;
	import com.makolab.fractus.model.ConfigManager;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.view.generic.GenericEditor;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.containers.Form;
	import mx.containers.TabNavigator;
	import mx.controls.TextInput;
	import mx.core.ClassFactory;
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.utils.ObjectProxy;
	import mx.utils.XMLNotifier;
	
	import flight.binding.Bind;
	
	/**
	 * Sets the width of labels describing formular fields.
	 */
	[Style(name="labelWidth", type="Number", format="Length", inherit="yes")]
	/**
	 * Sets the editors width in the formular. 
	 */
	[Style(name="editorWidth", type="Number", format="Length", inherit="yes")]
	/**
	 * Builds a formular on base of given XML.
	 * Assign a configuration XML to <code>config</code> property
	 * and data XML to <code>data</code>.
	 * 
	*/
	
	public class ClipboardFormBuilder extends TabNavigator implements mx.utils.IXMLNotifiable, IFormBuilderComponent
	{
		/**
		 * Constructor.
		 */
		public function ClipboardFormBuilder()
		{
			super();
			setStyle("paddingLeft", 10);
			setStyle("paddingRight", 10);
			setStyle("paddingTop", 10);
			setStyle("paddingBottom", 10);
			var langManager:LanguageManager = LanguageManager.getInstance();
			Bind.addBinding(this, "labels", langManager, "labels");
			this.addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
		}
		
		private function handleRemovedFromStage(event:Event):void
		{
			if (data) XMLNotifier.getInstance().unwatchXML(data, this);
		}
		
		private var labelWatcher:ChangeWatcher;
		
		private var notificationEnabled:Boolean = true;
		
		private var _config:XML;
		
		private var _binding:Array;
		private var _components:Array;
			
		private var ti:TextInput;
		
		private var _labels:ObjectProxy;
		private var model:ModelLocator = ModelLocator.getInstance();
		
		/**
		 * Contains labels values.
		 */
		[Bindable]
		public function set labels(value:ObjectProxy):void
		{
			_labels = value;
			updateBinding();
		}
		/**
		 * @private
		 */
		public function get labels():ObjectProxy { return _labels; }
		
		/**
		 * Returns an instance of DictionaryManager
		 * @see com.makolab.factus.model.DictionaryManager
		 */
		public function get dictionaryManager():DictionaryManager { return DictionaryManager.getInstance(); }
		
		/**
		 * An array of all components references existing in formular.
		 */
		public function get components():Array
		{
			if (!_components) return null;
			var a:Array = [];
			for (var i:int = 0; i < _components.length; i++) a.push(_components[i].component);
			return a;
		}
		
		public function get componentsDes():Array
		{
			if (!_components) return null;
			var a:Array = [];
			for (var i:int = 0; i < _components.length; i++) a.push(_components[i].descriptor);
			return a;
		}
		
		/**
		 * An instance of ConfigManager.
		 */
		public var configManager:ConfigManager = model.configManager;
		
		/**
		 * An XML with formular configuration.
		 */
		public function set config(value:XML):void
		{
			var prevConfig:XML = _config;
			_config = value;
			if (prevConfig != value)
			{
				removeChildren();
				formInitialized = false;
				buildForm();
			}
		}
		
		/**
		 * Create child objects of the component.
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			if (!formInitialized) buildForm();
		}
		
		private var formInitialized:Boolean = false;
		
		private function buildForm():void
		{
			_components = [];
			_binding = [];
			var chain:Array;
			if (_config) for each (var i:XML in _config.tab)
			{
				var tab:Form = new Form();
				tab.setStyle("paddingTop", 3);
				tab.setStyle("paddingBottom", 3);
				tab.percentWidth = 100;
				tab.percentHeight = 100;
				if (i.@label.toString().match(/^\{.+\}$/))
				{
					chain = i.@label.toString().match(/^\{(.+)\}$/)[1].toString().split(/\./);
					_binding.push({ target : tab, dataField : "label", chain : chain, targetField : "label" });
				}else{
					tab.label = i.@label;
				}					
				initComponents(tab, i);
				addChild(tab);
			}
			updateBinding();
			reset();
			formInitialized = true;
		}
		
		private function removeChildren():void
		{
			removeAllChildren();
			_binding = [];
			_components = [];
		}
		
		/**
		 * Lets you pass values to the formular's editors.
		 */
		override public function set data(value:Object):void
		{
			if (value is XMLList) value = value[0];
			if (!(value is XML)) value = null;
			if (data != value) XMLNotifier.getInstance().unwatchXML(data, this);
			super.data = value;
			if (value) XMLNotifier.getInstance().watchXML(value, this);
			updateBinding();
			if (value) reset();
			//bindProperties();
		}
		
		private function updateBinding():void
		{
			notificationEnabled = false;
			for (var i:String in _binding)
			{
				var b:Object = _binding[i];
				var value:Object = getValue(this, b.chain);
				//if (true || b.target != changeSource){
				b.target[b.targetField] = value;  //}
			}
			notificationEnabled = true;
		}
		
		private function getValue(obj:Object, chain:Array):Object
		{
			for (var i:int = 0; i < chain.length; i++)
			{
				try
				{
					obj = obj[chain[i]];
				}
				catch (e:Error)
				{
					return null;
				}
			}
			return obj;
		}
		
		private function setValue(obj:Object, chain:Array, value:Object):void
		{
			for (var i:int = 0; i < chain.length - 1; i++)
			{
				try
				{
					obj = obj[chain[i]];
				}
				catch (e:Error)
				{
					obj = null;
					break;
				}
			}
			if (obj)
			{
				if (value is XMLList)
				{
					if (value.length() != 1) throw new Error("single XML required");
					else value = value[0];
				}
				if (value is XML) obj[chain[chain.length - 1]] = value;
				else obj[chain[chain.length - 1]] = value;
					
			}
		}
		
		private function initComponents(tab:Container, cfg:XML):void
		{
			for each (var i:XML in cfg.component)
			{
				var component:UIComponent;
				
				var className:String = i.@className;
				var dataType:String = i.@dataType;
				var dataField:String = i.@dataField;
				var dataSource:String = i.@dataSource;
				var targetField:String = i.@targetField;
				var enabled:String = i.@enabled;
				var permissionKey:String = i.@permissionKey;
				if (!targetField) targetField = "data";
				if (className)
				{
					var c:Class = getDefinitionByName(className) as Class;
					component = new c();
				}
				else if (dataType)
				{
					var fbc:ClassFactory = new ClassFactory(GenericEditor);
					fbc.properties =
					{
						dataType : dataType,
						dictionaryName : i.@dictionaryName,
						required : (i.@required == 1),
						regExp : (String(i.@regExp) ? i.@regExp : null)					
					}
					dataField = 'dataObject';
					targetField = 'data';
					component = new LabelValueEditor();
					LabelValueEditor(component).itemEditor = fbc;
					LabelValueEditor(component).editorDataField = 'dataObject';
					LabelValueEditor(component).required = fbc.properties.required;
					if (i.@label.length() > 0) LabelValueEditor(component).label = i.@label;
					else if (i.@labelKey.length() > 0) LanguageManager.bindLabel(component, 'label', i.@labelKey);
				}
				var cp:ClipboardCheckBox;
				
				if (component)
				{
					cp=new ClipboardCheckBox();
					cp.addComponent(component);
					_components.push({ component : cp, descriptor : i });
					component.percentWidth =90;
					component.addEventListener(FocusEvent.FOCUS_OUT, editorFocusOutHandler);
					
					if(permissionKey)
					{
						component.enabled = ModelLocator.getInstance().permissionManager.isEnabled(permissionKey);
						//component.visible = ModelLocator.getInstance().permissionManager.isVisible(permissionKey);
						//component.includeInLayout = component.visible;
					}
					
					if(enabled=="false") component.enabled = false;
					if (dataSource)
					{
						var chain:Array = dataSource.toString().split(/\./);
						_binding.push({ target : component, dataField : dataField, chain : chain, targetField : targetField });
					}
				}
				for each (var k:XML in i.*)
				{
					var pName:String = k.localName();
					var pType:String = describeType(component).*.((localName() == 'variable' || localName() == 'accessor') && @name == pName).@type;
					if (k.toString().match(/^\{.+\}$/))
					{
						chain = k.toString().match(/^\{(.+)\}$/)[1].toString().split(/\./);
						_binding.push({ target : component, dataField : dataField, chain : chain, targetField : pName });
					}
					else if (pType == "mx.core::ClassFactory")
					{
						component[pName] = new ClassFactory(getDefinitionByName(k) as Class);
					}
					else if (pType == "String") 
					{
						component[pName] = String(k);
					}
					else if (pType == "BooleanBoolean" || pType == "Boolean") 
					{
						var b:Boolean;
						if (k == "true") b = true;
						else if (k == "false") b = false;
						else if (!isNaN(parseInt(k))) b = Boolean(parseInt(k));
						else b = Boolean(String(k));
						component[pName] = b;
					}
					else component[pName] = k;
				}
				
			
				tab.addChild(cp);
			}
		}

		private var changeSource:Object;
		
		/**
		 * Updates binding when focus leaves the control.
		 */
		protected function editorFocusOutHandler(event:FocusEvent):void
		{
			updateValueFromEditor(event.currentTarget);
		}
		
		protected function updateValueFromEditor(editor:Object):void
		{
			for (var i:String in _binding)
			{
				var b:Object = _binding[i];
				if (editor == b.target)
				{
					changeSource = b.target;
					setValue({data : data}, b.chain, b.target[b.dataField]);
					changeSource = null;
					break;
				}
			}			
		}
		/**
		 * Validates values in the formular. 
		 * @return Array of error messages.
		 */
		public function validate():Object
		{
			var ret:Array = [];
			 for (var i:String in components) if (components[i].cmp is IFormBuilderComponent)
			{
				var result:Object = IFormBuilderComponent(components[i].cmp).validate();
				if (result is Array) for (var j:String in result) ret.push(result[j]);
				else if (result) ret.push(result);
			} 
			return ret;
		}
		
		/**
		 * Calls <code>commitChanges()</code> method of <code>IFormBuilderComponent</code> for each editor in formular.
		 */
		public function commitChanges():void
		{
			for (var i:String in components) if (components[i].cmp is IFormBuilderComponent&&components[i].cb.selected )
			{
				var component:IFormBuilderComponent = components[i].cmp as IFormBuilderComponent;
				notificationEnabled = false;
				component.commitChanges();
				updateValueFromEditor(component);
				notificationEnabled = true;
			}
		}
		
		/**
		 * Calls <code>reset()</code> method of <code>IFormBuilderComponent</code> for each editor in formular.
		 */
		public function reset():void
		{
			notificationEnabled = false;
			for (var i:String in components) if (components[i].cmp is IFormBuilderComponent)
			{
				IFormBuilderComponent(components[i].cmp).reset();
			}
			updateBinding();	// notify all controls after reset
			notificationEnabled = true;
		}
		
		/**
		 * A method of the <code>IXMLNotifiable</code>
		 * @see mx.utils.IXMLNotifiable
		 */
	    public function xmlNotification(
                     currentTarget:Object,
                     type:String,
                     target:Object,
                     value:Object,
                     detail:Object):void
		{
			if (notificationEnabled) updateBinding();
		}
		
	}
}