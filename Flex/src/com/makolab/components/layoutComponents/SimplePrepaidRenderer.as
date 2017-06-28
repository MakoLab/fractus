package com.makolab.components.layoutComponents
{
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.components.inputComponents.CurrencyRenderer;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.view.documents.documentControls.IDocumentControl;
	
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Label;
	
	
	public class SimplePrepaidRenderer extends HBox implements IDocumentControl{
		
		
		[Bindable] private var dictionaryManager:DictionaryManager = DictionaryManager.getInstance();
		[Bindable] private var languageManager:LanguageManager = LanguageManager.getInstance();
		
		private var prepaidData:XML;
		
		private var list:Array = [];
		private var mainContainer:HBox = new HBox();
		private var _documentObject:DocumentObject;
		
		private var _paymentCurrencyId:String;
		private var currencySymbol:String;
		private var color:String;
		
		private var positionHelper:CurrencyRenderer = new CurrencyRenderer();
		
		private var i:int;
		private var j:int;
		private var xmlTemp:XML;
		private var objectTemp:Object;
		private var pomPLN:Label;
		
		
		[Bindable]
		public function set documentObject(value:DocumentObject):void 
		{
			if(value)
			{
				_documentObject = value;
				_documentObject.addEventListener(DocumentEvent.DOCUMENT_PAYMENT_CHANGE,changePosition);
				_documentObject.addEventListener(DocumentEvent.DOCUMENT_LINE_CHANGE,changePosition);
				_documentObject.addEventListener(DocumentEvent.DOCUMENT_RECALCULATE,changePosition);
				
				prepaidData = XML(_documentObject.xml.settlements);
				
				createLayout();
			}
		}
		
		public function get documentObject():DocumentObject { return _documentObject; }
		
		
		public function SimplePrepaidRenderer()
		{
		}

		
		public function createLayout():void
		{			
			paymentCurrencyId = documentObject.xml.documentCurrencyId;
			
			//etykiety
			
			var labelDZ:Label = new Label();
			labelDZ.width = 140;
			labelDZ.text = languageManager.labels.prepaids.toPay;
			
			var labelZ:Label = new Label();
			labelZ.width = 140;
			labelZ.text = languageManager.labels.prepaids.prepaid;
						
			var labelP:Label = new Label();
			labelP.width = 140;
			labelP.text = languageManager.labels.prepaids.dueAmount;
			
			var etykiety:VBox = new VBox();
			etykiety.percentWidth = 100;
			etykiety.setStyle("horizontalAlign", "left");
			etykiety.addChild(labelDZ);
			etykiety.addChild(labelZ);
			etykiety.addChild(labelP);
			
			//kwoty
			var sumaDZ:Number = 0.0;
			for each(xmlTemp in prepaidData.salesOrder.vatRate)
			{
				sumaDZ += Number(xmlTemp.@grossValue);
			}
			
			var sumaZ:Number = 0.0;
			for each(xmlTemp in prepaidData.prepaids.vatRate)
			{
				sumaZ += Number(xmlTemp.@grossValue);
			}
			
			var sumaP:Number = sumaDZ - sumaZ;
			
			
			var sumaDZRenderer:CurrencyRenderer = new CurrencyRenderer();
			sumaDZRenderer.data = sumaDZ.toString();
			sumaDZRenderer.percentWidth = 100;
			sumaDZRenderer.nanText="0,00";
			
			var sumaZRenderer:CurrencyRenderer = new CurrencyRenderer();
			sumaZRenderer.data = sumaZ.toString();
			sumaZRenderer.percentWidth = 100;
			sumaDZRenderer.nanText="0,00";
			
			var sumaPRenderer:CurrencyRenderer = new CurrencyRenderer();
			sumaPRenderer.data = sumaP.toString();
			sumaPRenderer.percentWidth = 100;
			sumaDZRenderer.nanText="0,00";
			
			positionHelper.data = documentObject.xml.grossValue.toString();
			positionHelper.percentWidth = 100;
			positionHelper.height = 0;
			positionHelper.nanText="0,00";
			positionHelper.setStyle("fontWeight", "bold");
			positionHelper.setStyle("fontSize", 15);
			positionHelper.setStyle("verticalGap", 0);
			positionHelper.setStyle("paddingTop", 0);
			positionHelper.setStyle("paddingBottom", 0);

			
			
			var kwoty:VBox = new VBox();
			kwoty.percentWidth = 100;
			kwoty.setStyle("horizontalAlign", "left");
			kwoty.setStyle("paddingLeft", 7);

			kwoty.addChild(sumaDZRenderer);
			kwoty.addChild(sumaZRenderer);
			kwoty.addChild(sumaPRenderer);
			kwoty.addChild(positionHelper);
			
			//PLN
			var plnContainer:VBox = new VBox();
			plnContainer.percentWidth = 100;
			plnContainer.setStyle("horizontalAlign", "left");

			for(var j:int=0; j<3; j++)
			{
				pomPLN = new Label();
				pomPLN.percentWidth = 100;
				pomPLN.text = currencySymbol + ",";
				plnContainer.addChild(pomPLN);
			}
			
			
			//w tym

			var includedContainer:VBox = new VBox();
			includedContainer.percentWidth = 100;
			includedContainer.setStyle("horizontalAlign", "left");
			includedContainer.setStyle("horizontalGap", 0);
			includedContainer.setStyle("paddingLeft", 20);
			includedContainer.setStyle("paddingRight", 0);
					
			for(j=0; j<3; j++)
			{
				var included:Label = new Label();
				included.percentWidth = 100;
				included.text = languageManager.labels.prepaids.including;;
				includedContainer.addChild(included);
			}
			
			
			//procenty
			
			
			for each(xmlTemp in prepaidData.salesOrder.vatRate)
			{	
				objectTemp = {vatId : xmlTemp.@id, order : xmlTemp.@grossValue, prepaid : prepaidData.prepaids.vatRate.(attribute("id")==xmlTemp.@id).@grossValue};
				prepaidData.prepaids.vatRate.(attribute("id")==xmlTemp.@id).@id = "";

				this.list.push(objectTemp);
			}
			
			if(prepaidData.prepaids.vatRate.length() > prepaidData.salesOrder.vatRate.length())
			{
				for each(xmlTemp in prepaidData.prepaids.vatRate.(attribute("id")!=""))
				{			
					objectTemp = {vatId : xmlTemp.@id, order : 0, prepaid : xmlTemp.@grossValue};
					this.list.push(objectTemp);
				}
			}
			
			
			var szczegoly:HBox = new HBox();
			szczegoly.percentWidth = 100;
			
			var array:Array = [];
			
			for(var i:int = 0; i<list.length; i++)
			{
				//procent
				var dictionaryValue:Object = ModelLocator.getInstance().dictionaryManager.getById(list[i].vatId.toString());
				
				if((list[i].order == 0) && (Number(list[i].prepaid) > 0))
				{
					color = "red";
				}
				else
				{
					color = "0x0b333c";
				}

				var labelBlock:VBox = new VBox();
				labelBlock.percentWidth = 100;
				
				for(j=0; j<3; j++)
				{
					var block:HBox = new HBox();
					block.percentWidth = 100;
					block.setStyle("horizontalAlign", "left");
					
				/*	var pomLabel:FractusDictionaryRenderer = new FractusDictionaryRenderer();
					pomLabel.labelField = "symbol";
					pomLabel.dataObject = list[i].vatId.toString(); 
					pomLabel.percentWidth = 100;
					pomLabel.setStyle("horizontalGap", 0);
					pomLabel.setStyle("paddingLeft", 0);
					pomLabel.setStyle("paddingRight", 0);
					pomLabel.setStyle("fontWeight", "bold");
					pomLabel.truncateToFit = true;
				*/
				
					var pomLabel:Label = new Label();
					pomLabel.text = dictionaryValue.symbol.toString();
					if(dictionaryValue.symbol.toString() != "zw")
					{
						pomLabel.text += "% :";
					}
					else
					{
						pomLabel.text += " :";
					}
					
					pomLabel.setStyle("color", color);
					block.addChild(pomLabel);
					
				/*
					var pomProcent:Label = new Label();
					pomProcent.percentWidth = 100;
					pomProcent.text = "% :";
					pomProcent.setStyle("horizontalGap", 0);
					pomProcent.setStyle("paddingLeft", 0);
					pomProcent.setStyle("paddingRight", 0);
					
					block.addChild(pomProcent);*/
					
					block.setStyle("horizontalGap", "0");
					block.setStyle("paddingLeft", 0);
					block.setStyle("paddingRight", 0);
					
					labelBlock.addChild(block);
					
				}

				//kwota
				//do zapłaty
				var pomKwotaDZ:CurrencyRenderer = new CurrencyRenderer();
				pomKwotaDZ.data = list[i].order.toString(); //doto ze słownika
				pomKwotaDZ.percentWidth = 100;
				pomKwotaDZ.setStyle("color", color);
				
				// zaliczka
				var pomKwotaZ:CurrencyRenderer = new CurrencyRenderer();
				pomKwotaZ.percentWidth = 100;
				pomKwotaZ.data = list[i].prepaid.toString(); //doto ze słownika
				pomKwotaZ.setStyle("color", color);
				
				//pozostało
				var pomKwotaP:CurrencyRenderer = new CurrencyRenderer();
				pomKwotaP.percentWidth = 100;
				pomKwotaP.data = (Number(list[i].order) - Number(list[i].prepaid)).toString(); //doto ze słownika
				pomKwotaP.setStyle("color", color);
				
				var kwotaBlock:VBox = new VBox();
				kwotaBlock.percentWidth = 100;
				kwotaBlock.setStyle("horizontalAlign", "left");
				kwotaBlock.addChild(pomKwotaDZ);
				kwotaBlock.addChild(pomKwotaZ);
				kwotaBlock.addChild(pomKwotaP);
				
				//PLN
				var plnBlock:VBox = new VBox();
				plnBlock.percentWidth = 100;
				plnBlock.setStyle("horizontalAlign", "left");
				
				for(j=0; j<3; j++)
				{
					pomPLN = new Label();
					pomPLN.percentWidth = 100;
					pomPLN.text = currencySymbol + ",";
					pomPLN.setStyle("color", color);
					plnBlock.addChild(pomPLN);
				}
								
				szczegoly.addChild(labelBlock);
				szczegoly.addChild(kwotaBlock);
				szczegoly.addChild(plnBlock);

			}
			
			mainContainer.addChild(etykiety);
			mainContainer.addChild(kwoty);
			mainContainer.addChild(plnContainer);
			mainContainer.addChild(includedContainer);
			mainContainer.addChild(szczegoly);

				
			this.addChild(mainContainer);

		}


		
		public function set paymentCurrencyId(value:String):void	
		{
			_paymentCurrencyId = value;
			for each(var x:XML in dictionaryManager.dictionaries.currency)	{
				if(x.id.text() == value)	{
					currencySymbol = x.symbol.text();
					break;
				}
			}
		}
			
		public function get paymentCurrencyId():String	
		{
			return _paymentCurrencyId;
		}
		
		private function changePosition(event:Event = null):void
		{
			positionHelper.data = documentObject.xml.grossValue.toString();
		}
			
			
	}
}
