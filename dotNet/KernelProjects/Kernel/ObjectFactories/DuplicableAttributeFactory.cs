using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;
using System.Xml.XPath;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.ObjectFactories
{
    internal static class DuplicableAttributeFactory
    {
        public static void DuplicateAttributes(Document source, Document destination)
        {
            DuplicableAttributeFactory.DuplicateAttributes(source, destination, null);
        }
        


        internal static void DuplicateAttributes(Document source, Document destination, List<Guid> blockedAttributes)
        {
			List<DocumentAttrValue> attrsToRemove = new List<DocumentAttrValue>();
            foreach (DocumentAttrValue attr in source.Attributes.Children)
            {
				//zapamiętujemy czy atrybut wystepuje na dok. docelowym
				var dstAttribs = destination.Attributes.Children.Where(a => a.DocumentFieldId == attr.DocumentFieldId);
				if (attr.IsDuplicableTo(destination.DocumentTypeId) && 
                   (blockedAttributes == null || 
                    blockedAttributes != null && !blockedAttributes.Contains(attr.DocumentFieldId)))
                {
					//kreowanie nowego
                    if (dstAttribs.Count() == 0)
                    {
                        DocumentAttrValue newAttr = destination.Attributes.CreateNew();
                        newAttr.DocumentFieldId = attr.DocumentFieldId;
                        newAttr.Value = new XElement(attr.Value);
                    }
                    else
                    {
                        DuplicatedAttributeAction action = attr.DuplicateAction;

                        if (action == DuplicatedAttributeAction.OneInstance)
                        {
                            //sprawdzamy czy jest taka sama wartosc
                            if (attr.Value.ToString() != dstAttribs.First().Value.ToString())
                            {
								if (blockedAttributes != null)
									blockedAttributes.Add(attr.DocumentFieldId);
                                destination.Attributes.Remove(dstAttribs.First());
                            }
                        }
                        else if (action == DuplicatedAttributeAction.Concatenate)
                        {
                            DocumentAttrValue dstAttr = dstAttribs.First();

                            if (!dstAttr.Value.Value.Contains(attr.Value.Value))
                            {
                                if (dstAttr.Value.Value.Length > 0)
                                    dstAttr.Value.Value += ", ";

                                dstAttr.Value.Value += attr.Value.Value;
                            }
                        }
                        else if (action == DuplicatedAttributeAction.Duplicate)
                        {
                            var existingAttribs = destination.Attributes.Children.Where(a => a.DocumentFieldId == attr.DocumentFieldId && a.Value.ToString() == attr.Value.ToString()).FirstOrDefault();

                            if (existingAttribs == null)
                            {
                                DocumentAttrValue newAttr = destination.Attributes.CreateNew();
                                newAttr.DocumentFieldId = attr.DocumentFieldId;
                                newAttr.Value = new XElement(attr.Value);
                            }
                        }
                    }
                }
				//Jeśli atrybut nie ma być duplikowany a już jest w dokumencie (przyszedł do klienta) to jest usuwany.
				//Chyba, że ustawiono flagę wymuszającą jego pozostawienie
				else if (dstAttribs.Count() != 0)
				{
					foreach (DocumentAttrValue dstAttr in dstAttribs.Where(_attr => !_attr.Automatic))
					{
						attrsToRemove.Add(dstAttr);
					}
				}

				foreach (DocumentAttrValue attrToRemove in attrsToRemove)
				{
					destination.Attributes.Children.Remove(attrToRemove);
				}
            }

 

        }

        public static void DuplicateAttributes<T>(ICollection<T> source, Document destination) where T : Document
        {
            List<Guid> blockedAttributes = new List<Guid>();

            List<Guid> potentialyBlockedAttributes = new List<Guid>();
            //sprawdzamy czy atrybuty o akcji OneInstance wystepuja na kazdym dokumencie
            foreach (Document doc in source)
            {
                foreach (DocumentAttrValue attr in doc.Attributes.Children)
                {
                    if (attr.IsDuplicableTo(destination.DocumentTypeId) && attr.DuplicateAction == DuplicatedAttributeAction.OneInstance)
                        potentialyBlockedAttributes.Add(attr.DocumentFieldId);
                }
            }

            //sprawdzamy czy kazdy atrybut wystepuje na kazdym ze zrodlowych dok.
            foreach (Document doc in source)
            {
                foreach (Guid docFieldId in potentialyBlockedAttributes)
                {
                    if (doc.Attributes.Children.Where(a => a.DocumentFieldId == docFieldId).FirstOrDefault() == null)
                    {
                        if (!blockedAttributes.Contains(docFieldId))
                            blockedAttributes.Add(docFieldId);
                    }
                }
            }

            foreach (Document doc in source)
            {
                DuplicableAttributeFactory.DuplicateAttributes(doc, destination, blockedAttributes);
            }
        }

        public static void DuplicateAttributes<T>(Document source, ICollection<T> destination) where T : Document
        {
            foreach (Document doc in destination)
            {
                DuplicableAttributeFactory.DuplicateAttributes(source, doc, null);
            }
        }

		/// <summary>
		/// Skopiowanie atrybutów o określonych documentTypeId
		/// </summary>
		/// <param name="source"></param>
		/// <param name="destination"></param>
		/// <param name="attributesToCopy"></param>
		public static void CopyAttributes(Document source, Document destination, List<Guid> attributesToCopy)
		{
			if (attributesToCopy != null)
			{
				foreach (Guid documentFieldId in attributesToCopy)
				{
					DocumentAttrValue sAttr = source.Attributes.Children.Where(a => a.DocumentFieldId == documentFieldId).FirstOrDefault();
					DocumentAttrValue dAttr = source.Attributes.Children.Where(a => a.DocumentFieldId == documentFieldId).FirstOrDefault();
					if (sAttr != null && !sAttr.Automatic && (dAttr == null || dAttr != null && !dAttr.Automatic)) 
					{
						DocumentAttrValue newAttr = destination.Attributes.GetOrCreateNew(sAttr.DocumentFieldName);
						newAttr.Value = new XElement(sAttr.Value);
						newAttr.DocumentFieldId = sAttr.DocumentFieldId;
					}
				}
			}
		}

		public static void CopyAttributes(Document source, Document destination)
		{
			if (source == null || destination == null)
				return;

			//nie kopiujemy automatycznych bo i tak są już wstawione przez CreateNewBusinessObject
			foreach (DocumentAttrValue attr in source.Attributes.Where(_attr => !_attr.Automatic))
			{
				DocumentAttrValue dstAttr = destination.Attributes[attr.DocumentFieldName];
				if (dstAttr == null || !dstAttr.Automatic)
				{
					DocumentAttrValue newAttr = destination.Attributes.CreateNew(attr.DocumentFieldName);
					newAttr.Value = new XElement(attr.Value);
					newAttr.DocumentFieldId = attr.DocumentFieldId;
				}
			}

		}

		private static List<XElement> ShiftDuplicableAttributesList(XElement shiftDbXml)
		{
			List<XElement> result = new List<XElement>();
			foreach (XElement documentAttrValueElement in shiftDbXml.Element("documentAttrValue").Elements("entry"))
			{
				DocumentField df = DictionaryMapper.Instance.GetDocumentField(new Guid(documentAttrValueElement.Element(XmlName.DocumentFieldId).Value));
				if (df.ShiftDuplicateAction != DuplicatedAttributeAction.NoDuplicate)
				{
					result.Add(DuplicableAttributeFactory.ConvertAttributeFromDbToBoXmlFormat(documentAttrValueElement, df.DataType));
				}
			}
			return result;
		}

		//nowy obiekt tylko nowe atrybuty
		public static void DuplicateShiftAttributes(XElement source, XDocument destination)
		{
			var attrsToDuplicate = DuplicableAttributeFactory.ShiftDuplicableAttributesList(source);
			if (attrsToDuplicate.Count > 0)
			{
				var destAttrsElement = destination.XPathSelectElement("/*/*/attributes");
				var destAttrs = destAttrsElement.Elements(XmlName.Attribute);
				int order = destAttrs.Count() + 1;

				foreach (XElement attrToDuplicate in attrsToDuplicate)
				{
					XElement attr = new XElement(XmlName.Attribute
						, new XElement(XmlName.Id, Guid.NewGuid().ToUpperString())
						, new XElement(attrToDuplicate.Element(XmlName.Value))
						, new XElement(attrToDuplicate.Element(XmlName.DocumentFieldId))
						, new XElement(XmlName.Order, order)
						);
					destAttrsElement.Add(attr);
					order++;
				}
			}
		}

		//istniejący obiekt
		public static void DuplicateShiftAttributes(XElement source, Document destination)
		{
			var attrsToDuplicate = DuplicableAttributeFactory.ShiftDuplicableAttributesList(source);
			if (attrsToDuplicate.Count > 0)
			{
				foreach (XElement attrToDuplicate in attrsToDuplicate)
				{
					string documentFieldId = attrToDuplicate.Element(XmlName.DocumentFieldId).Value;
					DocumentField documentField = DictionaryMapper.Instance.GetDocumentField(new Guid(documentFieldId));
					DocumentFieldName documentFieldName = documentField.TypeName;
					DocumentAttrValue destAttr = destination.Attributes.GetOrCreateNew(documentFieldName);
					destAttr.Value = new XElement(XmlName.Value, attrToDuplicate.Element(XmlName.Value).Nodes());
				}
			}
		}

		/// <summary>
		/// Converts Fractus Attribute from db to bo xml format
		/// </summary>
		/// <param name="boAttributeElement">Result attributte element</param>
		/// <param name="srcAttrElement">Source attribute field element</param>
		/// <param name="srcAttrEntryElement">Source attributte entry</patram>
		public static XElement ConvertAttributeFromDbToBoXmlFormat(XElement boAttributeElement, XElement srcAttrElement, XElement srcAttrEntryElement)
		{
			if (!VariableColumnName.IsVariableColumnName(srcAttrElement.Name.LocalName))
				boAttributeElement.Add(srcAttrElement); //auto-cloning
			else
			{
				DocumentField cf = DictionaryMapper.Instance.GetDocumentField(new Guid(srcAttrEntryElement.Element(XmlName.DocumentFieldId).Value));

				string dataType = cf.DataType;

				if (dataType != DataType.Xml)
					boAttributeElement.Add(new XElement(XmlName.Value, BusinessObjectHelper.ConvertAttributeValueForSpecifiedDataType(srcAttrElement.Value, dataType)));
				else
					boAttributeElement.Add(new XElement(XmlName.Value, srcAttrElement.Elements()));
			}
			return boAttributeElement;
		}

		internal static XElement ConvertAttributeFromDbToBoXmlFormat(XElement attrElement, string dataType)
		{
			XElement result = new XElement(XmlName.Attribute);

			foreach (XElement memberElement in attrElement.Elements())
			{
				if (!VariableColumnName.IsVariableColumnName(memberElement.Name.LocalName))
					result.Add(memberElement); //auto-cloning
				else
				{
					if (dataType != DataType.Xml)
						result.Add(new XElement(XmlName.Value, BusinessObjectHelper.ConvertAttributeValueForSpecifiedDataType(memberElement.Value, dataType)));
					else
						result.Add(new XElement(XmlName.Value, memberElement.Elements()));
				}
			}

			return result;
		}
	
	}
}
