using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;
using System.Xml.Linq;
using System.Globalization;
using System.IO;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Factory that is responsible for creating communication packages from specified data.
    /// </summary>
    public class FractusPackageFactory : ICommunicationPackageFactory
    {
        #region ICommunicationPackageFactory Members

        /// <summary>
        /// Creates the communication package..
        /// </summary>
        /// <param name="data">The object with communication package data.</param>
        /// <returns>Created communication package.</returns>
        public ICommunicationPackage CreatePackage(object data)
        {
                CommunicationPackage package = null;

                XElement xml = data as XElement;
                if (xml == null) throw new ArgumentException("Invalid object type", "data");

                XmlTransferObject xmlData = new XmlTransferObject();
                xmlData.Id = new Guid(xml.Element("id").Value);
                xmlData.LocalTransactionId = new Guid(xml.Element("localTransactionId").Value);
                xmlData.DeferredTransactionId = new Guid(xml.Element("deferredTransactionId").Value);
                xmlData.Content = xml.Element("xml").FirstNode.ToString(SaveOptions.DisableFormatting);

                try
                {
                    xmlData.XmlType = xml.Element("type").Value;
                }
                catch (ArgumentException)
                {
                    xmlData.XmlType = "Unknown";
                }

                package = new CommunicationPackage(xmlData);

                package.OrderNumber = Int32.Parse(xml.Element("order").Value, CultureInfo.InvariantCulture);

                XElement databaseId = xml.Element("databaseId");
                if (databaseId == null) throw new InvalidDataException("DatabaseId cannot be null");
                package.DatabaseId = new Guid(databaseId.Value);

                return package;            
        }

        /// <summary>
        /// Creates the communication package from <see cref="XmlTransferObject"/> object.
        /// </summary>
        /// <param name="data">The <see cref="XmlTransferObject"/> with communication package data.</param>
        /// <returns>
        /// Communication package created from <see cref="XmlTransferObject"/> object.
        /// </returns>
        public ICommunicationPackage CreatePackage(XmlTransferObject data)
        {
            return new CommunicationPackage(data);
        }

        #endregion
    }
}
