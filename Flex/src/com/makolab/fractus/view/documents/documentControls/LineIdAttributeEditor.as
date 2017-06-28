package com.makolab.fractus.view.documents.documentControls
{
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.view.generic.IdSelector;
	
	import mx.core.ClassFactory;
	
	public class LineIdAttributeEditor extends LineAttributeEditor
	{
		public function LineIdAttributeEditor()
		{
			super();
			
			var parameters:Object;
			if(this.data && this.data.itemId)parameters = {itemId : this.data.itemId};
			
			editorDataField = "selectedId";
			
			editorFactory = new ClassFactory(IdSelector);
			editorFactory.properties = {ignoreCache : true, parameters : parameters, dataSetName : "technology", labelField : "@technologyName", idField : "@id"};
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			if(!data.itemId || data.itemId == ""){
				this.editor.enabled = false;
				(this.editor as IdSelector).text = LanguageManager.getInstance().labels.documents.messages.selectItem;
			}else{
				if(this.editor is IdSelector){
					(this.editor as IdSelector).parameters = {itemId : this.data.itemId};
					(this.editor as IdSelector).dataSetName = "technology";
				}
			}
		}
		
	}
}