namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Text;
    using System.Xml.Serialization;
    using System.Runtime.Serialization;
    using System.Security.Permissions;

    /// <summary>
    /// Serializable dictionary collection.
    /// </summary>
    [Serializable]
    [XmlRoot("dictionary")]
    public class SerializableStringDictionary : Dictionary<string, string>, IXmlSerializable
    {
        /// <summary>
        /// Name of root dictionary element.
        /// </summary>
        private string rootName;

        /// <summary>
        /// Name of key attribute.
        /// </summary>
        private string keyName;

        /// <summary>
        /// Name of value attribute.
        /// </summary>
        private string valueName;

        #region Contructors
        /// <summary>
        /// Initializes a new instance of the <see cref="SerializableStringDictionary"/> class.
        /// </summary>
        public SerializableStringDictionary() : this("entry", "key", "value") { }

        /// <summary>
        /// Initializes a new instance of the <see cref="SerializableStringDictionary"/> class.
        /// </summary>
        /// <param name="rootName">Name of the root element.</param>
        /// <param name="keyName">Name of the key attribute.</param>
        /// <param name="valueName">Name of the value attribute.</param>
        /// <exception cref="ArgumentNullException"><i>rootName</i> or <i>keyName</i> or <i>valueName</i> is null reference.</exception>
        public SerializableStringDictionary(string rootName, string keyName, string valueName)
        {
            if (String.IsNullOrEmpty(rootName)) throw new ArgumentNullException("rootName");

            if (String.IsNullOrEmpty(keyName)) throw new ArgumentNullException("keyName");

            if (String.IsNullOrEmpty(valueName)) throw new ArgumentNullException("valueName");

            this.rootName = rootName;
            this.keyName = keyName;
            this.valueName = valueName;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="SerializableStringDictionary"/> class.
        /// </summary>
        /// <param name="info">A <see cref="T:System.Runtime.Serialization.SerializationInfo"/> object containing the information required to serialize the <see cref="T:System.Collections.Generic.Dictionary`2"/>.</param>
        /// <param name="context">A <see cref="T:System.Runtime.Serialization.StreamingContext"/> structure containing the source and destination of the serialized stream associated with the <see cref="T:System.Collections.Generic.Dictionary`2"/>.</param>
        protected SerializableStringDictionary(SerializationInfo info, StreamingContext context)
            : base(info, context) 
        {
        }
        #endregion

        #region IXmlSerializable Members

        /// <summary>
        /// This method is reserved and should not be used. When implementing the IXmlSerializable interface, you should return null (Nothing in Visual Basic) from this method, and instead, if specifying a custom schema is required, apply the <see cref="T:System.Xml.Serialization.XmlSchemaProviderAttribute"/> to the class.
        /// </summary>
        /// <returns>
        /// An <see cref="T:System.Xml.Schema.XmlSchema"/> that describes the XML representation of the object that is produced by the <see cref="M:System.Xml.Serialization.IXmlSerializable.WriteXml(System.Xml.XmlWriter)"/> method and consumed by the <see cref="M:System.Xml.Serialization.IXmlSerializable.ReadXml(System.Xml.XmlReader)"/> method.
        /// </returns>
        public System.Xml.Schema.XmlSchema GetSchema()
        {
            return null;
        }

        /// <summary>
        /// Fills dictionary from its XML representation.
        /// </summary>
        /// <param name="reader">The <see cref="T:System.Xml.XmlReader"/> stream from which the object is deserialized.</param>
        public void ReadXml(System.Xml.XmlReader reader)
        {
            bool wasEmpty = reader.IsEmptyElement;
            reader.Read();

            if (wasEmpty) return;

            while (reader.NodeType != System.Xml.XmlNodeType.EndElement)
            {
                reader.MoveToAttribute(0);
                string key = reader.Value;
                reader.MoveToAttribute(1);
                string value = reader.Value;
                reader.MoveToElement();
                this.Add(key, value);
                reader.Read();
            }

            reader.ReadEndElement();
        }

        /// <summary>
        /// Converts an object into its XML representation.
        /// </summary>
        /// <param name="writer">The <see cref="T:System.Xml.XmlWriter"/> stream to which the object is serialized.</param>
        public void WriteXml(System.Xml.XmlWriter writer)
        {
            foreach (string key in this.Keys)
            {
                writer.WriteStartElement(this.rootName);
                writer.WriteAttributeString(this.keyName, key);
                string value = this[key];
                writer.WriteAttributeString(this.valueName, value);
                writer.WriteEndElement();
            }
        }
        #endregion

        /// <summary>
        /// Implements the <see cref="T:System.Runtime.Serialization.ISerializable"/> interface and returns the data needed to serialize the <see cref="T:System.Collections.Generic.Dictionary`2"/> instance.
        /// </summary>
        /// <param name="info">A <see cref="T:System.Runtime.Serialization.SerializationInfo"/> object that contains the information required to serialize the <see cref="T:System.Collections.Generic.Dictionary`2"/> instance.</param>
        /// <param name="context">A <see cref="T:System.Runtime.Serialization.StreamingContext"/> structure that contains the source and destination of the serialized stream associated with the <see cref="T:System.Collections.Generic.Dictionary`2"/> instance.</param>
        /// <exception cref="T:System.ArgumentNullException">
        /// 	<paramref name="info"/> is null.</exception>
        [SecurityPermission(SecurityAction.LinkDemand, Flags = SecurityPermissionFlag.SerializationFormatter)]
        public override void GetObjectData(SerializationInfo info, StreamingContext context)
        {
            base.GetObjectData(info, context);
        }
    }
}
