using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace XlsToXmlTools.Config
{
	public class SpreadSheet
	{
        public string Name { get; set; }

		public List<Column> Columns { get; set; }
		public List<StaticField> StaticFields { get; set; }
        public List<RenameField> RenameFields { get; set; }
        public List<String> ReturnOnly { get; set; }
        
        public static SpreadSheet forAll { get; set; }

        public SpreadSheet()
        {
            Columns = new List<Column>();
            StaticFields = new List<StaticField>();
            RenameFields = new List<RenameField>();
            ReturnOnly = new List<String>();
        }

        public SpreadSheet(string _Name) : this()
        {
            if (_Name == null)
            {
                this.Name = "";
                forAll = this;
            }
            else
            {
                this.Name = _Name;
            }
        }

        internal List<string> getColumnNameList()
        {
            List<string> Names = new List<string>();
            foreach(Column c in Columns)
            {
                Names.Add(c.Name);
            }
                return Names;
        }

        internal Dictionary<int, List<Field>> getStaticFieldsDictionary()
        {
            Dictionary<int, List<Field>> ans = new Dictionary<int, List<Field>>();

            foreach (StaticField sf in StaticFields)
                ans.Add(sf.Size, sf.Fields);

            return ans;
        }

        internal Dictionary<string, string> getRenameFieldDict()
        {
            Dictionary<string, string> Dict = new Dictionary<string, string>();
            foreach (RenameField f in RenameFields)
            {
                Dict.Add(f.Name, f.ChangeTo);
            }
            return Dict;
        }
    }
}
