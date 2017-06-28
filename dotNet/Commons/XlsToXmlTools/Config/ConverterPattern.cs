using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
//using XlsToXmlTools.extensionsTemp;

namespace XlsToXmlTools.Config
{
	[Serializable]
	public class ConverterPattern
	{
		public bool RemoveAllEmptyClosedElements { get; set; }
		public bool AddRowTags { get; set; }
		public bool RemoveDataBeforeHeaders { get; set; }
		public bool AddDocumentName { get; set; }

		public Dictionary<string, SpreadSheet> SpreadSheets;

		public ConverterPattern(XDocument xml)
		{
			this.RemoveAllEmptyClosedElements = this.GetBoolValue(xml.Root.Element("RemoveAllEmptyClosedElements"));
			this.AddRowTags = this.GetBoolValue(xml.Root.Element("AddRowTags"));
			this.RemoveDataBeforeHeaders = this.GetBoolValue(xml.Root.Element("RemoveDataBeforeHeaders"));
			this.AddDocumentName = this.GetBoolValue(xml.Root.Element("AddDocumentName"));

            ParseSpreadsheetsConfig(xml);
		}

		private bool GetBoolValue(XElement boolElement)
		{
			return boolElement != null ? Convert.ToBoolean(boolElement.GetAtributeValueOrNull("value") ?? "false") : false;
		}

        /// <summary>
        /// Parses the spreadsheets config.
        /// </summary>
        /// <param name="xml">The XML.</param>
		private void ParseSpreadsheetsConfig(XDocument xml)
		{
            var spreadsheetsElements = xml.Root.Elements("Spreadsheet");
            //var spreadsheetsElements = xml.Root.Elements("Spreadsheet").Where(el => el.GetAtributeValueOrNull("name") != null);

			this.SpreadSheets = new Dictionary<string, SpreadSheet>(spreadsheetsElements.Count());

			foreach (XElement spreadSheetEl in spreadsheetsElements)
			{
                SpreadSheet spreadSheetConfig = new SpreadSheet(spreadSheetEl.GetAtributeValueOrNull("name"));
				//spreadSheetConfig.Name = spreadSheetEl.GetAtributeValueOrNull("name");

				foreach (XElement columnElements in spreadSheetEl.Elements("Column"))
				{
                    spreadSheetConfig.Columns.Add(new Config.Column(columnElements.GetAtributeValueOrNull("name")));
				}

                foreach (XElement staticFieldElements in spreadSheetEl.Elements("StaticField"))
                {
                    Config.StaticField sf = new Config.StaticField();
                    foreach (XElement fieldElements in staticFieldElements.Elements("Field"))
                    {
                        sf.addField(fieldElements.GetAtributeValueOrNull("name"));
                    }
                    spreadSheetConfig.StaticFields.Add(sf);
                }

                foreach (XElement renameElements in spreadSheetEl.Elements("RenameField"))
                {
                    spreadSheetConfig.RenameFields.Add(new RenameField(renameElements.GetAtributeValueOrNull("name"), renameElements.GetAtributeValueOrNull("changeTo")));
                }

                foreach (XElement ignore in spreadSheetEl.Elements("ReturnOnly"))
                {
                    spreadSheetConfig.ReturnOnly.Add(ignore.GetAtributeValueOrNull("name"));
                }

                this.SpreadSheets.Add(spreadSheetConfig.Name, spreadSheetConfig);
			}
		}

        /// <summary>
        /// Gets the list of columns name by spreadsheet name.
        /// </summary>
        /// <param name="SpreadSheetName">Name of the spread sheet.</param>
        /// <returns></returns>
        internal List<string> getColumnNameListBySpreadSheet(string SpreadSheetName)
        {
            if (SpreadSheets.ContainsKey(SpreadSheetName) == true)
                return SpreadSheets[SpreadSheetName].getColumnNameList();
            else
                if (SpreadSheet.forAll != null)
                    return SpreadSheet.forAll.getColumnNameList();
                else
                return new List<string>();
        }

        internal Dictionary<int, List<Field>> getStaticFieldsDictionaryBySpreadSheet(string SpreadSheetName)
        {
            if (SpreadSheets.ContainsKey(SpreadSheetName) == true)
                return SpreadSheets[SpreadSheetName].getStaticFieldsDictionary();
            else
                if (SpreadSheet.forAll != null)
                    return SpreadSheet.forAll.getStaticFieldsDictionary();
                else
            return new Dictionary<int, List<Field>>();
        }

        internal Dictionary<string, string> getRenameFieldsDictBySpreadSheet(string p)
        {
            if (SpreadSheets.ContainsKey(p) == true)
                return SpreadSheets[p].getRenameFieldDict();
            else
                if (SpreadSheet.forAll != null)
                    return SpreadSheet.forAll.getRenameFieldDict();
                else
                    return new Dictionary<string, string>();
        }

        /// <summary>
        /// Gets the list of elements passing by filter.
        /// </summary>
        /// <param name="p">The p.</param>
        /// <returns></returns>
        internal List<string> getReturnOnlyListByName(string p)
        {
            if (SpreadSheets.ContainsKey(p) == true)
                return SpreadSheets[p].ReturnOnly;
            else
                if (SpreadSheet.forAll != null)
                    return SpreadSheet.forAll.ReturnOnly;
                else
                    return new List<string>();
        }
    }

}
