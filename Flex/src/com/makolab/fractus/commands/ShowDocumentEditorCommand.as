package com.makolab.fractus.commands
{
	import com.makolab.components.inputComponents.DocumentImportDetailsColorMix;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	import com.makolab.fractus.view.documents.documentEditors.AdvancedSalesDocumentEditor;
	import com.makolab.fractus.view.documents.documentEditors.CorrectivePurchaseDocumentEditor;
	import com.makolab.fractus.view.documents.documentEditors.CorrectiveSalesDocumentEditor;
	import com.makolab.fractus.view.documents.documentEditors.CorrectiveWarehouseDocumentEditor;
	import com.makolab.fractus.view.documents.documentEditors.DocumentEditor;
	import com.makolab.fractus.view.documents.documentEditors.FinancialDocumentEditor;
	import com.makolab.fractus.view.documents.documentEditors.OrderDocumentEditor;
	import com.makolab.fractus.view.documents.documentEditors.ProductionOrderDocumentEditor;
	import com.makolab.fractus.view.documents.documentEditors.ProtocolComplaintDocumentEditor;
	import com.makolab.fractus.view.documents.documentEditors.PurchaseDocumentEditor;
	import com.makolab.fractus.view.documents.documentEditors.QuickSalesDocumentEditor;
	import com.makolab.fractus.view.documents.documentEditors.SalesOrderDocumentEditor;
	import com.makolab.fractus.view.documents.documentEditors.ServiceDocumentEditor;
	import com.makolab.fractus.view.documents.documentEditors.SimpleSalesDocumentEditor;
	import com.makolab.fractus.view.documents.documentEditors.TechnologyDocumentEditor;
	import com.makolab.fractus.view.documents.documentEditors.TechnologyDocumentEditorEC;
	import com.makolab.fractus.view.documents.documentEditors.WarehouseDocumentEditor;
	
	import mx.controls.Alert;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	
	public class ShowDocumentEditorCommand extends FractusCommand
	{
		public static const EDITOR_SIMPLE:int = 1;
		public static const EDITOR_ADVANCED:int = 2;
		public static const EDITOR_QUICK:int = 3;
		public var isImport:Boolean=false;
		public var category:uint;
		public var editorType:int;
		public var template:String;
		public var documentId:String;
		public var correctedDocumentId:String;
		public var source:XML;
		public var objectType:String;

		private var newDocument:Boolean;
		 		
		private var editor:DocumentEditor;
		
		
		//qla
		private var documentObject:DocumentObject;
		public function ShowDocumentEditorCommand(category:uint)
		{
			this.category = category;
		}
		
		override public function execute(data:Object = null,addUser:Boolean=true):AsyncToken
		{
			if (!objectType) objectType = DocumentTypeDescriptor.getDocumentCategory(category);
			if (!objectType) throw new Error("ShowDocumentEditorCommand error: Unknown object type.");
			
			if (documentId)
			{
				this.newDocument = false;
				var loadCmd:LoadBusinessObjectCommand = new LoadBusinessObjectCommand();
				loadCmd.addEventListener(ResultEvent.RESULT, handleCommandResult);
				logExecution({ 'id' : documentId, 'type' : objectType });
				loadCmd.execute({ 'id' : documentId, 'type' : objectType },addUser);
			}
			else if (correctedDocumentId)
			{
				this.newDocument = true;
				var correctCmd:CreateBusinessObjectCommand = new CreateBusinessObjectCommand();
				correctCmd.addEventListener(ResultEvent.RESULT, handleCommandResult);
				var src:XML = <source type="correction"><correctedDocumentId>{correctedDocumentId}</correctedDocumentId></source>;
				logExecution({ 'template' : template, 'type' : objectType, 'source' : src });
				correctCmd.execute({ 'template' : template, 'type' : objectType, 'source' : src },addUser);
			}
			else //if (template || source)
			{
				this.newDocument = true;
				var createCmd:CreateBusinessObjectCommand = new CreateBusinessObjectCommand();
				createCmd.addEventListener(ResultEvent.RESULT, handleCommandResult);
				logExecution({ 'template' : template, 'type' : objectType, 'source' : source });
				createCmd.execute({ 'template' : template, 'type' : objectType, 'source' : source },addUser);
			}
			//else throw new Error("ShowDocumentEditorCommand error: No property set for ShowDocumentEditorCommand - documentId, tempate or source must be provided.");
			return null;
		}
		
		private function handleCommandResult(event:ResultEvent):void
		{
			documentObject = new DocumentObject(XML(event.result));
			documentObject.isNewDocument = this.newDocument;
			if (correctedDocumentId) {
				documentObject.basedOnDocumentID = this.correctedDocumentId;
			}
			if(isImport)
			{
	//		trace(documentObject.xml.contractor);
//				documentObject.xml.contractor.* = '';
//				documentObject.xml.netCalculationType=1;
//				documentObject.xml.netCalculationType.@selected = "1";
				//documentObject.xml.netCalculationTyp
				//trace(source);
//				var id:String='A855B6A4-C9CE-4C8D-A6C0-FFC1F07711F0';
//				var command:LoadBusinessObjectCommand = new LoadBusinessObjectCommand();
//				command.addEventListener(ResultEvent.RESULT, loadContractorResult);
//				command.execute( { type : "Contractor", id : id } );
                var str:String=(XML(event.result).commercialDocument.@source);
              //  trace("O:",zwrotka);
               // trace("A:",zwrotka.itemsNotFound);
                //trace("B:",zwrotka.root);
                
                var pattern:RegExp =/code>.*?<\/code/g; 
				var results:Array = str.match(pattern);
				trace(results);
				if(results.length)
				{
					for(var i:int=0;i<results.length;i++)
					{
						var s:String=results[i];
						
						 results[i]= s.substring(5,s.length-6);
						 trace(results[i]);
					}
							
					Alert.show("Nie znaleziono następujcych produktów:"+results, LanguageManager.getLabel('documents.validationErrors'));
				}
               //	var arr:Array=zwrotka.split("itemsNotFound");
               
               	showEditor(documentObject, editorType);
				dispatchEvent(ResultEvent.createEvent(documentObject));
			}
			else
			{
				showEditor(documentObject, editorType);
				dispatchEvent(ResultEvent.createEvent(documentObject));
			}
		}
//QLA

/*
<contractor>
  <contractor type="Contractor">
    <version>
      44D5B990-A304-4E07-8BC9-546828EA3BE2
    </version>
    <id>
      A855B6A4-C9CE-4C8D-A6C0-FFC1F07711F0
    </id>
    <groupMemberships/>
    <attributes/>
    <accounts/>
    <relations/>
    <addresses>
      <address>
        <version>
          995E8379-E5C1-4A74-AF87-2AEE1925D8C9
        </version>
        <id>
          B25DA78F-3564-4CF6-8847-CC2745674293
        </id>
        <countryId>
          8C67F218-903D-4A1D-8D21-E8040E7DCBCC
        </countryId>
        <postOffice>
          Łódź
        </postOffice>
        <postCode>
          90-245
        </postCode>
        <city>
          Łódź
        </city>
        <address>
          Wierzbowa 18
        </address>
        <contractorFieldId>
          36BF2FB3-9D77-43F1-93B9-519CD389DC14
        </contractorFieldId>
        <order>
          1
        </order>
      </address>
    </addresses>
    <creationUser>
      Makolab Administrator
    </creationUser>
    <creationUserId>
      08E5B4A8-C430-47CB-BEEA-76AD1DD443F7
    </creationUserId>
    <creationDate>
      2013-12-06T11:56:49.760
    </creationDate>
    <nipPrefixCountryId>
      8C67F218-903D-4A1D-8D21-E8040E7DCBCC
    </nipPrefixCountryId>
    <nip>
      725-171-53-26
    </nip>
    <shortName>
      Dancing Queen Club
    </shortName>
    <fullName>
      Dancing Queen Club Aneta Bielicka
    </fullName>
    <isOwnCompany>
      0
    </isOwnCompany>
    <isEmployee>
      0
    </isEmployee>
    <isBank>
      0
    </isBank>
    <isBusinessEntity>
      1
    </isBusinessEntity>
    <isReceiver>
      1
    </isReceiver>
    <isSupplier>
      0
    </isSupplier>
    <code>
      DANCING QUEEN CLUB
    </code>
  </contractor>
</contractor>
*/
			public function loadContractorResult(event:ResultEvent):void
			{
				documentObject.xml.contractor.* = XML(event.result).contractor;
				
				
				showEditor(documentObject, editorType);
				dispatchEvent(ResultEvent.createEvent(documentObject));
			}
			
			
			
		public static function showEditor(documentObject:DocumentObject, editorType:int = EDITOR_ADVANCED):void
		{
			var editorClass:Class;
			switch (documentObject.typeDescriptor.categoryNumber)
			{
				case DocumentTypeDescriptor.CATEGORY_SALES:
					/* if (editorType == EDITOR_SIMPLE) editorClass = SimpleSalesDocumentEditor;
					else editorClass = AdvancedSalesDocumentEditor; */
					switch (editorType)
					{
						case EDITOR_SIMPLE: 	editorClass = SimpleSalesDocumentEditor; break;
						case EDITOR_ADVANCED:	editorClass = AdvancedSalesDocumentEditor; break;
						case EDITOR_QUICK:		editorClass = QuickSalesDocumentEditor; break;
						default:				editorClass = AdvancedSalesDocumentEditor; break;
					}
					break;
				case DocumentTypeDescriptor.CATEGORY_SALES_CORRECTION:
					editorClass = CorrectiveSalesDocumentEditor;
					break;
				case DocumentTypeDescriptor.CATEGORY_WAREHOUSE:
					editorClass = WarehouseDocumentEditor;
					break;
				case DocumentTypeDescriptor.CATEGORY_WAREHOUSE_INCOME_CORRECTION:
					editorClass = CorrectiveWarehouseDocumentEditor;
					break;
				case DocumentTypeDescriptor.CATEGORY_WAREHOUSE_OUTCOME_CORRECTION:
					editorClass = CorrectiveWarehouseDocumentEditor;
					break;
				case DocumentTypeDescriptor.CATEGORY_PURCHASE:
					editorClass = PurchaseDocumentEditor;
					break;
				case DocumentTypeDescriptor.CATEGORY_PURCHASE_CORRECTION:
					editorClass = CorrectivePurchaseDocumentEditor;
					break;
				case DocumentTypeDescriptor.CATEGORY_WAREHOUSE_ORDER:
				case DocumentTypeDescriptor.CATEGORY_WAREHOUSE_RESERVATION:
					editorClass = OrderDocumentEditor;
					break;
				/*
				case DocumentTypeDescriptor.CATEGORY_SALES_CORRECTION:
					editorClass = CorrectiveSalesDocumentEditor;
					break;
				case DocumentTypeDescriptor.CATEGORY_PURCHASE_CORRECTION:
					editorClass = CorrectivePurchaseDocumentEditor;
					break;
				*/
				case DocumentTypeDescriptor.CATEGORY_WAREHOUSE_INCOME_CORRECTION:
				case DocumentTypeDescriptor.CATEGORY_WAREHOUSE_OUTCOME_CORRECTION:
					editorClass = CorrectiveWarehouseDocumentEditor;
					break;
				case DocumentTypeDescriptor.CATEGORY_FINANCIAL_DOCUMENT:
					editorClass = FinancialDocumentEditor;
					break;
				case DocumentTypeDescriptor.CATEGORY_SERVICE_DOCUMENT:
					editorClass = ServiceDocumentEditor;
					break;
				case DocumentTypeDescriptor.CATEGORY_SALES_ORDER_DOCUMENT:
					editorClass = SalesOrderDocumentEditor;
					break;
				case DocumentTypeDescriptor.CATEGORY_PROTOCOL_COMPLAINTS:
					editorClass = ProtocolComplaintDocumentEditor;
					break;
				case DocumentTypeDescriptor.CATEGORY_TECHNOLOGY_DOCUMENT:
					editorClass = TechnologyDocumentEditorEC;
					break;
				case DocumentTypeDescriptor.CATEGORY_PRODUCTION_ORDER_DOCUMENT:
					editorClass = ProductionOrderDocumentEditor;
					break;
				case DocumentTypeDescriptor.CATEGORY_SALES_PREORDER:
					editorClass = DocumentImportDetailsColorMix;
					break;
			}
			DocumentEditor.showWindow(documentObject, editorClass);
		}
	}
}