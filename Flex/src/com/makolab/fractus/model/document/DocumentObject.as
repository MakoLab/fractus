package com.makolab.fractus.model.document
{
	import com.makolab.components.inputComponents.DictionaryEditor;
	import com.makolab.components.util.ComponentExportManager;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.view.documents.TextPrintPreviewWindow;
	import com.makolab.fractus.view.documents.documentControls.DocumentBarcodeVerificationObject;
	import com.makolab.fractus.view.documents.documentEditors.DocumentEditor;
	
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	import mx.containers.HBox;
	import mx.containers.TitleWindow;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.TextInput;
	import mx.managers.PopUpManager;

	/**
	 * Dispatched when a user changes any field of editing document.
	 */
	[Event(name="documentFieldChange", type="com.makolab.components.document.DocumentEvent")]
	/**
	 * Dispatched when a user modifies an item.
	 */	
	[Event(name="documentLineChange", type="com.makolab.components.document.DocumentEvent")]
	[Event(name="documentLoad", type="com.makolab.components.document.DocumentEvent")]
	[Event(name="documentCommit", type="com.makolab.components.document.DocumentEvent")]
	public class DocumentObject extends EventDispatcher
	{
		public static const FIELD_CONTRACTOR:String = "contractor";
		public static const FIELD_CONTRACTOR_ADDRESS:String = "contractorAddress";
		public static const FIELD_RECIPIENT_ADDRESS:String = "recipientAddress";
		public static const FIELD_ISSUE_DATE:String = "issueDate";
		public static const FIELD_EVENT_DATE:String = "eventDate";
		public static const FIELD_PAYMENTS:String = "payments";
		
		public static const STATUS_BOOKED:Number = 60;
		public static const STATUS_COMMITED:Number = 40;
		public static const STATUS_CANCELED:Number = -20;
		public static const STATUS_SAVED:Number = 20;
		
		public static const ITEM_SALE:String = "itemSale";
		public static const SERVICE_SALE:String = "serviceSale";
		public static const ITEM_SALE_RESERVATION:String = "itemSaleReservation";
		public static const SERVICE_SALE_RESERVATION:String = "serviceSaleReservation";
		
		protected var sourceXML:XML;
		
		public var defaultLineDiscount:Number = 0;
		
		[Bindable]
		public var enableAddressSelection:Boolean;
		
		public var lineClass:Class;
		
		[Bindable]
		public var typeDescriptor:DocumentTypeDescriptor;
		
		[Bindable]
		public var draftId:String = null;
		
		/**
		 * Collection of <code>CommercialDocumentLine</code> objects.
		 */
		[Bindable]
		public var lines:ArrayCollection;
		
		public var metaData:Object = {};
		
		[Bindable]
		public var allowLinesEdit:Boolean = true;
		
		public var commitBlock:String;
		
		/**
		 * Collection of DocumentBarecodeVerificationObjectLine objects.
		 * contains barecode quantity verification
		 */
		[Bindable]
		public var verificationObject:DocumentBarcodeVerificationObject;
		
		[Bindable]
		public var decisionComplaint:ArrayCollection;
		
		/**
		 * Indicates that the edited document is a new one
		 * (the user is issuing a new document, not modifying a previously
		 * issued one).
		 */
		[Bindable]
		public var isNewDocument:Boolean = false;
		
		
		[Bindable]
		public var basedOnDocumentID:String = null;
		
		/**
		 * String containing document remarks
		 */
		/*
		[Bindable]
		public var remarksValue:String;
		[Bindable]
		public var remarksId:String;
		*/
		
		/**
		 * XML containing document payment data
		 */
		[Bindable]
		public var paymentsXML:XML;
		
		/**
		 * XML containing document attribute xml template
		 */
		 
		//public var attributeXML:XML =  <attribute><documentFieldId/><value/></attribute>;
		[Bindable]
		//public var attrib:XML = <attributes/>;
		public var attributes:XMLListCollection;
		
		/**
		 * XML containing document remarks attribute
		 */
		/* 
		[Bindable]
		public var remarksXML:XML = attributeXML;
		*/
		/**
		 * Collection of <code>CommercialDocumentVatTableEntry</code> objects.
		 */
		[Bindable]
		public var vatTable:ArrayCollection;
		
		[Bindable]
		public var differentialVatTable:ArrayCollection;
		
		[Bindable]
		public var automaticDifferentialVatTable:ArrayCollection;
		
		[Bindable]
		public var vatTableBeforeCorrection:ArrayCollection;
		
		/**
		 * Total amount that should by paid to cover the value of the document.
		 */
		[Bindable]
		public var totalForPayment:Number;
		
		/**
		 * Allows to bypass negative quantity and value validation. Set by validation plugin.
		 */
		public var allowNegativeLines:Boolean = false;
		
		public function DocumentObject(documentXML:XML)
		{
			loadXML(documentXML);
		}
		
		[Bindable]
		public function set xml(value:XML):void
		{
			sourceXML = value;
		}
		public function get xml():XML
		{
			return sourceXML;
		}
		
		[Bindable]
		public var documentOptions:XMLList;
		
		[Bindable]
		public var shiftsTransaction:Object = {};
		
		[Bindable]
		public var allowPaymentsEdit:Boolean = true;

		
		/**
		 * Editor currently used for editing this document.
		 */
		public var editor:DocumentEditor;
		
		/**
		 * Creates a new <code>CommercialDocumentLine</code> object instance.
		 * 
		 * @return Newly created <code>CommercialDocumentLine</code> object instance.
		 */
		public function newLineTemplateFactory():Object
		{
			return new lineClass(null, this);
		}
		
		[Bindable]
		public function get documentCurrencyId():String
		{
			if (xml.documentCurrencyId.length() > 0) return xml.documentCurrencyId.toString();
			else return null; 
		}
		
		public function set documentCurrencyId(value:String):void
		{
			xml.documentCurrencyId = value; 
		}
		
		/**
		 * Deserializes <code>CommercialDocument</code> from full xml.
		 * 
		 * @param value Source xml to deserialize from.
		 */
		protected function loadXML(value:XML):void
		{
			var xml:XML = value.*.(valueOf().localName().match(/.+Document/))[0].copy();
			if(value.hasOwnProperty("shiftTransaction")){
				for each(var child:Object in value.shiftTransaction.*){
					if(child.name() != "shifts")shiftsTransaction[child.name()] = child.*;
				}
				shiftsTransaction.shifts = value.shiftTransaction.shifts.*;
				//shiftsTransaction.id = value.shiftTransaction.id.toString();
				//shiftsTransaction.version = value.shiftTransaction.version.toString();
			}
			this.typeDescriptor = new DocumentTypeDescriptor(xml.documentTypeId);
			
			if (value.options.length() > 0)
			{
				this.documentOptions = value.options.*.copy();
			}
			else
			{
				documentOptions = typeDescriptor.availableIssueOptions.copy();
			}
			
			// TODO: Prowizorka - do obsużenia w kernelu.
			for each (var option:XML in documentOptions)
			{
				if (option.localName() == "generateDocument" && option.@method == "outcomeFromSales")
				{
					if (xml.version.length() > 0 && xml.lines..commercialWarehouseRelations.commercialWarehouseRelation.length() == 0)
						option.@selected = 0;
				}
			}
			
			switch (typeDescriptor.categoryNumber)
			{
				case DocumentTypeDescriptor.CATEGORY_SALES:
				case DocumentTypeDescriptor.CATEGORY_PURCHASE:
				case DocumentTypeDescriptor.CATEGORY_WAREHOUSE_ORDER:
				case DocumentTypeDescriptor.CATEGORY_WAREHOUSE_RESERVATION:
				case DocumentTypeDescriptor.CATEGORY_SALES_ORDER_DOCUMENT:
				case DocumentTypeDescriptor.CATEGORY_TECHNOLOGY_DOCUMENT:
				case DocumentTypeDescriptor.CATEGORY_PRODUCTION_ORDER_DOCUMENT:
					lineClass = CommercialDocumentLine;
					break;
				case DocumentTypeDescriptor.CATEGORY_WAREHOUSE:
					lineClass = WarehouseDocumentLine;
					break;
				case DocumentTypeDescriptor.CATEGORY_SALES_CORRECTION:
				case DocumentTypeDescriptor.CATEGORY_PURCHASE_CORRECTION:
					lineClass = CorrectiveCommercialDocumentLine;
					break;
				case DocumentTypeDescriptor.CATEGORY_WAREHOUSE_INCOME_CORRECTION:
				case DocumentTypeDescriptor.CATEGORY_WAREHOUSE_OUTCOME_CORRECTION:
					lineClass = CorrectiveWarehouseDocumentLine;
					break;
				case DocumentTypeDescriptor.CATEGORY_FINANCIAL_DOCUMENT:
					lineClass = FinancialDocumentLine;
					break;
				case DocumentTypeDescriptor.CATEGORY_SERVICE_DOCUMENT:
					lineClass = ServiceDocumentLine;
					break;
				case DocumentTypeDescriptor.CATEGORY_PROTOCOL_COMPLAINTS:
					lineClass = ProtocolComplainDocumentLine;
					break; 	
				default:
					throw new Error("DocumentObject error: undetermined line object class.");
			}
			
			// deserialize lines
			this.lines = new ArrayCollection();
			this.decisionComplaint = new ArrayCollection();
			
			var lineList:XMLList = typeDescriptor.isFinancialDocument ? xml.payments.payment : xml.lines.line; //lista pozycji
			var lineShifts:XMLList;//lista shiftow danej pozycji 
			var relatedShifts:XMLList;//lista shiftow powiązanych z danym dokumentem.
			var shiftList:Array = [];
			var newLine:*;
			var lineOrdinalNumber:int = 1;
			for each (var xmlLine:XML in lineList){
				
				if(shiftsTransaction.shifts)lineShifts = shiftsTransaction.shifts.(@lineOrdinalNumber == lineOrdinalNumber);
				relatedShifts = new XMLList();
				shiftList = [];
				
				if(typeDescriptor.isWarehouseIncome && !typeDescriptor.isCorrectiveDocument){
					for each(var ls:XML in lineShifts){
						if(Number(ls.@lineOrdinalNumber) == lineOrdinalNumber)
							shiftList.push(new ShiftObject({
																quantity : ls.quantity.toString(),
																status : ls.status.toString(),
																containerId : ls.containerId.toString(),
																version : ls.version.toString(),
																shiftId : ls.id.toString(),
																attributes : XML(ls.attributes),
																shiftTransactionId : ls.shiftTransactionId.toString(),
																incomeWarehouseDocumentLineId : ls.incomeWarehouseDocumentLineId.toString(),
																warehouseDocumentLineId : ls.WarehouseDocumentLineId.toString(),
																ordinalNumber : ls.ordinalNumber.toString(),
																sourceContainerId : ls.sourceContainerId.toString(),
																warehouseId : ls.warehouseId.toString()
															}));
					}
				}else if(typeDescriptor.isWarehouseOutcome && !typeDescriptor.isCorrectiveDocument){
					for each(var ior:XML in xmlLine.incomeOutcomeRelations.incomeOutcomeRelation){
						if(lineShifts)relatedShifts = /* relatedShifts +  */lineShifts.(incomeWarehouseDocumentLineId.toString() == ior.relatedLine.line.id.toString());
						if(relatedShifts.length() > 0){
							var unalocatedQuantity:Number = Number(ior.quantity.toString());
							for each(var rs:XML in relatedShifts){
								var structure:XML = XML(ModelLocator.getInstance().configManager.getValue("warehouse.warehouseMap"));
								var label:String = structure..slot.(@id == rs.sourceContainerId.toString()).@label;
								unalocatedQuantity -= Number(rs.quantity.toString());
								shiftList.push(new ShiftObject({
																incomeWarehouseDocumentLineId : ior.relatedLine.line.id.toString(),
																IORid : ior.id.toString(),
																IORversion : ior.version.toString(),
																IORincomeDate : ior.incomeDate.toString(),
																IORquantity : ior.quantity.toString(),
																shiftId : rs.id.toString(),
																sourceShiftId : rs.sourceShiftId.toString(),
																containerId : rs.containerId.toString(),
																sourceContainerId : rs.sourceContainerId,
																warehouseDocumentLineId : rs.warehouseDocumentLineId,
																warehouseId : rs.warehouseId,
																shiftTransactionId : rs.shiftTransactionId,
																containerLabel : label,
																quantity : rs.quantity.toString(),
																version : rs.version.toString(),
																incomeDate : rs.incomeDate.toString(),
																status : rs.status.toString(),
																ordinalNumber : rs.ordinalNumber.toString(),
																attributes : XML(rs.attributes)
																}));
							}
							if(unalocatedQuantity > 0){
								var unalocatedShift:ShiftObject = new ShiftObject();
								unalocatedShift.incomeWarehouseDocumentLineId = ior.relatedLine.line.id.toString();
								unalocatedShift.IORid = ior.id.toString();
								unalocatedShift.IORincomeDate = ior.incomeDate.toString();
								unalocatedShift.quantity = unalocatedQuantity.toString();
								
								shiftList.push(unalocatedShift);
							}
						}else{
							shiftList.push(new ShiftObject({
															incomeWarehouseDocumentLineId : ior.relatedLine.line.id.toString(),
															IORid : ior.id.toString(),
															IORversion : ior.version.toString(),
															IORincomeDate : ior.incomeDate.toString(),
															quantity : ior.quantity.toString()
															}));
						}
					}
				}
				
				
				lineOrdinalNumber++;
				newLine = new lineClass(xmlLine, this);
				if(newLine.hasOwnProperty("shifts"))newLine.shifts = shiftList;
				if(newLine.hasOwnProperty("itemTypeId") && xmlLine.itemTypeId.length() > 0)newLine.itemTypeId = xmlLine.itemTypeId.toString();
				lines.addItem(newLine);
				shiftList = [];
				//lines.addItem(new lineClass(xmlLine, this));
				
				if(xmlLine != null && lineClass == ProtocolComplainDocumentLine)
				{	
					for each (var decComplainXmlLine:XML in xmlLine.complaintDecisions.complaintDecision)
					{
						var decision:DecisionComplainDocumentLine = new DecisionComplainDocumentLine(decComplainXmlLine, this, newLine);
					  	this.decisionComplaint.addItem(decision);
					}
				}
			}
				
			if (lineClass == CorrectiveCommercialDocumentLine) CorrectiveCommercialDocumentLine.relateCorrectedLines(this.lines, xml.lines.line);
			
			
			// deserialize vat table
			this.vatTable = deserializeVatTable(xml.vatTable.vtEntry);
			
			if (this.typeDescriptor.isCorrectiveDocument)
			{
				this.vatTableBeforeCorrection = deserializeVatTable(xml.vatTableBeforeCorrection.vtEntry);
				// tabela roznicowa zostanie wyliczona przez CalculationPlugin
			}
			
			// detach payments
			if (typeDescriptor.isFinancialDocument)
			{
				delete xml.payments;
			}
			else if (xml.payments.length() > 0)
			{
				this.paymentsXML = XML(xml.payments);
				delete xml.payments;
				//sprawdzanie czy nasz dokument to faktura do paragonu
				for each(var relation:XML in xml.relations.relation){
					if(relation.relationType.toString() == "1")//relationType = 1 - typ relacji 'faktura do paragonu'
					{
						allowPaymentsEdit = false;
					}
				}
			}
			
			// detach remarks
			//this.remarksValue = xml.attributes.*.(documentFieldId==String(DictionaryManager.getInstance().dictionaries.documentRemarks.id.text())).value;
			//this.remarksId = xml.attributes.*.(documentFieldId==String(DictionaryManager.getInstance().dictionaries.documentRemarks.id.text())).documentFieldId;
			
			this.attributes = new XMLListCollection(xml.attributes.*);
			//this.attrib.* = xml.attributes.*;
			
			delete xml.attributes.*;			
			
			// remove lines and vat table from XML
			delete xml.lines;
			delete xml.vatTable;
			if (typeDescriptor.isCorrectiveDocument) delete xml.vatTableBeforeCorrection;
			
			this.xml = xml;
			
			// dodaj pozycje jezeli dokument nie zawiera zadnej
			if (this.lines.length == 0)
			{
				this.lines.addItem(this.newLineTemplateFactory());
			}
			
			// TODO: prowizorka do czasu obsluzenia korekt w .NET
			/*
			this.xml.netValueBeforeCorrection = String(this.xml.netValue);
			this.xml.grossValueBeforeCorrection = String(this.xml.grossValue);
			this.xml.vatValueBeforeCorrection = String(this.xml.vatValue);
			*/
			
			verificationObject = new DocumentBarcodeVerificationObject();
			verificationObject.addLines(this.lines);
		}
		
		/**
		 * Gets the full <code>CommercialDocument</code> serialized to XML format.
		 * 
		 * @return Serialized document in XML format.
		 */
		public function getFullXML():XML
		{
			var ret:XML = sourceXML.copy();
			
			if(this.draftId)
				ret.@draftId = this.draftId;
			
			var xmlLines:XML = typeDescriptor.isFinancialDocument ? <payments/> : <lines/>;
			var IORTemplate:XML = 	<incomeOutcomeRelation>
										<relatedLine>
											<line>
												<id/>
											</line>
										</relatedLine>
									</incomeOutcomeRelation>;
			var warehouseDocumentLine:Object;						
			
			for each (var line:BusinessObject in this.lines)
			{
				if (!line.isEmpty()){
					var xmlLine:XML = line.serialize();
					xmlLines.appendChild(xmlLine);	
					//reklamacje
					for each(var decComplain:DecisionComplainDocumentLine in this.decisionComplaint) 
						if( decComplain.relatedProtocolLine == line)
							xmlLine.complaintDecisions[0].appendChild(decComplain.serialize())
				}
				if(
					(typeDescriptor.isWarehouseOutcome && !typeDescriptor.isCorrectiveDocument && (line as WarehouseDocumentLine).shifts)
					 || (typeDescriptor.isSalesDocument && line.hasOwnProperty("shifts") && (line as CommercialDocumentLine).shifts)
				){
					warehouseDocumentLine = line;
					xmlLines.*[xmlLines.*.length()-1].incomeOutcomeRelations = "";
					for(var i:int = 0; i < warehouseDocumentLine.shifts.length; i++){
						//if(warehouseDocumentLine.shifts[i].containerId != "")IORTemplate.containerId.* = warehouseDocumentLine.shifts[i].containerId;
						//if(warehouseDocumentLine.shifts[i].status != "")IORTemplate.status.* = warehouseDocumentLine.shifts[i].status;
						if(warehouseDocumentLine.shifts[i].IORversion != "")IORTemplate.version.* = warehouseDocumentLine.shifts[i].IORversion;
						if(warehouseDocumentLine.shifts[i].IORid != "")IORTemplate.id.* = warehouseDocumentLine.shifts[i].IORid;
						if(warehouseDocumentLine.shifts[i].IORincomeDate != "")IORTemplate.incomeDate.* = warehouseDocumentLine.shifts[i].IORincomeDate;
						if(warehouseDocumentLine.shifts[i].quantity != "")IORTemplate.quantity.* = warehouseDocumentLine.shifts[i].quantity;
						else if(warehouseDocumentLine.shifts[i].IORquantity != "")IORTemplate.quantity.* = warehouseDocumentLine.shifts[i].IORquantity;
						var IORexists:Boolean = false;
						IORTemplate.relatedLine.line.id.* = warehouseDocumentLine.shifts[i].incomeWarehouseDocumentLineId;
						var existingRelations:XMLList = xmlLines.*[xmlLines.*.length()-1].incomeOutcomeRelations.incomeOutcomeRelation;
						for each(var relation:XML in existingRelations){
							if(relation.relatedLine.line.id.toString() == IORTemplate.relatedLine.line.id.toString()){
								relation.quantity.* = Number(IORTemplate.quantity.toString()) + Number(relation.quantity.toString());
								IORexists = true;
								break;
							}else{
								IORexists = false;
							}
						}
						if(!IORexists)xmlLines.*[xmlLines.*.length()-1].incomeOutcomeRelations.appendChild(IORTemplate.copy());
					}
				}
			}
			
			ret.appendChild(xmlLines);
			
			if (this.vatTable)
			{
				var xmlVatTable:XML = <vatTable/>;
				
				for each(var vtEntry:CommercialDocumentVatTableEntry in this.vatTable)
				{
					xmlVatTable.appendChild(vtEntry.serialize());
				}
				ret.appendChild(xmlVatTable);
			}
			
			
			if (this.paymentsXML) {				
				ret.payments = this.paymentsXML;
				delete ret.payments.payment.dueDays;
			}
			
			ret.attributes = '';
			if (this.attributes) 
			{
				for each (var x:XML in this.attributes) 
				{
					if(String(x.documentFieldId)==ModelLocator.getInstance().dictionaryManager.getIdByName("Attribute_requireSettlement"))
					{
						if(String(x.value)=="0")
						{
							for each (var x1:XML in ret.payments.payment)
								x1.requireSettlement=0; 
						}
						else
						{
							for each (var x1:XML in ret.payments.payment)
								x1.requireSettlement=1; 
						}
					}					
					if (String(x.value).replace(/\s/g, '') != '')
					{
						ret.attributes.appendChild(x.copy());
					}
				}
			}
			/*
			if(this.remarksValue)	{
				remarksXML.value = this.remarksValue;
				remarksXML.documentFieldId = this.remarksId;
				ret.attributes.appendChild(remarksXML);	
			}
			
			if(!this.remarksValue && this.attrib.*.length()==0) delete ret.attributes.*;
			*/
			// trace pozostawiony celowo dla celow diagnostycznych
			// trace("DOCUMENT FULL XML:\n" + ret.toXMLString());
			
			return ret;
		}
		
		public function getShiftsXML():XML
		{
			var ret:XML = new XML();
			var shiftSelectionEnabled:Boolean = false;
			if((typeDescriptor.isWarehouseDocument && !typeDescriptor.isCorrectiveDocument) || typeDescriptor.isCommercialDocument){
				ret = <shiftTransaction type="ShiftTransaction"><shifts/></shiftTransaction>;
				var shiftTemplate:XML = 	<shift lineOrdinalNumber="0">
												<status>40</status>
												<quantity/>
											</shift>;
				var l:int = 0;
				
				for(var child:String in shiftsTransaction)
				{
					if(child != "shifts")ret[child].* = shiftsTransaction[child];
				}
				
				//if(shiftsTransaction.id)ret.id.* = shiftsTransaction.id;
				//if(shiftsTransaction.version)ret.version.* = shiftsTransaction.version;
				//var alocationsEnabled:Boolean = true;
				if(
					(ModelLocator.getInstance().dictionaryManager.dictionaries.allWarehouses.(id.toString() ==  xml.warehouseId.toString()).valuationMethod.toString() == "1")
					 || typeDescriptor.isCommercialDocument
				)shiftSelectionEnabled = true;
				for each (var line:Object in this.lines)
				{
					l++;
					if(line.shifts){
						for(var i:int=0;i<line.shifts.length;i++){
							if(line.shifts[i].containerId || (typeDescriptor.isWarehouseOutcome && line.shifts[i].sourceShiftId) || (typeDescriptor.isSalesDocument && line.shifts[i].sourceShiftId != "")){
								//if(line.shifts[i].quantity > 0)shiftSelectionEnabled = true;
								if(line.shifts[i].status && line.shifts[i].status != "")shiftTemplate.status.* = line.shifts[i].status;
								if(typeDescriptor.isWarehouseIncome || typeDescriptor.isPurchaseDocument)shiftTemplate.quantity.* = line.shifts[i].quantity;
									else shiftTemplate.quantity.* = line.shifts[i].quantity;
								if(line.shifts[i].containerId)shiftTemplate.containerId.* = line.shifts[i].containerId;
								if(line.shifts[i].sourceContainerId)shiftTemplate.sourceContainerId.* = line.shifts[i].sourceContainerId;
								if(line.shifts[i].sourceShiftId)shiftTemplate.sourceShiftId.* = line.shifts[i].sourceShiftId;
								if(line.shifts[i].shiftId)shiftTemplate.id.* = line.shifts[i].shiftId;
								if(line.shifts[i].version)shiftTemplate.version.* = line.shifts[i].version;
								if(line.shifts[i].attributes)shiftTemplate.attributes = line.shifts[i].attributes;
								if(line.shifts[i].warehouseId)shiftTemplate.warehouseId.* = line.shifts[i].warehouseId;
								if(line.shifts[i].shiftTransactionId)shiftTemplate.shiftTransactionId.* = line.shifts[i].shiftTransactionId;
								if(line.shifts[i].ordinalNumber)shiftTemplate.ordinalNumber.* = line.shifts[i].ordinalNumber;
								if(line.shifts[i].incomeWarehouseDocumentLineId != "")shiftTemplate.incomeWarehouseDocumentLineId.* = line.shifts[i].incomeWarehouseDocumentLineId;
								if(line.shifts[i].warehouseDocumentLineId != "")shiftTemplate.warehouseDocumentLineId.* = line.shifts[i].warehouseDocumentLineId;
								shiftTemplate.@lineOrdinalNumber = l;
								ret.shifts.appendChild(shiftTemplate.copy());
								shiftTemplate = <shift lineOrdinalNumber="0">
													<status>40</status>
													<quantity/>
												</shift>;
							}
						}
					}
				}
			}
			if(shiftSelectionEnabled)return ret;
			else return XML("");
		}
		
		public function getOptionsXML():XML
		{
			//zakomentowane bo teraz opcje beda nie beda wycinane tylko bezdie ustawiane selected="0" lub 1
			/*var ret:XML = <options/>;
			for each (var x:XML in documentOptions)
			{
				if (x.@selected.length() == 0 || x.@selected == 1)
				{
					var y:XML = x.copy();
					if (y.@selected.length() > 0) delete y.@selected;
					ret.* += y;
				}
			}
			return ret;*/
			return <options>{documentOptions}</options>
		}

		public function getAttribute(name:String):XML
		{
			var idx:XML = DictionaryManager.getInstance().getByName(name, 'documentFields');
			if (idx == null) return null;
			var id:String = idx.id;
			var l:XMLList = this.attributes.source.(documentFieldId == id);
			if (l.length() == 0) return null;
			else return l[0];
		}
		
		public static function deserializeVatTable(entries:XMLList):ArrayCollection
		{
			if (entries.length() > 0)
			{
				var table:ArrayCollection = new ArrayCollection();
							
				for each (var xmlVtEntry:XML in entries)
					table.addItem(new CommercialDocumentVatTableEntry(xmlVtEntry));
					
				return table;
			}
			else return null;
		}
		
		public static function exportDocument(documentObject:DocumentObject,documentXML:XML = null):void
		{
		
			var relatedDocuments:XML = null;
			if (documentXML) relatedDocuments = XML(documentXML.relatedDocuments); 
			if (!documentXML) documentXML = documentObject.xml;
			//
			var arr:Array=[];
			var autoPr:String=arr[0]=documentObject.typeDescriptor.automaticPrint;
			if(autoPr.length)
				if(autoPr.search(";"))
				{
					arr=autoPr.split(";");
				}
			for(var i:int=0;i<arr.length;i++)
			{
				if(arr[i] == "pdf")
					ComponentExportManager.getInstance().exportDocuments(documentObject.typeDescriptor, documentXML.id.*, 'content', relatedDocuments);
				else if(arr[i] == "fiscal" && documentObject.isNewDocument && documentObject.xml.netCalculationType.* == "0")
					ComponentExportManager.getInstance().exportObjectFiscal(documentXML.id.*, documentObject.typeDescriptor.getDefaultFiscalPrintProfile());
				else if (arr[i] == "textAndFiscal")
				{
					TextPrintPreviewWindow.showWindow(documentXML.id.*, documentObject.typeDescriptor.xmlOptions.@defaultTextPrintProfile.toString());
					
					if(documentObject.isNewDocument && documentObject.isNewDocument && documentObject.xml.netCalculationType.* == "0")
						ComponentExportManager.getInstance().exportObjectFiscal(documentXML.id.*, documentObject.typeDescriptor.getDefaultFiscalPrintProfile());
				}
				else if(arr[i] == "text") {
					if(documentObject.typeDescriptor.categoryNumber == 9) {
						ModelLocator.getInstance().eventManager.dispatchEvent(new Event('refreshPaymentList'));
					}
					TextPrintPreviewWindow.showWindow(documentXML.id.*, documentObject.typeDescriptor.xmlOptions.@defaultTextPrintProfile.toString(), documentXML.relatedDocuments[0],null,documentObject.xml.id.toString());
				}
			}
		}
		
	
		//ODKOMENTUJ TEN FRAGMENT BY WIDZIEC EVENTY DOKUMENTU
		/* public override function dispatchEvent(event:Event):Boolean
		{
			trace(event);
			return super.dispatchEvent(event);
		} */
		
			
		// commented because objects are now strictly typed and they serializes/deserializes by themselves.
		/*protected function deserializeObject(lineXML:XML):Object
		{
			var line:Object = {};
			for each (var node:XML in lineXML.*)
			{
				line[node.name()] = String(node);
			}
			return line;
		}
		
		protected function serializeObject(line:Object, nodeName:String):XML
		{
			var xmlLine:XML = <{nodeName}/>;
			for (var field:String in line)
			{
				if(field != "mx_internal_uid")
					xmlLine[field] = line[field];
			}
			return xmlLine;
		}*/

	}
	
}