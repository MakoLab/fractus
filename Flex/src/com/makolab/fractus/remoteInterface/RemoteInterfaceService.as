
/**
 * RemoteInterfaceServiceService.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */
 /**
  * Usage example: to use this service from within your Flex application you have two choices:
  * Use it via Actionscript only
  * Use it via MXML tags
  * Actionscript sample code:
  * Step 1: create an instance of the service; pass it the LCDS destination string if any
  * var myService:RemoteInterfaceService= new RemoteInterfaceService();
  * Step 2: for the desired operation add a result handler (a function that you have already defined previously)  
  * myService.addGetCommentEventListener(myResultHandlingFunction);
  * Step 3: Call the operation as a method on the service. Pass the right values as arguments:
  * myService.GetComment(myrequestXml);
  *
  * MXML sample code:
  * First you need to map the package where the files were generated to a namespace, usually on the <mx:Application> tag, 
  * like this: xmlns:srv="com.makolab.fractus.remoteInterface.*"
  * Define the service and within its tags set the request wrapper for the desired operation
  * <srv:RemoteInterfaceService id="myService">
  *   <srv:GetComment_request_var>
  *		<srv:GetComment_request requestXml=myValue/>
  *   </srv:GetComment_request_var>
  * </srv:RemoteInterfaceService>
  * Then call the operation for which you have set the request wrapper value above, like this:
  * <mx:Button id="myButton" label="Call operation" click="myService.GetComment_send()" />
  */
 package com.makolab.fractus.remoteInterface{
	import mx.rpc.AsyncToken;
	import flash.events.EventDispatcher;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import flash.utils.ByteArray;
	import mx.rpc.soap.types.*;

    /**
     * Dispatches when a call to the operation GetComment completes with success
     * and returns some data
     * @eventType GetCommentResultEvent
     */
    [Event(name="GetComment_result", type="com.makolab.fractus.remoteInterface.GetCommentResultEvent")]
    
    /**
     * Dispatches when a call to the operation SetComment completes with success
     * and returns some data
     * @eventType SetCommentResultEvent
     */
    [Event(name="SetComment_result", type="com.makolab.fractus.remoteInterface.SetCommentResultEvent")]
    
    /**
     * Dispatches when a call to the operation GetChangeList completes with success
     * and returns some data
     * @eventType GetChangeListResultEvent
     */
    [Event(name="GetChangeList_result", type="com.makolab.fractus.remoteInterface.GetChangeListResultEvent")]
    
    /**
     * Dispatches when a call to the operation SetChange completes with success
     * and returns some data
     * @eventType SetChangeResultEvent
     */
    [Event(name="SetChange_result", type="com.makolab.fractus.remoteInterface.SetChangeResultEvent")]
    
	/**
	 * Dispatches when the operation that has been called fails. The fault event is common for all operations
	 * of the WSDL
	 * @eventType mx.rpc.events.FaultEvent
	 */
    [Event(name="fault", type="mx.rpc.events.FaultEvent")]

	public class RemoteInterfaceService extends EventDispatcher implements IRemoteInterfaceService
	{
    	private var _baseService:BaseRemoteInterfaceService;
        
        /**
         * Constructor for the facade; sets the destination and create a baseService instance
         * @param The LCDS destination (if any) associated with the imported WSDL
         */  
        public function RemoteInterfaceService(destination:String=null,rootURL:String=null)
        {
        	_baseService = new BaseRemoteInterfaceService(destination,rootURL);
        }
        
		//stub functions for the GetComment operation
          

        /**
         * @see IRemoteInterfaceService#GetComment()
         */
        public function getComment(requestXml:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.getComment(requestXml);
            _internal_token.addEventListener("result",_GetComment_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IRemoteInterfaceService#GetComment_send()
		 */    
        public function getComment_send():AsyncToken
        {
        	return getComment(_GetComment_request.requestXml);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _GetComment_request:GetComment_request;
		/**
		 * @see IRemoteInterfaceService#GetComment_request_var
		 */
		[Bindable]
		public function get getComment_request_var():GetComment_request
		{
			return _GetComment_request;
		}
		
		/**
		 * @private
		 */
		public function set getComment_request_var(request:GetComment_request):void
		{
			_GetComment_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _GetComment_lastResult:String;
		[Bindable]
		/**
		 * @see IRemoteInterfaceService#GetComment_lastResult
		 */	  
		public function get getComment_lastResult():String
		{
			return _GetComment_lastResult;
		}
		/**
		 * @private
		 */
		public function set getComment_lastResult(lastResult:String):void
		{
			_GetComment_lastResult = lastResult;
		}
		
		/**
		 * @see IRemoteInterfaceService#addGetComment()
		 */
		public function addgetCommentEventListener(listener:Function):void
		{
			addEventListener(GetCommentResultEvent.GetComment_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _GetComment_populate_results(event:ResultEvent):void
        {
        var e:GetCommentResultEvent = new GetCommentResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             getComment_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the SetComment operation
          

        /**
         * @see IRemoteInterfaceService#SetComment()
         */
        public function setComment(requestXml:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.setComment(requestXml);
            _internal_token.addEventListener("result",_SetComment_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IRemoteInterfaceService#SetComment_send()
		 */    
        public function setComment_send():AsyncToken
        {
        	return setComment(_SetComment_request.requestXml);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _SetComment_request:SetComment_request;
		/**
		 * @see IRemoteInterfaceService#SetComment_request_var
		 */
		[Bindable]
		public function get setComment_request_var():SetComment_request
		{
			return _SetComment_request;
		}
		
		/**
		 * @private
		 */
		public function set setComment_request_var(request:SetComment_request):void
		{
			_SetComment_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _SetComment_lastResult:String;
		[Bindable]
		/**
		 * @see IRemoteInterfaceService#SetComment_lastResult
		 */	  
		public function get setComment_lastResult():String
		{
			return _SetComment_lastResult;
		}
		/**
		 * @private
		 */
		public function set setComment_lastResult(lastResult:String):void
		{
			_SetComment_lastResult = lastResult;
		}
		
		/**
		 * @see IRemoteInterfaceService#addSetComment()
		 */
		public function addsetCommentEventListener(listener:Function):void
		{
			addEventListener(SetCommentResultEvent.SetComment_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _SetComment_populate_results(event:ResultEvent):void
        {
        var e:SetCommentResultEvent = new SetCommentResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             setComment_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the GetChangeList operation
          

        /**
         * @see IRemoteInterfaceService#GetChangeList()
         */
        public function getChangeList(requestXml:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.getChangeList(requestXml);
            _internal_token.addEventListener("result",_GetChangeList_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IRemoteInterfaceService#GetChangeList_send()
		 */    
        public function getChangeList_send():AsyncToken
        {
        	return getChangeList(_GetChangeList_request.requestXml);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _GetChangeList_request:GetChangeList_request;
		/**
		 * @see IRemoteInterfaceService#GetChangeList_request_var
		 */
		[Bindable]
		public function get getChangeList_request_var():GetChangeList_request
		{
			return _GetChangeList_request;
		}
		
		/**
		 * @private
		 */
		public function set getChangeList_request_var(request:GetChangeList_request):void
		{
			_GetChangeList_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _GetChangeList_lastResult:String;
		[Bindable]
		/**
		 * @see IRemoteInterfaceService#GetChangeList_lastResult
		 */	  
		public function get getChangeList_lastResult():String
		{
			return _GetChangeList_lastResult;
		}
		/**
		 * @private
		 */
		public function set getChangeList_lastResult(lastResult:String):void
		{
			_GetChangeList_lastResult = lastResult;
		}
		
		/**
		 * @see IRemoteInterfaceService#addGetChangeList()
		 */
		public function addgetChangeListEventListener(listener:Function):void
		{
			addEventListener(GetChangeListResultEvent.GetChangeList_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _GetChangeList_populate_results(event:ResultEvent):void
        {
        var e:GetChangeListResultEvent = new GetChangeListResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             getChangeList_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//stub functions for the SetChange operation
          

        /**
         * @see IRemoteInterfaceService#SetChange()
         */
        public function setChange(requestXml:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.setChange(requestXml);
            _internal_token.addEventListener("result",_SetChange_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IRemoteInterfaceService#SetChange_send()
		 */    
        public function setChange_send():AsyncToken
        {
        	return setChange(_SetChange_request.requestXml);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _SetChange_request:SetChange_request;
		/**
		 * @see IRemoteInterfaceService#SetChange_request_var
		 */
		[Bindable]
		public function get setChange_request_var():SetChange_request
		{
			return _SetChange_request;
		}
		
		/**
		 * @private
		 */
		public function set setChange_request_var(request:SetChange_request):void
		{
			_SetChange_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _SetChange_lastResult:String;
		[Bindable]
		/**
		 * @see IRemoteInterfaceService#SetChange_lastResult
		 */	  
		public function get setChange_lastResult():String
		{
			return _SetChange_lastResult;
		}
		/**
		 * @private
		 */
		public function set setChange_lastResult(lastResult:String):void
		{
			_SetChange_lastResult = lastResult;
		}
		
		/**
		 * @see IRemoteInterfaceService#addSetChange()
		 */
		public function addsetChangeEventListener(listener:Function):void
		{
			addEventListener(SetChangeResultEvent.SetChange_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _SetChange_populate_results(event:ResultEvent):void
        {
        var e:SetChangeResultEvent = new SetChangeResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             setChange_lastResult = e.result;
		             dispatchEvent(e);
	        		
		}
		
		//service-wide functions
		/**
		 * @see IRemoteInterfaceService#getWebService()
		 */
		public function getWebService():BaseRemoteInterfaceService
		{
			return _baseService;
		}
		
		/**
		 * Set the event listener for the fault event which can be triggered by each of the operations defined by the facade
		 */
		public function addRemoteInterfaceServiceFaultEventListener(listener:Function):void
		{
			addEventListener("fault",listener);
		}
		
		/**
		 * Internal function to re-dispatch the fault event passed on by the base service implementation
		 * @private
		 */
		 
		 private function throwFault(event:FaultEvent):void
		 {
		 	dispatchEvent(event);
		 }
    }
}
