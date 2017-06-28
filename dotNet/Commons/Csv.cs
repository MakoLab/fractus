using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Commons
{
    public class Csv
    {
        public static string Load(SqlDataReader reader)
        {
            string separator = ";";
            StringBuilder result = new StringBuilder();
            if (reader.HasRows)
            {
                
                for (int c = 0; c < reader.FieldCount; c++)
                {
                    result.AppendFormat("\"{0}\"", reader.GetName(c).ToString());
                    if (c < reader.FieldCount - 1)
                        result.Append(separator);
                }
                result.AppendLine(string.Empty);
                while (reader.Read())
                {
                    for (int i = 0; i < reader.FieldCount; i++)
                    {
                        result.AppendFormat("\"{0}\"", reader.GetSqlValue(i).ToString().Replace("\n"," ").Replace("Null","0"));
                        if (i < reader.FieldCount - 1)
                            result.Append(separator);
                    }
                    result.AppendLine(string.Empty);
                }
            }
            return result.ToString();
        }
    }
}
