using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace XlsToXmlTools.Config
{
	public class Column
	{
		public string Name { get; set; }
		//public string ChangeTo { get; set; }

        public Column(string _Name)
        {
            this.Name = _Name;
            //this.ChangeTo = _ChangeTo;
        }
	}
}
