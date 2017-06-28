package com.makolab.components.util
{
	public class ColorTools
	{
		public static const HUE_MAX:int = 360;
		public static const HUE_MIN:int = 0;
		
		public static const BRIGHTNESS_MAX:int = 100;
		public static const BRIGHTNESS_MIN:int = 0;
		
		public function ColorTools()
		{
		}
		
		public static function HexToRGB(hex:uint):Object{ 
			var rgb:Object = new Object();      
			var r:uint = hex >> 16 & 0xFF;  
			var g:uint = hex >> 8 & 0xFF;  
			var b:uint = hex & 0xFF;
			var red:String = r.toString(16);
			var green:String = g.toString(16);
			var blue:String = b.toString(16);
			rgb.r = r;
			rgb.g = g;
			rgb.b = b;
			rgb.string = "#" + (red.length == 1 ? "0"+red : red) + (green.length == 1 ? "0"+green : green) + (blue.length == 1 ? "0"+blue : blue);
			return rgb;  
		} 
		
		public static function RGBToHex(r:uint, g:uint, b:uint):uint{  
			var hex:uint = (r << 16 | g << 8 | b);  
			return hex;  
		}  
		
		public static function HexToHSV(hex:uint):Object{

			var rgb:Object=HexToRGB(hex);
			var hsv:Object = new Object(); 
		
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
   			
   			hsv.h = hue;
   			hsv.v = brightness;
   			hsv.s = saturation;
   			
   			return hsv;		
		} 
		
		public static function HSVtoRGB(h:Number, s:Number, v:Number):Object{  
			var r:Number = 0;  
			var g:Number = 0;  
			var b:Number = 0;  
			var rgb:Object = new Object();  
			var tempS:Number = s / 100;  
			var tempV:Number = v / 100;  
			var hi:int = Math.floor(h/60) % 6;  
			var f:Number = h/60 - Math.floor(h/60);  
			var p:Number = (tempV * (1 - tempS));  
			var q:Number = (tempV * (1 - f * tempS));  
			var t:Number = (tempV * (1 - (1 - f) * tempS));  
			switch(hi){  
				case 0: r = tempV; g = t; b = p; break;  
				case 1: r = q; g = tempV; b = p; break;  
				case 2: r = p; g = tempV; b = t; break;  
				case 3: r = p; g = q; b = tempV; break;  
				case 4: r = t; g = p; b = tempV; break;  
				case 5: r = tempV; g = p; b = q; break;  
			}  
			rgb.r = Math.round(r * 255);
			rgb.g = Math.round(g * 255);
			rgb.b = Math.round(b * 255);  
			return rgb;  
		} 
		
		public static function addColorsByBrightness(color:uint, brightnessColor:uint):uint{
			var c1:Object = HexToHSV(color);
			var c2:Object = HexToHSV(brightnessColor);
			
			var brightness:Number = c1.v - (BRIGHTNESS_MAX-c2.v);
			
			c1.v = (brightness<=BRIGHTNESS_MAX)? ((brightness>=BRIGHTNESS_MIN)? brightness: BRIGHTNESS_MIN): BRIGHTNESS_MAX;
			
			var rgb:Object = HSVtoRGB(c1.h, c1.s, c1.v);
			
			return RGBToHex(rgb.r, rgb.g, rgb.b);
		}

	}
}