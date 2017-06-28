using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Xml;
using System.Text.RegularExpressions;
using System.Globalization;

namespace Makolab.Printing.Text
{
    public class MakoPrintText
    {
        #region zmienne

        int szerokoscStronyDomyslna = 152;
        XmlDocument fakturaXML = new XmlDocument();
        StringBuilder ramkaTop = new StringBuilder("");
        StringBuilder ramkaBottom = new StringBuilder("");
        ArrayList wiersze = new ArrayList();
        Char bialyZnak = ' ';
        String margines = "  ";
        String rez = "";
        bool zawijanie = true;
		private const string fontSizeOnTemplate = "%FONT-SIZE%{0}pt_on";
		private const string fontSizeOffTemplate = "%FONT-SIZE%{0}pt_off";
		private const string pageBreak = "%KONIEC-STRONY%";

        ArrayList listaWierszySkladowych = new ArrayList();

		public int DefaultPageWidth { get { return this.szerokoscStronyDomyslna; } }
		public string MarginText { get { return this.margines; } }

        #endregion

        private MakoPrintText()
        {
        }

        public static void Generate(string data)
        {
            DotMatrixPrinter dmp = new DotMatrixPrinter();
            dmp.Print(data);
        }

        public static string Generate(string xml, Stream output, string driverConfigXml = null)
        {

            StreamWriter w = new StreamWriter(output, Encoding.UTF8);

            MakoPrintText mp = new MakoPrintText();
            XmlDocument xmlDocument = new XmlDocument();
			xmlDocument.PreserveWhitespace = true;
            xmlDocument.LoadXml(xml);
            string result = mp.Convert(xmlDocument);
			#region Extract paging element
			if (driverConfigXml != null)
			{
				XmlDocument xdoc = new XmlDocument();
				xdoc.LoadXml(driverConfigXml);
				XmlNodeList list = xdoc.DocumentElement.GetElementsByTagName("paging");
				if (list.Count > 0 && list[0].NodeType == XmlNodeType.Element)
				{
					XmlElement pagingElement = (XmlElement)list[0];
					PagingLogic pagingLogic = new PagingLogic(pagingElement, mp);
					result = pagingLogic.TryApplyPaging(result);
				}
			}
			#endregion
			foreach (XmlNode child in xmlDocument.DocumentElement.ChildNodes)
            {
                xmlDocument.DocumentElement.RemoveChild(child);
            }
            w.Write(xmlDocument.DocumentElement.OuterXml);
            w.Write("@@@@");
            w.Write(result);
            w.Flush();

			return result;
        }

        private string Convert(XmlDocument xml)
        {
            this.szerokoscStronyDomyslna -= this.margines.Length;
            this.fakturaXML = xml;
            this.Convert();

            rez = "";
            for (int i = 0; i < wiersze.Count; i++)
            {
                rez += margines + wiersze[i] + "\n";
            }
			rez += MakoPrintText.pageBreak;

            return rez;
        }

        private void Convert()
        {
            PrepareXML(this.fakturaXML.DocumentElement);

            for (int i = 0; i < listaWierszySkladowych.Count; i++)
            {
				TRObject tr = (TRObject)(listaWierszySkladowych[i]);
				if (tr.IsForcedPageBreak)
				{
					wiersze.Add(MakoPrintText.pageBreak);
				}
				else if (tr.Cells == null)
                {
                    wiersze.Add("");
                }
                else
                {
                    PrepareLine(tr);
                }

            }
        }

        private void PrepareLine(TRObject tr)
        {
            var cellLines = new List<List<string>>();
            List<int> cellWidthTable = PrepareCellsLength(tr, this.szerokoscStronyDomyslna);
            ArrayList tempResults = new ArrayList();
            zawijanie = true;
            int maxIloscZwojow = 0;
                        
         
            #region sprawdzenie zawijania

            if (tr.Attributes.ContainsKey("TEXT-WRAP"))
            {
                if (tr.Attributes["TEXT-WRAP"].Equals("false"))
                {
                    zawijanie = false;
                }
            }

            #endregion

            for (int i = 0; i < tr.Cells.Count; i++)
            {
                TDObject td = tr.Cells[i];

                #region usunięcie \n

                td.RawText = td.RawText.Trim();

                if (td.Attributes.ContainsKey("ALLOW-N"))
                {
                    if (td.Attributes["ALLOW-N"].Equals("false"))
                    {
                        td.RawText = td.RawText.Replace("\n", " ");
                        td.RawText = td.RawText.Replace("\r", "");
                    }
                }

                #endregion
                int cellWidth = cellWidthTable[i]; //tr.HasVerticalBorder && zawijanie && cellWidthTable[i] > 1 ? cellWidthTable[i] - 1 : cellWidthTable[i];
                cellLines.Add(PrepareCell(td, cellWidth, zawijanie, tr.HasVerticalBorder));

            }

            for (int j = 0; j < cellLines.Count; j++)
            {
                if (cellLines[j].Count > maxIloscZwojow)
                {
                    maxIloscZwojow = cellLines[j].Count;
                }
            }


            for (int k = 0; k < maxIloscZwojow; k++)
            {
                tempResults.Add(new StringBuilder());
            }



            int preLength = 0;
            int postLength = 0;


            for (int m = 0; m < cellLines.Count; m++)
            {
                #region BLANK

                if (cellLines[m][0].Length == 0)
                {
                    for (int k = 0; k < maxIloscZwojow; k++)
                    {
                        if ((tr.Cells[m]).Attributes.ContainsKey("FORCE-BORDER"))
                        {
                            if ((tr.Cells[m]).Attributes.ContainsKey("FORCE-LEFTBORDER"))
                            {
                                ((StringBuilder)tempResults[k]).Append(tr.Attributes["VERTICALBORDER"]);
                                ((StringBuilder)tempResults[k]).Append(AddWhiteChars(cellWidthTable[m] - 1));
                            }
                            else if ((tr.Cells[m]).Attributes.ContainsKey("FORCE-BOTHBORDER"))
                            {
                                ((StringBuilder)tempResults[k]).Append(tr.Attributes["VERTICALBORDER"]);
                                ((StringBuilder)tempResults[k]).Append(AddWhiteChars(cellWidthTable[m] - 1));
                                if (m == cellLines.Count - 1)
                                {
                                    ((StringBuilder)tempResults[k]).Append(tr.Attributes["VERTICALBORDER"]);
                                }
                            }
                            else if ((tr.Cells[m]).Attributes.ContainsKey("FORCE-RIGHTBORDER"))
                            {
                                ((StringBuilder)tempResults[k]).Append(AddWhiteChars(cellWidthTable[m] - 1));
                                ((StringBuilder)tempResults[k]).Append(tr.Attributes["VERTICALBORDER"]);
                            }
                            else
                            {
                                //((StringBuilder)tempResults[k]).Append(bialyZnak);
                                ((StringBuilder)tempResults[k]).Append(AddWhiteChars(cellWidthTable[m] - 1));
                            }
                        }
                        else
                        {
                            ((StringBuilder)tempResults[k]).Append(AddWhiteChars(cellWidthTable[m]));
                        }
                    }

                    if (tr.Attributes.ContainsKey("TOPBORDER"))
                    {
                        if ((tr.Cells[m]).Attributes.ContainsKey("FORCE-BORDER"))
                        {
                            ramkaTop.Append(tr.Attributes["CROSSBORDER"]);
                            ramkaTop.Append(AddBorderChars(cellWidthTable[m] - 1, "TOPBORDER", tr.Attributes));

                            if ((tr.Cells[m]).Attributes.ContainsKey("FORCE-RIGHTBORDER"))
                            {
                                ramkaTop.Append(tr.Attributes["CROSSBORDER"]);
                            }

                        }
                        else
                        {
                            ramkaTop.Append(AddWhiteChars(cellWidthTable[m]));
                        }
                    }


                    if (tr.Attributes.ContainsKey("BOTTOMBORDER"))
                    {
                        if ((tr.Cells[m]).Attributes.ContainsKey("FORCE-BORDER"))
                        {
                            ramkaBottom.Append(tr.Attributes["CROSSBORDER"]);
                            ramkaBottom.Append(AddBorderChars(cellWidthTable[m] - 1, "BOTTOMBORDER", tr.Attributes));

                            if ((tr.Cells[m]).Attributes.ContainsKey("FORCE-RIGHTBORDER"))
                            {
                                ramkaBottom.Append(tr.Attributes["CROSSBORDER"]);
                            }

                        }
                        else
                        {
                            ramkaBottom.Append(AddWhiteChars(cellWidthTable[m]));
                        }
                    }

                }
                #endregion

                else
                {
                    for (int k = 0; k < maxIloscZwojow; k++)
                    {
                        StringBuilder temp = new StringBuilder();

                        if (tr.HasVerticalBorder)
                        {
                            temp.Append(tr.Attributes["VERTICALBORDER"]);


                            if (k >= cellLines[m].Count)
                            {
                                temp.Append(AddWhiteChars(cellWidthTable[m] - 1));
                            }
                            else
                            {
                                temp.Append(AddWhiteChars(cellWidthTable[m] - 1, cellLines[m][k], tr.Cells[m].Attributes["ALIGN"]));
                            }

                            if (m == tr.Cells.Count - 1)
                            {
                                temp.Append(tr.Attributes["VERTICALBORDER"]);
                            }
                            else if (((tr.Cells[m + 1]).Attributes.ContainsKey("BLANK")) || tr.Cells[m + 1].RawText.Equals(String.Empty))
                            {
                                temp.Append(tr.Attributes["VERTICALBORDER"]);
                            }
                        }
                        else
                        {
                            if (k >= cellLines[m].Count)
                            {
                                temp.Append(AddWhiteChars(cellWidthTable[m]));
                            }
                            else
                            {
                                temp.Append(AddWhiteChars(cellWidthTable[m], cellLines[m][k], (tr.Cells[m]).Attributes["ALIGN"]));
                            }
                        }

                        preLength = temp.Length;
                        temp = AddStyle(temp, (tr.Cells[m]).Attributes);
                        postLength = temp.Length;

                        ((StringBuilder)tempResults[k]).Append(temp);
                    }

                    tr.Width += (postLength - preLength);

                    #region ramki
                    if (tr.Attributes.ContainsKey("TOPBORDER"))
                    {
                        ramkaTop.Append(tr.Attributes["CROSSBORDER"]);
                        ramkaTop.Append(AddBorderChars(cellWidthTable[m] - 1, "TOPBORDER", tr.Attributes));

                        if ((m == tr.Cells.Count - 1) || (tr.Cells[m + 1]).Attributes.ContainsKey("BLANK"))
                        {
                            ramkaTop.Append(tr.Attributes["CROSSBORDER"]);
                        }
                    }
                    if (tr.Attributes.ContainsKey("BOTTOMBORDER"))
                    {
                        ramkaBottom.Append(tr.Attributes["CROSSBORDER"]);
                        ramkaBottom.Append(AddBorderChars(cellWidthTable[m] - 1, "BOTTOMBORDER", tr.Attributes));

                        if ((m == tr.Cells.Count - 1) || (tr.Cells[m + 1]).Attributes.ContainsKey("BLANK"))
                        {
                            ramkaBottom.Append(tr.Attributes["CROSSBORDER"]);
                        }
                    }

                    #endregion

                    ramkaBottom = AddStyle(ramkaBottom, (tr.Cells[m]).Attributes);
                    ramkaTop = AddStyle(ramkaTop, (tr.Cells[m]).Attributes);

                }

            }




            #region dodanie białych znaków do końca każdego zwoju wiersza

            if (tr.Attributes.ContainsKey("TOPBORDER"))
            {
                if (ramkaTop.Length > tr.Width)
                {
                    ramkaTop.Remove(tr.Width, ramkaTop.Length - tr.Width);
                    //throw new TextPrinterException(TextExceptionId.TooManyCharsInRow);
                }
                else
                {
                    ramkaTop.Append(this.bialyZnak, tr.Width - ramkaTop.Length);
                }
            }

            foreach (StringBuilder sb in tempResults)
            {
                if (sb.Length > tr.Width)
                {
                    sb.Remove(tr.Width, sb.Length - tr.Width);
                    // throw new TextPrinterException(TextExceptionId.TooManyCharsInRow);
                }
                else
                {
                    sb.Append(this.bialyZnak, tr.Width - sb.Length);
                }
            }


            if (tr.Attributes.ContainsKey("BOTTOMBORDER"))
            {
                if (ramkaBottom.Length > tr.Width)
                {
                    ramkaBottom.Remove(tr.Width, ramkaBottom.Length - tr.Width);
                    //throw new TextPrinterException(TextExceptionId.TooManyCharsInRow);
                }
                else
                {
                    ramkaBottom.Append(this.bialyZnak, tr.Width - ramkaBottom.Length);
                }
            }

            #endregion
            #region dodanie rozmiaru czcionki do wierszy

            if (tr.Attributes.ContainsKey("FONT-SIZE"))
            {
                ramkaTop.Insert(0, "%FONT-SIZE%" + tr.Attributes["FONT-SIZE"] + "_on");
                ramkaTop.Append("%FONT-SIZE%" + tr.Attributes["FONT-SIZE"] + "_off");

                foreach (StringBuilder sb in tempResults)
                {
                    sb.Insert(0, "%FONT-SIZE%" + tr.Attributes["FONT-SIZE"] + "_on");
                    sb.Append("%FONT-SIZE%" + tr.Attributes["FONT-SIZE"] + "_off");
                }

                ramkaBottom.Insert(0, "%FONT-SIZE%" + tr.Attributes["FONT-SIZE"] + "_on");
                ramkaBottom.Append("%FONT-SIZE%" + tr.Attributes["FONT-SIZE"] + "_off");
            }

            #endregion




            #region dodanie zwojów wierszy i ramek

            if (tr.Attributes.ContainsKey("TOPBORDER"))
            {
                if (tr.Attributes.ContainsKey("CROSSBORDER"))
                {
                    String temp = tr.Attributes["CROSSBORDER"] + tr.Attributes["CROSSBORDER"];
                    ramkaTop = ramkaTop.Replace(temp, tr.Attributes["CROSSBORDER"]);
                }
                wiersze.Add(ramkaTop);
            }

            foreach (StringBuilder sb in tempResults)
            {
                if (tr.Attributes.ContainsKey("VERTICALBORDER"))
                {
                    String temp = tr.Attributes["VERTICALBORDER"] + tr.Attributes["VERTICALBORDER"];
                    StringBuilder tempSB = sb.Replace(temp, tr.Attributes["VERTICALBORDER"]);
                    wiersze.Add(tempSB);
                }
                else
                {
                    wiersze.Add(sb);
                }

            }

            if (tr.Attributes.ContainsKey("BOTTOMBORDER"))
            {
                if (tr.Attributes.ContainsKey("CROSSBORDER"))
                {
                    String temp = tr.Attributes["CROSSBORDER"] + tr.Attributes["CROSSBORDER"];
                    ramkaBottom = ramkaBottom.Replace(temp, tr.Attributes["CROSSBORDER"]);
                }
                wiersze.Add(ramkaBottom);
            }

            #endregion

            ramkaTop = new StringBuilder();
            ramkaBottom = new StringBuilder();


        }






        private List<int> PrepareCellsLength(TRObject tr, int defaultPageWidth)
        {
            List<int> cellWidthTable = new List<int>();
            int autoCells = 0;
            int widthLeft = defaultPageWidth - 1;

            for (int j = 0; j < tr.Cells.Count; j++)
            {
                TDObject td = tr.Cells[j];
                int cellWidth = 0;

                if (td.Attributes.ContainsKey("WIDTH"))
                {
                    if (td.Attributes["WIDTH"].Contains("%"))
                    {
                        cellWidth = (int)Math.Floor(tr.Width * Double.Parse((td.Attributes["WIDTH"]).Substring(0, td.Attributes["WIDTH"].Length - 1)) / 100);
                        widthLeft -= cellWidth;
                    }
                    else if (td.Attributes["WIDTH"].Contains("pt"))
                    {
                        cellWidth = (int)Math.Floor(Double.Parse((td.Attributes["WIDTH"]).Substring(0, td.Attributes["WIDTH"].Length - 2)) / 4);
                        widthLeft -= cellWidth;
                    }
                    else if (td.Attributes["WIDTH"].Equals(""))
                    {
                        cellWidth = 10;
                        widthLeft -= cellWidth;
                    }
                    else if (td.Attributes["WIDTH"].Equals("AUTO"))
                    {
                        cellWidth = -1;
                        autoCells++;
                    }
                    else
                    {
                        cellWidth = (int)(Double.Parse(td.Attributes["WIDTH"]));
                        widthLeft -= cellWidth;
                    }
                }
                cellWidthTable.Add(cellWidth);
            }

            if (autoCells > 0)
            {
                int autoCellWidth = widthLeft / autoCells;
                for (int k = 0; k < tr.Cells.Count; k++)
                {
                    if (cellWidthTable[k] == -1)
                    {
                        cellWidthTable[k] = autoCellWidth;
                    }
                }
            }
            return cellWidthTable;
        }






        private List<string> PrepareCell(TDObject td, int szerokoscKomorki, bool zawijanie, bool hasVerticalBorder)
        {
            String textBase = td.RawText;
            List<string> resultLines = new List<string>();


            if (zawijanie == false)
            {
                if (textBase.Length > szerokoscKomorki)
                {
                    resultLines.Add(textBase.Substring(0, szerokoscKomorki));
                }
                else
                {
                    resultLines.Add(textBase);
                }

                return resultLines;
            }

            String[] delimiters = new String[1];
            delimiters[0] = "\r\n";

            String[] lineSplit = textBase.Split(delimiters, System.StringSplitOptions.None);


            for (int i = 0; i < lineSplit.Length; i++)
            {
                lineSplit[i] = lineSplit[i].Trim();

                if (lineSplit[i].Length < szerokoscKomorki)
                {
                    resultLines.Add(lineSplit[i]);
                }
                else
                {
                    //if (hasVerticalBorder && szerokoscKomorki > 1)  // błąd związany z dziwnym zachoweaniem VAT [%]
                    //    szerokoscKomorki--;


                    Regex r = new Regex(@"\s+");
                    lineSplit[i] = r.Replace(lineSplit[i], @" ");

                    String[] spaceSplit = lineSplit[i].Split(' ');
                    int licznik = 0;
                    ArrayList spaceSplitArrayList = new ArrayList(spaceSplit);

                    while (spaceSplitArrayList.Count > licznik)
                    {
                        StringBuilder line = new StringBuilder();

                        //if (spaceSplit.Length == 1)
                        //{
                        //    resultLines.Add(spaceSplit[0]);
                        //    break;
                        //}

                        for (; licznik < spaceSplitArrayList.Count; )
                        {
                            if (spaceSplitArrayList[licznik].ToString().Length >= szerokoscKomorki)
                            {
                                if (line.Length > 0)
                                {
                                    resultLines.Add(line.ToString());
                                    line = new StringBuilder();
                                }

                                if (checkSpecialSplitChars(spaceSplitArrayList[licznik].ToString()))
                                {
                                    String temp = PrepareStringForSplit(spaceSplitArrayList[licznik].ToString());
                                    String[] tempSplit = temp.Split(' ');
                                    StringBuilder additionalText = new StringBuilder();

                                    for (int k = 0; k < tempSplit.Length; k++)
                                    {
                                        if ((line.Length + tempSplit[k].Length) < szerokoscKomorki)
                                        {
                                            line.Append(tempSplit[k]);
                                        }
                                        else
                                        {
                                            if (line.ToString().Length != 0)
                                            {
                                                resultLines.Add(line.ToString());
                                                line = new StringBuilder();
                                            }
                                           if (tempSplit[k].Length >= szerokoscKomorki)
                                           {
                                               resultLines.Add(tempSplit[k].ToString().Substring(0, szerokoscKomorki - 1));
                                               tempSplit[k] = tempSplit[k].ToString().Substring(szerokoscKomorki - 1);
                                           }

                                           spaceSplitArrayList[licznik] = JoinCuttings(tempSplit, k);
                                           break;
                                        }                                       
                                    }

                                }
                                else
                                {
                                    resultLines.Add(spaceSplitArrayList[licznik].ToString().Substring(0, szerokoscKomorki - 1));
                                    spaceSplitArrayList[licznik] = spaceSplitArrayList[licznik].ToString().Substring(szerokoscKomorki - 1);
                                }
                            }
                            else if ((line.Length + spaceSplitArrayList[licznik].ToString().Length) < szerokoscKomorki)
                            {
                                line.Append(spaceSplitArrayList[licznik].ToString());

                                if (licznik < (spaceSplitArrayList.Count - 1))  // ostatniemu wyrazowi nie dodajemy " "
                                {
                                    line.Append(' ');
                                }

                                licznik++;
                            }
                            /*else if ((line.Length + spaceSplitArrayList[licznik].ToString().Length) == szerokoscKomorki)  //błąd wynikający z ucinania czasami ostatnich literek przez |
                            {
                                line.Append(spaceSplitArrayList[licznik].ToString());
                                licznik++;
                            }*/
                            else
                            {
                               break;
                            }
                        }
                        resultLines.Add(line.ToString());
                    }
                }
            }
            return resultLines;
        }

        public string PrepareStringForSplit(string str)
        {
            StringBuilder b = new StringBuilder(str);
            b.Replace(".", ". ")
             .Replace(",", ", ")
             .Replace(":", ": ")
             .Replace(";", "; ")
             .Replace("-", "- ");

            return b.ToString();
        }

        public string JoinCuttings(String[] tempArray, int startIndex)
        {
            StringBuilder b = new StringBuilder();

            for (int i = startIndex; i < tempArray.Length; i++)
            {
               b.Append(tempArray[i]);
            }
            return b.ToString();
        }

        public bool checkSpecialSplitChars(string str)
        {
            if (str.Contains(".") || str.Contains(",") || str.Contains(":") || str.Contains(";") || str.Contains("-")) return true;
            else return false;
        }

        private String AddBorderChars(int cellWidth, String borderType, Dictionary<string, string> attributes)
        {
            StringBuilder sb = new StringBuilder("");

            if (borderType.Equals("BOTTOMBORDER"))
            {
                sb.Append(Char.Parse(attributes["BOTTOMBORDER"]), cellWidth);
            }

            if (borderType.Equals("TOPBORDER"))
            {
                sb.Append(Char.Parse(attributes["TOPBORDER"]), cellWidth);
            }

            return sb.ToString();
        }

        private String AddWhiteChars(int cellWidth)
        {
            StringBuilder sb = new StringBuilder("");
            sb.Append(this.bialyZnak, cellWidth);
            return sb.ToString();
        }

        private String AddWhiteChars(int cellWidth, String text, String style)
        {
            StringBuilder textSB = new StringBuilder(text);
            StringBuilder result = new StringBuilder();
            StringBuilder uzupelnienie = new StringBuilder();

            if (text.Length >= cellWidth)
            {
                result = textSB.Remove(cellWidth, textSB.Length - (cellWidth));
            }
            else
            {
                uzupelnienie.Append(this.bialyZnak, cellWidth - textSB.Length);

                if (style.Equals("left"))
                {
                    result.Append(textSB);
                    result.Append(uzupelnienie);
                }
                else if (style.Equals("right"))
                {
                    result.Append(uzupelnienie);
                    result.Append(textSB);
                }
                else if (style.Equals("center"))
                {
                    result.Append(uzupelnienie.ToString().Substring(0, (uzupelnienie.Length / 2)));
                    result.Append(textSB);
                    result.Append(uzupelnienie.ToString().Substring(0, uzupelnienie.Length - uzupelnienie.Length / 2));
                }
            }

            return result.ToString();
        }

        private void PrepareXML(XmlNode faktura)
        {
            foreach (XmlNode tr in faktura.ChildNodes)
            {
				if (tr.Name == "page-break")
				{
					TRObject tro = new TRObject();
					tro.IsForcedPageBreak = true;
					this.listaWierszySkladowych.Add(tro);
				}
                else if ((tr.Name == "tr") || (tr.Name == "th"))
                {
                    Dictionary<String, String> wierszAttr = new Dictionary<string, string>();
                    StringBuilder wiersz = new StringBuilder();
                    List<TDObject> cells = new List<TDObject>();
                    TRObject tro;

                    #region pobranie atrybutów węzła

                    foreach (XmlAttribute attribute in tr.Attributes)
                    {
                        wierszAttr.Add(attribute.Name, attribute.InnerXml);
                    }
                    if (!wierszAttr.ContainsKey("FONT-SIZE"))
                    {
                        wierszAttr.Add("FONT-SIZE", "8.0pt");
                    }


                    #endregion


                    if (wierszAttr.ContainsKey("BLANK") == true)
                    {
                        tro = new TRObject(wierszAttr, null, 10);
                        listaWierszySkladowych.Add(tro);
                    }
                    else if (tr.HasChildNodes)
                    {
                        String text = "";
                        foreach (XmlNode td in tr.ChildNodes)
                        {
                            if ((td.Name == "td"))
                            {
                                Dictionary<String, String> tdAttr = new Dictionary<string, string>();
                                foreach (XmlAttribute attribute in td.Attributes)
                                {
                                    tdAttr.Add(attribute.Name, attribute.InnerXml);
                                }
                                if (!tdAttr.ContainsKey("ALIGN"))
                                {
                                    tdAttr.Add("ALIGN", "left");
                                }
                                if (!tdAttr.ContainsKey("FONT-WEIGHT"))
                                {
                                    tdAttr.Add("FONT-WEIGHT", "normal");
                                }
                                if (!tdAttr.ContainsKey("FONT-STYLE"))
                                {
                                    tdAttr.Add("FONT-STYLE", "normal");
                                }

                                text = td.InnerText;
                                Object a = td.Value;
                                TDObject tdo = new TDObject(tdAttr, text);

                                cells.Add(tdo);
                            }
                            if (cells.Count == 0)
                            {
                                Console.WriteLine();
                            }
                        }
                        if (wierszAttr.ContainsKey("RAW-WIDTH"))
                        {
                            tro = new TRObject(wierszAttr, cells, Int32.Parse(wierszAttr["RAW-WIDTH"]));
                        }
                        else
                        {
                            tro = new TRObject(wierszAttr, cells, szerokoscStronyDomyslna);
                        }

                        listaWierszySkladowych.Add(tro);
                    }
                }
                else
                {
                    PrepareXML(tr);
                }
            }
        }


        private StringBuilder AddStyle(StringBuilder text, Dictionary<string, string> attributes)
        {
            StringBuilder resultSb;
            String result = text.ToString();

            #region dodanie stylu czcionki

            if (attributes.ContainsKey("FONT-STYLE"))
            {
                String prefix;
                String postfix;

                if (attributes["FONT-STYLE"] == "italic")
                {
                    prefix = "%FONT-STYLE%" + attributes["FONT-STYLE"] + "_on";
                    postfix = "%FONT-STYLE%" + attributes["FONT-STYLE"] + "_off";
                    result = prefix + result + postfix;

                }
                else
                {
                    //     result = "%FONT-STYLE%" + "normal" + "_on" + result + "%FONT-STYLE%" + "normal" + "_off";
                }
            }

            #endregion

            #region dodanie pogrubienia czcionki

            if (attributes.ContainsKey("FONT-WEIGHT"))
            {
                if (attributes["FONT-WEIGHT"] == "bold")
                {
                    result = "%FONT-WEIGHT%" + attributes["FONT-WEIGHT"] + "_on" + result + "%FONT-WEIGHT%" + attributes["FONT-WEIGHT"] + "_off";
                }
                else
                {
                    //  result = "%FONT-WEIGHT%" + "normal" + "_on" + result + "%FONT-WEIGHT%" + "normal" + "_off";
                }
            }

            #endregion

            resultSb = new StringBuilder(result);

            return resultSb;
        }
    }
}
