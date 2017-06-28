using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;

namespace OrderTrackerGUI
{
    public static class Extensions
    {
        public static bool FieldExists(this IDataReader reader, string fieldName)
        {
            reader.GetSchemaTable().DefaultView.RowFilter = string.Format("ColumnName= '{0}'", fieldName);
            return (reader.GetSchemaTable().DefaultView.Count > 0);
        }
    }

}
