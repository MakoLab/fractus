using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using System.IO;
using Excel;
using System.Data;
using System.Windows.Forms;
using Makolab.Fractus.Commons;
//using XlsToXmlTools.extensionsTemp;
using XlsToXmlTools.Config;

namespace XlsToXmlTools
{
	public class XlsConvert
	{
		public ConverterPattern Config { get; private set; }
        private Dictionary<string, List<header>> headers { get; set; }

		public XlsConvert(string config)
		{
			this.Config = new ConverterPattern(XDocument.Parse(config));
		}
        public XlsConvert( )
            
        {
           
        }
		/// <summary>
		/// Parse xls file as simple xml file
		/// </summary>
		/// <param name="xlsStream">Stream with xls file to parse</param>
		/// <returns>Parsed xml file</returns>
        public XDocument ToXml(bool is2007Format, Stream xlsStream)
		{
            DataSet result = this.ToDataSet(is2007Format, xlsStream, false);

			foreach (DataTable dataTable in result.Tables)
			{
				dataTable.TableName = dataTable.TableName.ToXmlName();
			}

			XDocument resultXml = XDocument.Parse(result.GetXml());

			return resultXml;
		}

		/// <summary>
		/// Parse xls file as dataset
		/// </summary>
		/// <param name="xlsStream">Stream with xls file to parse</param>
		/// <returns>DataSet</returns>
		public DataSet ToDataSet(bool is2007Format, Stream xlsStream, bool asDataSet)
		{
			IExcelDataReader excelReader = null;
			DataSet resultDataSet = null;
			try
			{

				if (is2007Format)
				{
					excelReader = ExcelReaderFactory.CreateOpenXmlReader(xlsStream);
				}
				else
				{
					excelReader = ExcelReaderFactory.CreateBinaryReader( xlsStream );
				}
                if (asDataSet)
                    //excelReader.IsFirstRowAsColumnNames = true;
                    resultDataSet = excelReader.AsDataSet(asDataSet);
                else
                {
                    resultDataSet = excelReader.AsDataSet();
                }
			}
			finally
			{
				if (excelReader != null)
				{
					excelReader.Dispose();
				}
			}

			return resultDataSet;
		}

        /// <summary>
        /// Use after XlsConvert.toXml() to clean the data
        /// </summary>
        /// <param name="xml">The XML.</param>
        /// <param name="documentName">Name of the document.</param>
        /// <returns></returns>
        public XDocument CorrectFile(XDocument xml, string documentName="")
		{
			
			if (this.Config.AddRowTags)                                  // -- Zmienia uklad drzewa XML, praktycznie niezbedna funkcjonalnosc.
			{
				xml = AddRowsTags(xml);
			}

            xml = findHeaders(xml, Config.RemoveDataBeforeHeaders);     // -- Szuka po tresci elementow naglowka (po nazwach podanych w Column)

            xml = CorrectStaticFieldsByCountElements(xml);              // -- Zlicza elementy wewnatrz <Row></Row> 
                                                                        //      - jesli rowne liczbie elementow w StaticField to zmienia ich nazwy

            xml = CorrectElementsNameByHeaders(xml);                    // -- Zmienia nazwy pozostalych elementow na elementy naglowka,
                                                                        //          w oparciu o nazwy elementow w ktorych naglowek zostal znaleziony
                            
            xml = CorrectElementsNameByRenameFields(xml);               // -- Zmienia nazwy elementow z konkretnych na nowe konkretne

            xml = SelectOnly(xml);                                      // -- Filtruje tresc odpowiedzi tylko do wybranych elementow

            xml = CorrectMistakes(xml);

            if (this.Config.RemoveAllEmptyClosedElements)               // -- Sprzata dokument pod katem pustych tagow
			{
				xml = RemoveEmptyTags(xml);
			}

            if (documentName != "")
                xml.Root.Attribute("documentName").Value = documentName;    // -- Dodaje opcjonalny atry z nazwa dokumentu podana w parametrze

            return xml;

			/*
           
			consoleApT("# Correcting Columns Names     .......... ");
			CorrectColumnsName(tmp);

			RemoveNodesFromList(tmp); // -- List<XmlNode> NodeToRemove

			consoleApT("AddDocumentName                .......... " + checkTag("AddDocumentName").ToString());
			AddDocumentNameTag(checkTag("AddDocumentName"), tmp, fileName); ;
            */
		}

        private XDocument CorrectMistakes(XDocument xml)
        {
            foreach (XElement spreadSheetName in xml.Element("Document").Elements()) // Dla kazdego arkusza
            {
                foreach (XElement cell in spreadSheetName.Elements("Row").Elements())
                {
                    // Atrybut xml:space="preserve" pojawia sie przy konwertowaniu kolumny z pustym znakiem do XMLa.
                    // Zdarzylo sie ze pojawilo sie pole np. Column19 (gdzie kolumna była pusta w xls'ie) z atrybutem xml:space="preserve" przez co xml się nie parsował.
                    if (cell.Attributes("{http://www.w3.org/XML/1998/namespace}space").Count() > 0)
                        cell.Attribute("{http://www.w3.org/XML/1998/namespace}space").Remove();
                }
            }
            return xml;
        }

        /// <summary>
        /// If ReturnOnly exists in configure, content will be filtered to necessary minimum
        /// </summary>
        /// <param name="xml">The XML.</param>
        /// <returns></returns>
        private XDocument SelectOnly(XDocument xml)
        {
            foreach (XElement spreadSheetName in xml.Element("Document").Elements())
            {
                string ssn = spreadSheetName.Name.ToString();
                List<string> returnList = Config.getReturnOnlyListByName(ssn);
                if (returnList.Count > 0)
                {
                    foreach (XElement cell in spreadSheetName.Elements("Row").Elements())
                    {
                        bool remove = true;
                        foreach (string item in returnList)
                            if (item == cell.Name.ToString())
                            {
                                remove = false;
                                break;
                            }
                        if (remove)
                        {
                            cell.RemoveAttributes();
                            cell.RemoveNodes();
                        }
                    }
                    // Sprzatanie ------------
                    var toRemove = spreadSheetName.Elements("Row").Elements().Where(el => el.IsEmpty);
                    while (toRemove.Count() > 0)
                    {
                        toRemove.Last().Remove();
                    }
                    xml = EmptyRowRemover(xml);
                    // -----------------------

                }
            }

            return xml;
        }

        private XDocument CorrectElementsNameByRenameFields(XDocument xml)
        {
            foreach (XElement spreadSheetName in xml.Element("Document").Elements()) // Dla kazdego arkusza
            {
                string ssn = spreadSheetName.Name.ToString();
                Dictionary<string, string> list = Config.getRenameFieldsDictBySpreadSheet(ssn);

                foreach (XElement cell in spreadSheetName.Elements("Row").Elements())
                {
                    foreach (var item in list)
                        if (item.Key.ToString() == cell.Name.ToString())
                            cell.Name = item.Value.ToString();
                }
            
            }
            return xml;
        }

        /// <summary>
        /// Corrects elements name using document content found in headers row
        /// </summary>
        /// <param name="xml">The XML.</param>
        /// <returns></returns>
        private XDocument CorrectElementsNameByHeaders(XDocument xml)
        {
            foreach (XElement spreadSheetName in xml.Element("Document").Elements()) // Dla kazdego arkusza
            {
                List<string> list = Config.getColumnNameListBySpreadSheet(spreadSheetName.Name.ToString());
                
                foreach (XElement cell in spreadSheetName.Elements("Row").Elements())
                {
                    // -- header.newName
                    // -- header.xName zawiera stara nazwe kolumny
                    cell.Name = correctName(spreadSheetName.Name.ToString(), cell.Name.ToString(), headers);
                }

            }
                return xml;
        }

        private XName correctName(string spreadSheetName, string p, Dictionary<string, List<header>> headers)
        {
            if (headers.ContainsKey(spreadSheetName) == true)
            {
                foreach (header h in headers[spreadSheetName])
                {
                    if (h.pass(p)) return h.newName;
                }
            }
            return p;
        }



        /// <summary>
        /// Corrects elements name by counting them and using conf template (StaticFields/Fields)
        /// </summary>
        /// <param name="xml">The XML.</param>
        /// <returns></returns>
        private XDocument CorrectStaticFieldsByCountElements(XDocument xml)
        {
            foreach (XElement spreadSheetElement in xml.Element("Document").Elements()) // Dla kazdego arkusza
            {
                string name = spreadSheetElement.Name.ToString();

                Dictionary<int, List<XlsToXmlTools.Config.Field>> sf = Config.getStaticFieldsDictionaryBySpreadSheet(name);

                foreach (XElement ex in spreadSheetElement.Elements("Row"))
                {

                    XElement[] child = ex.Elements().ToArray();
                    int num = child.Count();
                    
                    if (sf.ContainsKey(num) == true)
                    {
                        for (int i = 0; i < num; i++)
                            child[i].Name = sf[num][i].Title;
                    }
                }
            }

                return xml;

        }

        /// <summary>
        /// Finds the headers by content. 
        /// </summary>
        /// <param name="xml">The XML.</param>
        /// <param name="RemoveData">if set to <c>true</c> [remove data].</param>
        /// <returns></returns>
        private XDocument findHeaders(XDocument xml, bool RemoveData)
        {
            // spreadSheetElement -> ex -> brothers
            headers = new Dictionary<string, List<header>>();

            foreach (XElement spreadSheetElement in xml.Element("Document").Elements()) // Dla kazdego arkusza
            {
                XElement stopRemoving = null;
                string name = spreadSheetElement.Name.ToString();

                List<header> headerList = new List<header>();

                foreach(String content in Config.getColumnNameListBySpreadSheet(name)) // Wyciagnij Liste slow kluczowych
                {
                   
                    foreach (XElement ex in spreadSheetElement.Elements("Row").Elements())
                    {
                        if (content == ex.Value)
                        {
                            foreach (XElement brothers in ex.Parent.Elements()) headerList.Add(new header(brothers.Value, brothers.Name));
                            if (stopRemoving == null) stopRemoving = ex.Parent; // <Row> <Column3> ..... </Row>
                            
                        }
                    }

                    
                }

                if (RemoveData == true && stopRemoving != null)
                {
                    foreach (XElement el in stopRemoving.ElementsBeforeSelf())
                        el.RemoveAll(); // - Zostawia <Row />
                    stopRemoving.RemoveAll();
                    
                    
                }
                //xml.ToString();

                headers.Add(name, headerList);
            }
            // -- Korekcja o usuniecie <Row />
            xml = EmptyRowRemover(xml);
            // -----------------

            return xml;
        }

        /// <summary>
        /// Removes any empty tags only in ../Row/*
        /// </summary>
        /// <param name="xml">The XML.</param>
        /// <returns></returns>
        private XDocument EmptyRowRemover(XDocument xml)
        {
            var toRemove = xml.Root.Elements().Elements("Row").Where(el => el.IsEmpty);
            while (toRemove.Count() > 0)
            {
                toRemove.Last().Remove();
            }
            return xml;
        }

        /// <summary>
        /// Removes the empty tags (Root.Elements().Where(el => el.IsEmpty))
        /// </summary>
        /// <param name="xml">The XML.</param>
        /// <returns></returns>
		private XDocument RemoveEmptyTags(XDocument xml)
		{
			var toRemove = xml.Root.Elements().Where(el => el.IsEmpty); //TODO: elements().elements() ??
            
			while (toRemove.Count() > 0)
			{
				toRemove.Last().Remove();
			}

            return xml;
		}

        /// <summary>
        /// Rebuilds the structure of the (workbook / cell) in the (workbook / row / cell)
        /// </summary>
        /// <param name="xml">The XML.</param>
        /// <returns></returns>
		private XDocument AddRowsTags(XDocument xml)
		{
			var spreadList = xml.Elements("NewDataSet").ToList();

			if (spreadList.Count > 0 && spreadList[0].HasElements)
			{
				List<string> spreadSheetNames = spreadList[0].Elements().Select(el => el.Name.LocalName).Distinct().ToList();

				XDocument convertedXml = XDocument.Parse(@"<?xml version=""1.0"" encoding=""utf-8""?><Document/>");

				foreach (String spreadSheetName in spreadSheetNames)
				{
					XElement spreadSheetElement = new XElement(spreadSheetName);
					convertedXml.Root.Add(spreadSheetElement);

                    foreach (XElement spreadSheetRowElement in spreadList[0].Elements(spreadSheetName))
					{
                       XElement newSpreadSheetElement = new XElement("Row");
						spreadSheetElement.Add(newSpreadSheetElement);

						foreach (XElement field in spreadSheetRowElement.Elements())
						{
							XElement importNode = new XElement(field);
							newSpreadSheetElement.Add(importNode);
						}
					}

				}

				return convertedXml;
			}

			return xml;
		}

	}
}
