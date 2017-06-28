 package com.makolab.components.document
{
	import flash.events.Event;

	public class DocumentEvent extends Event
	{
		public static const DOCUMENT_FIELD_CHANGE:String = "documentFieldChange";
		public static const DOCUMENT_LINE_CHANGE:String = "documentLineChange";
		public static const DOCUMENT_RECALCULATE:String = "documentRecalculate";
		public static const DOCUMENT_LINE_ADD:String = "documentLineAdd";
		public static const DOCUMENT_LINE_DELETE:String = "documentLineDelete";
		public static const DOCUMENT_LINE_SET_ITEM:String = "documentLineSetItem";
		public static const DOCUMENT_LINE_ITEM_DETAILS_LOAD:String = "documentLineItemDetailsLoad";
		public static const DOCUMENT_LINE_ATTRIBUTE_CHANGE:String = "documentLineAttributeChange";
		public static const DOCUMENT_LOAD:String = "documentLoad";
		public static const DOCUMENT_COMMIT:String = "documentCommit";
		public static const DOCUMENT_SAVE:String = "documentSave";
		public static const DOCUMENT_PAYMENT_CHANGE:String = "documentPaymentChangeSimple";
		//public static const DOCUMENT_PAYMENT_CHANGE_ADVANCED:String = "documentPaymentChangeAdvanced";
		public static const DOCUMENT_OPTIONS_CHANGE:String = "documentOptionsChange";
		public static const DOCUMENT_STATUS_CHANGE:String = "documentStatusChange";
		public static const DOCUMENT_ATTRIBUTE_CHANGE:String = "documentAttributeChange";
		public static const DOCUMENT_LINE_ADD_DECISION_COMPLAIN:String = "documentLineAddDecisionComplain";
		public static const DOCUMENT_LINE_SET_COMPLAIN:String = "DocumentLineSetComplain";
		public static const DOCUMENT_SHIFTS_FAULT:String = "DocumentShiftsFault";
		
		public var line:Object;
		public var fieldName:String;
		
		private var _updateDocument:Boolean = false;
		
		public function DocumentEvent(
			type:String,
			bubbles:Boolean=false,
			cancelable:Boolean=false,
			fieldName:String = null,
			line:Object = null
		)
		{
			super(type, bubbles, cancelable);
			this.fieldName = fieldName;
			this.line = line;
		}
		
		public function setUpdateDocument():void
		{
			_updateDocument = true;
		}
		
		public function get isUpdateDocumentSet():Boolean
		{
			return _updateDocument;
		}
		
		public static function createEvent
			(
				type:String,
				fieldName:String = null,
				line:Object = null,
				cancelable:Boolean = false
			):DocumentEvent
		{
			return new DocumentEvent(type, false, cancelable, fieldName, line);
		}
		
		public override function toString():String
		{
			return super.toString() + '\n' +
				'fieldName=' + this.fieldName + ',line=' + this.line;
		}
	}
}