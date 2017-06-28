using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Communication.DBLayer
{
    public class DBRowIdComparer : IEqualityComparer<DBRow>
    {
        #region IEqualityComparer<DBRow> Members

        public bool Equals(DBRow x, DBRow y)
        {
            return (x.Element("id").Value.Equals(y.Element("id").Value, StringComparison.OrdinalIgnoreCase));
        }

        public int GetHashCode(DBRow obj)
        {
            return obj.Element("id").Value.GetHashCode();
        }

        #endregion
    }
}
