using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace XlsToXmlTools.Config
{
	public class StaticField
	{
		public int Size { get {return this.Fields.Count;} }
        public List<Field> Fields
        {
            get;
            private set;
        }

        public StaticField()
        {
            Fields = new List<Field>();
        }
        internal void addField(string p)
        {
            Fields.Add(new Config.Field(Fields.Count, p));
        }

    }
}
