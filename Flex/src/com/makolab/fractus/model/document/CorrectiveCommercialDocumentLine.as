package com.makolab.fractus.model.document
{
	import mx.collections.ArrayCollection;
	
	public class CorrectiveCommercialDocumentLine extends CommercialDocumentLine
	{
		public var itemNameBeforeCorrection:String;
		
		public var quantityBeforeCorrection:Number = 1;
		
		public var netPriceBeforeCorrection:Number = 0;
		public var grossPriceBeforeCorrection:Number = 0;
		
		public var initialNetPriceBeforeCorrection:Number = 0;
		public var initialGrossPriceBeforeCorrection:Number = 0;
		
		public var discountRateBeforeCorrection:Number = 0;
		public var discountNetValueBeforeCorrection:Number = 0;
		public var discountGrossValueBeforeCorrection:Number = 0;

		public var initialNetValueBeforeCorrection:Number = 0;
		public var initialGrossValueBeforeCorrection:Number = 0;

		public var netValueBeforeCorrection:Number = 0;
		public var grossValueBeforeCorrection:Number = 0;
		public var vatValueBeforeCorrection:Number = 0;
		
		public var correctedLine:CommercialDocumentLine = null;
		
		public function CorrectiveCommercialDocumentLine(line:XML=null, parent:DocumentObject=null)
		{
			super(line, parent);
		}
		
		override public function deserialize(value:XML):void
		{
			super.deserialize(value);
			
			var l:XMLList = value.correctedLine.line;
			
		    if (l.length() > 0) for each (var node:XML in l[0].*)
		 	{
		 		var name:String = node.localName();
		 		switch (name)
		 		{
		 			case "itemName":

		 				this[name + 'BeforeCorrection'] = BusinessObject.deserializeString(node);		 			
		 				break;

		 			case "netPrice":
		 			case "grossPrice":
		 			case "initialNetPrice":
		 			case "initialGrossPrice":
		 			
		 			case "discountRate":
		 			case "discountNetValue":
		 			case "discountGrossValue":
		 			
		 			case "initialNetValue":
		 			case "initialGrossValue":
		 			case "netValue":
		 			case "grossValue":
		 			case "vatValue":

		 			case "quantity":

		 				this[name + 'BeforeCorrection'] = BusinessObject.deserializeNumber(node);
		 				break;

		 		}
		 	}			
		}
		
		override public function serialize():XML
		{
			var result:XML = super.serialize();
			if (this.correctedLine)
			{
				result.correctedLine = <correctedLine><line><id>{this.correctedLine.id}</id></line></correctedLine>;
			}
			return result;
		}
		
		override public function copy():BusinessObject
		{
			var newLine:CorrectiveCommercialDocumentLine = super.copy() as CorrectiveCommercialDocumentLine;
			
			newLine.itemNameBeforeCorrection = this.itemNameBeforeCorrection;
			
			newLine.quantityBeforeCorrection = this.quantityBeforeCorrection;
			
			newLine.netPriceBeforeCorrection = this.netPriceBeforeCorrection;
			newLine.grossPriceBeforeCorrection = this.grossPriceBeforeCorrection;
			
			newLine.initialNetPriceBeforeCorrection = this.initialNetPriceBeforeCorrection;
			newLine.initialGrossPriceBeforeCorrection = this.initialGrossPriceBeforeCorrection;
			
			newLine.discountRateBeforeCorrection = this.discountRateBeforeCorrection;
			newLine.discountNetValueBeforeCorrection = this.discountNetValueBeforeCorrection;
			newLine.discountGrossValueBeforeCorrection = this.discountGrossValueBeforeCorrection;
	
			newLine.initialNetValueBeforeCorrection = this.initialNetValueBeforeCorrection;
			newLine.initialGrossValueBeforeCorrection = this.initialGrossValueBeforeCorrection;
	
			newLine.netValueBeforeCorrection = this.netValueBeforeCorrection;
			newLine.grossValueBeforeCorrection = this.grossValueBeforeCorrection;
			newLine.vatValueBeforeCorrection = this.vatValueBeforeCorrection;
			
			return newLine;
		}
		
		public function restoreValues():void
		{
			this.itemName = this.itemNameBeforeCorrection;
			
			this.quantity = this.quantityBeforeCorrection;
			
			this.netPrice = this.netPriceBeforeCorrection;
			this.grossPrice = this.grossPriceBeforeCorrection;
			
			this.initialNetPrice = this.initialNetPriceBeforeCorrection;
			this.initialGrossPrice = this.initialGrossPriceBeforeCorrection;
			
			this.discountNetValue = this.discountNetValueBeforeCorrection;
			this.discountGrossValue = this.discountGrossValueBeforeCorrection;
			this.discountRate = this.discountRateBeforeCorrection;

			this.initialNetValue = this.initialNetValueBeforeCorrection;
			this.initialGrossValue = this.initialGrossValueBeforeCorrection;

			this.netValue = this.netValueBeforeCorrection;
			this.grossValue = this.grossValueBeforeCorrection;
			this.vatValue = this.vatValueBeforeCorrection;			
		}
		
		public static function relateCorrectedLines(linesCollection:ArrayCollection, linesList:XMLList):void
		{
			var lines:Object = {};
			for each (var line:CorrectiveCommercialDocumentLine in linesCollection) lines[line.id] = line;
			for each (var lineXML:XML in linesList)
			{
				var correctedId:String = String(lineXML.correctedLine.line.id);
				var correctedLine:CorrectiveCommercialDocumentLine = lines[correctedId] as CorrectiveCommercialDocumentLine;
				if (correctedLine)
				{
					var correctiveLine:CorrectiveCommercialDocumentLine = lines[String(lineXML.id)] as CorrectiveCommercialDocumentLine;
					correctiveLine.correctedLine = correctedLine;
					correctedLine.correctiveLine = correctiveLine;
				}
			}
		}
	}
}