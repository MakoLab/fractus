package com.makolab.fractus.view.catalogue
{
	import flash.events.Event;
	
	import mx.controls.Label;

	public class ColumnColorRenderer extends Label
	{
		public var colorField:String = null; 
		
		public function ColumnColorRenderer()
		{
			addEventListener(Event.RENDER, renderListener);
		}
		
		private function HexToRGB(hex:uint):Object{ 
			var rgb:Object = new Object();      
			var r:uint = hex >> 16 & 0xFF;  
			var g:uint = hex >> 8 & 0xFF;  
			var b:uint = hex & 0xFF;  
			rgb.r = r;
			rgb.g = g;
			rgb.b = b;  
			return rgb;  
		}  


		protected function renderListener(event:Event):void
		{	
			if(colorField!=null && event.currentTarget.data[colorField].toString()!=""){

				var color:uint = event.currentTarget.data[colorField];
				//var rgb:Color = new Color(Number(color));	
				var rgb:Object=HexToRGB(color);
			
				var maxRGB:Number = Math.max(rgb.r, rgb.g, rgb.b);
				var minRGB:Number = Math.min(rgb.r, rgb.g, rgb.b);
				var delta:Number = (maxRGB - minRGB);
				//brightness
				var brightness:Number = maxRGB*100/255; 
	   			//saturation
				var saturation:Number = 0;
	   			if (maxRGB > 0) saturation= 100 * delta / maxRGB;
	   			//hue
	   			var hue:Number = -1;
	   			if (saturation != 0){
	   				if(maxRGB == rgb.r) hue = (rgb.g - rgb.b)/delta;
	   				else if(maxRGB == rgb.g) hue = 2+(rgb.b - rgb.r)/delta;
	   				else hue = 4+(rgb.r - rgb.g)/delta;
	   			}
			    hue = hue*60;
			    if(hue<0) hue+=360;
	   			
	            if(brightness<50 || (saturation>70 && (hue>200 || hue<30))) this.textField.textColor = 0xffffff;
	            else this.textField.textColor = 0x000000;
				this.opaqueBackground = color;
			}
			else{
				this.textField.textColor = 0x000000;
				this.opaqueBackground = null;
			} 
		}
	}
}