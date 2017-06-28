using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;

namespace Makolab.Printing.Text
{
    public class TRObject
    {
		public Dictionary<String, String> Attributes { get; set; }
        public List<TDObject> Cells;
        public int Width;
		public bool IsForcedPageBreak { get; set; }

		public bool HasVerticalBorder { get { return Attributes.ContainsKey("VERTICALBORDER"); } }

        public TRObject()
        {
            this.Attributes = new Dictionary<string, string>();
			this.Cells = new List<TDObject>();

        }

        public TRObject(TRObject tro)
        {
            this.Attributes = tro.Attributes;
            this.Cells = tro.Cells;
            this.Width = tro.Width;
        }

        public TRObject(Dictionary<string, string> attr, List<TDObject> cells, int szerokosc)
        {
            this.Attributes = attr;
            this.Cells = cells;
            this.Width = szerokosc;
        }

    }
}
