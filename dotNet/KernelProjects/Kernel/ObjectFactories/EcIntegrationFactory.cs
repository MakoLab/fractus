using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Kernel.BusinessObjects.Items;
using System.Xml.Linq;
using System.Xml.XPath;
using Makolab.Fractus.Kernel.Constants;
using Makolab.Fractus.Kernel.Coordinators;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Converters.Dictionaries;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using System.Globalization;
using Makolab.Fractus.Kernel.MethodInputParameters;
using LumenWorks.Framework.IO.Csv;
using System.IO;
using Makolab.Fractus.Kernel.HelperObjects;
using System.Diagnostics;
using System.Threading;

namespace Makolab.Fractus.Kernel.ObjectFactories
{
    internal class EcIntegrationFactory
    {
      

        public static void GenerateSalesOrder(XElement source, CommercialDocument destination, bool isNew)
        {
            if (destination == null)
                return;

            #region Contractors
            string str;
            ContractorMapper contractorMapper = DependencyContainerManager.Container.Get<ContractorMapper>();
            Contractor sourceSeller = null;
            if (source.Element("karta-klienta").Element("klient").Element("nip") != null)
            {
                str = source.Element("karta-klienta").Element("klient").Element("nip").Value;

                sourceSeller = contractorMapper.GetContractorByNip(str);
                if (sourceSeller == null)
                {
                    throw new ClientException(ClientExceptionId.ObjectNotFound);
                }
            }

            if (source.Element("karta-klienta").Element("klient").Element("nazwa") != null && sourceSeller == null)
            {
                str = source.Element("karta-klienta").Element("klient").Element("nazwa").Value;

                sourceSeller = contractorMapper.GetContractorByFullName(str);
                if (sourceSeller == null)
                {
                    throw new ClientException(ClientExceptionId.ObjectNotFound);
                }
            }
            
            
            destination.Contractor = sourceSeller;
            #endregion          

            #region Parsing Lines
            var sourceLines = new List<CustomXmlOrderLine>();
      
            double coloreValue = 0;
            XDocument codesInputDocument = XDocument.Parse(XmlName.EmptyRoot);
            XPathDocument itemsLists = new XPathDocument(source.CreateReader());
            XPathNavigator oXPathNavigator = itemsLists.CreateNavigator();
            XPathNodeIterator oIpozycjaNodesIterator = oXPathNavigator.Select("/source/karta-klienta/pozycja");
            int lineNumber = 1;
            foreach (XPathNavigator  item in oIpozycjaNodesIterator)
	            {
                var lineInfo = new CustomXmlOrderLine();
                lineInfo.ItemUnit = item.SelectSingleNode("ilosc").Value.Replace(",", "."); //jeśli < 1000 to wstawiam ten produkt
                if (!item.SelectSingleNode("kod_fr").IsEmptyElement)
                {
                    lineInfo.ItemCode = item.SelectSingleNode("kod_fr").Value;
                }
                else
                {
                    lineInfo.ItemCode = item.SelectSingleNode("produkt").Value;
                }

                if (int.Parse(lineInfo.ItemUnit) < 1000)
                {
                    lineInfo.ItemDescription = "directUse";
                }
                else
                {
                    lineInfo.ItemDescription = "getItemEquivalent";
                }
                lineInfo.Quantity =  decimal.Parse( item.SelectSingleNode("sztuk").ToString().Replace(",", "."));
               
                //Brakuje logiki zamiany towarów na opakowane
                sourceLines.Add(lineInfo);

                codesInputDocument.Root.Add(
                        new XElement("line"
                        , new XElement("LineNumber", lineNumber.ToStringInvariant())
                        , new XElement(XmlName.Code, lineInfo.ItemCode)
                        , new XElement("itemDescription", lineInfo.ItemDescription)
                        , new XElement("itemUnit", lineInfo.ItemUnit)
                        , new XElement("quantity",lineInfo.Quantity)
                        ));
                    lineNumber++;

                    if ( !item.SelectSingleNode("wartosc-pigment").IsEmptyElement)
                    {
                        //to się sumuje do usługi barwienie z sumą kosztów
                        coloreValue = coloreValue + double.Parse(item.SelectSingleNode("wartosc-pigment").Value);
                    }

	            }

           // Dodanie pozycji usługowej z wycena wartości barwienia
            if (coloreValue != 0)
            {
                var lineInfo = new CustomXmlOrderLine();
                coloreValue = Math.Round(coloreValue, 2);

                lineInfo.ItemCode = "Pigment - barwienie";
                lineInfo.Quantity = 1;
                sourceLines.Add(lineInfo);

                codesInputDocument.Root.Add(
                                        new XElement("line"
                                        , new XElement("LineNumber", lineNumber.ToStringInvariant())
                                        , new XElement(XmlName.Code, lineInfo.ItemCode)
                                        , new XElement("defaultPrice", coloreValue)
                                        , new XElement("quantity", 1)
                                        , new XElement("itemDescription","directUse")
                                        ));
            }
            #endregion



            #region AddLines
            XDocument itemsNotFound = XDocument.Parse(XmlName.EmptyRoot);
            ItemMapper itemMapper = DependencyContainerManager.Container.Get<ItemMapper>();
            XElement documentItems = EcIntegrationFactory.CheckItemsExistence(itemMapper, codesInputDocument); //p_checkItemsExistenceByCode

            XPathDocument itemsCheckedLists = new XPathDocument(documentItems.CreateReader());
            XPathNavigator itemsNavigator = itemsCheckedLists.CreateNavigator();
            XPathNodeIterator itemsIterator = itemsNavigator.Select("/root/line");
            lineNumber = 1;
            foreach (XPathNavigator line in itemsIterator)
            {
                if (line.SelectSingleNode("id") != null)
                {
                destination.CalculationType = (CalculationType)Enum.Parse(typeof(CalculationType), "Gross");
                destination.CalculationTypeSelected = true;
                    
                CommercialDocumentLine commercialDocumentLine = destination.Lines.CreateNew();
                commercialDocumentLine.Quantity = (decimal)line.SelectSingleNode("quantity").ValueAsDouble;
                commercialDocumentLine.ItemVersion = new Guid(line.SelectSingleNode("version").Value);
                commercialDocumentLine.ItemId = new Guid(line.SelectSingleNode("id").Value);
                commercialDocumentLine.UnitId = new Guid(line.SelectSingleNode("unitId").Value);
                commercialDocumentLine.VatRateId = new Guid(line.SelectSingleNode("vatRateId").Value);
                commercialDocumentLine.ItemCode = line.SelectSingleNode("code").Value;
                commercialDocumentLine.ItemName = line.SelectSingleNode("name").Value;
                commercialDocumentLine.ItemTypeId = line.SelectSingleNode("itemTypeId").Value;
                commercialDocumentLine.InitialNetPrice  = Convert.ToDecimal(line.SelectSingleNode("defaultPrice").Value, CultureInfo.InvariantCulture);
               
                commercialDocumentLine.Calculate(commercialDocumentLine.Quantity, commercialDocumentLine.InitialNetPrice, 0);
                }
                else
                {
                    itemsNotFound.Root.Add(
                        new XElement("itemsNotFound",
                            XElement.Load( line.ReadSubtree()))
                            );
                }
            }
            source.Add( XElement.Load(itemsNotFound.Root.CreateReader()));
            source.Element("karta-klienta").Remove();
            #endregion

            //Vat Table
            destination.Calculate();

        }

   
        private static XElement CheckItemsExistence(ItemMapper mapper, XDocument inputXml)
        {

            XDocument dbResultXml = mapper.ExecuteStoredProcedure(StoredProcedure.custom_p_checkItemsExistenceByCode, true, inputXml);
            //Oczekuje kolekcji w postaci <line><id></id><lineNumber></lineNumber></line>

            //dodanie do xml idków
            foreach (var dbElement in dbResultXml.Root.Elements())
            {
                XElement idElement = dbElement.Element(XmlName.Id);
                if (idElement != null && !String.IsNullOrEmpty(idElement.Value))
                {
                    XElement lineNumberElement = dbElement.Element("lineNumber");
                    string lineNumber = lineNumberElement != null ? lineNumberElement.Value : String.Empty;
                    XElement srcLineElement = inputXml.Root.Elements()
                        .Where(line => line.Element("LineNumber") != null
                            && line.Element("LineNumber").Value == lineNumber).FirstOrDefault();
                    if (srcLineElement != null)
                    {
                        srcLineElement.Add(new XElement(idElement));
                        srcLineElement.Add(new XElement(dbElement.Element(XmlName.Id)));
                        srcLineElement.Add(new XElement(dbElement.Element("version")));
                        srcLineElement.Add(new XElement(dbElement.Element("unitId")));
                        srcLineElement.Add(new XElement(dbElement.Element("vatRateId")));
                        srcLineElement.Add(new XElement(dbElement.Element("code")));
                        srcLineElement.Add(new XElement(dbElement.Element("name")));
                        srcLineElement.Add(new XElement(dbElement.Element("itemTypeId")));
                        srcLineElement.Add(new XElement(dbElement.Element("defaultPrice")));
                    }
                }
            }

            return inputXml.Root;
        }



        private static string GetItemCodeForSalesOrder(List<CustomXmlOrderLine> linesInfo, int lineNumber)
        {
            if (linesInfo != null && linesInfo.Count >= lineNumber)
            {
                CustomXmlOrderLine lineInfo = linesInfo.ElementAt(lineNumber - 1);
                return lineInfo.ItemCode;
            }
            else
                throw new ClientException(ClientExceptionId.SourceDocumentInvalidFormat);
        }
    }
}
