package com.makolab.fractus.view.generic
{
	import mx.controls.Label;
	
	public class DocumentTypePrefixRenderer extends DocumentTypeRenderer
	{
		protected var prefixLabel:Label;
		private var _dataProvider:XMLList;
		private var isChild:Boolean = true;
		private var _prefix:String = ' \u2022';

		public function set prefix(prefix:String):void{//2
            this._prefix = prefix;
        }
        
        public function get prefix():String{
            return this._prefix;
        }
        
        public function set dataProvider(xmll:XMLList):void{//2
            this._dataProvider = xmll;
        }
        
        public function get dataProvider():XMLList{
            return this._dataProvider;
        }
		
		public function DocumentTypePrefixRenderer()
		{//1
			super();
			prefixLabel = new Label();
		}
		
		override public function newInstance():*
		{
			return new DocumentTypePrefixRenderer();
		}
		
		protected override function createChildren():void
		{//3
			super.createChildren();
			addChild(prefixLabel);
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{//5
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if(isChild){
				prefixLabel.move(2, 0);
				img.move(24, 0);
				lbl.move(56, 0);
				prefixLabel.setActualSize(20, unscaledHeight);
				lbl.setActualSize(unscaledWidth - 50, unscaledHeight);
			}
		}
		
		[Bindable]
		override public function set dataObject(value:Object):void
		{//4
			super.dataObject = value;
			isChild = true;
			var item:Object = cache[String(this.dataObject)];
			if (item)
			{
				for each (var x:XML in dataProvider){
					if(x == data) isChild = false;
				}
				prefixLabel.text = prefix;
			}
		}
		
	}
}