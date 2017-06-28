package com.makolab.fractus.commands
{
	import com.makolab.fractus.model.ModelLocator;
	
	import mx.collections.XMLListCollection;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	
	public class SearchCommand extends FractusCommand
	{
		public static const CONTRACTORS:String = "contractors";
		public static const ITEMS:String = "items";
		public static const PRODUCTION:String = "production";
		public static const DOCUMENTS:String = "documents";
		public static const SERVICED_OBJECTS:String = "servicedObjects";
		public static const DRAFTS:String = "drafts";
		public static const PARCEL:String="parcel";
		
		public var searchParams:XML;
		public var dateFrom:Date;
		public var dateTo:Date;
		public var query:String;
		public var applicationUserId:String;
		
		private var filters:XMLList;
		
		protected var customProcedure:String;
		
		public function SearchCommand(type:String, searchParams:XML = null)
		{
			var operationName:String;
			if (type == CONTRACTORS) operationName = "GetContractors";
			else if (type == ITEMS) operationName = "GetItems";
			else if (type == DOCUMENTS) operationName = "GetDocuments";
			else if (type == SERVICED_OBJECTS) customProcedure = "service.p_GetServicedObjects";
			else if (type == DRAFTS) customProcedure = "document.p_getDrafts";
			else if (type == PRODUCTION) operationName = "GetProductionItems";
			else if(type==PARCEL) customProcedure="communication.getOutgoingDeliveryOrders";
			if (searchParams) this.searchParams = searchParams.copy();
			
			if (type == ITEMS)
			this.applicationUserId=ModelLocator.getInstance().sessionManager.userId;
			super("kernelService", operationName);
		}
		
		override protected function getOperationParams(data:Object):Object
		{
			var ret:XML = searchParams.copy();
			if (data && data.query) ret.query = data.query;
			if (this.query) ret.query = this.query;
			if (this.filters) ret.filters = <filters>{ret.filters.* + filters}</filters>;
			if (this.dateTo) ret.dateTo = this.dateTo;
			if (this.dateFrom) ret.dateFrom = this.dateFrom;
			if (this.applicationUserId) ret.applicationUserId = this.applicationUserId;
			return ret.toXMLString();
		}
		
		override protected function resultHandler(event:ResultEvent):void
		{
			super.resultHandler(event);
			if (targetObject && targetField)
			{
				targetObject[targetField] = new XMLListCollection(XML(event.result).*);
			}
		}
		
		public function addFilter(field:String, value:String):void
		{
			addXmlFilter(<column field={field}>{value}</column>);
		}
		
		public function addXmlFilter(filter:XML):void
		{
			if (!filters) filters = new XMLList();
			filters += filter;			
		}
		
		public override function execute(data:Object=null,addUser:Boolean=true):AsyncToken
		{
			if (customProcedure)
			{
				var cmd:ExecuteCustomProcedureCommand = new ExecuteCustomProcedureCommand(customProcedure, XML(getOperationParams(data)));
				cmd.addEventListener(ResultEvent.RESULT, result);
				return cmd.execute();
			}
			else return super.execute(data);
		}
		
		protected function handleCustomProcedureResult(event:ResultEvent):void
		{
			this.result(event.result);
		}
	}
}