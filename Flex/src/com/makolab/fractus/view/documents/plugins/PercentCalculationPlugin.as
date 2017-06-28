package com.makolab.fractus.view.documents.plugins
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.document.CommercialDocumentLine;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.view.documents.documentControls.IDocumentControl;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;

	public class PercentCalculationPlugin implements IDocumentControl
	{
		private var idPercent:String;
		private var idCheckPercent:String;
		private var idProductioType:String;
		public static const  namePercent:String="LineAttribute_ProductionMaterialPercent";
		public static const nameCheckPercent:String="LineAttribute_ProductionMaterialPercentUse";
		public static const nameProductionType:String="LineAttribute_ProductionItemType";
		
		private var _isOn:Boolean=false;
		private var _totalPercent:Number=0; 	
		[Bindable]
		public function get totalPercent() :Number
		{
			return _totalPercent;
		}
		private var mainQuantity:Number=0;
		[Bindable]
		public  function set isOn(i:Boolean) :void
		{
			_isOn=i;
		}
		public function get isOn() :Boolean
		{
			return _isOn;
		}
		public function PercentCalculationPlugin()
		{
			idPercent=DictionaryManager.getInstance().getByName(namePercent).id;
			idProductioType=DictionaryManager.getInstance().getByName(nameProductionType).id;
			idCheckPercent=DictionaryManager.getInstance().getByName(nameCheckPercent).id;
		}
		
		private var _documentObject:DocumentObject;
		public function set documentObject(value:DocumentObject):void
		{
			_documentObject = value;
			_documentObject.addEventListener(DocumentEvent.DOCUMENT_LINE_CHANGE, handleLineChange);
			_documentObject.addEventListener(DocumentEvent.DOCUMENT_LINE_ATTRIBUTE_CHANGE, handleLineChange);
		}
		
			
		public function get documentObject():DocumentObject
		{
			return _documentObject;
		}

		private function handleLineChange(event:DocumentEvent):void
		{
			if(isOn)
			{
			if(event.fieldName == nameProductionType|| event.fieldName=="quantity")
					setMainQuantity(event);
			
			if(event.type == DocumentEvent.DOCUMENT_LINE_ATTRIBUTE_CHANGE && (event.fieldName == namePercent||event.fieldName==nameCheckPercent))
					if(mainQuantity<=0)
					findMainQuantity();
					else
					recalculateAll();
			}
		}
		private function setMainQuantity(event:DocumentEvent):void
		{
			
			if(event.line is CommercialDocumentLine)
			{
				var entry:XML = DictionaryManager.getInstance().getByName("LineAttribute_ProductionItemType");
				
					if(event.line.attributes)
					{
						var arr:ArrayCollection=ArrayCollection(event.line.attributes)
						for(var i:int=0;i<arr.length;i++)
						{
							if(arr[i].fieldId.toString()==entry.id.toString())
							{
								if(arr[i].value=="product")
								{
									mainQuantity=event.line.quantity;
									recalculateAll();
								}
								if(arr[i].value=="material"&&arr.length==3&&mainQuantity>0)
								{
									var isCheck:Boolean=false;
									var isProductioType:Boolean=false;
									var isPercent:Boolean=false;
									var percent:int=0;
									for(var j:int=0;j<arr.length;j++)
									{
										if(arr[j].fieldId ==idPercent)
										{
											isPercent=true;
											percent=j;
										}
										if(arr[j].fieldId==idProductioType)
										{
											if(arr[j].value=="material")
												isProductioType=true;
										}
										if(arr[j].fieldId==idCheckPercent&&arr[j].value==1)
										{
											isCheck=true;
											
										}
										
									}
									if(isPercent&&isCheck&&isProductioType)
									{
										arr[percent].value=event.line.quantity/mainQuantity*100;
										recalculateAll();
									}
								}else
								{
									findMainQuantity();
								}
							}
						}
					} 
			}
			
		}
		private function findMainQuantity():void
		{
	
			
			var arr:ArrayCollection= this.documentObject.lines;
				if(arr)
				for(var i:int=0;i<arr.length;i++)
				{
					var att:ArrayCollection=arr[i].attributes;
					
					if(att)
					for(var j:int=0;j<att.length;j++)
					{	
					
						if(att[j].fieldId==idProductioType)
						{
							if(att[j].value=="product")
								{
									mainQuantity=arr[i].quantity;
									recalculateAll();
								}
						}
						
						
					}
				
				}
			
		}
		private function recalculateAll():void
		{
				var arr:ArrayCollection= this.documentObject.lines;
				_totalPercent=0;
				if(arr)
				for(var i:int=0;i<arr.length;i++)
				{
					var att:ArrayCollection=arr[i].attributes;
					var isCheck:Boolean=false;
					var isProductioType:Boolean=false;
					var isPercent:Boolean=false;
					var percent:Number=0;
					if(att&& att.length>=3)
					for(var j:int=0;j<att.length;j++)
					{	
						if(att[j].fieldId ==idPercent)
						{
							isPercent=true;
							percent=att[j].value;
							
						}
						if(att[j].fieldId==idProductioType)
						{
							if(att[j].value=="material")
								isProductioType=true;
						}
						if(att[j].fieldId==idCheckPercent&&att[j].value==1)
						{
							
							isCheck=true;
							
						}
					}
					if(isPercent&&isCheck&&isProductioType)
					{
						arr[i].quantity=percent*mainQuantity/100;
						_totalPercent+=percent;
					}
				}
				dispatchEvent(new Event("ZMIANA"));
				trace("_totalPercent:",_totalPercent);
		}
	
		
	}
}