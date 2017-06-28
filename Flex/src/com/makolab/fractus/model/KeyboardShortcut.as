package com.makolab.fractus.model
{
	public class KeyboardShortcut
	{
		public function KeyboardShortcut(object:Object = null)
		{
			keyCodes = [];
			for (var element:String in object) keyCodes.push(object[element]);
		}
		
		public function toString():String
		{
			var result:String = "";
			for (var i:int = 0; i < keyCodes.length; i++) result += (keyCodes[i] + " ");
			return result; 
		}
		
		public var keyCodes:Array = [];
		
		public function addKey(code:uint):Array
		{
			var exists:Boolean = false;
			for (var j:int = 0; j < keyCodes.length; j++)
				if(keyCodes[j] == code) exists = true;
			if (!exists) keyCodes.push(code);
			return keyCodes;
		}
		
		public function removeKey(code:uint):Array
		{
			var newKeyCodes:Array = [];
			for (var j:int = 0; j < keyCodes.length; j++)
				if(keyCodes[j] != code) newKeyCodes.push(keyCodes[j]);
			keyCodes = newKeyCodes;
			return keyCodes;
		}
		
		public function equals(keyArray:Array):Boolean
		{
			var result:Boolean = true;
			var pressed:Object = {};
			for (var i:int = 0; i < keyArray.length; i++)
			{
				pressed["key" + keyArray[i]] = false;
				for (var j:int = 0; j < keyCodes.length; j++)
					if(keyCodes[j] == keyArray[i]) pressed["key" + keyArray[i]] = true;
			}
			for (var key:String in pressed)
				if (!pressed[key]) result = false;
			
			if (keyArray.length != keyCodes.length) result = false;
			
			return result;
		}
	}
}