using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace XlsToXmlTools.Config
{
	public class Field
	{
        public int Index { get; set; }
		public string Title { get; set; }

        public Field(int _Index, string _Title)
        {
            this.Index = _Index;
            this.Title = _Title;
        }
	}
}
