package com.makolab.fractus.model.document
{
	
	public class ShiftObject extends Object
	{
		public function ShiftObject(object:Object = null)
		{
			if(!object)return;
			if(object.shiftId)shiftId = object.shiftId;
			if(object.sourceShiftId)sourceShiftId = object.sourceShiftId;
			if(object.containerId)containerId = object.containerId;
			if(object.incomeWarehouseDocumentLineId)incomeWarehouseDocumentLineId = object.incomeWarehouseDocumentLineId;
			if(object.warehouseDocumentLineId)warehouseDocumentLineId = object.warehouseDocumentLineId;
			if(object.quantity)quantity = object.quantity;
			if(object.version)version = object.version;
			if(object.incomeDate)incomeDate = object.incomeDate;
			if(object.status)status = object.status;
			if(object.sourceContainerId)sourceContainerId = object.sourceContainerId;
			if(object.shiftTransactionId)shiftTransactionId = object.shiftTransactionId;
			if(object.warehouseId)warehouseId = object.warehouseId;
			if(object.ordinalNumber)ordinalNumber = object.ordinalNumber;
			if(object.attributes)attributes = object.attributes[0];
			if(object.fullNumber)fullNumber = object.fullNumber;
			if(object.price)price = object.price;
			
			if(object.containerLabel)containerLabel = object.containerLabel;
			
			if(object.IORid)IORid = object.IORid;
			if(object.IORversion)IORversion = object.IORversion;
			if(object.IORincomeDate)IORincomeDate = object.IORincomeDate;
			if(object.IORquantity)IORquantity = object.IORquantity;
		}
		
		public function getXML(rootName:String = "shift"):XML
		{
			var xml:XML = <root/>;
			xml[rootName] = "";
			if(shiftId && shiftId != "")xml[rootName].shiftId = shiftId;
			if(sourceShiftId && sourceShiftId != "")xml[rootName].sourceShiftId = sourceShiftId;
			if(containerId && containerId != "")xml[rootName].containerId = containerId;
			if(incomeWarehouseDocumentLineId && incomeWarehouseDocumentLineId != "")xml[rootName].incomeWarehouseDocumentLineId = incomeWarehouseDocumentLineId;
			if(warehouseDocumentLineId && warehouseDocumentLineId != "")xml[rootName].warehouseDocumentLineId = warehouseDocumentLineId;
			if(quantity && quantity != "")xml[rootName].quantity = quantity;
			if(version && version != "")xml[rootName].version = version;
			if(incomeDate && incomeDate != "")xml[rootName].incomeDate = incomeDate;
			if(status && status != "")xml[rootName].status = status;
			if(sourceContainerId && sourceContainerId != "")xml[rootName].sourceContainerId = sourceContainerId;
			if(shiftTransactionId && shiftTransactionId != "")xml[rootName].shiftTransactionId = shiftTransactionId;
			if(warehouseId && warehouseId != "")xml[rootName].warehouseId = warehouseId;
			if(ordinalNumber && ordinalNumber != "")xml[rootName].ordinalNumber = ordinalNumber;
			if(fullNumber && fullNumber != "")xml[rootName].fullNumber = fullNumber;
			if(price && price != "")xml[rootName].price = price;
			if(attributes && attributes != "")xml[rootName].attributes = attributes;
			
			return xml[rootName][0];
		}
		
		[Bindable] public var shiftId:String = "";
		[Bindable] public var sourceShiftId:String = "";
		[Bindable] public var containerId:String = "";
		[Bindable] public var incomeWarehouseDocumentLineId:String = "";
		[Bindable] public var warehouseDocumentLineId:String = "";
		[Bindable] public var quantity:String = "";
		[Bindable] public var version:String = "";
		[Bindable] public var incomeDate:String = "";
		[Bindable] public var status:String = "";
		[Bindable] public var sourceContainerId:String = "";
		[Bindable] public var shiftTransactionId:String = "";
		[Bindable] public var warehouseId:String = "";
		[Bindable] public var ordinalNumber:String = "";
		[Bindable] public var fullNumber:String = "";
		[Bindable] public var price:String = "";
		[Bindable] public var attributes:XML;
		
		//zmienne pomocnicze
		[Bindable] public var containerLabel:String = "";
		
		[Bindable] public var IORid:String = "";
		[Bindable] public var IORversion:String = "";
		[Bindable] public var IORincomeDate:String = "";
		[Bindable] public var IORquantity:String = "";

	}
}