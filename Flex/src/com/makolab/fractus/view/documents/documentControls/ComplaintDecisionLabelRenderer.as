package com.makolab.fractus.view.documents.documentControls
{
	import com.makolab.components.inputComponents.DataObjectManager;
	
	import mx.controls.Label;

	public class ComplaintDecisionLabelRenderer extends Label
	{
		public function ComplaintDecisionLabelRenderer()
		{
			super();
		}
		
		private var _data:Object;
		
		public override function set data(value:Object):void
		{
			super.data = value;
			this._data = DataObjectManager.getDataObject(data, listData);
			
			if(this._data == 0)
				this.text = "Nie uznana";
			else if (this._data == 3)
				this.text = "Uznana - utylizacja";
			else if (this._data == 4)
				this.text = "Uznana - do dostawcy";
			else
				this.text = "";
		}
	}
}