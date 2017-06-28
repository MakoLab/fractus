using System;
using System.Collections.Generic;
using System.Reflection;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.ReflectionCache;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects
{
    /// <summary>
    /// Base class for all business objects. Contains basic fields and methods that every <see cref="BusinessObject"/> needs.
    /// </summary>
    public abstract class BusinessObject : IBusinessObject
    {
        public static Dictionary<Type, XmlSerializationCache[]> PropertiesXmlSerializationCache = new Dictionary<Type, XmlSerializationCache[]>();
        public static Dictionary<Type, DatabaseMappingCache[]> PropertiesDatabaseMappingCache = new Dictionary<Type, DatabaseMappingCache[]>();
        public static Dictionary<Type, ComparableCache[]> PropertiesComparableCache = new Dictionary<Type, ComparableCache[]>();
        public static Dictionary<Type, XmlSerializationCache> ClassXmlSerializationCache = new Dictionary<Type, XmlSerializationCache>();
        public static Dictionary<Type, DatabaseMappingCache[]> ClassDatabaseMappingCache = new Dictionary<Type, DatabaseMappingCache[]>();
        public static Dictionary<Type, bool> IsClassCached = new Dictionary<Type, bool>();

        /// <summary>
        /// Gets or sets a value indicating the status of the <see cref="BusinessObject"/> test.
        /// </summary>
        public BusinessObjectStatus Status { get; set; }

        /// <summary>
        /// Gets the xml that object operates on.
        /// </summary>
        public virtual XDocument FullXml
        {
            get
            {
                XDocument xdoc = XDocument.Parse("<root/>");
                xdoc.Root.Add(new XAttribute("dictionaryVersion", DictionaryMapper.Instance.DictionariesVersion));
                xdoc.Root.Add(this.Serialize());
                return xdoc;
            }
        }

        /// <summary>
        /// Gets or sets <see cref="BusinessObject"/>'s Id.
        /// </summary>
        [XmlSerializable(XmlField = "id")]
        [Comparable]
        [DatabaseMapping(ColumnName = "id")]
        public Guid? Id { get; set; }

		/// <summary>
		/// Gets or sets origin system id for imported documents//TODO mapping
		/// </summary>
		public Guid? OriginId { get; set; }

        /// <summary>
        /// Gets or sets <see cref="BusinessObject"/>'s version number.
        /// </summary>
        [XmlSerializable(XmlField = "version")]
        [DatabaseMapping(ColumnName = "version")]
        public Guid? Version { get; set; }

        /// <summary>
        /// Gets or sets parent <see cref="BusinessObject"/>.
        /// </summary>
        public IBusinessObject Parent { get; set; }
		
		/// <summary>
		/// 
		/// </summary>
		public virtual string ParentIdColumnName { get { return null; } } 

        /// <summary>
        /// Gets the type of the <see cref="BusinessObject"/>.
        /// </summary>
        public BusinessObjectType BOType { get; protected set; }

        /// <summary>
        /// Gets or sets the alternate version of the <see cref="BusinessObject"/>. For new BO it references to itd old version and for the old BO version it references to its new BO version.
        /// </summary>
        public IBusinessObject AlternateVersion { get; set; }

        public bool IsNew { get { return this.Version == null; } }

        /// <summary>
        /// Initializes a new instance of the <see cref="BusinessObject"/> class with a specified xml root element.
        /// </summary>
        /// <param name="rootElement">Root element that the object is to be attached to.</param>
        /// <param name="parent">Parent <see cref="BusinessObject"/>.</param>
        protected BusinessObject(BusinessObject parent)
            : this(parent, BusinessObjectType.Other)
        {
        }

        public static void CacheAllClasses()
        {
			Assembly assembly = Assembly.GetAssembly(typeof(BusinessObject));
            Type[] types = assembly.GetTypes();
			
			foreach (Type t in types)
            {
                if (t.Namespace != null && 
                    (t.Namespace.StartsWith("Makolab.Fractus.Kernel.BusinessObjects", StringComparison.Ordinal)
					|| t.Namespace.StartsWith("Makolab.Fractus.Kernel.MethodInputParameters", StringComparison.Ordinal) 
						&& t.Name.Equals("ItemInfo", StringComparison.Ordinal)))
                {
                    BusinessObject.CacheClass(t);
                }
            }
		}

        private static void CacheClass(Type t)
        {
            if (!BusinessObject.IsClassCached.ContainsKey(t))
            {
                bool isObjectToCache = false;

                // get the class attributes
                object[] obj = t.GetCustomAttributes(typeof(XmlSerializableAttribute), true);

                if (obj != null && obj.Length == 1)
                {
                    XmlSerializableAttribute attr = (XmlSerializableAttribute)obj[0];
                    BusinessObject.ClassXmlSerializationCache.Add(t, new XmlSerializationCache() { Attribute = attr });
                    isObjectToCache = true;
                }

                obj = t.GetCustomAttributes(typeof(DatabaseMappingAttribute), true);

                if (obj != null && obj.Length > 0)
                {
                    DatabaseMappingCache[] cache = new DatabaseMappingCache[obj.Length];

                    for (int i = 0; i < obj.Length; i++)
                    {
                        DatabaseMappingAttribute attr = (DatabaseMappingAttribute)obj[i];
                        cache[i] = new DatabaseMappingCache() { Attribute = attr };
                    }

                    BusinessObject.ClassDatabaseMappingCache.Add(t, cache);
                    isObjectToCache = true;
                }

                if (isObjectToCache)
                {
                    //get properties XmlSerializableAttribiute
                    LinkedList<XmlSerializationCache> xmlSerializableCacheList = new LinkedList<XmlSerializationCache>();

                    foreach (PropertyInfo propertyInfo in t.GetProperties())
                    {
                        obj = propertyInfo.GetCustomAttributes(typeof(XmlSerializableAttribute), true);

                        if (obj != null && obj.Length == 1)
                        {
                            XmlSerializableAttribute attr = (XmlSerializableAttribute)obj[0];
                            XmlSerializationCache cache = new XmlSerializationCache() { Attribute = attr, Property = propertyInfo };

                            if (attr.ProcessLast)
                                xmlSerializableCacheList.AddLast(cache);
                            else
                                xmlSerializableCacheList.AddFirst(cache);
                        }
                    }

                    XmlSerializationCache[] xmlCache = new XmlSerializationCache[xmlSerializableCacheList.Count];

                    int u = 0;

                    foreach (XmlSerializationCache c in xmlSerializableCacheList)
                    {
                        xmlCache[u++] = c;
                    }

                    BusinessObject.PropertiesXmlSerializationCache.Add(t, xmlCache);

                    //get properties ComparableAttribiute
                    List<ComparableCache> comparableCacheList = new List<ComparableCache>();

                    foreach (PropertyInfo propertyInfo in t.GetProperties())
                    {
                        obj = propertyInfo.GetCustomAttributes(typeof(ComparableAttribute), true);

                        if (obj != null && obj.Length == 1)
                        {
                            ComparableAttribute attr = (ComparableAttribute)obj[0];
                            ComparableCache cache = new ComparableCache() { Attribute = attr, Property = propertyInfo };
                            comparableCacheList.Add(cache);
                        }
                    }

                    BusinessObject.PropertiesComparableCache.Add(t, comparableCacheList.ToArray());

                    //get properties DatabaseMappingCache
                    List<DatabaseMappingCache> databaseMappingCacheList = new List<DatabaseMappingCache>();

                    foreach (PropertyInfo propertyInfo in t.GetProperties())
                    {
                        obj = propertyInfo.GetCustomAttributes(typeof(DatabaseMappingAttribute), true);

                        if (obj != null && obj.Length > 0)
                        {
                            foreach (object objAttr in obj)
                            {
                                DatabaseMappingAttribute attr = (DatabaseMappingAttribute)objAttr;
                                DatabaseMappingCache cache = new DatabaseMappingCache() { Attribute = attr, Property = propertyInfo };
                                databaseMappingCacheList.Add(cache);
                            }
                        }
                    }

                    BusinessObject.PropertiesDatabaseMappingCache.Add(t, databaseMappingCacheList.ToArray());

                    BusinessObject.IsClassCached.Add(t, true);
                }
            }
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="BusinessObject"/> class with a specified xml root element.
        /// </summary>
        /// <param name="parent">Parent <see cref="BusinessObject"/>.</param>
        /// <param name="boType">Type of <see cref="BusinessObject"/>.</param>
        protected BusinessObject(BusinessObject parent, BusinessObjectType boType)
        {
            this.Parent = parent;
            this.BOType = boType;

            if (this.Id == null)
                this.GenerateId();
        }

        /// <summary>
        /// Sets the alternate version of the <see cref="BusinessObject"/>.
        /// </summary>
        /// <param name="alternate"><see cref="BusinessObject"/> that is to be considered as the alternate one.</param>
        public virtual void SetAlternateVersion(IBusinessObject alternate)
        {
            this.AlternateVersion = alternate;
            
            if (alternate != null)
                alternate.AlternateVersion = this;
        }

        /// <summary>
        /// Generates new object's Id
        /// </summary>
        public void GenerateId()
        {
            this.Id = Guid.NewGuid();
        }

        /// <summary>
        /// Recursively creates new children (BusinessObjects) and loads settings from provided xml.
        /// </summary>
        /// <param name="element">Xml element to attach.</param>
        public virtual void Deserialize(XElement element)
        {
            Type t = this.GetType();

			if (!BusinessObject.PropertiesXmlSerializationCache.ContainsKey(t))
			{
				BusinessObject.CacheClass(t);
			}

            XmlSerializationCache[] cache = BusinessObject.PropertiesXmlSerializationCache[t];

            for (int i = 0; i < cache.Length; i++)
            {
                XmlSerializationCache c = cache[i];

                if (c.Attribute.AutoDeserialization)
                {
                    BusinessObjectHelper.DeserializeSingleValue(this, c.Property, c.Attribute, element);
                }
            }
        }

        public XElement Serialize()
        {
            return this.Serialize(false);
        }

        public virtual XElement Serialize(bool selfOnly)
        {
            XElement returnVal = null;

            Type t = this.GetType();

            if (BusinessObject.ClassXmlSerializationCache.ContainsKey(t))
            {
                XmlSerializationCache classCache = BusinessObject.ClassXmlSerializationCache[t];

                returnVal = new XElement(classCache.Attribute.XmlField);

                if (this.BOType != BusinessObjectType.Other)
                    returnVal.Add(new XAttribute("type", this.BOType.ToString()));

                XmlSerializationCache[] cache = BusinessObject.PropertiesXmlSerializationCache[t];

                for (int i = 0; i < cache.Length; i++)
                {
                    XmlSerializationCache c = cache[i];

                    object propertyValue = c.Property.GetValue(this, null);

                    if (propertyValue != null)
                    {
                        XObject element = BusinessObjectHelper.SerializeSingleValue(c.Property.PropertyType, 
                            c.Attribute.XmlField, 
                            propertyValue, 
                            false, 
                            c.Attribute.UseAttribute,
                            c.Attribute.SelfOnlySerialization, selfOnly);

                        if (String.IsNullOrEmpty(c.Attribute.EncapsulatingXmlField))
                            returnVal.Add(element);
                        else
                        {
                            if (returnVal.Element(c.Attribute.EncapsulatingXmlField) != null)
                                returnVal.Element(c.Attribute.EncapsulatingXmlField).Add(element);
                            else
                                returnVal.Add(new XElement(c.Attribute.EncapsulatingXmlField, element));
                        }
                    }
                }
            }

            return returnVal;
        }

        private bool IsEqualTo(IBusinessObject businessObject)
        {
            Type t = this.GetType();

            ComparableCache[] cache = BusinessObject.PropertiesComparableCache[t];

            for (int i = 0; i < cache.Length; i++)
            {
                ComparableCache c = cache[i];

                object ourValue = c.Property.GetValue(this, null);
                object otherValue = c.Property.GetValue(businessObject, null);

                Type type = c.Property.PropertyType;

                if (type == typeof(Boolean))
                {
                    if ((Boolean)ourValue != (Boolean)otherValue) 
                        return false;
                }
                else if (type == typeof(String))
                {
                    if (String.Compare((string)ourValue, (string)otherValue, StringComparison.Ordinal) != 0) 
                        return false;
                }
                else if (type == typeof(Decimal))
                {
                    if (!((decimal)ourValue).Equals((decimal)otherValue)) 
                        return false;
                }
                else if (type == typeof(Decimal?))
                {
                    Decimal? ourDecimal = (Decimal?)ourValue;
                    Decimal? otherDecimal = (Decimal?)otherValue;

                    if (ourDecimal != null && otherDecimal == null ||
                        ourDecimal == null && otherDecimal != null)
                        return false;

                    if (ourDecimal != null && otherDecimal != null &&
                        ourDecimal.Value != otherDecimal.Value) 
                        return false;
                }
                else if (type == typeof(Int32))
                {
                    if (!((int)ourValue).Equals((int)otherValue)) 
                        return false;
                }
                else if (type == typeof(Int32?))
                {
                    Int32? ourInt = (Int32?)ourValue;
                    Int32? otherInt = (Int32?)otherValue;

                    if (ourInt != null && otherInt == null ||
                        ourInt == null && otherInt != null)
                        return false;

                    if (ourInt != null && otherInt != null &&
                        ourInt.Value != otherInt.Value)
                        return false;
                }
                else if (type == typeof(Guid))
                {
                    if ((Guid)ourValue != (Guid)otherValue)
                        return false;
                }
                else if (type == typeof(Guid?))
                {
                    Guid? ourGuid = (Guid?)ourValue;
                    Guid? otherGuid = (Guid?)otherValue;

                    if (ourGuid != null && otherGuid == null ||
                        ourGuid == null && otherGuid != null)
                        return false;

                    if (ourGuid != null && otherGuid != null &&
                        ourGuid.Value != otherGuid.Value)
                        return false;
                }
                else if (type == typeof(DateTime))
                {
                    if ((DateTime)ourValue != ((DateTime)otherValue))
                        return false;
                }
                else if (type == typeof(DateTime?))
                {
                    DateTime? ourDateTime = (DateTime?)ourValue;
                    DateTime? otherDateTime = (DateTime?)otherValue;

                    if (ourDateTime != null && otherDateTime == null ||
                        ourDateTime == null && otherDateTime != null)
                        return false;

                    if (ourDateTime != null && otherDateTime != null &&
                        ourDateTime.Value != otherDateTime.Value)
                        return false;
                }
                else if (type == typeof(XElement))
                {
                    XElement ourXElement = (XElement)ourValue;
                    XElement otherXElement = (XElement)otherValue;

                    if (ourXElement != null && otherXElement == null ||
                        ourXElement == null && otherXElement != null)
                        return false;

                    if (ourXElement != null && otherXElement != null &&
                        ourXElement.ToString() != otherXElement.ToString())
                        return false;
                }
                else if (typeof(IBusinessObject).IsAssignableFrom(type))
                {
                    IBusinessObject ourObject = (IBusinessObject)ourValue;
                    IBusinessObject otherObject = (IBusinessObject)otherValue;

                    if (ourObject != null && otherObject == null ||
                        ourObject == null && otherObject != null)
                        return false;

                    if (ourObject != null && otherObject != null &&
                        ourObject.Id.Value != otherObject.Id.Value)
                        return false;
                }
                else if (type.IsEnum)
                {
                    if ((int)ourValue != (int)otherValue)
                        return false;
                }
                else
                    throw new InvalidOperationException("Unknown type to compare");
            }

            return true;
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public abstract void ValidateConsistency();

        /// <summary>
        /// Validates the <see cref="BusinessObject"/>.
        /// </summary>
        public virtual void Validate()
        {
            this.ValidateConsistency();
        }

        /// <summary>
        /// Checks if the object has changed against <see cref="BusinessObject.AlternateVersion"/> and updates its own <see cref="BusinessObject.Status"/>.
        /// </summary>
        /// <param name="isNew">Value indicating whether the <see cref="BusinessObject"/> should be considered as the new one or the old one.</param>
        public virtual void UpdateStatus(bool isNew)
        {
            if (this.AlternateVersion == null) //object is new or deleted
            {
                if (isNew)
                    this.Status = BusinessObjectStatus.New;
                else
                    this.Status = BusinessObjectStatus.Deleted;
            }
            else //object can be modified or unchanged
            {
                bool isDifferent = !this.IsEqualTo(this.AlternateVersion);

                if (isNew)
                {
                    if (isDifferent)
                        this.Status = BusinessObjectStatus.Modified;
                    else
                        this.Status = BusinessObjectStatus.Unchanged;
                }

                //!isNew can be skipped because from old version we only have to know what was deleted
            }
        }

		/// <summary>
		/// Updates parent status if object status is modified
		/// </summary>
		public virtual void UpdateParentStatus()
		{
			if (this.Status == BusinessObjectStatus.Modified && this.Parent.Status != BusinessObjectStatus.Modified)
			{
				this.Parent.Status = BusinessObjectStatus.Modified;
			}
		}

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public abstract void SaveChanges(XDocument document);
    }
}
