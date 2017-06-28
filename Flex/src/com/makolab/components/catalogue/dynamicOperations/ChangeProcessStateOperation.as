package com.makolab.components.catalogue.dynamicOperations
{
	import com.makolab.fractus.commands.ChangeProcessStateCommand;
	import com.makolab.fractus.commands.ShowDocumentEditorCommand;
	import com.makolab.fractus.model.GlobalEvent;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.model.ModelLocator;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	import mx.controls.ComboBox;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	public class ChangeProcessStateOperation extends DynamicOperation
	{
		private var options:XMLList;
		
		public override function loadParameters(operation:XML):void
		{
			var replacedOperation:XML = this.replaceDynamicParameters(operation);

			if (replacedOperation.option.length() > 0) this.options = replacedOperation.option;
			else this.options = null;
		}
		
		private var combo:ComboBox;
		private var window:TitleWindow;
		
		public override function invokeOperation(operationIndex:int = -1):void
		{
			var lm:LanguageManager = LanguageManager.getInstance();
			window = new TitleWindow();
			window.title = this.label;
			window.showCloseButton = true;
			window.setStyle('horizontalAlign', 'center');
			window.setStyle('verticalGap', 6);
			window.addEventListener(CloseEvent.CLOSE, handleClose);

			combo = new ComboBox();
			combo.dataProvider = this.options;
			combo.labelFunction = this.comboLabelFunction;
			// okreslenie domyslnej opcji
			for each (var x:XML in this.options)
			{
				var isDefault:Boolean = false;
				if (x.@default == 1) isDefault = true;
				else if (x.@defaultWithContractor == 1)
				{
					if (this.panel.itemData.*.contractor.contractor.id.length() > 0) isDefault = true;
				}
				else if (x.@defaultWithNoContractor == 1)
				{
					if (this.panel.itemData.*.contractor.contractor.id.length() == 0) isDefault = true;
				}
				if (isDefault) combo.selectedItem = x;
			}

			window.addChild(combo);
			var bt:Button = new Button();
			bt.label = lm.getLabel("common.ok");
			bt.addEventListener(MouseEvent.CLICK, handleButtonClick);
			window.addChild(bt);

			PopUpManager.addPopUp(window, Application.application as DisplayObject, true);
			PopUpManager.centerPopUp(window);
			window.visible = true;
			// domyslna operacja
	
		}
		
		private function comboLabelFunction(item:Object):String
		{
			return LanguageManager.getLabel(item.@labelKey);
		}
		
		private function handleButtonClick(event:MouseEvent):void
		{
			executeOption(combo.selectedItem);
			closeWindow();
		}
		
		private function handleClose(event:CloseEvent):void
		{
			closeWindow();
		}
		
		private function closeWindow():void
		{
			window.visible = false;
			if (window) PopUpManager.removePopUp(window);
			window = null;
		}
		
		private function executeOption(option:Object):void
		{
			if (option.@type == 'createDocument')
			{
				var cmd:ShowDocumentEditorCommand = new ShowDocumentEditorCommand(0);
				cmd.objectType = String(option.type);
				cmd.template = String(option.template);
				cmd.source = option.source.length() > 0 ? option.source[0] : null;
				cmd.execute();				
			}
			else if (option.@type == 'changeState')
			{
				var cmd2:ChangeProcessStateCommand = new ChangeProcessStateCommand();
				cmd2.execute(XML(option.*[0]));
				ModelLocator.getInstance().eventManager.dispatchEvent(new GlobalEvent(GlobalEvent.DOCUMENT_CHANGED, "10"));// fixme na sztywno podany numer kategorii dokumentu jako dokument serwisowy, gdyz przekazywane do okna dane nie pozwalają na dynamiczną identyfikację tego numeru
			}
			this.panel.clearSelectionFunction();
		}
	}
}