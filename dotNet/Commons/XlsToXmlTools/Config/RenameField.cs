using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace XlsToXmlTools.Config
{
    public class RenameField
    {
        public string Name { get; set; }
        public string ChangeTo { get; set; }

        public RenameField(string _Name, string _ChangeTo)
        {
            if (_Name != null || _ChangeTo != null)
            {
                this.Name = _Name;
                this.ChangeTo = _ChangeTo;
            }
        }
    }
}
