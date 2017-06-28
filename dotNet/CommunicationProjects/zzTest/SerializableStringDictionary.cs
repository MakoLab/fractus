using System;
using System.Collections.Generic;
using System.Text;
using System.Xml.Serialization;

namespace zzTest
{

    [XmlRoot("dictionary")]
    public class SerializableStringDictionary : Dictionary<string, string>, IXmlSerializable
    {
        private string rootName;
        private string keyName;
        private string valueName;

        public SerializableStringDictionary() : this("entry", "key", "value") {  }

        public SerializableStringDictionary(string rootName, string keyName, string valueName)
        {
            if (String.IsNullOrEmpty(rootName))
                throw new ArgumentNullException("rootName");
            if (String.IsNullOrEmpty(rootName))
                throw new ArgumentNullException("keyName");
            if (String.IsNullOrEmpty(rootName))
                throw new ArgumentNullException("valueName");

            this.rootName = rootName;
            this.keyName = keyName;
            this.valueName = valueName;
        }

        #region IXmlSerializable Members

        public System.Xml.Schema.XmlSchema GetSchema()
        {
            return null;
        }

        public void ReadXml(System.Xml.XmlReader reader)
        {
            bool wasEmpty = reader.IsEmptyElement;
            reader.Read();

            if (wasEmpty)
                return;

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

        public void WriteXml(System.Xml.XmlWriter writer)
        {
            foreach (string key in this.Keys)
            {
                writer.WriteStartElement(rootName);
                writer.WriteAttributeString(keyName, key);
                string value = this[key];
                writer.WriteAttributeString(valueName, value);
                writer.WriteEndElement();
            }
        }
        #endregion
    }
}
