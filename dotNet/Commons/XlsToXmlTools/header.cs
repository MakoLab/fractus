using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace XlsToXmlTools
{
	//Nazwy klas powinny się zaczynać z wielkich liter
	class header
	{
		public string newName;
		private System.Xml.Linq.XName oldName;

		public header(string newName, System.Xml.Linq.XName oldName)
		{
			this.newName = normalizeName(newName);
			this.oldName = oldName;
		}

		//Nieoptymalne
		private string normalizeName(string n)
		{
			String ans = "";
			foreach (Char c in n)
			{
				if (Char.IsLetterOrDigit(c)) ans += c;
				else
					if (Char.IsWhiteSpace(c)) ans += '_';
			}
            byte[] bb= System.Text.Encoding.GetEncoding("Cyrillic").GetBytes(ans);
            ans = System.Text.Encoding.ASCII.GetString(bb);
            if (ans == "") ans = "_";
            return ans;
		}

		internal bool pass(string p)
		{
			if (p == oldName) return true;
			else return false;
		}
	}
}
