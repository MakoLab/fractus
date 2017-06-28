package com.makolab.fractus.model.document
{
	import com.makolab.components.util.CurrencyManager;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.ModelLocator;
	
	public class DocumentLabelFunctions
	{
		public function DocumentLabelFunctions()
		{
		}
																
		public static var calculateCost:Function = 			function (documentXML:XML):String
																{
																	var cost:Number = 0;
																	var currencySymbol:String = DictionaryManager.getInstance().getById(ModelLocator.getInstance().systemCurrencyId).symbol.toString();
																	for each (var line:XML in documentXML.*.lines.line)
																	{
																		var isWarehouseStorable:Boolean = DictionaryManager.getInstance().getById(line.itemTypeId.toString()).isWarehouseStorable.toString() == "1";
																		var valuatedQuantity:Number = 0;
																		for each (var commercialDocumentValuation:XML in line.commercialWarehouseValuations.commercialWarehouseValuation)
																		{
																			cost += Number(commercialDocumentValuation.value);
																			valuatedQuantity += Number(commercialDocumentValuation.quantity);
																		}
																		if (valuatedQuantity != Number(line.quantity) && isWarehouseStorable) cost = NaN;
																		
																	}
																	var totalCost:String = CurrencyManager.formatCurrency((cost), '-', '0', 2) + (isNaN(cost) ? '' : (' ' + currencySymbol));
																	return totalCost;
																}
		
		public static var calculateProfitMargin:Function = 		function (documentXML:XML):String
																{
																	var cost:Number = 0;
																	var netValue:Number = 0;
																	for each (var line:XML in documentXML.*.lines.line)
																	{
																		var isWarehouseStorable:Boolean = DictionaryManager.getInstance().getById(line.itemTypeId.toString()).isWarehouseStorable.toString() == "1";
																		netValue += Number(line.netValue);
																		var valuatedQuantity:Number = 0;
																		for each (var commercialDocumentValuation:XML in line.commercialWarehouseValuations.commercialWarehouseValuation)
																		{
																			cost += Number(commercialDocumentValuation.value);
																			valuatedQuantity += Number(commercialDocumentValuation.quantity);
																		} 
																		if (valuatedQuantity != Number(line.quantity) && isWarehouseStorable) cost = NaN;
																		
																	}
																	netValue = netValue * Number(documentXML.*.exchangeRate.toString()) / Number(documentXML.*.exchangeScale.toString()); 
																	var profitMargin:String = CurrencyManager.formatCurrency(100 * (netValue - cost) / netValue, '-', '0', -2) + (isNaN(cost) ? '' : ' %');
																	return profitMargin;
																}
																
		public static var calculateProfit:Function = 			function (documentXML:XML):String
																{
																	var cost:Number = 0;
																	var netValue:Number = 0;
																	var currencySymbol:String = DictionaryManager.getInstance().getById(ModelLocator.getInstance().systemCurrencyId).symbol.toString();
																	for each (var line:XML in documentXML.*.lines.line)
																	{
																		var isWarehouseStorable:Boolean = DictionaryManager.getInstance().getById(line.itemTypeId.toString()).isWarehouseStorable.toString() == "1";
																		netValue += Number(line.netValue);
																		var valuatedQuantity:Number = 0;
																		for each (var commercialDocumentValuation:XML in line.commercialWarehouseValuations.commercialWarehouseValuation)
																		{
																			cost += Number(commercialDocumentValuation.value);
																			valuatedQuantity += Number(commercialDocumentValuation.quantity);
																		}
																		if (valuatedQuantity != Number(line.quantity) && isWarehouseStorable) cost = NaN;
																		
																	}
																	netValue = netValue * Number(documentXML.*.exchangeRate.toString()) / Number(documentXML.*.exchangeScale.toString());
																	var profitValue:Number = netValue - cost;
																	var profit:String = CurrencyManager.formatCurrency(profitValue, '-', '0', 2) + (isNaN(profitValue) ? '' : (' ' + currencySymbol));
																	return profit;
																}
																
		public static var calculateProfitAndProfitMargin:Function = function (documentXML:XML):String
																{
																	return DocumentLabelFunctions.calculateProfit.call(this,documentXML) + " / " + DocumentLabelFunctions.calculateProfitMargin.call(this,documentXML);
																}
		
		public static var countLines:Function =			 		function (documentXML:XML):String
																{
																	var quantity:int = documentXML.*.lines.line.length();
																	return String(quantity);
																}
	}
}