package com.makolab.fractus.model.document
{
	import com.makolab.fractus.model.DictionaryManager;
	
	import mx.collections.ArrayCollection;
	
	public class BusinessObject
	{
		public var id:String;
		public var version:String;
		
		public var attributes:ArrayCollection;
		
		protected var rootNodeName:String;
		protected var attributeFieldName:String;
		
		public function BusinessObject(rootNodeName:String, attributeFieldName:String = null)
		{
			this.rootNodeName = rootNodeName;
			this.attributeFieldName = attributeFieldName;
		}
		
		protected static function deserializeNumber(value:Object):Number
		{
			if (value.length() != 0) return parseFloat(value.*);
			else if (value is XML) return parseFloat(String(value));
			else return 0;
		}
		
		protected static function deserializeInt(value:Object):int
		{
			if (value is XMLList && value.length() != 0) return parseInt(value.*);
			else if (value is XML) return parseInt(String(value));
			else return 0;
		}
		
		protected static function deserializeString(value:Object):String
		{
			if (value is XMLList && value.length() != 0) return String(value.*);
			else if (value is XML) return String(value);
			else return null;
		}
		
		protected static function serializeSingleValue(value:Object, xml:XML, nodeName:String, precision:uint=0):void
		{
			if (value is Number && !isNaN(Number(value)))
				xml.appendChild(<{nodeName}>{Number(value).toFixed(precision)}</{nodeName}>);
			else if (value)
				xml.appendChild(<{nodeName}>{value}</{nodeName}>);
		}
		
		public function copy():BusinessObject
		{
			var c:Class = Object(this).constructor;
			var newBo:BusinessObject = new c();
			
			if(this.attributes != null)
			{
				for each (var attr:BusinessObjectAttribute in this.attributes)
				{
					var newAttr:BusinessObjectAttribute = newBo.addAttribute(attr.fieldId);
					newAttr.value = attr.value;
				}
			}
			
			return newBo;
		}
		
		public function serialize():XML
		{
			var xml:XML = XML('<' + this.rootNodeName + '/>');
			if (this.attributes && this.attributes.length > 0)
			{
				var attribXML:XML = <attributes/>;
				for each (var a:BusinessObjectAttribute in this.attributes)
				{
					if((a.value != "") && (a.value != null)) 
					{
						attribXML.appendChild(a.serialize());
					}
				} 
				xml.appendChild(attribXML);
			} 
			return xml;
		}
		
		public function deserialize(value:XML):void
		{
			if (value && value.attributes.length() > 0)
			{
				this.attributes = new ArrayCollection();
				for each (var x:XML in value.attributes.attribute) 	this.attributes.addItem(new BusinessObjectAttribute(this.attributeFieldName, x));
				
				delete value.attributes[0];
			}
		}
		
		public static function addIfNotExists(defaultValue:Object, xml:XML, name:String):void
		{
			if (xml[name].length() == 0)
			{
				xml[name] = '';
				xml[name].* = defaultValue;
			}
		}
		
		public function isEmpty():Boolean
		{
			return false;
		}
		
		public function getAttributeByFieldId(id:String):BusinessObjectAttribute
		{
			if (this.attributes)
			{
				for each (var a:BusinessObjectAttribute in this.attributes) if (a.fieldId == id) return a;
			}
			return null;
		}
		
		public function getAttributeByName(name:String, dictionaryName:String = "documentFields"):BusinessObjectAttribute
		{
			var attr:XML = DictionaryManager.getInstance().getByName(name, dictionaryName);
			if(!attr)
				return null;
			
			var id:String = attr.id;
			return this.getAttributeByFieldId(id); 
		}
		
		public function addAttributeByName(name:String, dictionaryName:String = "documentFields"):BusinessObjectAttribute
		{
			var attr:XML = DictionaryManager.getInstance().getByName(name, dictionaryName);
			if(!attr)
				return null;
				
			return this.addAttribute(attr.id.*);
		}
		
		public function addAttribute(fieldId:String):BusinessObjectAttribute
		{
			var attr:BusinessObjectAttribute = new BusinessObjectAttribute(this.attributeFieldName);
			attr.fieldId = fieldId;
			if (!this.attributes) this.attributes = new ArrayCollection();
			this.attributes.addItem(attr);
			return attr; 
		}
	}
}