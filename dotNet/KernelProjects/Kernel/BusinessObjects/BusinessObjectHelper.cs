using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.BusinessObjects.Finances;
using Makolab.Fractus.Kernel.BusinessObjects.ReflectionCache;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects
{
    /// <summary>
    /// Helper class for <see cref="BusinessObject"/>s containing common methods.
    /// </summary>
    internal static class BusinessObjectHelper
    {
        /// <summary>
        /// Gets the business object label in user language.
        /// </summary>
        /// <param name="businessObject">The business object that contains xmlLabels node.</param>
        /// <returns>Label in user language version.</returns>
        public static XElement GetBusinessObjectLabelInUserLanguage(ILabeledDictionaryBusinessObject businessObject)
        {
			return BusinessObjectHelper.GetBusinessObjectLabelInUserLanguage(businessObject, null);
        }

		public static XElement GetBusinessObjectLabelInUserLanguage(ILabeledDictionaryBusinessObject businessObject, string customLanguage)
		{
			XElement xmlLabels = businessObject.Labels;

			if (xmlLabels == null || !xmlLabels.HasElements)
				throw new InvalidOperationException("Object does not contain labels.");

			string language = customLanguage ?? SessionManager.Language;

			//filter the proper language version
			var preferredLang = from node in xmlLabels.Elements()
								where node.Attribute("lang").Value == language
								select node;

			//preferred language exists
			if (preferredLang.Count() > 0)
				return preferredLang.ElementAt(0);
			else //if doesn't exist - get the first one
				return (XElement)xmlLabels.FirstNode;
		}
		
		/// <summary>
        /// Gets the XML label in user language.
        /// </summary>
        /// <param name="labelsElement">The xml element containing 'labels' element.</param>
        /// <returns>Label element in user language version.</returns>
        public static XElement GetXmlLabelInUserLanguage(XElement labelsElement)
        {
            string language = SessionManager.Language;

            //filter the proper language version
            var preferredLang = from node in labelsElement.Elements()
                                where node.Attribute("lang").Value == language
                                select node;

            //preferred language exists
            if (preferredLang.Count() > 0)
                return preferredLang.ElementAt(0);
            else //if doesn't exist - get the first one
                return (XElement)labelsElement.FirstNode;
        }

   
        public static void LoadObjectDefaults(IDefaultsHolder defaultsHolder)
        {
            Type t = defaultsHolder.GetType();

            if (BusinessObject.ClassXmlSerializationCache.ContainsKey(t))
            {
                XmlSerializationCache classCache = BusinessObject.ClassXmlSerializationCache[t];

                XElement defaultSettings = defaultsHolder.DefaultsXml.Root.Element(classCache.Attribute.XmlField);

                XmlSerializationCache[] cache = BusinessObject.PropertiesXmlSerializationCache[t];

                for (int i = 0; i < cache.Length; i++)
                {
                    XmlSerializationCache c = cache[i];

                    XmlSerializableAttribute propAttr = c.Attribute;
                    if (!propAttr.UseAttribute && defaultSettings.Element(propAttr.XmlField) != null ||
                        propAttr.UseAttribute && defaultSettings.Attribute(propAttr.XmlField) != null) //zeby nie nullowal juz ustawionych ustawien
                        BusinessObjectHelper.DeserializeSingleValue(defaultsHolder, c.Property, propAttr, defaultSettings);
                }
            }
        }

        private static string ReadValueFromXml(XElement boElement, string xmlField, bool useAttribute)
        {
            if (useAttribute)
            {
                if (boElement.Attribute(xmlField) == null)
                    return null;
                else
                    return boElement.Attribute(xmlField).Value;
            }
            else
            {
                if (boElement.Element(xmlField) == null)
                    return null;
                else
                    return boElement.Element(xmlField).Value;
            }
        }

        private static XElement ReadXmlValueFromXml(XElement boElement, string xmlField, bool useAttribute)
        {
            if (useAttribute)
                return XElement.Parse(boElement.Attribute(xmlField).Value);
            else
                return boElement.Element(xmlField);
        }

        public static void DeserializeSingleValue(object target, PropertyInfo propertyInfo, XmlSerializableAttribute attribute, XElement boElement)
        {
            Type type = propertyInfo.PropertyType;

            if (!String.IsNullOrEmpty(attribute.EncapsulatingXmlField))
                boElement = boElement.Element(attribute.EncapsulatingXmlField);

            /*if (boElement == null ||
                (!attribute.UseAttribute && attribute.XmlField != null && boElement.Element(attribute.XmlField) == null) ||
                (attribute.UseAttribute && attribute.XmlField != null && boElement.Attribute(attribute.XmlField) == null))
                propertyInfo.SetValue(target, null, null);
            else*/
			if (boElement != null && attribute.XmlField != null)
			{
				if (boElement.Element(attribute.XmlField) != null || boElement.Attribute(attribute.XmlField) != null)
				{
					if (propertyInfo.PropertyType == typeof(Boolean))
					{
						if (BusinessObjectHelper.ReadValueFromXml(boElement, attribute.XmlField, attribute.UseAttribute) == "1")
							propertyInfo.SetValue(target, true, null);
						else
							propertyInfo.SetValue(target, false, null);
					}
					else if (type == typeof(String))
						propertyInfo.SetValue(target, BusinessObjectHelper.ReadValueFromXml(boElement, attribute.XmlField, attribute.UseAttribute), null);
					else if (type == typeof(Decimal) || type == typeof(Decimal?))
						propertyInfo.SetValue(target, Convert.ToDecimal(BusinessObjectHelper.ReadValueFromXml(boElement, attribute.XmlField, attribute.UseAttribute), CultureInfo.InvariantCulture), null);
					else if (type == typeof(Int32) || type == typeof(Int32?))
						propertyInfo.SetValue(target, Convert.ToInt32(BusinessObjectHelper.ReadValueFromXml(boElement, attribute.XmlField, attribute.UseAttribute), CultureInfo.InvariantCulture), null);
					else if (type == typeof(Guid) || type == typeof(Guid?))
						propertyInfo.SetValue(target, new Guid(BusinessObjectHelper.ReadValueFromXml(boElement, attribute.XmlField, attribute.UseAttribute)), null);
					else if (type == typeof(DateTime) || type == typeof(DateTime?))
						propertyInfo.SetValue(target, DateTime.Parse(BusinessObjectHelper.ReadValueFromXml(boElement, attribute.XmlField, attribute.UseAttribute), CultureInfo.InvariantCulture), null);
					else if (type == typeof(XElement))
					{
						XElement element = BusinessObjectHelper.ReadXmlValueFromXml(boElement, attribute.XmlField, attribute.UseAttribute);

						if (element.FirstNode is XElement && !attribute.UseAttribute)
							propertyInfo.SetValue(target, new XElement((XElement)element.FirstNode), null);
						else if (!attribute.UseAttribute)
							propertyInfo.SetValue(target, new XElement(attribute.XmlField, element.Value), null);
						else
							propertyInfo.SetValue(target, element, null);
					}
					else if (typeof(IBusinessObject).IsAssignableFrom(type))
					{
						if (!String.IsNullOrEmpty(attribute.XmlField))
						{
							IBusinessObject obj = BusinessObjectHelper.CreateRelatedBusinessObjectFromXmlElement((XElement)boElement.Element(attribute.XmlField).FirstNode, attribute.RelatedObjectType);
							propertyInfo.SetValue(target, obj, null);
						}
						else //check if the nested object has attribute indicating from which node to deserialize him
						{
							if (BusinessObject.ClassXmlSerializationCache.ContainsKey(type))
							{
								XmlSerializationCache cache = BusinessObject.ClassXmlSerializationCache[type];

								IBusinessObject obj = (IBusinessObject)Activator.CreateInstance(type, target); //constructor(parent)
								obj.Deserialize((XElement)boElement.Element(cache.Attribute.XmlField));
								propertyInfo.SetValue(target, obj, null);
							}
						}
					}
					else if (type.IsEnum)
						propertyInfo.SetValue(target, Convert.ToInt32(BusinessObjectHelper.ReadValueFromXml(boElement, attribute.XmlField, attribute.UseAttribute), CultureInfo.InvariantCulture), null);
					else if (typeof(ISerializableBusinessObjectContainer).IsAssignableFrom(type))
						((ISerializableBusinessObjectContainer)propertyInfo.GetValue(target, null)).Deserialize(boElement.Element(attribute.XmlField));
					else
						throw new InvalidOperationException("Unknown type to deserialize");
				}
			}
			else if (attribute.OverrideWithEmptyValue && type == typeof(Nullable))
			{
				///DO przemyślenia
				//propertyInfo.SetValue(target, null, null);
			}
        }

        private static XObject CreateXObject(string name, object value, bool useAttribute)
        {
            if (useAttribute)
                return new XAttribute(name, value);
            else
            {
                if (!String.IsNullOrEmpty(name))
                    return new XElement(name, value);
                else
                    return (XElement)value;
            }
        }

        public static XObject SerializeSingleValue(Type type, string xmlField, object value, bool onlyIdForObjects, bool useAttribute, bool selfOnlySerialization, bool parentSelfOnlySerialization)
        {
            if (value == null) return null;

            XObject returnVal = null;

            if (type == typeof(Boolean))
            {
                if ((Boolean)value)
                    returnVal = BusinessObjectHelper.CreateXObject(xmlField, "1", useAttribute);
                else
                    returnVal = BusinessObjectHelper.CreateXObject(xmlField, "0", useAttribute);
            }
            else if (type == typeof(String) || type == typeof(Int32) || type == typeof(Int32?))
                returnVal = BusinessObjectHelper.CreateXObject(xmlField, value.ToString(), useAttribute);
            else if (type == typeof(Decimal) || type == typeof(Decimal?))
                returnVal = BusinessObjectHelper.CreateXObject(xmlField, ((Decimal)value).ToString(CultureInfo.InvariantCulture), useAttribute);
            else if (type == typeof(Guid) || type == typeof(Guid?))
                returnVal = BusinessObjectHelper.CreateXObject(xmlField, ((Guid)value).ToUpperString(), useAttribute);
            else if (type == typeof(DateTime) || type == typeof(DateTime?))
                returnVal = BusinessObjectHelper.CreateXObject(xmlField, ((DateTime)value).ToIsoString(), useAttribute);
            else if (type == typeof(XElement))
            {
                XElement xValue = (XElement)value;
                if ((xValue.FirstNode is XElement || xValue.HasAttributes || xValue.Name.LocalName != "value") && !useAttribute)
                    returnVal = BusinessObjectHelper.CreateXObject(xmlField, value, useAttribute);
                else if (!useAttribute)
                    returnVal = BusinessObjectHelper.CreateXObject(xmlField, xValue.Value, useAttribute);
                else
                    returnVal = BusinessObjectHelper.CreateXObject(xmlField, xValue.ToString(SaveOptions.DisableFormatting), useAttribute);
            }
            else if (typeof(IBusinessObject).IsAssignableFrom(type))
            {
                if (!parentSelfOnlySerialization || !selfOnlySerialization)
                {
                    IBusinessObject obj = (IBusinessObject)value;

                    if (onlyIdForObjects)
                        returnVal = BusinessObjectHelper.CreateXObject(xmlField, obj.Id.Value.ToUpperString(), useAttribute);
                    else
                        returnVal = BusinessObjectHelper.CreateXObject(xmlField, obj.Serialize(selfOnlySerialization), useAttribute);
                }
                else return null;
            }
            else if (type.IsEnum)
                returnVal = BusinessObjectHelper.CreateXObject(xmlField, (int)value, useAttribute);
            else if (typeof(ISerializableBusinessObjectContainer).IsAssignableFrom(type))
            {
                if (!parentSelfOnlySerialization && !selfOnlySerialization)
                {
                    XElement xel = ((ISerializableBusinessObjectContainer)value).Serialize();
                    xel.Name = xmlField;
                    returnVal = xel;
                }
                else return null;
            }
            else
                throw new InvalidOperationException("Unknown type to serialize");

            return returnVal;
        }

        /// <summary>
        /// Converts attribute value according to the specified data type rules.
        /// </summary>
        /// <param name="attributeValue">The attribute value to convert.</param>
        /// <param name="dataType">Type of the attribute.</param>
        /// <returns></returns>
        public static string ConvertAttributeValueForSpecifiedDataType(string attributeValue, string dataType)
        {
            string convertedValue = null;
            int i;

            switch (dataType)
            {
                case "float":
                    if (attributeValue.Contains(".0000"))
                        convertedValue = attributeValue.Substring(0, attributeValue.IndexOf('.'));
                    else
                    {
                        convertedValue = Decimal.Parse(attributeValue, CultureInfo.InvariantCulture).ToString(CultureInfo.InvariantCulture);
                    }
                    break;
                case "money":
                    i = attributeValue.IndexOf('.');

                    if (i > 0)
                        convertedValue = attributeValue.Substring(0, attributeValue.IndexOf('.') + 3);
                    else if (i == -1)
                        convertedValue = attributeValue + ".00";
                    break;
                case "boolean":
                case "integer":
                    i = attributeValue.IndexOf('.');

                    if (i > 0)
                        convertedValue = attributeValue.Substring(0, i);
                    else if (i == -1)
                        convertedValue = attributeValue;
                    break;
                default:
                    convertedValue = attributeValue;
                    break;
            }

            return convertedValue;
        }

        private static void SaveBusinessObjectColumns(IBusinessObject businessObject, Type boType, DatabaseMappingAttribute objAttribute, XElement entry, string dataType)
        {
            DatabaseMappingCache[] propCaches = BusinessObject.PropertiesDatabaseMappingCache[boType];

            foreach (DatabaseMappingCache propCache in propCaches)
            {
                DatabaseMappingAttribute propertyAttr = propCache.Attribute;

                if (propertyAttr.LoadOnly)
                    continue;

                PropertyInfo propertyInfo = propCache.Property;

                if (propertyAttr.TableName == null || propertyAttr.TableName == objAttribute.TableName)
                {
                    object value = propertyInfo.GetValue(businessObject, null);

                    //proper attribute for the currently processing table
                    if (value != null && !propertyAttr.VariableColumnName)
                    {
                        XElement existingColumn = entry.Element(propertyAttr.ColumnName);
                        if (existingColumn == null)
                            entry.Add(BusinessObjectHelper.SerializeSingleValue(propertyInfo.PropertyType, propertyAttr.ColumnName, propertyInfo.GetValue(businessObject, null), propertyAttr.OnlyId, false, false, false));
                        else if (existingColumn != null && propertyAttr.TableName == objAttribute.TableName) //eg. if there version from contractor but we're saving employee table
                        {
                            existingColumn.Remove();
                            entry.Add(BusinessObjectHelper.SerializeSingleValue(propertyInfo.PropertyType, propertyAttr.ColumnName, propertyInfo.GetValue(businessObject, null), propertyAttr.OnlyId, false, false, false));
                        }
                    }
                    else if (value != null && propertyAttr.VariableColumnName)
                    {
                        //change attribute type
                        XElement fieldValue = (XElement)BusinessObjectHelper.SerializeSingleValue(propertyInfo.PropertyType, propertyAttr.ColumnName, propertyInfo.GetValue(businessObject, null), propertyAttr.OnlyId, false, false, false);

                        switch (dataType)
                        {
                            case "select":
                            case "multiselect":
                            case "string":
                                fieldValue.Name = XName.Get(VariableColumnName.TextValue, String.Empty);
                                break;
                            case "float":
                            case "money":
                            case "boolean":
                            case "integer":
                            case "decimal":
                                fieldValue.Name = XName.Get(VariableColumnName.DecimalValue, String.Empty);
                                break;
                            case "xml":
                                fieldValue.Name = XName.Get(VariableColumnName.XmlValue, String.Empty);
                                break;
                            case "datetime":
							case "booldate": //Data wyświetlana w GUI jako checkbox
                                fieldValue.Name = XName.Get(VariableColumnName.DateValue, String.Empty);
                                break;
							case "guid":
								fieldValue.Name = XName.Get(VariableColumnName.GuidValue, String.Empty);
								break;
                            case "link":
                                fieldValue.Name = XName.Get(VariableColumnName.TextValue, String.Empty);
                                break;
                            case "auto":
                                if (fieldValue.FirstNode is XElement)
									fieldValue.Name = XName.Get(VariableColumnName.XmlValue, String.Empty);
                                else
									fieldValue.Name = XName.Get(VariableColumnName.TextValue, String.Empty);
                                break;
                        }

                        entry.Add(fieldValue);
                    }
                }
            }
        }

        public static void SaveBusinessObjectChanges(IBusinessObject businessObject, XDocument document, Dictionary<string, object> forcedElements, string dataType)
        {
            IVersionedBusinessObject versionedObject = businessObject as IVersionedBusinessObject;

            //force parent to save to change the main object version
            //these conditions are to secure a situation where both parent and its alternate version
            //are forced to save and therefore there is 1 additional update to the same record
            if (businessObject.Parent is IVersionedBusinessObject)
            {
                if (businessObject.Parent.AlternateVersion == null ||
                    ((IVersionedBusinessObject)businessObject.Parent.AlternateVersion).ForceSave == false)
                {
                    ((IVersionedBusinessObject)businessObject.Parent).ForceSave = true;
                    if (((IVersionedBusinessObject)businessObject.Parent).Status == BusinessObjectStatus.Unknown)
                        ((IVersionedBusinessObject)businessObject.Parent).Status = BusinessObjectStatus.Modified;
                }
            }

            Type t = businessObject.GetType();

            DatabaseMappingCache[] classCaches = BusinessObject.ClassDatabaseMappingCache[t];

            foreach (DatabaseMappingCache classCache in classCaches) //foreach tableName
            {
                DatabaseMappingAttribute objAttribute = classCache.Attribute;

                //find or create table element
                XElement table = document.Root.Element(objAttribute.TableName);

                if (table == null)
                {
                    table = new XElement(objAttribute.TableName);
                    document.Root.Add(table);
                }

                //create new entry element
                XElement entry = new XElement("entry");
                table.Add(entry);

                if (businessObject.Status != BusinessObjectStatus.Deleted)
                {
                    BusinessObjectHelper.SaveBusinessObjectColumns(businessObject, t, objAttribute, entry, dataType);
                   
                    Guid newVersion;

                    if (versionedObject != null)
                    {
                        versionedObject.NewVersion = Guid.NewGuid();
                        newVersion = versionedObject.NewVersion.Value;
                    }
                    else
                        newVersion = Guid.NewGuid();

                    if (businessObject.Status == BusinessObjectStatus.New)
                    {
                        entry.Add(new XAttribute("action", "insert"));
                        entry.Add(new XElement("version", newVersion.ToUpperString()));
                    }
                    else //BusinessObjectStatus.Modified or child elements changed
                    {
                        entry.Add(new XAttribute("action", "update"));
                        entry.Add(new XElement("_version", newVersion.ToUpperString()));
                    }

                    if (forcedElements != null)
                    {
                        foreach (string key in forcedElements.Keys)
                        {
                            entry.Add(new XElement(key, forcedElements[key]));
                        }
                    }
                }
                else
                {
                    entry.Add(new XElement("id", businessObject.Id.ToUpperString()));
                    entry.Add(new XElement("version", businessObject.Version.ToUpperString()));
                    entry.Add(new XAttribute("action", "delete"));
                }
            }
        }

        /// <summary>
        /// Saves changes of specified <see cref="IBusinessObjectRelation"/> to the operations list.
        /// </summary>
        /// <param name="businessObject"><see cref="IBusinessObjectRelation"/> to save.</param>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public static void SaveRelationChanges(IBusinessObjectRelation businessObject, XDocument document)
        {
            IVersionedBusinessObject mainObject;
            IVersionedBusinessObject relatedObject;

            //if we are processing a relation from alternate object
            if (businessObject.Status == BusinessObjectStatus.Deleted)
            {
                mainObject = (IVersionedBusinessObject)businessObject.Parent.AlternateVersion;
                //related object doesn't have to be independently versioned
                relatedObject = businessObject.RelatedObject as IVersionedBusinessObject; //reference to the OLD version
                //if we delete an object in new version we dont have its old version via the new main object reference
                //so we have to grab it from the old main object
            }
            else
            {
                mainObject = (IVersionedBusinessObject)businessObject.Parent;
                //related object doesn't have to be independently versioned
                relatedObject = businessObject.RelatedObject as IVersionedBusinessObject;
            }

            //mainObject and relatedObject now reference the NEW version of the alternates

            if (mainObject.Status == BusinessObjectStatus.Unchanged && mainObject.ForceSave == false && mainObject.NewVersion == null)
            {
                businessObject.UpgradeMainObjectVersion = true;
                mainObject.NewVersion = Guid.NewGuid();
            }

            if (relatedObject != null && relatedObject.Status == BusinessObjectStatus.Unchanged && relatedObject.ForceSave == false && relatedObject.NewVersion == null)
            {
                businessObject.UpgradeRelatedObjectVersion = true;
                relatedObject.NewVersion = Guid.NewGuid();
            }

            Type t = businessObject.GetType();
            DatabaseMappingCache[] classCaches = BusinessObject.ClassDatabaseMappingCache[t];

            foreach (DatabaseMappingCache classCache in classCaches) //foreach tableName
            {
                DatabaseMappingAttribute objAttribute = classCache.Attribute;

                //find or create table element
                XElement table = document.Root.Element(objAttribute.TableName);

                if (table == null)
                {
                    table = new XElement(objAttribute.TableName);
                    document.Root.Add(table);
                }

                //create new entry element
                XElement entry = new XElement("entry");
                table.Add(entry);

                if (businessObject.Status != BusinessObjectStatus.Deleted)
                {
                    BusinessObjectHelper.SaveBusinessObjectColumns(businessObject, t, objAttribute, entry, null);

                    Guid newVersion;

                    IVersionedBusinessObject versionedObject = businessObject as IVersionedBusinessObject;

                    if (versionedObject != null)
                    {
                        versionedObject.NewVersion = Guid.NewGuid();
                        newVersion = versionedObject.NewVersion.Value;
                    }
                    else
                        newVersion = Guid.NewGuid();

                    if (businessObject.Status == BusinessObjectStatus.New)
                    {
                        entry.Add(new XAttribute("action", "insert"));
                        entry.Add(new XElement("version", newVersion.ToUpperString()));
                    }
                    else //BusinessObjectStatus.Modified or child elements changed
                    {
                        entry.Add(new XAttribute("action", "update"));
                        entry.Add(new XElement("_version", newVersion.ToUpperString()));
                    }
                }
                else
                {
                    entry.Add(new XElement("id", businessObject.Id.ToUpperString()));
                    entry.Add(new XElement("version", businessObject.Version.ToUpperString()));
                    entry.Add(new XAttribute("action", "delete"));

                    DatabaseMappingCache[] cache = BusinessObject.PropertiesDatabaseMappingCache[t];

                    for (int i = 0; i < cache.Length; i++)
                    {
                        DatabaseMappingCache c = cache[i];

                        if (c.Attribute.ForceSaveOnDelete)
                        {
                            entry.Add(BusinessObjectHelper.SerializeSingleValue(c.Property.PropertyType,
                                c.Attribute.ColumnName, c.Property.GetValue(businessObject, null), c.Attribute.OnlyId, false, false, false));
                        }
                    }
                }

                if (businessObject.UpgradeMainObjectVersion)
                {
                    entry.Add(new XElement("_object1from", mainObject.Version.ToUpperString()));
                    entry.Add(new XElement("_object1to", mainObject.NewVersion.ToUpperString()));
                }

                if (businessObject.UpgradeRelatedObjectVersion)
                {
                    entry.Add(new XElement("_object2from", relatedObject.Version.ToUpperString()));
                    entry.Add(new XElement("_object2to", relatedObject.NewVersion.ToUpperString()));
                }
            }
        }

        /// <summary>
        /// Saves changes of specified <see cref="IBusinessObjectRelation"/> to the operations list.
        /// </summary>
        /// <param name="relation"><see cref="IBusinessObjectRelation"/> to save.</param>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public static void SaveDictionaryRelationChanges(IBusinessObjectDictionaryRelation businessObject, XDocument document)
        {
            IVersionedBusinessObject mainObject;

            //if we are processing a relation from alternate object
            if (businessObject.Status == BusinessObjectStatus.Deleted)
            {
                mainObject = (IVersionedBusinessObject)businessObject.Parent.AlternateVersion;
                //if we delete an object in new version we dont have its old version via the new main object reference
                //so we have to grab it from the old main object
            }
            else
            {
                mainObject = (IVersionedBusinessObject)businessObject.Parent;
            }

            //mainObject now references the NEW version of the alternates

            if (mainObject.Status == BusinessObjectStatus.Unchanged && mainObject.ForceSave == false && mainObject.NewVersion == null)
            {
                businessObject.UpgradeMainObjectVersion = true;
                mainObject.NewVersion = Guid.NewGuid();
            }

            Type t = businessObject.GetType();
            DatabaseMappingCache[] classCaches = BusinessObject.ClassDatabaseMappingCache[t];

            foreach (DatabaseMappingCache classCache in classCaches) //foreach tableName
            {
                DatabaseMappingAttribute objAttribute = classCache.Attribute;

                //find or create table element
                XElement table = document.Root.Element(objAttribute.TableName);

                if (table == null)
                {
                    table = new XElement(objAttribute.TableName);
                    document.Root.Add(table);
                }

                //create new entry element
                XElement entry = new XElement("entry");
                table.Add(entry);

                if (businessObject.Status != BusinessObjectStatus.Deleted)
                {
                    BusinessObjectHelper.SaveBusinessObjectColumns(businessObject, t, objAttribute, entry, null);

                    Guid newVersion;

                    IVersionedBusinessObject versionedObject = businessObject as IVersionedBusinessObject;

                    if (versionedObject != null)
                    {
                        versionedObject.NewVersion = Guid.NewGuid();
                        newVersion = versionedObject.NewVersion.Value;
                    }
                    else
                        newVersion = Guid.NewGuid();

                    if (businessObject.Status == BusinessObjectStatus.New)
                    {
                        entry.Add(new XAttribute("action", "insert"));
                        entry.Add(new XElement("version", newVersion.ToUpperString()));
                    }
                    else //BusinessObjectStatus.Modified or child elements changed
                    {
                        entry.Add(new XAttribute("action", "update"));
                        entry.Add(new XElement("_version", newVersion.ToUpperString()));
                    }
                }
                else
                {
                    entry.Add(new XElement("id", businessObject.Id.ToUpperString()));
                    entry.Add(new XElement("version", businessObject.Version.ToUpperString()));
                    entry.Add(new XAttribute("action", "delete"));
                }

                if (businessObject.UpgradeMainObjectVersion)
                {
                    entry.Add(new XElement("_object1from", mainObject.Version.ToUpperString()));
                    entry.Add(new XElement("_object1to", mainObject.NewVersion.ToUpperString()));
                }
            }
        }

        /// <summary>
        /// Creates the related business object from XML element.
        /// </summary>
        /// <param name="element">Xml element from which to create the <see cref="IBusinessObject"/>.</param>
        /// <param name="relatedObjectType">Type of the related object.</param>
        /// <returns>Related object.</returns>
        public static IBusinessObject CreateRelatedBusinessObjectFromXmlElement(XElement element, string relatedObjectType)
        {
            return BusinessObjectHelper.CreateRelatedBusinessObjectFromXmlElement(element, (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), relatedObjectType, true));
        }

        /// <summary>
        /// Creates the related business object from XML element.
        /// </summary>
        /// <param name="element">Xml element from which to create the <see cref="IBusinessObject"/>.</param>
        /// <param name="relatedObjectType">Type of the related object.</param>
        /// <returns>Related object.</returns>
        public static IBusinessObject CreateRelatedBusinessObjectFromXmlElement(XElement element, BusinessObjectType relatedObjectType)
        {
            if (relatedObjectType == BusinessObjectType.CommercialDocumentLine)
            {
                CommercialDocumentLine line = new CommercialDocumentLine(null);
                line.Deserialize(element);
                return line;
            }
            else if (relatedObjectType == BusinessObjectType.WarehouseDocumentLine)
            {
                WarehouseDocumentLine line = new WarehouseDocumentLine(null);
                line.Deserialize(element);
                return line;
            }
            else if (relatedObjectType == BusinessObjectType.Payment)
            {
                Payment pt = new Payment(null);
                pt.Deserialize(element);
                return pt;
            }
            else
            {
                Mapper m = Mapper.GetMapperForSpecifiedBusinessObjectType(relatedObjectType);

                return m.ConvertToBusinessObject(element, null);
            }
        }

        /// <summary>
        /// Converts ICollection of one type to ICollection&lt;IBusinessObjectRelation&gt;. 
        /// </summary>
        /// <typeparam name="T">Full source collection type.</typeparam>
        /// <typeparam name="Z">Templated source collection type.</typeparam>
        /// <param name="col">Source collection</param>
        /// <returns>Converted collection</returns>
        public static ICollection<IBusinessObjectRelation> ConvertToRelation<T, Z>(T col)
            where T : ICollection<Z>
            where Z : IBusinessObjectRelation
        {
            ICollection<IBusinessObjectRelation> c = new List<IBusinessObjectRelation>();

            foreach (IBusinessObjectRelation item in col) c.Add(item);

            return c;
        }

        /// <summary>
        /// Converts ICollection of one type to ICollection&lt;IBusinessObjectDictionaryRelation&gt;. 
        /// </summary>
        /// <typeparam name="T">Full source collection type.</typeparam>
        /// <typeparam name="Z">Templated source collection type.</typeparam>
        /// <param name="col">Source collection</param>
        /// <returns>Converted collection</returns>
        public static ICollection<IBusinessObjectDictionaryRelation> ConvertToDictionaryRelation<T, Z>(T col)
            where T : ICollection<Z>
            where Z : IBusinessObjectDictionaryRelation
        {
            ICollection<IBusinessObjectDictionaryRelation> c = new List<IBusinessObjectDictionaryRelation>();

            foreach (IBusinessObjectDictionaryRelation item in col) c.Add(item);

            return c;
        }

        /// <summary>
        /// Gets the xml prepared for printing. The xml contains labels instead of foreign key id.
        /// </summary>
        /// <param name="rootElement">Object's xml to add labels and other stuff.</param>
        /// <returns>Xml prepared for printing.</returns>
		public static void GetPrintXml(XDocument xml)
		{
			BusinessObjectHelper.GetPrintXml(xml, null);
		}

        public static void GetPrintXml(XDocument xml, string customLabelsLang)
        {
            string emptyGuid = Guid.Empty.ToString();

            var foreignKeys = from node in xml.Root.Descendants()
                              where node.Name.LocalName != "id" && node.Name.LocalName.EndsWith("Id", StringComparison.Ordinal)
                              && node.Value != emptyGuid
                              select node;

            foreach (XElement element in foreignKeys)
            {
                ILabeledDictionaryBusinessObject bo = null;

                switch (element.Name.LocalName)
                {
                    case "contractorFieldId":
                        bo = DictionaryMapper.Instance.GetContractorField(new Guid(element.Value));
                        element.Add(new XAttribute("name", ((ContractorField)bo).Name));
                        break;
                    case "documentFieldId":
                        bo = DictionaryMapper.Instance.GetDocumentField(new Guid(element.Value));
                        DocumentField df = (DocumentField)bo;
                        element.Add(new XAttribute("name", df.Name));
                        //jezeli jest to id magazynu przeciwnego to dolaczamy jego label i symbol
                        if (df.Name == DocumentFieldName.ShiftDocumentAttribute_OppositeWarehouseId.ToString())
                        {
                            Warehouse whOp = DictionaryMapper.Instance.GetWarehouse(new Guid(element.Parent.Element("value").Value));
                            element.Add(new XAttribute("warehouseLabel", BusinessObjectHelper.GetBusinessObjectLabelInUserLanguage(whOp, customLabelsLang).Value));
                            element.Add(new XAttribute("warehouseSymbol", whOp.Symbol));
                        }
						//jeśli jest atrybut typu select to zamiast wartości musi się pojawić etykieta odpowiadająca tej wartości w języku usera
						if (df.DataType == DataType.Select)
						{
							XElement valueElement = element.Parent.Element(XmlName.Value);
							if (valueElement != null)
							{
								valueElement.Value = BusinessObjectHelper.GetSelectedValueInUserLanguage(df, valueElement.Value);
							}
						}
                        break;
                    case "jobPositionId":
                        bo = DictionaryMapper.Instance.GetJobPosition(new Guid(element.Value));
                        break;
                    case "countryId":
                    case "nipPrefixCountryId":
                        bo = DictionaryMapper.Instance.GetCountry(new Guid(element.Value));
                        element.Add(new XAttribute("symbol", ((Country)bo).Symbol));
                        break;
                    case "contractorRelationTypeId":
                        bo = DictionaryMapper.Instance.GetContractorRelationType(new Guid(element.Value));
                        break;
                    case "itemFieldId":
                        bo = DictionaryMapper.Instance.GetItemField(new Guid(element.Value));
                        element.Add(new XAttribute("name", ((ItemField)bo).Name));
                        break;
                    case "itemRAVTypeId":
                        bo = DictionaryMapper.Instance.GetItemRelationAttrValueType(new Guid(element.Value));
                        break;
                    case "itemRelationId":
                        bo = DictionaryMapper.Instance.GetItemRelationType(new Guid(element.Value));
                        break;
                    case "itemTypeId":
                        bo = DictionaryMapper.Instance.GetItemType(new Guid(element.Value));
                        break;
                    case "unitId":
                        bo = DictionaryMapper.Instance.GetUnit(new Guid(element.Value));
                        element.Add(new XAttribute("symbol", BusinessObjectHelper.GetBusinessObjectLabelInUserLanguage(bo, customLabelsLang).Attribute("symbol").Value));
                        break;
                    case "unitTypeId":
                        bo = DictionaryMapper.Instance.GetUnitType(new Guid(element.Value));
                        break;
                    case "vatRateId":
                        bo = DictionaryMapper.Instance.GetVatRate(new Guid(element.Value));
                        VatRate vr = (VatRate)bo;
                        element.Add(new XAttribute("fiscalSymbol", vr.FiscalSymbol));
                        element.Add(new XAttribute("symbol", vr.Symbol));
                        break;
                    case "documentCurrencyId":
                    case "systemCurrencyId":
                    case "paymentCurrencyId":
                        bo = DictionaryMapper.Instance.GetCurrency(new Guid(element.Value));
                        element.Add(new XAttribute("symbol", ((Currency)bo).Symbol));
                        break;
                    case "documentTypeId":
                        bo = DictionaryMapper.Instance.GetDocumentType(new Guid(element.Value));
                        element.Add(new XAttribute("symbol", ((DocumentType)bo).Symbol));
                        break;
                    case "issuePlaceId":
                        bo = null;
						IssuePlace issuePlace = DictionaryMapper.Instance.GetIssuePlace(new Guid(element.Value));
						if (issuePlace == null)
							throw new ArgumentNullException("issuePlaceId");
                        element.Add(new XAttribute("label", issuePlace.Name));
                        break;
                    case "paymentMethodId":
                        bo = DictionaryMapper.Instance.GetPaymentMethod(new Guid(element.Value));
                        element.Add(new XAttribute("isIncrementingDueAmount", ((PaymentMethod)bo).IsIncrementingDueAmount ? "1" : "0"));
                        break;
                    case "warehouseId":
                        bo = DictionaryMapper.Instance.GetWarehouse(new Guid(element.Value));
                        Warehouse wh = (Warehouse)bo;
                        element.Add(new XAttribute("symbol", wh.Symbol));
                        break;
                    case "financialRegisterId":
                        FinancialRegister fr = DictionaryMapper.Instance.GetFinancialRegister(new Guid(element.Value));
                        bo = fr;

                        element.Add(new XAttribute("registerCategory", ((int)fr.RegisterCategory).ToString(CultureInfo.InvariantCulture)));

						Guid systemCurrencyId = ConfigurationMapper.Instance.SystemCurrencyId;
						Currency currency = DictionaryMapper.Instance.GetCurrency(fr.CurrencyId);

						element.Add(new XAttribute("currencyId", currency.Id.ToUpperString()));
						element.Add(new XAttribute("currencySymbol", currency.Symbol));
						element.Add(new XAttribute("systemCurrencyId", systemCurrencyId.ToUpperString()));

						if (!String.IsNullOrEmpty(fr.AccountingAccount))
							element.Add(new XAttribute("accountingAccount", fr.AccountingAccount));

                        if (!String.IsNullOrEmpty(fr.BankAccountNumber))
                            element.Add(new XAttribute("bankAccountNumber", fr.BankAccountNumber));

                        break;
                    case "containerTypeId":
                        bo = DictionaryMapper.Instance.GetContainerType(new Guid(element.Value));
                        break;
                    case "servicePlaceId":
                        element.Add(new XAttribute("label", DictionaryMapper.Instance.GetServicePlace(new Guid(element.Value)).Name));
                        break;
					case "itemGroupId":
						string path = DictionaryMapper.Instance.GetItemGroupMembershipPath(element.Value);
						if (path != null)
						{
							element.Add(new XAttribute("path", path));
						}
						break;
                }

                if (bo != null)
                    element.Add(new XAttribute("label", BusinessObjectHelper.GetBusinessObjectLabelInUserLanguage(bo, customLabelsLang).Value));
            }
        }


		/// <summary>
		/// Dla danych typu select odszukujemy etykiety dla wartości w odpowiednim języku
		/// </summary>
		/// <param name="value"></param>
		/// <returns></returns>
		public static string GetSelectedValueInUserLanguage(IMetadataContainingBusinessObject bo, string valueName)
		{
			string result = String.Empty;
			if (!String.IsNullOrEmpty(valueName))
			{
				XElement valuesElement = bo.Metadata.Element(XmlName.Values);
				if (valuesElement != null)
				{
					XElement selectedValue = (from value in valuesElement.Elements(XmlName.Value)
											  where value.Element(XmlName.Name) != null && value.Element(XmlName.Name).Value == valueName
											  select value).FirstOrDefault();
					XElement labelsElement = selectedValue != null ? selectedValue.Element(XmlName.Labels) : null;
					if (labelsElement != null)
					{
						labelsElement = BusinessObjectHelper.GetXmlLabelInUserLanguage(labelsElement);
						if (labelsElement != null)
						{
							result = labelsElement.Value;
						}
					}
				}
			}
			return result;
		}

    }
}
