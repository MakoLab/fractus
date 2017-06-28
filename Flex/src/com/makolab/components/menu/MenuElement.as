package com.makolab.components.menu
{
	import flash.display.DisplayObject;
	
	import mx.containers.ApplicationControlBar;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Label;
    
    public class MenuElement extends VBox
	{
		private var hBox:HBox;
		[Bindable]
		public var title:String;
		
		public function MenuElement()
		{
			super();
				
				hBox = new HBox();                     
	            super.addChild(hBox);
		}

		override public function addChild(child:DisplayObject):DisplayObject{
			return this.hBox.addChild(child);
		}

	}
    /*        
	public class MenuElement extends ApplicationControlBar
	{
		private var vBox:VBox;
		private var hBox:HBox;
		[Bindable]
		public var title:String;
		
		public function MenuElement()
		{
			super();
				vBox = new VBox();
				vBox.styleName = "vBoxMenuBar";
				
				hBox = new HBox();
    			var acb:ApplicationControlBar = new ApplicationControlBar();
    			var lab:Label = new Label();
    			
    			BindingUtils.bindProperty(lab, "text",this,"title");
	            acb.addChild(lab);
	            acb.percentWidth = 100;
	            acb.height = 16;
	            acb.styleName = "titleMenuElementControlBar";
	            
	            vBox.addChild(hBox);
	            vBox.addChild(acb);
	            
	            super.addChild(vBox);
		}

		override public function addChild(child:DisplayObject):DisplayObject{
			return this.hBox.addChild(child);
		}

	}
	*/
}