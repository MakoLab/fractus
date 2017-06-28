package com.makolab.fractus.model
{
	import com.makolab.components.barcode.BarcodeEvent;
	import com.makolab.fractus.commands.FractusCommand;
	import com.makolab.fractus.commands.GetItemsDetailsForDocumentCommand;
	import com.makolab.fractus.view.catalogue.BarcodeInputWindow;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	

	[Event("barcodeRead","com.makolab.components.barcode")]
	[Event("result","flash.events.Event")]
	
	public class BarcodeManager extends EventDispatcher
	{
		public function BarcodeManager()
		{
			timer.addEventListener(TimerEvent.TIMER_COMPLETE,handleTimerComplete);
			if (ModelLocator.getInstance().sessionManager.currentState == SessionManager.LOGGED_IN)
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
					if (component)
					{ 
						component.removeEventListener(KeyboardEvent.KEY_DOWN,standardHandleKeyDown);
						component.addEventListener(KeyboardEvent.KEY_DOWN,handleKeyDown);
						component.addEventListener(KeyboardEvent.KEY_UP,handleKeyUp);
					}
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
	
		public static function getInstance():BarcodeManager
		{
			if (instance == null) instance = new BarcodeManager();
			return instance;
		}
		
		private static var instance:BarcodeManager;
		private var timer:Timer = new Timer(100,1);
		private var charSequence:String = "";
		private var buffer:Array = [];
		public var elementsList:ArrayCollection = new ArrayCollection();
		private var commandQueue:ArrayCollection = new ArrayCollection();
		private var executingCommand:FractusCommand;
		private var configuration:XML;
		private var prefixKeys:Object = {};
		
		public var componentInitializedBy:String = "";
		
		private var _callbackFunction:Function;
		public function set callbackFunction(value:Function):void
		{
			_callbackFunction = value;
			timer.stop();
		}
		public function get callbackFunction():Function
		{
			return _callbackFunction;
		}
		
		private var _component:DisplayObject;
		public function set component(value:DisplayObject):void
		{
			if (_component && _component.hasEventListener(KeyboardEvent.KEY_DOWN)) _component.removeEventListener(KeyboardEvent.KEY_DOWN,handleKeyDown);
			if (_component && _component.hasEventListener(KeyboardEvent.KEY_UP)) _component.removeEventListener(KeyboardEvent.KEY_UP,handleKeyUp);
			_component = value;
			if (_component)
			{
				if (!configuration)
				{
					_component.addEventListener(KeyboardEvent.KEY_DOWN,standardHandleKeyDown);
				}else{
					_component.addEventListener(KeyboardEvent.KEY_DOWN,handleKeyDown);
					_component.addEventListener(KeyboardEvent.KEY_UP,handleKeyUp);
				}
			}
		}
		public function get component():DisplayObject
		{
			return _component;
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
			if ( configuration && configuration.prefix.length() > 0 )
			{
				var keyCode:String = "key" + event.keyCode;
				
				var prefixSequence:Boolean = true;
				
				if (configuration.prefix.valueOf().@ctrlKey == "1")
				{
					if (!event.ctrlKey) prefixSequence = false;
				}else{
					if (event.ctrlKey) prefixSequence = false;
				}
				
				if (configuration.prefix.valueOf().@altKey == "1")
				{
					if (!event.altKey) prefixSequence = false;
				}else{
					if (event.altKey) prefixSequence = false;
				}
				
				if (configuration.prefix.valueOf().@shiftKey == "1")
				{
					if (!event.shiftKey) prefixSequence = false;
				}else{
					if (event.shiftKey) prefixSequence = false;
				}
				
				for each (var code:Object in prefixKeys) prefixSequence = prefixSequence && code;
				
				if (prefixSequence)
				{
					if (prefixKeys.hasOwnProperty(keyCode)) prefixKeys[keyCode] = false;
					//event.preventDefault();
					//event.stopImmediatePropagation();
					dispatchEvent(new BarcodeEvent(BarcodeEvent.BARCODE_READ_START));
					timer.start();
				}
				else if (event.keyCode == 13)
				{
					if (timer.running){
						buffer.push(charSequence);
						dispatchEvent(new BarcodeEvent(BarcodeEvent.BARCODE_READ,charSequence));
						charSequence = "";
					}
				}
				else
				{
					if (timer.running)
					{
						//event.preventDefault();
						//event.stopImmediatePropagation();
						timer.reset();
						timer.start();
						if (event.charCode != 0) charSequence += String.fromCharCode(event.charCode);
					}
				}
			}
			
		}
		
		private function standardHandleKeyDown(event:KeyboardEvent):void
		{
			// ctrl+B
			if (event.ctrlKey && !event.altKey && event.keyCode == 66)
			{
				//event.preventDefault();
				//event.stopImmediatePropagation();
				dispatchEvent(new BarcodeEvent(BarcodeEvent.BARCODE_READ_START));
				timer.start();
			}
			else if (event.keyCode == 13)
			{
				if (timer.running){
					buffer.push(charSequence);
					dispatchEvent(new BarcodeEvent(BarcodeEvent.BARCODE_READ,charSequence));
					charSequence = "";
				}
			}
			else
			{
				if (timer.running)
				{
					//event.preventDefault();
					//event.stopImmediatePropagation();
					timer.reset();
					timer.start();
					if (event.charCode != 0) charSequence += String.fromCharCode(event.charCode);
				}
			}
		}
		
		private function handleTimerComplete(event:TimerEvent):void
		{
			charSequence = "";
			timer.reset();
			if (callbackFunction != null) callbackFunction();
			//getItems();
		}
		
		public function getItems(codes:Array = null):void
		{
			if (codes != null)
			{
				for (var c:int = 0; c < codes.length; c++)
					buffer.push(codes[c]);
			}
			if (buffer.length > 0)
			{
					var xml:XML = <root/>;
					for (var i:int = 0; i < buffer.length; i++)
					{
						xml.appendChild(<barcode>{buffer[i]}</barcode>);
					}
				
					// TODO Dolozyc liste kodow, dla ktorych nie znaleziono elementow.
					
					var itemDetailsCommand:GetItemsDetailsForDocumentCommand = new GetItemsDetailsForDocumentCommand();
					itemDetailsCommand.addEventListener(ResultEvent.RESULT,handleCommandResult);
					itemDetailsCommand.itemsBarcodes = [];
					for (var b:int = 0; b < buffer.length; b++)
						itemDetailsCommand.itemsBarcodes.push(buffer[b]); 
					commandQueue.addItem(itemDetailsCommand);
					executeCommand(); 
				
					/* var command:GetItemsByBarcodesCommand = new GetItemsByBarcodesCommand("item.p_getItemsByBarcode",xml);
					command.addEventListener(ResultEvent.RESULT,handleCommandResult);
					commandQueue.addItem(command);
					executeCommand();  */
					buffer = [];
			}
		}
		
		private function executeCommand():void
		{
			if (!executingCommand && commandQueue.length > 0)
			{
				executingCommand = commandQueue.removeItemAt(0) as FractusCommand;
				executingCommand.execute();
				//trace("-----START------");
			}
			if ( executingCommand && commandQueue.length == 0 ) executingCommand = null;
		}
		
		private function handleCommandResult(event:ResultEvent):void
		{
			executeCommand();
			//trace("-----STOP-----");
			var result:XML = XML(event.result);
			var item:XML;
			
			for each ( item in result.item )
			{
				elementsList.addItem(item);
			}
			var command:GetItemsDetailsForDocumentCommand = event.target as GetItemsDetailsForDocumentCommand;
			var itemFound:Boolean;
			for (var i:int = 0; i < command.itemsBarcodes.length; i++)
			{
				itemFound = false;
				for each ( item in result.item )
					for each ( var barcode:XML in item.barcodes.barcode)
						if (command.itemsBarcodes[i] == barcode.toString())
							itemFound = true;
				if (!itemFound)
					dispatchEvent(new BarcodeEvent(BarcodeEvent.ITEM_NOT_FOUND,command.itemsBarcodes[i]));
			}
			this.dispatchEvent(new Event("result"));
		}
		
			
		public function enterBarcodeManually():void
		{
			var barcodeInputWindow:BarcodeInputWindow = BarcodeInputWindow.show();
			barcodeInputWindow.addEventListener("barcodeSet",handleEnterBarcodeManually);
		}
		
		private function handleEnterBarcodeManually(event:Event):void
		{
			if ((event.target as BarcodeInputWindow).barcode)
			{
				buffer.push((event.target as BarcodeInputWindow).barcode);
				if (callbackFunction != null) getItems();
			}
		}
		
		public function popElement(index:int = -1):Object // TODO to można by pozniej stypizowac bardziej konkretnie.
		{
			var element:Object;
			if (index > -1 && elementsList.length > index) element = elementsList.removeItemAt(index);
			else if (index < 0 && elementsList.length > 0) element = elementsList.removeItemAt(elementsList.length - 1);
			return element;
		}
		
		public function appendBarcodesFromFile(barcodes:Array):void
		{
			for each (var arr:Array in barcodes)
			{
				if(arr[0].toString().length != 0)
				{
					if(arr[1] != null)
					{
						for (var i:int = 0; i < int(arr[1]); i++)
						{
							buffer.push(arr[0]);
						}
					}
					else
					{
						buffer.push(arr[0]);
					}
				}
			}
			if (callbackFunction != null) getItems();
		}
	}
}