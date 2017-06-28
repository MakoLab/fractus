
using System;
using System.Collections.Generic;
using System.Text;

namespace Makolab.Printing.Text
{
    public class TDObject
    {
        public Dictionary<String, String> Attributes { get; set; }
		public string RawText { get; set; }

        public TDObject()
        {
            this.Attributes = new Dictionary<string, string>();
            this.RawText = String.Empty;
        }

        public TDObject(TDObject tdo)
        {
            this.Attributes = tdo.Attributes;
            this.RawText = tdo.RawText;
        }

        public TDObject(Dictionary<string, string> attr, String text)
        {
            this.Attributes = attr;
            this.RawText = text;
        }

    }
}
