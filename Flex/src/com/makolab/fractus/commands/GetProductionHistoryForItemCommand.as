package com.makolab.fractus.commands
{
	import com.makolab.components.util.Tools;
	
	public class  GetProductionHistoryForItemCommand extends ExecuteCustomProcedureCommand  implements IDocumentSearchCommand
	{
		private var _dateTo:Date;
		private var _dateFrom:Date;
		private var _documentTypeId:String;
		private var _procedure:String;
		
		public var objectId:String;
		public var objectType:int;
		
		public function  GetProductionHistoryForItemCommand(itemId:String= null, dateFrom:String=null, dateTo:String = null )
		{
			var proc;
			objectId = itemId;
			dateFrom = dateFrom;
			dateTo = dateTo;
			if(_procedure != null)
			{
				proc = _procedure;
			}else
			{
				proc = 'document.p_getDocumentsForItem';
			}
			super(proc);
		}
		
		protected override function getOperationParams(data:Object):Object
		{
			operationParams = <params/>;
			operationParams.itemId =  objectId;
			operationParams.@procedure = 'document.p_getDocumentsForItem';
			operationParams.procedure = 'document.p_getDocumentsForItem';
			if(_dateFrom)
			{
				operationParams.dateFrom = Tools.dateToString(_dateFrom);
			}
			if(_dateTo)
			{
				operationParams.dateTo = Tools.dateToString(_dateTo) + "T23:59:59.997";
			}	
			if(_documentTypeId)
			{
				operationParams.documentTypeId=_documentTypeId
			}	
			
			return super.operationParams;			
		}
		public function  setProcedureTypes(id:String):void
		{
			_procedure = id ;
		} 
		public function setDateSpan(dateFrom:Date, dateTo:Date ):void
		{
			_dateTo = dateTo;
			_dateFrom = dateFrom;
		}
	
		public function setDocumentTypes(id:String):void
		{
			_documentTypeId = id ;
		} 
		
	}
}