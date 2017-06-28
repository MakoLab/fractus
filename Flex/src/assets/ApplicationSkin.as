package assets
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.net.LocalConnection;
	
	import mx.core.BitmapAsset;
	import mx.skins.ProgrammaticSkin;

	public class ApplicationSkin extends ProgrammaticSkin
	{
		public function ApplicationSkin()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number,    unscaledHeight:Number):void
		{
			graphics.clear();
			var backgroundImageClass:Class = getStyle("backgroundImage");
			if(backgroundImageClass)
			{
				var backgroundImage:BitmapAsset = new backgroundImageClass();
				var bitmapData:BitmapData = backgroundImage.bitmapData;
				var matrix:Matrix = new Matrix();
				matrix.translate(unscaledWidth / 2 - bitmapData.width / 2, unscaledHeight / 2 - bitmapData.height / 2);
				graphics.beginBitmapFill(bitmapData, matrix, false);
				graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
				graphics.endFill();
			}
			garbageCollect();
		}
		
		private function garbageCollect():void
		{
		    // unsupported hack that seems to force a full GC
	        try 
	        {
	            var lc1:LocalConnection = new LocalConnection();
	            var lc2:LocalConnection = new LocalConnection();
	            lc1.connect('name');
	            lc2.connect('name');
	        }
	        catch (e:Error)
	        {
	        }
		}   
	}
}