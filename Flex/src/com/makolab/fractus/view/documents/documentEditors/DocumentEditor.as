package com.makolab.fractus.view.documents.documentEditors
{
	import com.greensock.layout.AlignMode;
	import com.makolab.components.document.DocumentEvent;
	import com.makolab.components.util.ErrorReport;
	import com.makolab.fractus.commands.ExecuteCustomProcedureCommand;
	import com.makolab.fractus.commands.SaveBusinessObjectCommand;
	import com.makolab.fractus.commands.SearchCommand;
	import com.makolab.fractus.commands.ShowDocumentEditorCommand;
	import com.makolab.fractus.model.ConfigManager;
	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.GlobalEvent;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	import com.makolab.fractus.model.document.BusinessObject;
	import com.makolab.fractus.model.document.DocumentObject;
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	import com.makolab.fractus.view.ComponentWindow;
	import com.makolab.fractus.view.catalogue.BarcodeSearchWindow;
	import com.makolab.fractus.view.documents.AuthorizationWindow;
	import com.makolab.fractus.view.documents.DateValidationWindow;
	import com.makolab.fractus.view.documents.SalesLockWindow;
	import com.makolab.fractus.view.documents.documentControls.AbstractLinesComponent;
	import com.makolab.fractus.vo.ErrorVO;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.TitleWindow;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.CheckBox;
	import mx.controls.Label;
	import mx.controls.Menu;
	import mx.controls.PopUpButton;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.core.EventPriority;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.events.MenuEvent;
	import mx.events.ValidationResultEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.validators.EmailValidator;
	
	import adobe.utils.CustomActions;
	
	[Style(name="editorWidth", type="Number", format="Length", inherit="yes")]
	public class DocumentEditor extends Canvas
	{
		//barreader
		var strA:Array=new Array();;
		var timer:Timer;
		// parameters
		public var printProfileName:String;
		public var customUrl:String;
		public var cardsPayement:Boolean=false;
		private var currBarcode:String="";
		[Bindable]
		private static var title:String;
		
		private var timerDt:int=500;
		private var addMode:int=0;
		public var defaultErrorHandling:Boolean = true;
		
		var  searchParams:XML=
				<searchParams>
					<pageSize>10</pageSize>
					<page>1</page>
					<columns>
						<column field="name"/>
						<column field="code"/>
						<column field="version"/>
					</columns>
					<filters>
						<column field="barcode"/>
					</filters>
				</searchParams>;
		public var selectedItem:Object;
		
		
		//formularz z e-mailem
		private   var _win:TitleWindow;
		private   var _addButton:Button;
		private   var _sendButton:Button;
		private   var _cancelButton:Button;
		private   var _lab:Label;
		private   var _tit:TextArea;
		private   var _email:TextInput;
		private var _send:Boolean=true;
		private var commerceOptions:XMLList;
		private var sendDocId:String;
		private var printNormal:Boolean;
		private   var _ch:CheckBox;
		private var resXML:XML;
		
		
		public function DocumentEditor()
		{
			super();
			addEventListener(KeyboardEvent.KEY_DOWN, standardHandleKeyDown);
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete, false, 0, true);
			
			// To powinno obsluzone w BarcodeManagerze, ktory tu powinien byc tylko uzyty, 
			// ale na razie powielamy kod bo nie ma pozwolenia.
			ModelLocator.getInstance().configManager.requestList(["system.barcode"],configurationLoaded);
		}
		
		private function configurationLoaded():void
		{
			try 
			{
				var barcodesConfig:XML = ModelLocator.getInstance().configManager.getXML("system.barcode");
				configuration = barcodesConfig.configValue.configuration[0];
				if (configuration)
				{
					if (configuration.prefix.length() > 0)
					{
						for each (var keyCode:XML in configuration.prefix.keyCode)
						{
							prefixKeys["key" + keyCode.toString()] = false;
						}
					}
					timerDt=int(configuration.scanTime);
					addMode=int(configuration.addMode);
					timer = new Timer(timerDt,1);
					timer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimerComplete);
					
					removeEventListener(KeyboardEvent.KEY_DOWN,standardHandleKeyDown);
					addEventListener(KeyboardEvent.KEY_DOWN,handleKeyDown);
					addEventListener(KeyboardEvent.KEY_UP,handleKeyUp);
					this.setFocus();
				}
			}
			catch (e:Error)
			{
				//trace(e.message);
			}
			finally
			{
				
			}
		}
		
		private var configuration:XML;
		
		private var _documentObject:DocumentObject;
		
		[Bindable]
		public function set documentObject(value:DocumentObject):void
		{
			_documentObject = value;
			_documentObject.editor = this;
			if (_documentObject != null)
			{
				_documentObject.addEventListener(DocumentEvent.DOCUMENT_COMMIT, documentCommitHandler, false, EventPriority.DEFAULT_HANDLER);
				_documentObject.addEventListener(DocumentEvent.DOCUMENT_SAVE, documentSaveHandler, false, EventPriority.DEFAULT_HANDLER);
			}
			if(value.basedOnDocumentID) {
				checkPayments();
			}
		}
		
		public function get documentObject():DocumentObject
		{
			return _documentObject;
		}
		
		private function checkPayments():void {
			var cmd:ExecuteCustomProcedureCommand = new ExecuteCustomProcedureCommand("document.p_getDocumentPayments", XML('<root><commercialDocumentHeaderId>'+_documentObject.basedOnDocumentID+'</commercialDocumentHeaderId></root>'));
			cmd.addEventListener(ResultEvent.RESULT, handleResult);
			cmd.execute();
		}
		
		private function handleResult(event:ResultEvent):void {			
			var result:XML = XML(event.result);
			if(result.length()&&result.payment&&documentObject.paymentsXML){
				documentObject.paymentsXML.payment[0].paymentMethodId = result.payment[0].paymentMethodId;
				documentObject.paymentsXML.payment[0].paymentCurrencyId = documentObject.xml.documentCurrencyId;
				documentObject.paymentsXML.payment[0].paymentCurrencyId = result.payment[0].paymentCurrencyId;
			}
		}
		
		protected function onCreationComplete(event:FlexEvent):void
		{
			if(_documentObject != null)
				_documentObject.dispatchEvent(new DocumentEvent(DocumentEvent.DOCUMENT_LOAD));
		}
		
		public function showFullXml():void
		{
			var fullXML:XML = documentObject.getFullXML();
			var optionsXML:XML = documentObject.getOptionsXML();
			var shiftsXML:XML = documentObject.getShiftsXML();
			ErrorReport.showWindow("Document XML", String(<root>{fullXML}{optionsXML}{shiftsXML}</root>), "XML");
		}
				
		[Bindable]
		public var dictionaryManager:DictionaryManager = DictionaryManager.getInstance();
		
		public function commitDocument():Boolean
		{
			if(documentObject.commitBlock)
			{
				//Alert.show(documentObject.commitBlock);
				SalesLockWindow.show(this, this.innerCommitFunction1, documentObject.xml.contractor.contractor, documentObject.commitBlock, null);
				return false;
			}
			else
			this.innerCommitFunction1();
		
			return false;
		}
		private function innerCommitFunction1():void
		{
			var docDesc:DocumentTypeDescriptor=new DocumentTypeDescriptor(documentObject.xml.documentTypeId);
			if(ModelLocator.getInstance().permissionManager.getPermissionLevel("administration.permissions.authorization")!=2)
			{
				if(docDesc.getAuthorization()=="true" )
				{
					AuthorizationWindow.show(this, this.innerCommitFunction2);
				}
				else
				this.innerCommitFunction2();	
			}
			else
			this.innerCommitFunction2();
		}
		private function innerCommitFunction2():void
		{
			var docDesc:DocumentTypeDescriptor=new DocumentTypeDescriptor(documentObject.xml.documentTypeId);
			
			if(docDesc.getDateValidation()=="true" )
			{
				var fullXML:XML =   documentObject.getFullXML();
				var options:XMLList=documentObject.documentOptions;
				
				DateValidationWindow.show(this, this.innerCommitFunction,fullXML,
				documentObject.lines,docDesc.getCashId(),docDesc.getTransferId(),
				docDesc.getServiceId(),options);
			}	
			else
			innerCommitFunction()
		}
		private function innerCommitFunction():void
		{
			setButtonsEnabled(false);
			documentObject.dispatchEvent(DocumentEvent.createEvent(DocumentEvent.DOCUMENT_COMMIT, null, null, true));	
		}
		
		public function saveDocument():Boolean
		{
			setButtonsEnabled(false);
			documentObject.dispatchEvent(DocumentEvent.createEvent(DocumentEvent.DOCUMENT_SAVE, null, null, true));
			return false;
		}
		
		protected function documentSaveHandler(event:DocumentEvent):void
		{
			if (event.isDefaultPrevented())
			{
				setButtonsEnabled(true);
				return;
			}
			
			var fullXML:XML = documentObject.getFullXML();
			var optionsXML:XML = documentObject.getOptionsXML();
			
			var draftXml:XML = <root><draft><entry><dataXml><root>{fullXML}{optionsXML}</root></dataXml><applicationUserId>{ModelLocator.getInstance().sessionManager.userId}</applicationUserId></entry></draft></root>;
						
			if(documentObject.draftId)
				draftXml.draft.entry[0].appendChild(<id>{documentObject.draftId}</id>);
				
			if(fullXML.documentTypeId.length() > 0)
				draftXml.draft.entry[0].appendChild(<documentTypeId>{fullXML.documentTypeId.*}</documentTypeId>);
			
			if(fullXML.contractor.contractor.id.length() > 0)
				draftXml.draft.entry[0].appendChild(<contractorId>{fullXML.contractor.contractor.id.*}</contractorId>);
			
			var command:ExecuteCustomProcedureCommand = null;
			
			if(documentObject.draftId)
				command = new ExecuteCustomProcedureCommand("document.p_updateDraft", draftXml);
			else
				command = new ExecuteCustomProcedureCommand("document.p_insertDraft", draftXml);
				
			command.defaultErrorHandling = defaultErrorHandling;
			command.addEventListener(ResultEvent.RESULT, handleSaveDraftResult);
			command.addEventListener(FaultEvent.FAULT, handleSaveDraftFault);
			
			command.execute();
		}
		
		protected function documentCommitHandler(event:DocumentEvent):void
		{
		
			
			if (event.isDefaultPrevented())
			{
				setButtonsEnabled(true);
				return;
			}
			 
			var command:SaveBusinessObjectCommand = new SaveBusinessObjectCommand();
			command.defaultErrorHandling = defaultErrorHandling;
			command.addEventListener(ResultEvent.RESULT, handleSaveResult);
			command.addEventListener(FaultEvent.FAULT, handleSaveFault);
			var fullXML:XML = documentObject.getFullXML();
			var optionsXML:XML = documentObject.getOptionsXML();
			var shiftsXML:XML = documentObject.getShiftsXML();
			command.execute(<root>{fullXML}{optionsXML}{shiftsXML}</root>);
		}
		
		public function setButtonsEnabled(enabled:Boolean):void
		{
			if (window) window.buttonsEnabled = enabled;
		}
		
		protected function handleSaveDraftResult(event:ResultEvent):void
		{
			var docCategories:String = documentObject.typeDescriptor.dictionaryTypeDescriptor.documentCategory; 
			
			ModelLocator.getInstance().eventManager.dispatchEvent(new GlobalEvent(GlobalEvent.DOCUMENT_CHANGED, docCategories));
			
			Alert.show(LanguageManager.getInstance().labels.documents.documentSaved);
			
			var resultXml:XML = XML(event.result);
			
			if(resultXml.id.length() > 0)
				documentObject.draftId = resultXml.id.*;
				 
			this.setButtonsEnabled(true);
		}
		
		protected function handleSaveResult(event:ResultEvent):void
		{
			resXML=XML(event.result);
			commerceOptions=documentObject.typeDescriptor.xmlOptions.commerceOptions;
			printNormal=true;
			sendDocId=XML(event.result).id.toString();
			if(commerceOptions.length())
			{
				if(commerceOptions.printNormal.length()&&commerceOptions.printNormal.toString()=="0")
					printNormal=false;
				if(commerceOptions.sendEmail.length()&&commerceOptions.sendEmail.toString()=="1"&&commerceOptions.sendEmailProcedure.length())
					showWindow();
			
			}
			if(printNormal)
			{
				printDocs();
				
			
			}
			if (window && window.hideAfterCommit) window.hide();
		}
		private function printDocs(){
			var docCategories:String = documentObject.typeDescriptor.dictionaryTypeDescriptor.documentCategory; 
			
			for each(var doc:XML in resXML.relatedDocuments.id){
				docCategories+="," + (new DocumentTypeDescriptor(doc.@documentTypeId)).categoryNumber.toString();	
			}
			
			if (printProfileName)
			{
				DocumentObject.exportDocument(documentObject,resXML);
			}
			
			var docDesc:DocumentTypeDescriptor=new DocumentTypeDescriptor(documentObject.xml.documentTypeId);
			
			if(docDesc.getCustomUrl())
			{
				navigateToURL(new URLRequest(docDesc.getCustomUrl()+resXML.id),'_blank');
			}
			ModelLocator.getInstance().eventManager.dispatchEvent(new GlobalEvent(GlobalEvent.DOCUMENT_CHANGED, docCategories));
			ModelLocator.getInstance().eventManager.dispatchEvent(new GlobalEvent(GlobalEvent.SEND_TO_TERMINAL,docCategories, resXML.id));
		}
		protected function handleSaveDraftFault(event:FaultEvent):void
		{
			Alert.show(LanguageManager.getInstance().labels.alert.errorAppeared+":\n" + XML(event.fault.faultString).*);			
			setButtonsEnabled(true);
		}

		protected function handleSaveFault(event:FaultEvent):void
		{
			var x:XML = new XML(event.fault.faultString);
			var error:ErrorVO = ErrorVO.createFromFault(event.fault);
			
			if(x.question.length() > 0)
				this.processQuestion(x);
			else if (x.@id == "MinimalMarginValidationError" || x.@id == "MaximalDiscountValidationError")
			{
				SalesLockWindow.show(this, this.commitWithMinimalMargin, null, null, x.ordinalNumber.*);				
			}
			else if(!this.defaultErrorHandling)
				ModelLocator.getInstance().errorManager.handleError(error);	
			
			setButtonsEnabled(true);
		}
		
		private function commitWithMinimalMargin():void
		{
			documentObject.xml.skipMinimalMarginValidation.* = "1";
			this.commitDocument();
		}
		
		private function processQuestion(xml:XML):void
		{
			Alert.yesLabel = LanguageManager.getLabel("alert.yes");
			Alert.noLabel = LanguageManager.getLabel("alert.no");
			
			var buttons:uint = 0;
			var defaultBtn:uint = 0;
			
			for each(var btn:XML in xml.question.buttons.button)
			{
				if(btn.* == "yes")
				{
					buttons = buttons | Alert.YES;
					
					if(btn.@isDefault == "1") defaultBtn = Alert.YES;
				}
				else if(btn.* == "no")
				{
					buttons = buttons | Alert.NO;
					
					if(btn.@isDefault == "1") defaultBtn = Alert.NO;
				}
				else if(btn.* == "cancel")
				{
					buttons = buttons | Alert.CANCEL;
					
					if(btn.@isDefault == "1") defaultBtn = Alert.CANCEL;
				}
				else if(btn.* == "ok")
				{
					buttons = buttons | Alert.OK;
					
					if(btn.@isDefault == "1") defaultBtn = Alert.OK;
				}
			}
			
			var alert:Alert = Alert.show(String(xml.customMessage).replace(/\\n/g, "\n"), "", buttons, null, questionCloseHandler, null, defaultBtn);
			alert.data = xml; 
		}
		
		private function questionCloseHandler(event:CloseEvent):void
		{
			var btnName:String;
			var dataXml:XML = XML(event.target.data);
			
			if(event.detail == Alert.YES) btnName = "yes";
			else if(event.detail == Alert.NO) btnName = "no";
			else if(event.detail == Alert.OK) btnName = "ok";
			else if(event.detail == Alert.CANCEL) btnName = "cancel";
			
			var btnXml:XML = dataXml.question.buttons.button.(valueOf().* == btnName)[0];
			
			if(btnXml.@abort != "1")
			{
				var actionField:String = dataXml.question.actionField;
				this.documentObject.xml[actionField] = String(btnXml.@value);
				this.commitDocument();
			}
		}
		
		protected function getDocumentType(data:Object):Object
		{
			return dictionaryManager.getById(data.documentTypeId);
		}
		
		private var _window:ComponentWindow;
		protected function set window(value:ComponentWindow):void
		{
			_window = value;
				
			// sprawdzamy, czy typ naszego dokumentu moĹĽemy zamienic na inny.
			if (documentObject.isNewDocument && documentObject.typeDescriptor.documentTemplateChangePossibilities.length > 0)
			{
				var array:Array = [];
				for (var i:int = 0; i < documentObject.typeDescriptor.documentTemplateChangePossibilities.length; i++)
				{
					var configKey:String = "templates."+this.documentObject.typeDescriptor.documentCategory + "." + documentObject.typeDescriptor.documentTemplateChangePossibilities[i];
					array.push(configKey);
				}
				ModelLocator.getInstance().configManager.requestList(array,createTypeChangeButton);
			}
		}
		protected function get window():ComponentWindow
		{
			return _window;
		}
		
		private function createTypeChangeButton():void
		{
			var selectedItem:Object;
			var typeChangeButton:PopUpButton = new PopUpButton();
			var menuData:Array = [];
			for (var i:int = 0; i < documentObject.typeDescriptor.documentTemplateChangePossibilities.length; i++)
			{
				var configKey:String = "templates."+this.documentObject.typeDescriptor.documentCategory + "." + documentObject.typeDescriptor.documentTemplateChangePossibilities[i];
				try
				{
					var template:XML = ModelLocator.getInstance().configManager.getXML(configKey);
					if (template.configValue.root.*.documentTypeId[0].toString() != documentObject.typeDescriptor.typeId)
						menuData.push({label : template.configValue.root.labels.label.(@lang.toString() == LanguageManager.getInstance().currentLanguage),template : documentObject.typeDescriptor.documentTemplateChangePossibilities[i],category : this.documentObject.typeDescriptor.documentCategory});
				}
				catch(e:Error)
				{
					ConfigManager.reportConfigurationError("W sĹ‚owniku typĂłw dokumentĂłw w dla typu " + documentObject.typeDescriptor.label + " w wÄ™Ĺşle documentTemplateChange zdefiniowano odniesienie do szablonu '" + documentObject.typeDescriptor.documentTemplateChangePossibilities[i] + "', ktĂłry nie istnieje w konfiguracji templates." + documentObject.typeDescriptor.documentCategory,"BĹ‚Ä…d konfiguracji");
				}
			}
			typeChangeButton.id = "documentTypeChangeButton";
			typeChangeButton.toolTip = LanguageManager.getInstance().labels.documents.changeDocumentType;
			var menu:Menu = new Menu();
			menu.dataProvider = menuData;
			typeChangeButton.popUp = menu;
			menu.addEventListener(ListEvent.ITEM_CLICK, itemClickHandler);
			menu.selectedIndex = 0;
			selectedItem = menuData[0];
			typeChangeButton.label = menuData[0].label;
			typeChangeButton.addEventListener(MouseEvent.CLICK, clickHandler);
			var existingButton:DisplayObject;
			if (_window.windowControlBar) 
			{
				existingButton = _window.windowControlBar.getChildByName("documentTypeChangeButton");
				if (existingButton) _window.windowControlBar.removeChild(existingButton);
				_window.windowControlBar.addChild(typeChangeButton);
			}
			function clickHandler(event:MouseEvent):void {
				changeDocumentType(selectedItem);
			}
			
			function itemClickHandler(event:MenuEvent):void
			{
				typeChangeButton.label = event.item.label;
				selectedItem = event.item;
				changeDocumentType(event.item);
			}
		}
		
		private function changeDocumentType(value:Object):void
		{
			var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(DocumentTypeDescriptor[value.category]);
			cmd.template = value.template;
			cmd.addEventListener(ResultEvent.RESULT,resultHandler);
			cmd.execute();
			
			function resultHandler(event:ResultEvent):void
			{
				try
				{
					var newDocumentObject:DocumentObject = event.result as DocumentObject;
					newDocumentObject.lines = documentObject.lines;
					/* 
					if (documentObject.xml.documentCurrencyId) newDocumentObject.xml.documentCurrencyId = documentObject.xml.documentCurrencyId;
					if (documentObject.xml.exchangeRate) newDocumentObject.xml.exchangeRate = documentObject.xml.exchangeRate;
					if (documentObject.xml.exchangeScale) newDocumentObject.xml.exchangeScale = documentObject.xml.exchangeScale;
					if (documentObject.xml.exchangeDate) newDocumentObject.xml.exchangeDate = documentObject.xml.exchangeDate;
					 */
					
					if (documentObject.xml.contractor.length() > 0 
						&& newDocumentObject.xml.@disableContractorChange.length() == 0 
						&& newDocumentObject.typeDescriptor.xmlOptions.@contractorOptionality != 'forbidden'
						) 
						newDocumentObject.xml.contractor = documentObject.xml.contractor;
					
					newDocumentObject.dispatchEvent(DocumentEvent.createEvent(DocumentEvent.DOCUMENT_RECALCULATE, "initialNetPrice"));
					if(window.parent) window.parent.removeChild(window);
				}catch(e:Error)
				{
					
				}
			}
		}
		
		public static function showWindow(documentObject:DocumentObject, editorClass:Class):void
		{
			var number:String;
			var type:String;
			var editor:DocumentEditor = new editorClass() as DocumentEditor;
			number = String(documentObject.xml.number.fullNumber);
			type = documentObject.typeDescriptor.symbol;
			editor.documentObject = documentObject;
			switch(editorClass)	{
				case AdvancedSalesDocumentEditor: title = LanguageManager.getInstance().labels.title.documents.panel.advanced; break;
				case SimpleSalesDocumentEditor: title = LanguageManager.getInstance().labels.title.documents.panel.simple; break;
				case WarehouseDocumentEditor: title = LanguageManager.getInstance().labels.title.documents.panel.warehouse; break;
				case OrderDocumentEditor : 
					if(documentObject.typeDescriptor.isWarehouseOrder)title = LanguageManager.getInstance().labels.title.documents.panel.warehouseOrder;
					if(documentObject.typeDescriptor.isWarehouseReservation)title = LanguageManager.getInstance().labels.title.documents.panel.warehouseReservation;
					break;
				case PurchaseDocumentEditor : title = LanguageManager.getInstance().labels.title.documents.panel.purchase; break;
				case FinancialDocumentEditor : title = LanguageManager.getInstance().labels.title.documents.panel.finance; break;
				case ProtocolComplaintDocumentEditor : title = LanguageManager.getInstance().labels.title.documents.panel.protocolComplaun; break;
				case ServiceDocumentEditor : title = LanguageManager.getInstance().labels.title.documents.panel.serviceDocument; break;
				case SalesOrderDocumentEditor : title = LanguageManager.getInstance().labels.title.documents.panel.serviceOrderDocument; break;
				case QuickSalesDocumentEditor : title = LanguageManager.getInstance().labels.title.documents.panel.quick; break;
				default:title = ""; break;
			}
			title += (title ? " - " : "") + type + " " + number;
			var buttons:int = ComponentWindow.BUTTON_COMMIT | ComponentWindow.BUTTON_CANCEL;
			
			if(documentObject.xml.@source.length() == 0 && documentObject.xml.version.length() == 0 &&
				(documentObject.typeDescriptor.categoryNumber == DocumentTypeDescriptor.CATEGORY_SALES ||
				documentObject.typeDescriptor.categoryNumber == DocumentTypeDescriptor.CATEGORY_PURCHASE ||
				documentObject.typeDescriptor.categoryNumber == DocumentTypeDescriptor.CATEGORY_WAREHOUSE ||
				documentObject.typeDescriptor.categoryNumber == DocumentTypeDescriptor.CATEGORY_WAREHOUSE_ORDER ||
				documentObject.typeDescriptor.categoryNumber == DocumentTypeDescriptor.CATEGORY_WAREHOUSE_RESERVATION ||
				documentObject.typeDescriptor.categoryNumber == DocumentTypeDescriptor.CATEGORY_SALES_ORDER_DOCUMENT))
				buttons = buttons | ComponentWindow.BUTTON_SAVE;
						
			editor.window = ComponentWindow.showWindow(editor, buttons,editorClass == QuickSalesDocumentEditor ? ComponentWindow.FULLSCREEN : null,title);
			editor.window.setStyle("headerColors",[documentObject.typeDescriptor.documentThemeColor,documentObject.typeDescriptor.documentThemeColorLight]);
			editor.window.setStyle("themeColor",documentObject.typeDescriptor.documentThemeColor);
			editor.window.showXmlFunction = editor.showFullXml;
			editor.window.commitFunction = editor.commitDocument;
			editor.window.saveFunction = editor.saveDocument;			 
		}
		
		protected function standardHandleKeyDown(event:KeyboardEvent):void
		{
			// ctrl+B
			if (event.ctrlKey && !event.altKey && event.keyCode == 66 && !documentObject.typeDescriptor.isFinancialDocument)
			{
				//if (this['lines']) AbstractLinesComponent(this['lines']).goToNewItem();
				event.preventDefault();
				event.stopImmediatePropagation();
				BarcodeSearchWindow.show(true).addEventListener(BarcodeSearchWindow.ITEM_SELECTED, handleBarcodeSelect);
			}
		}
		
		protected function handleKeyDown(event:KeyboardEvent):void
		{
			
			var keyCode:String = "key" + event.keyCode;
		
			if (prefixKeys.hasOwnProperty(keyCode))
			{
				prefixKeys[keyCode] = true;
			}
		}
		
		protected function handleKeyUp(event:KeyboardEvent):void
		{
			if (configuration && configuration.prefix.length() > 0)
			{
				var keyCode:String = "key" + event.keyCode;
				
				if (configuration.prefix.valueOf().@ctrlKey == "1")
				{
					if (!event.ctrlKey) return;
				}else{
					if (event.ctrlKey) return;
				}
				
				if (configuration.prefix.valueOf().@altKey == "1")
				{
					if (!event.altKey) return;
				}else{
					if (event.altKey) return;
				}
				
				if (configuration.prefix.valueOf().@shiftKey == "1")
				{
					if (!event.shiftKey) return;
				}else{
					if (event.shiftKey) return;
				}
				
				var prefixSequence:Boolean = true;
				for each (var code:Object in prefixKeys) 
					prefixSequence = prefixSequence && code;
				
				
				if (prefixSequence)
				{
					if(!timer.running)
					{
						timer.start();
					}
					else
						if(event.charCode!=66&&event.charCode!=17&&event.charCode!=98)
						{
							trace("keyUp:",event.charCode);
							strA.push(String.fromCharCode(event.charCode));
						}
			
					//if (prefixKeys.hasOwnProperty(keyCode)) prefixKeys[keyCode] = false;
					//event.preventDefault();
					//event.stopImmediatePropagation();
					//BarcodeSearchWindow.show(true).addEventListener(BarcodeSearchWindow.ITEM_SELECTED, handleBarcodeSelect);
				}
				
			}
		}
		private var prefixKeys:Object = {};
		
		protected function handleBarcodeSelect(event:Event):void
		{
			var window:BarcodeSearchWindow = event.target as BarcodeSearchWindow;
			var lines:AbstractLinesComponent = this['lines'] as AbstractLinesComponent;
			if (lines && lines.enabled && lines.lineAddEnabled)
			{
				var line:BusinessObject = lines.getEmptyLine();
				lines.setLineItem(window.selectedItem, line);
				lines.documentLines.editLine(line, 'quantity');
			}
		}
		protected function handleBarcodeSelectAuto():void
		{
			var lines:AbstractLinesComponent = this['lines'] as AbstractLinesComponent;
			if (lines && lines.enabled && lines.lineAddEnabled)
			{
				var line:BusinessObject = lines.getEmptyLine();
				lines.setLineItem(selectedItem, line);
				if(!line.getAttributeByFieldId("barcode"))
					line.addAttribute("barcode");
				line.getAttributeByFieldId("barcode").value=currBarcode;
				//lines.documentLines.editLine(line, 'quantity');
				lines.getEmptyLine();
				//lines.documentLines.editLine(line, 'itemName');
			}
		}
		protected function handleBarcodeSelectAutoAddTheSame():void
		{
			var lines:AbstractLinesComponent = this['lines'] as AbstractLinesComponent;
			if (lines && lines.enabled && lines.lineAddEnabled)
			{
				var line:BusinessObject = lines.getEmptyLine();
				
			
				lines.setLineItemOrChangeQuantity(selectedItem, line);
				if(!line.getAttributeByFieldId("barcode"))
					line.addAttribute("barcode");
				line.getAttributeByFieldId("barcode").value=currBarcode;
				//lines.documentLines.editLine(line, 'quantity');
				
				lines.getEmptyLine();
				//lines.documentLines.editLine(line, 'itemName');
			}
		}
		private function onTimerComplete(e:TimerEvent):void
		{
			timer.stop();
			timer.reset();
			var str:String="";
			
			while(strA.length)
				str+=strA.shift();
			if(str.length>3)
			{
				search(str);
			}
		}
		private function search(id:String):void
		{
			var cmd:SearchCommand = new SearchCommand(SearchCommand.ITEMS);
			var params:XML = searchParams.copy();
			params.filters.column.(@field == 'barcode').* = id;
			currBarcode=id;
			cmd.searchParams = params;
			cmd.addEventListener(ResultEvent.RESULT, handleSearchResult);
			cmd.execute();
		}
		
		private function handleSearchResult(event:ResultEvent):void
		{
			var results:XMLList = XML(event.result).*;
			
			var msg:String;
			var color:uint;
			var lm:LanguageManager = LanguageManager.getInstance();
			if (results.length() == 0)
			{
				msg = lm.getLabel("items.notFound");
				color = 0xff0000;
				selectedItem = null;
			}
			else 
			{
				
				selectedItem = results[0];
				if(selectedItem.attributes.length()==0)
					selectedItem.attributes=new XMLList();
				
				msg = selectedItem.@code + ": " + selectedItem.@name;
				color = 0x666666;
				
				if(addMode==1)
				{
					handleBarcodeSelectAutoAddTheSame();
				}else
					handleBarcodeSelectAuto();
				
			}
		}
		
		
		
		
		public  function showWindow():void
		{
			
			if (!_win)
			{
				_win = new TitleWindow();
				_win.width = 400;
				_win.height =300;
				var vBox:VBox = new VBox();
				var hBox1:HBox = new HBox();
				vBox.percentHeight = 100;
				vBox.percentWidth = 100;
				hBox1.percentWidth = 100;
				_win.addChild(vBox);
				
				_lab=new Label();
				_tit=new TextArea();
				_ch=new CheckBox();
				_ch.selected=true;
				_ch.label=LanguageManager.getInstance().labels.common.print;
				_tit.percentWidth=100;
				_tit.height=100;
				_tit.editable=false;
				_tit.setStyle("borderStyle","none");
				_tit.setStyle("textAlign","center");
				_tit.setStyle("fontSize",16);
				_tit.setStyle("paddingLeft",10);
				_tit.setStyle("paddingRight",10);
				_tit.setStyle("paddingTop",10);
				_tit.setStyle("paddingBottom",10);
				
				_lab.setStyle("fontSize",12);
				
				_email=new TextInput();
				_email.width=300;
				_lab.width=200;
				
				vBox.addChild(_tit);
				vBox.addChild(_lab);
				//hBox1.addChild(_lab);
				hBox1.addChild(_email);
				
				vBox.addChild(hBox1);
				if(!printNormal)
					vBox.addChild(_ch);
				
				var hBox:HBox = new HBox();
				hBox.percentWidth=100;
				hBox.setStyle("horizontalAlign", AlignMode.CENTER);
				hBox.setStyle("paddingTop", 30);
				
				_sendButton = new Button();
				_sendButton.label = LanguageManager.getInstance().labels.common.send;
				_sendButton.width = 100;
				_sendButton.addEventListener(MouseEvent.CLICK, buttonClickHandler);
				hBox.addChild(_sendButton);
				
				_addButton = new Button();
				_addButton.label = LanguageManager.getInstance().labels.common.add;
				_addButton.width = 100;
				_addButton.addEventListener(MouseEvent.CLICK, buttonClickHandler);
				hBox.addChild(_addButton);
				
				_cancelButton = new Button();
				_cancelButton.label = LanguageManager.getInstance().labels.common.cancel;
				_cancelButton.width = 100;
				_cancelButton.addEventListener(MouseEvent.CLICK, buttonClickHandler);
				hBox.addChild(_cancelButton);
				vBox.addChild(hBox);
				
				_lab.text=LanguageManager.getInstance().labels.common.email+":";
				_tit.text=commerceOptions.question.label.(@lang==LanguageManager.getInstance().currentLanguage)[0].toString();
				
				var emailId:String=dictionaryManager.dictionaries.contractorFields.(name==commerceOptions.attributeEmail.toString()).id;
				if(documentObject.xml.contractor.contractor.attributes.attribute.length())
				{
					for(var i:int=0;i<documentObject.xml.contractor.contractor.attributes.attribute.length();i++)
						if(documentObject.xml.contractor.contractor.attributes.attribute[i].contractorFieldId.toString()==emailId)
						{
							_email.text=documentObject.xml.contractor.contractor.attributes.attribute[i].value.toString();
							break;
						}
				}
			}
			//356AFECD-99E6-4D0B-9F27-D802AE116C1C
			PopUpManager.addPopUp(_win, this, true);
			PopUpManager.centerPopUp(_win);
		}
		protected function buttonClickHandler(event:MouseEvent):void
		{	
			if (event.target == _sendButton)
			{
				var ev:EmailValidator=new EmailValidator();
				ev.addEventListener(ValidationResultEvent.INVALID,onInvalid);
				ev.addEventListener(ValidationResultEvent.VALID,onValid);
				_send=true;
				ev.validate(_email.text);
				
			
			}
			else 
			if (event.target == _addButton)
			{
				_send=false;
				var ev:EmailValidator=new EmailValidator();
				ev.addEventListener(ValidationResultEvent.INVALID,onInvalid);
				ev.addEventListener(ValidationResultEvent.VALID,onValid);
								
				ev.validate(_email.text);
				
			}
			else if (event.target == _cancelButton)
			{
				_send=false;
				hideWindow();
			}
			
			
		}
		private function onInvalid(e:ValidationResultEvent):void
		{
			trace("e");
			_email.errorString=e.message;
			_email.setStyle("borderColor",0xFF0000);
		}
		private function onValid(e:ValidationResultEvent):void
		{
			var cmd:ExecuteCustomProcedureCommand = new ExecuteCustomProcedureCommand(
				commerceOptions.sendEmailProcedure.toString(),
				XML('<root><id>'+sendDocId+'</id><email>'+_email.text+'</email><sendDoc>'+_send.toString()+'</sendDoc>'+'</root>'));
			cmd.addEventListener(ResultEvent.RESULT, handleResultSE);
			cmd.execute();
			hideWindow();
		}
		private function handleResultSE(event:ResultEvent):void {			
			var result:XML = XML(event.result);
		}
		protected function hideWindow():void
		{
			if(!printNormal&&_ch.selected)
			{
				printDocs();
			}
			if (_win) PopUpManager.removePopUp(_win);
		}
	}
}