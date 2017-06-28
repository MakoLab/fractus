package com.makolab.components.lineList
{
	import assets.IconManager;
	
	import com.makolab.fractus.model.LanguageManager;
	
	import flash.events.MouseEvent;
	
	import mx.controls.LinkButton;	

	[Bindable]
	public class LineImageButton extends LinkButton
	{
		public var clickFunction:Function;
		public var _iconsName:String;
		public var _labelKey:String;
		
		public function set iconsName(value:String):void
		{
				_iconsName = value;
				this.setStyle('icon', IconManager.getIcon(_iconsName));
				this.setStyle('disabledIcon', IconManager.getIcon('dis_'+_iconsName));
		}
		public function set labelKey(value:String):void
		{
			_labelKey = value;
			this.toolTip = LanguageManager.getLabel(_labelKey);		
		}
		
		public function LineImageButton()
		{
			super();
			this.width = 19;
			this.height = 19;
			
			this.addEventListener(MouseEvent.CLICK, handleClick);
		}
		
		private function handleClick(event:MouseEvent):void
		{
			if (clickFunction != null) clickFunction(this.data);
		}
	}
}