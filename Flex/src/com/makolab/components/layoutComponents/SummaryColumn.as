package com.makolab.components.layoutComponents
{
	import com.makolab.components.util.Tools;
	
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.dataGridClasses.DataGridColumn;

	public class SummaryColumn extends DataGridColumn
	{
		public function SummaryColumn(columnName:String=null)
		{
			super(columnName);
		}
		
		[Bindable]
		public var operations:Array = [];
		
		public var childDataField:String;
		public var childDataFields:Array;
		
		[Bindable]
		public var sourceColumn:AdvancedDataGridColumn;
		
		public static const SUM:Function = 	function (source:XMLList,dataField:String,childDataField:String = null,childDataFields:Array=null):String{
												var result:Number = 0;
												if(source){
													for(var i:int=0;i<source.length();i++){
														if(childDataField){
															for each (var element:XML in source[i].*){
																if(element[childDataField].length() > 0)result += Number(element[childDataField]);
															}
														}else{
															if(source[i][dataField].length() > 0)result += Number(source[i][dataField].toString());
														}
													}
												}
												return result.toString();
											}
		
		public static const ROW_COUNT:Function = 	function (source:XMLList,dataField:String,childDataField:String = null,childDataFields:Array=null):String{
												return source.length().toString();
											}
											
		public static const AVERAGE:Function = 	function (source:XMLList,dataField:String,childDataField:String = null,childDataFields:Array=null):String{
													var result:Number = 0;
													var sum:Number = 0;
													var quantity:int = 0;
													if(source){
														for(var i:int=0;i<source.length();i++){
															var value:Number;
															if(childDataField){
																for each (var element:XML in source[i].*){
																	value = Number(element[childDataField]);
																	if(element[childDataField].length() > 0 && !isNaN(value)){
																		sum += value;
																		quantity++;
																	}
																}
															}else{
																value = Number(source[i][dataField]);
																if(source[i][dataField].length() > 0 && !isNaN(value)){
																	sum += value;
																	quantity++;
																}
															}
															result = Tools.round(sum / quantity,6);
														}
													}
													return result.toString();
												}
			public static const PER:Function = 	function (source:XMLList,dataField:String,childDataField:String = null,childDataFields:Array=null):String{
													var result:Number = 0;
													var sum:Number = 0;
													var quantity:int = 0;
													var value:Array=new Array();
													var j:int=0;
													var i:int=0
													for(var k:int=0;k<childDataFields.length;k++)
													{
														value.push(0);
													}
													
													if(source){
														var val:Number=0;
														for(i=0;i<source.length();i++){
															for(j=0;j<childDataFields.length;j++)
															{
																	var element:XML =source[i];
																	val = Number(element[childDataFields[j]]);
																	if( !isNaN(val)){
																		value[j]+=val;
																	}
																
															}
														}
															result=value[0]
															for(j=1;j<childDataFields.length;j++)
															result/=value[j]
															result = Tools.round(result,6);
														
													}
													return result.toString();
												}									
		public static const WEIGHTED_MEAN:Function = 	function (source:XMLList, dataField:String,weightDataField:String,childDataFields:Array=null):String
														{
															var result:Number = 0;
															var sum:Number = 0;
															var weightSum:Number = 0;
															
															if(source){
																for(var i:int = 0; i < source.length(); i++){
																	if (source[i][dataField].length() > 0 && source[i][weightDataField].length() > 0)
																	{
																		var value:Number = parseFloat(source[i][dataField]);
																		var weight:Number = parseFloat(source[i][weightDataField]);
																		if (isNaN(value)) value = 0;
																		if (isNaN(weight)) weight = 0;
																		
																			sum += value * weight;
																			weightSum += weight;
																		
																	}
																}
																result = Tools.round(sum / weightSum,6);
															}
															
															return result.toString();
														}
	}
}