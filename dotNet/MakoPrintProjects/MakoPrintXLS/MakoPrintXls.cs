using System;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Xml.Linq;
using org.in2bits.MyXls;

namespace Makolab.Printing.XLS
{
    /// <summary>
    /// Class that prints document to XLS format.
    /// </summary>
    public static class MakoPrintXls
    {
        /// <summary>
        /// Generates an XLS file from the specified xml to the specified output stream.
        /// </summary>
        /// <param name="xml">Input xml.</param>
        /// <param name="output">Output stream.</param>
        public static void Generate(string xml, Stream output)
        {
            XDocument xmlDoc = XDocument.Parse(xml);
            XlsDocument xls = new XlsDocument();

            foreach (XElement sheetElement in xmlDoc.Root.Elements("sheet"))
            {
                MakoPrintXls.ProcessSheet(xls, sheetElement);
            }

            output.Write(xls.Bytes.ByteArray, 0, xls.Bytes.Length);
            output.Flush();
        }

        /// <summary>
        /// Processes the sheet.
        /// </summary>
        /// <param name="xls">Main XLS document.</param>
        /// <param name="sheetXml">Input sheet xml.</param>
        private static void ProcessSheet(XlsDocument xls, XElement sheetXml)
        {
            //default sheet name
            string sheetName = "Arkusz";

            //set the sheet name if exists
            if (sheetXml.Attribute("name") != null)
                sheetName = sheetXml.Attribute("name").Value;

            Worksheet sheet = xls.Workbook.Worksheets.Add(sheetName);

            int startingRow = 1;

            if (MakoPrintXls.ProcessDocumentHeader(sheetXml, sheet))
                startingRow += 2;

            MakoPrintXls.ProcessTable(sheetXml, sheet, startingRow);
        }

        /// <summary>
        /// Processes the main table of the output document.
        /// </summary>
        /// <param name="sheetXml">Input sheet xml.</param>
        /// <param name="sheet">Worksheet to operate on.</param>
        /// <param name="startingRow">Row number to start.</param>
        private static void ProcessTable(XElement sheetXml, Worksheet sheet, int startingRow)
        {
            var columns = sheetXml.Element("table").Element("configuration").Elements();

            int columnIndex = 1;

            foreach (XElement column in columns)
            {
                switch (column.Attribute("type").Value)
                {
                    case "autonumbering":
                        MakoPrintXls.ProcessAutonumberColumn(sheetXml, sheet, startingRow, columnIndex, column.Name.LocalName);
                        break;
                    case "text":
                        MakoPrintXls.ProcessTextColumn(sheetXml, sheet, startingRow, columnIndex, column.Name.LocalName);
                        break;
                    case "decimal":
                        MakoPrintXls.ProcessDoubleColumn(sheetXml, sheet, startingRow, columnIndex, column.Name.LocalName);
                        break;
                    case "money":
                        MakoPrintXls.ProcessMoneyColumn(sheetXml, sheet, startingRow, columnIndex, column.Name.LocalName);
                        break;
                    case "decimal2":
                        MakoPrintXls.ProcessDecimal2Column(sheetXml, sheet, startingRow, columnIndex, column.Name.LocalName);
                        break;
                }

                columnIndex++;
            }
        }

        /// <summary>
        /// Processes the column of the output document as decimal2 column.
        /// </summary>
        /// <param name="sheetXml">Input sheet xml.</param>
        /// <param name="sheet">Worksheet to operate on.</param>
        /// <param name="startingRow">Row number to start.</param>
        /// <param name="columnIndex">1-based index of the column.</param>
        /// <param name="columnName">Name of the column.</param>
        private static void ProcessDecimal2Column(XElement sheetXml, Worksheet sheet, int startingRow, int columnIndex, string columnName)
        {
            MakoPrintXls.WriteTableHeader(sheetXml, sheet, startingRow, columnIndex, columnName);

            var items = sheetXml.Element("table").Element("items").Elements();

            XElement configElement = sheetXml.Element("table").Element("configuration").Element(columnName);

            int i = 1;

            foreach (XElement item in items)
            {
                if (item.Element(columnName) != null)
                {
                    Cell c = MakoPrintXls.CreateNewItemCell(sheet, startingRow + i++, columnIndex, configElement, item.Element(columnName));

                    if (item.Element(columnName).Value.Length > 0)
                        c.Value = Convert.ToDouble(item.Element(columnName).Value, CultureInfo.InvariantCulture);
                    else
                        c.Value = null;
                    
                    c.Format = StandardFormats.Decimal_2;
                }
            }
        }

        /// <summary>
        /// Processes the column of the output document as money column.
        /// </summary>
        /// <param name="sheetXml">Input sheet xml.</param>
        /// <param name="sheet">Worksheet to operate on.</param>
        /// <param name="startingRow">Row number to start.</param>
        /// <param name="columnIndex">1-based index of the column.</param>
        /// <param name="columnName">Name of the column.</param>
        private static void ProcessMoneyColumn(XElement sheetXml, Worksheet sheet, int startingRow, int columnIndex, string columnName)
        {
            MakoPrintXls.WriteTableHeader(sheetXml, sheet, startingRow, columnIndex, columnName);

            var items = sheetXml.Element("table").Element("items").Elements();

            XElement configElement = sheetXml.Element("table").Element("configuration").Element(columnName);

            int i = 1;

            foreach (XElement item in items)
            {
                if (item.Element(columnName) != null)
                {
                    Cell c = MakoPrintXls.CreateNewItemCell(sheet, startingRow + i++, columnIndex, configElement, item.Element(columnName));
                    
                    if (item.Element(columnName).Value.Length > 0)
                        c.Value = Convert.ToDouble(item.Element(columnName).Value, CultureInfo.InvariantCulture);
                    else
                        c.Value = null;
                    
                    c.Format = StandardFormats.Currency_2;
                }
            }
        }

        /// <summary>
        /// Processes the column of the output document as double column.
        /// </summary>
        /// <param name="sheetXml">Input sheet xml.</param>
        /// <param name="sheet">Worksheet to operate on.</param>
        /// <param name="startingRow">Row number to start.</param>
        /// <param name="columnIndex">1-based index of the column.</param>
        /// <param name="columnName">Name of the column.</param>
        private static void ProcessDoubleColumn(XElement sheetXml, Worksheet sheet, int startingRow, int columnIndex, string columnName)
        {
            MakoPrintXls.WriteTableHeader(sheetXml, sheet, startingRow, columnIndex, columnName);

            var items = sheetXml.Element("table").Element("items").Elements();

            XElement configElement = sheetXml.Element("table").Element("configuration").Element(columnName);

            int i = 1;

            foreach (XElement item in items)
            {
                if (item.Element(columnName) != null)
                {
                    Cell c = MakoPrintXls.CreateNewItemCell(sheet, startingRow + i++, columnIndex, configElement, item.Element(columnName));

                    if (item.Element(columnName).Value.Length > 0)
                        c.Value = Convert.ToDouble(item.Element(columnName).Value, CultureInfo.InvariantCulture);
                    else
                        c.Value = null;
                }
            }
        }

        /// <summary>
        /// Processes the column of the output document as text column.
        /// </summary>
        /// <param name="sheetXml">Input sheet xml.</param>
        /// <param name="sheet">Worksheet to operate on.</param>
        /// <param name="startingRow">Row number to start.</param>
        /// <param name="columnIndex">1-based index of the column.</param>
        /// <param name="columnName">Name of the column.</param>
        private static void ProcessTextColumn(XElement sheetXml, Worksheet sheet, int startingRow, int columnIndex, string columnName)
        {
            MakoPrintXls.WriteTableHeader(sheetXml, sheet, startingRow, columnIndex, columnName);

            var items = sheetXml.Element("table").Element("items").Elements();

            XElement configElement = sheetXml.Element("table").Element("configuration").Element(columnName);

            int i = 1;

            foreach (XElement item in items)
            {
                if (item.Element(columnName) != null)
                {
                    Cell c = MakoPrintXls.CreateNewItemCell(sheet, startingRow + i++, columnIndex, configElement, item.Element(columnName));
                    c.Value = item.Element(columnName).Value;
                }
            }
        }

        /// <summary>
        /// Processes the column of the output document as autonumbering column.
        /// </summary>
        /// <param name="sheetXml">Input sheet xml.</param>
        /// <param name="sheet">Worksheet to operate on.</param>
        /// <param name="startingRow">Row number to start.</param>
        /// <param name="columnIndex">1-based index of the column.</param>
        /// <param name="columnName">Name of the column.</param>
        private static void ProcessAutonumberColumn(XElement sheetXml, Worksheet sheet, int startingRow, int columnIndex, string columnName)
        {
            MakoPrintXls.WriteTableHeader(sheetXml, sheet, startingRow, columnIndex, columnName);

            var items = sheetXml.Element("table").Element("items").Elements();

            XElement configElement = sheetXml.Element("table").Element("configuration").Element(columnName);

            int i = 1;

            foreach(XElement item in items)
            {
                Cell c = MakoPrintXls.CreateNewItemCell(sheet, startingRow + i, columnIndex, configElement, item);
                c.Value = i++;
            }
        }

        /// <summary>
        /// Writes the header of the main table.
        /// </summary>
        /// <param name="sheetXml">Input sheet xml.</param>
        /// <param name="sheet">Worksheet to operate on.</param>
        /// <param name="row">Header's row number.</param>
        /// <param name="columnIndex">1-based index of the column.</param>
        /// <param name="columnName">Name of the column.</param>
        private static void WriteTableHeader(XElement sheetXml, Worksheet sheet, int row, int columnIndex, string columnName)
        {
            XElement columnDef = sheetXml.Element("table").Element("configuration").Element(columnName);

            Cell c = MakoPrintXls.CreateNewCell(sheet, row, columnIndex, columnDef);

            //write the value
            c.Value = columnDef.Value;
        }

        /// <summary>
        /// Processes the document header of the output document.
        /// </summary>
        /// <param name="sheetXml">Input sheet xml.</param>
        /// <param name="sheet">Worksheet to operate on.</param>
        /// <returns><c>true</c> if the header exists; otherwise <c>false</c>.</returns>
        private static bool ProcessDocumentHeader(XElement sheetXml, Worksheet sheet)
        {
            XElement titleElement = sheetXml.Element("header");

            if (titleElement != null)
            {
                int columns = sheetXml.Element("table").Element("configuration").Elements().Count();

                Cell c = MakoPrintXls.CreateNewCell(sheet, 1, 1, titleElement);
                c.Value = titleElement.Value;

                sheet.AddMergeArea(new MergeArea(1, 1, 1, columns));

                return true;
            }
            else
                return false;
        }

        /// <summary>
        /// Creates the new item cell in the specified worksheet getting defaults from item-* attributes and from the individual cell settings.
        /// </summary>
        /// <param name="sheet">The worksheet in which to create the cell.</param>
        /// <param name="row">Row number.</param>
        /// <param name="col">Column number.</param>
        /// <param name="configurationElement">Element that contains item-* configuration for the cell.</param>
        /// <param name="itemElement">The item element that may contains settings for particular cell.</param>
        /// <returns>Created cell.</returns>
        private static Cell CreateNewItemCell(Worksheet sheet, int row, int col, XElement configurationElement, XElement itemElement)
        {
            if (sheet == null)
                throw new ArgumentNullException("sheet", "sheet cannot be null");

            if (configurationElement == null)
                throw new ArgumentNullException("configurationElement", "configurationElement cannot be null");

            if (itemElement == null)
                throw new ArgumentNullException("itemElement", "itemElement cannot be null");

            XElement itemConfigElement = new XElement(configurationElement.Name);

            var attribs = from attr in configurationElement.Attributes()
                          where attr.Name.LocalName.StartsWith("item-", StringComparison.Ordinal) == true
                          select attr;

            foreach (XAttribute attr in attribs)
            {
                itemConfigElement.Add(new XAttribute(attr.Name.LocalName.Substring(5), attr.Value));
            }

            MakoPrintXls.OverrideXmlAttributes(itemElement.Parent, itemConfigElement);
            MakoPrintXls.OverrideXmlAttributes(itemElement, itemConfigElement);

            return MakoPrintXls.CreateNewCell(sheet, row, col, itemConfigElement);
        }

        /// <summary>
        /// Overrides and merges XML attributes in slave element with elements from the master element.
        /// </summary>
        /// <param name="masterElement">The master element.</param>
        /// <param name="slaveElement">The slave element.</param>
        private static void OverrideXmlAttributes(XElement masterElement, XElement slaveElement)
        {
            foreach (XAttribute attr in masterElement.Attributes())
            {
                if (slaveElement.Attribute(attr.Name) != null)
                    slaveElement.Attribute(attr.Name).Value = attr.Value;
                else
                    slaveElement.Add(attr); //auto-cloning
            }
        }

        /// <summary>
        /// Creates the new cell in the specified worksheet.
        /// </summary>
        /// <param name="sheet">The worksheet in which to create the cell.</param>
        /// <param name="row">Row number.</param>
        /// <param name="col">Column number.</param>
        /// <param name="configurationElement">Element that contains configuration for the cell.</param>
        /// <returns>Created cell.</returns>
        private static Cell CreateNewCell(Worksheet sheet, int row, int col, XElement configurationElement)
        {
            if (sheet == null)
                throw new ArgumentNullException("sheet", "sheet cannot be null");

            if (configurationElement == null)
                throw new ArgumentNullException("configurationElement", "configurationElement cannot be null");

            Color backgroundColor = null;

            if (configurationElement.Attribute("backgroundColor") != null)
                backgroundColor = Utils.ParseColor(configurationElement.Attribute("backgroundColor").Value);

            FontWeight? fontWeight = null;

            if (configurationElement.Attribute("fontWeight") != null)
                fontWeight = (FontWeight)Enum.Parse(typeof(FontWeight), configurationElement.Attribute("fontWeight").Value, true);

            ushort border = 0;

            if (configurationElement.Attribute("border") != null)
                border = Convert.ToUInt16(configurationElement.Attribute("border").Value, CultureInfo.InvariantCulture);

            HorizontalAlignments horizontalAlignment = HorizontalAlignments.Default;

            if (configurationElement.Attribute("horizontalAlignment") != null)
                horizontalAlignment = (HorizontalAlignments)Enum.Parse(typeof(HorizontalAlignments), configurationElement.Attribute("horizontalAlignment").Value, true);

            bool italic = false;
            UnderlineTypes? underlineType = null;
            bool struckOut = false;

            if (configurationElement.Attribute("italic") != null && configurationElement.Attribute("italic").Value == "true")
                italic = true;

            if (configurationElement.Attribute("underline") != null)
                underlineType = (UnderlineTypes)Enum.Parse(typeof(UnderlineTypes), configurationElement.Attribute("underline").Value, true);

            if (configurationElement.Attribute("struckOut") != null && configurationElement.Attribute("struckOut").Value == "true")
                struckOut = true;

            FontColor color = FontColor.Black;

            if (configurationElement.Attribute("color") != null)
                color = (FontColor)Enum.Parse(typeof(FontColor), configurationElement.Attribute("color").Value, true);

            string fontName = null;

            if (configurationElement.Attribute("fontName") != null)
                fontName = configurationElement.Attribute("fontName").Value;

            ushort? fontSize = null;

            if (configurationElement.Attribute("fontSize") != null)
                fontSize = Convert.ToUInt16(configurationElement.Attribute("fontSize").Value, CultureInfo.InvariantCulture);

            return MakoPrintXls.CreateNewCell(sheet, row, col, fontWeight, border, backgroundColor, horizontalAlignment, italic, underlineType, struckOut, color, fontName, fontSize);
        }

        /// <summary>
        /// Creates the new cell in the specified worksheet.
        /// </summary>
        /// <param name="sheet">The worksheet in which to create the cell.</param>
        /// <param name="row">Row number.</param>
        /// <param name="col">Column number.</param>
        /// <param name="fontWeight">The font weight.</param>
        /// <param name="border">The border.</param>
        /// <param name="backgroundColor">Color of the background.</param>
        /// <param name="horizontalAlignment">Cell's content horizontal alignment.</param>
        /// <param name="italic">if set to <c>true</c> font will be italic.</param>
        /// <param name="underlineType">Type of the underline style.</param>
        /// <param name="struckOut">if set to <c>true</c> font will be struck out.</param>
        /// <param name="color">The color of font.</param>
        /// <param name="fontName">Name of the font.</param>
        /// <param name="fontSize">Size of the font.</param>
        /// <returns>Created cell.</returns>
        private static Cell CreateNewCell(Worksheet sheet, int row, int col, FontWeight? fontWeight, ushort border, Color backgroundColor,
            HorizontalAlignments horizontalAlignment, bool italic, UnderlineTypes? underlineType, bool struckOut, FontColor color,
            string fontName, ushort? fontSize)
        {
            if (sheet == null)
                throw new ArgumentNullException("sheet", "sheet cannot be null");

            Cell cell = sheet.Cells.Add(row, col, String.Empty);

            if (border > 0)
            {
                cell.RightLineStyle = border;
                cell.LeftLineStyle = border;
                cell.TopLineStyle = border;
                cell.BottomLineStyle = border;
                cell.UseBorder = true;
            }

            if (backgroundColor != null)
            {
                cell.PatternColor = backgroundColor;
                cell.Pattern = 1;
            }

            if (fontWeight != null)
                cell.Font.Weight = fontWeight.Value;

            cell.Font.Italic = italic;

            if(underlineType != null)
                cell.Font.Underline = underlineType.Value;
            
            cell.Font.StruckOut = struckOut;

            if (fontName != null)
                cell.Font.FontName = fontName;

            if (fontSize != null)
                cell.Font.Height = (ushort)(fontSize.Value * 20);

            cell.HorizontalAlignment = horizontalAlignment;

            cell.Font.ColorIndex = (ushort)color;

            return cell;
        }
    }
}
