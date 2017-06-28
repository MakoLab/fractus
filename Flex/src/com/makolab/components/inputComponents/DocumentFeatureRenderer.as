package com.makolab.components.inputComponents
{

	import com.makolab.fractus.model.DictionaryManager;
	import com.makolab.fractus.model.LanguageManager;
	
	import mx.containers.VBox;
	import mx.controls.Text;
	
	public class DocumentFeatureRenderer extends VBox
	{
		private var txtMain:Text;
		/**
		 * Constructor
		 */
		public function DocumentFeatureRenderer()
		{
			super();
		}
		/**
		 * Lets you pass a value to the renderer.
		 * @param value list of attributes of selected feature.
		 */
		public override function set data(value:Object):void
		{
			super.data = value;
			var htmlText:String = "<b>" + LanguageManager.getInstance().labels.documents.documentFeatures + "</b>";
			
			var features:XMLList = DictionaryManager.getInstance().dictionaries.documentFeatures;
			
			for each(var entry:XML in features)
			{
				if (this.isFeatureSelected(entry.id.*))
				{
					htmlText += "<br/>" + entry.label.*;
				}
			}
			
			if(!this.txtMain)
			{
				this.txtMain = new Text();
				this.txtMain.selectable = false;
				this.addChild(this.txtMain);
			}
			
			this.txtMain.htmlText = htmlText;
		}
		
		/**
		 * Checks whether choosen document feature is selected.
		 * 
		 * @param id Document feature id to check for selection.
		 * 
		 * @return true if the feature is selected; otherwise false.
		 */
		private function isFeatureSelected(id:String):Boolean
		{
			var attributes:XMLList = XMLList(this.data);
			
			for each(var attribute:XML in attributes)
			{
				if(attribute.documentFieldId.* == id && attribute.value.* == "1")
					return true;
			}
			
			return false;
		}
	}
}