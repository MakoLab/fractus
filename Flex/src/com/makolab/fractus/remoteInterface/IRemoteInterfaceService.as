
/**
 * Service.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */
package com.makolab.fractus.remoteInterface{
	import mx.rpc.AsyncToken;
	import flash.utils.ByteArray;
	import mx.rpc.soap.types.*;
               
    public interface IRemoteInterfaceService
    {
    	//Stub functions for the GetComment operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param requestXml
    	 * @return An AsyncToken
    	 */
    	function getComment(requestXml:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function getComment_send():AsyncToken;
        
        /**
         * The getComment operation lastResult property
         */
        function get getComment_lastResult():String;
		/**
		 * @private
		 */
        function set getComment_lastResult(lastResult:String):void;
       /**
        * Add a listener for the getComment operation successful result event
        * @param The listener function
        */
       function addgetCommentEventListener(listener:Function):void;
       
       
        /**
         * The getComment operation request wrapper
         */
        function get getComment_request_var():GetComment_request;
        
        /**
         * @private
         */
        function set getComment_request_var(request:GetComment_request):void;
                   
    	//Stub functions for the SetComment operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param requestXml
    	 * @return An AsyncToken
    	 */
    	function setComment(requestXml:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function setComment_send():AsyncToken;
        
        /**
         * The setComment operation lastResult property
         */
        function get setComment_lastResult():String;
		/**
		 * @private
		 */
        function set setComment_lastResult(lastResult:String):void;
       /**
        * Add a listener for the setComment operation successful result event
        * @param The listener function
        */
       function addsetCommentEventListener(listener:Function):void;
       
       
        /**
         * The setComment operation request wrapper
         */
        function get setComment_request_var():SetComment_request;
        
        /**
         * @private
         */
        function set setComment_request_var(request:SetComment_request):void;
                   
    	//Stub functions for the GetChangeList operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param requestXml
    	 * @return An AsyncToken
    	 */
    	function getChangeList(requestXml:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function getChangeList_send():AsyncToken;
        
        /**
         * The getChangeList operation lastResult property
         */
        function get getChangeList_lastResult():String;
		/**
		 * @private
		 */
        function set getChangeList_lastResult(lastResult:String):void;
       /**
        * Add a listener for the getChangeList operation successful result event
        * @param The listener function
        */
       function addgetChangeListEventListener(listener:Function):void;
       
       
        /**
         * The getChangeList operation request wrapper
         */
        function get getChangeList_request_var():GetChangeList_request;
        
        /**
         * @private
         */
        function set getChangeList_request_var(request:GetChangeList_request):void;
                   
    	//Stub functions for the SetChange operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param requestXml
    	 * @return An AsyncToken
    	 */
    	function setChange(requestXml:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function setChange_send():AsyncToken;
        
        /**
         * The setChange operation lastResult property
         */
        function get setChange_lastResult():String;
		/**
		 * @private
		 */
        function set setChange_lastResult(lastResult:String):void;
       /**
        * Add a listener for the setChange operation successful result event
        * @param The listener function
        */
       function addsetChangeEventListener(listener:Function):void;
       
       
        /**
         * The setChange operation request wrapper
         */
        function get setChange_request_var():SetChange_request;
        
        /**
         * @private
         */
        function set setChange_request_var(request:SetChange_request):void;
                   
        /**
         * Get access to the underlying web service that the stub uses to communicate with the server
         * @return The base service that the facade implements
         */
        function getWebService():BaseRemoteInterfaceService;
	}
}