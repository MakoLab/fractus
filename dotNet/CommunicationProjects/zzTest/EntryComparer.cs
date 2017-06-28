using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;

namespace zzTest
{
    public class EntryComparer : IEqualityComparer<XElement>
    {
        public EntryComparer()
        {

        }

        #region IEqualityComparer<XElement> Members

        public bool Equals(XElement x, XElement y)
        {
            bool result = false;
            if (x.Element("id").Value.Equals(y.Element("id").Value, StringComparison.OrdinalIgnoreCase) &&
                x.Element("version").Value.Equals(y.Element("version").Value, StringComparison.OrdinalIgnoreCase))
                result = true;
            else
                result = false;

            return result;
        }

        public int GetHashCode(XElement obj)
        {
            string s = (obj.Element("id").Value + obj.Element("version").Value);
           return s.GetHashCode();
        }

        #endregion
    }
}
