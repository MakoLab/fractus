package com.makolab.aspDictionary
{
	import com.makolab.components.inputComponents.DataObjectManager;
	import com.makolab.components.lineList.LineMenu;
	import com.makolab.components.lineList.LineOperation;
	
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.core.IFactory;
	import mx.events.CloseEvent;
	
	public class LineMenuRenderer extends LineMenu implements IFactory
	{
		public var nodeName:String = null;
		
		//zewnętrzne funkcje z dnaymi
		public var operationFunction:Function = null;
		
		private var dataObject:Object;
		private var selectedItemName:String =null;
		  
		public function LineMenuRenderer(){
			super();
			this.setStyle("color","0x000000");
		}
		
		
		public override function set data(value:Object):void
		{
			super.data = value;
			dataObject = DataObjectManager.getDataObject(data, listData)
			var options:XMLList = XML(dataObject).children();
			var arr:Array = new Array();
			for (var i:int=0; i<options.length();i++)
			{
				var lo:LineOperation = new LineOperation();
				lo.label = options[i].@label.toString();
				lo.name = options[i].@name.toString();
				lo.addEventListener("operationInvoke",operationItem);
				lo.width=100;	
				switch(options[i].@icon.toString()){
				/*
				case "deleteIcon":
					lo.setStyle("icon",deleteIcon);
					break;
				case "copyIcon":
					lo.setStyle("icon",copyIcon);
					break;
				case "editIcon":
					lo.setStyle("icon",editIcon);
					break;
				case "saveIcon":
					lo.setStyle("icon",saveIcon);
					break;
				case "exportIcon":
					lo.setStyle("icon",exportIcon);
					break;
				default:
					break;
				*/
				case "deleteIcon":
					lo.setStyle("icon",IconManager.getIcon('delete_small'));
					break;
				case "copyIcon":
					lo.setStyle("icon",IconManager.getIcon('duplicate_small'));
					break;
				case "editIcon":
					lo.setStyle("icon",IconManager.getIcon('edit_small'));
					break;
				case "saveIcon":
					lo.setStyle("icon",IconManager.getIcon('save_small'));
					break;
				case "exportIcon":
					lo.setStyle("icon",IconManager.getIcon('export_small'));
					break;
				default:
					break;		
				}
				arr.push(lo);
			}
			this.operations = arr;
		}
		public function operationItem(event:Event):void
		{
		 	this.selectedItemName = event.currentTarget.name; //nazwa objektu
			var label:String =   event.currentTarget.label;
			if(operationFunction  is Function && this.selectedItemName is String )
			{		
				//Alert.yesLabel = "Tak";
            	//Alert.noLabel = "Nie";
            	var conf:String = this.dataObject.*.(@name.toString()== this.selectedItemName ).@confirm.toString();
            	if (conf != "")
	            	Alert.show(conf, label, 1|2, this, confirmClickHandler);
				else
					operationFunction(this.dataObject, this.selectedItemName);
			}
		}
		private function confirmClickHandler(event:CloseEvent):void 
		{
            if (event.detail==Alert.YES)
                operationFunction(this.dataObject, this.selectedItemName);
        }
        
		public function newInstance():*
		{
			var newInst:LineMenuRenderer = new LineMenuRenderer();
			newInst.operationFunction = this.operationFunction;
			return newInst;
		}//newInstance

	}
}