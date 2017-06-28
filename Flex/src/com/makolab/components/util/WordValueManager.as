package com.makolab.components.util
{
	public class WordValueManager
	{
		public const MINUS:String = "-";
		
		public const WORDS:Object = {
			0 : "zero",
			1 : "jeden",
			2 : "dwa",
			3 : "trzy",
			4 : "cztery",
			5 : "pięć",
			6 : "sześć",
			7 : "siedem",
			8 : "osiem",
			9 : "dziewięć",
			10 : "dziesięć",
			20 : "dwadzieścia",
			30 : "trzydzieści",
			40 : "czterdzieści",
			50 : "pięćdziesiąt",
			60 : "sześćdziesiąt",
			70 : "siedemdziesiąt",
			80 : "osiemdziesiąt",
			90 : "dziewięćdziesiąt",
			100 : "sto",
			200 : "dwieście",
			300 : "trzysta",
			400 : "czterysta",
			500 : "pięćset",
			600 : "sześćset",
			700 : "siedemset",
			800 : "osiemset",
			900 : "dziewięćset",
			1000 : ["tysiąc", "tysiące", "tysięcy"],
			1000000 : ["milion", "miliony", "milionów"],
			1000000000 : ["miliard", "miliardy", "miliardów"]
		}
	
		public function getWordValue(val:Number, unit:String):String
		{
			var s:String = "";
			if (val < 0)
			{
				s += MINUS;
				val *= -1;
			}
			var intVal:int = int(val);
			var t:int = 1;
			if (intVal == 0) s += WORDS[0];
			else while (intVal > 0)
			{
				var wv:String = getWordValue1000(intVal % 1000);
				if (wv)
				{
					if (t > 1)
					{
						var words:Array = WORDS[t];
						if (words) wv += " " + getWordForm(intVal % 1000, words);
						else wv += " " + t.toString();
					}
				}
				intVal /= 1000;
				t *= 1000;
				s = " " + wv + s;
			}
			s += " " + unit;
			var fraction:int = int((val - int(val)) * 100);
			s += " " + (fraction == 0 ? WORDS[0] : getWordValue1000(fraction)) + " " + unit + "/100";
			return s;
		}
		
		private function getWordValue1000(val:int):String
		{
			var s:String = "";
			while (val > 0)
			{
				var maxI:int = 0;
				for (var i:String in WORDS)
				{
					var ii:int = parseInt(i);
					if (val >= ii && ii > maxI) maxI = ii;
				}
				if (maxI > 0)
				{
					val -= maxI;
					if (s) s += " ";
					s += WORDS[maxI];
				}
			}
			return s;
		}
		
		private function getWordForm(val:int, words:Array):String
		{
			var u:int = val % 10;
			if (u == 0) return words[2];						// zero i kilkadziesiat
			else if (val <= 20 && val >= 10) return words[2];	// kilkanascie
			else if (val == 1) return words[0];					// jeden
			else if (u == 1) return words[2];					// kilkadziesiat jeden
			else if (u <= 4) return words[1];					// 2, 3, 4 lub kilkadziesiat- 2, 3, 4
			else return words[2];
		}
	}
}