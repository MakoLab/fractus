package com.makolab.components.graphics
{
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.controls.SWFLoader;
	
	import org.gif.player.GIFPlayer;

	public class AnimatedImage extends SWFLoader
	{
		protected var player:GIFPlayer;
		
		public function AnimatedImage()
		{
			super();
			player = new GIFPlayer();
		}
		
		public override function set source(value:Object):void
		{
			if (value is String && String(value).match(/\.gif$/)) player.load(new URLRequest(String(value)));
			else if (value is String)
			{
				super.source = value;
				return;
			}
			else if (value is ByteArray) player.loadBytes(ByteArray(value));
			else if (value is Class)
			{
				var obj:Object = new (Class(value))();
				if (obj is ByteArray) player.loadBytes(ByteArray(obj));
				else
				{
					super.source = obj;
					return;
				}
			} 
			super.source = player;
		} 

	}
}