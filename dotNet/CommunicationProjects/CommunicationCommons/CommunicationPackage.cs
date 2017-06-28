using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using System.Xml;
using System.IO;
using ICSharpCode.SharpZipLib.Zip;
using System.Xml.Linq;
using System.Globalization;

namespace Makolab.Commons.Communication
{
    /// <summary>
    /// 
    /// </summary>
    [Serializable]
    public class CommunicationPackage : ICommunicationPackage
    {
        #region Constructors
        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationPackage"/> class.
        /// </summary>
        /// <param name="xmlPackage">The XML package.</param>
        public CommunicationPackage(XElement xmlPackage)
        {
            XmlData = new XmlTransferObject();
            XmlData.Id = new Guid(xmlPackage.Element("id").Value);
            XmlData.LocalTransactionId = new Guid(xmlPackage.Element("localTransactionId").Value);
            XmlData.DeferredTransactionId = new Guid(xmlPackage.Element("deferredTransactionId").Value);
            XmlData.XmlType = xmlPackage.Element("type").Value;
            XmlData.Content = xmlPackage.Element("xml").FirstNode.ToString(SaveOptions.DisableFormatting);
            OrderNumber = Int32.Parse(xmlPackage.Element("order").Value, CultureInfo.InvariantCulture);

            XElement departmentId = xmlPackage.Element("departmentId");
            if (departmentId != null) DatabaseId = new Guid(departmentId.Value);
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="CommunicationPackage"/> class from <see cref="XmlTransferObject"/> object.
        /// </summary>
        /// <param name="data">The data.</param>
        public CommunicationPackage(XmlTransferObject data)
        {
            XmlData = data;
        } 
        #endregion

        /// <summary>
        /// Gets or sets the syntax exception.
        /// </summary>
        /// <value>The syntax exception.</value>
        public virtual Exception SyntaxException { get; private set; }

        #region ICommunicationPackage Members

        /// <summary>
        /// Gets or sets the XML data.
        /// </summary>
        /// <value>The XML data.</value>
        public XmlTransferObject XmlData { get; set; }

        /// <summary>
        /// Gets or sets the database identifier.
        /// </summary>
        /// <value>The database id.</value>
        public Guid? DatabaseId { get; set; }

        /// <summary>
        /// Gets or sets the communication package order number.
        /// </summary>
        /// <value>The order number.</value>
        public int OrderNumber { get; set; }

        /// <summary>
        /// Gets or sets the package execution time in seconds.
        /// </summary>
        /// <value>The package execution time.</value>
        public double ExecutionTime { get; set; }

        /// <summary>
        /// Compresses communication package.
        /// </summary>
        public virtual void Compress()
        {
            if (String.IsNullOrEmpty(this.XmlData.Content) == true)
                return;

            byte[] inputByteArray = Encoding.UTF8.GetBytes(this.XmlData.Content);
            using (MemoryStream compressesStream = new MemoryStream())
            using (ZipOutputStream zipOut = new ZipOutputStream(compressesStream))
            {
                ZipEntry entry = new ZipEntry("ZippedXML");

                zipOut.PutNextEntry(entry);
                zipOut.SetLevel(9);
                zipOut.Write(inputByteArray, 0, inputByteArray.Length);
                zipOut.Finish();
                zipOut.Close();

                this.XmlData.Content = Convert.ToBase64String(compressesStream.ToArray());
            }
        }

        /// <summary>
        /// Decompresses communication package.
        /// </summary>
        public virtual void Decompress()
        {
            if (String.IsNullOrEmpty(this.XmlData.Content) == true)
                return;

            byte[] inputByteArray = Convert.FromBase64String(this.XmlData.Content);
            using (MemoryStream compressedStream = new MemoryStream(inputByteArray))
            using (MemoryStream result = new MemoryStream())
            using (ZipInputStream zipInput = new ZipInputStream(compressedStream))
            {
                zipInput.GetNextEntry();
                Byte[] buffer = new Byte[2048];
                int size = 2048;
                while (true)
                {
                    size = zipInput.Read(buffer, 0, buffer.Length);
                    if (size > 0)
                    {
                        result.Write(buffer, 0, size);
                    }
                    else break;
                }

                this.XmlData.Content = Encoding.UTF8.GetString(result.ToArray());
            }
        }

        /// <summary>
        /// Checks the syntax of communication package.
        /// </summary>
        /// <returns>
        /// 	<c>true</c> if communication package is valid; otherwise, <c>false</c>.
        /// </returns>
        public virtual bool CheckSyntax()
        {
            bool isValid = false;
            XmlDocument xmlDoc = new XmlDocument();
            try
            {
                xmlDoc.LoadXml(this.XmlData.Content);
                isValid = true;
            }
            catch (XmlException e) 
            {
                SyntaxException = e;
            }

            return isValid;
        }

        #endregion

        #region ICloneable Members

        /// <summary>
        /// Creates a new object that is a copy of the current instance.
        /// </summary>
        /// <returns>
        /// A new object that is a copy of this instance.
        /// </returns>
        public object Clone()
        {
            CommunicationPackage clone = new CommunicationPackage(new XmlTransferObject());
            clone.XmlData.Content = this.XmlData.Content;
            clone.XmlData.DeferredTransactionId = this.XmlData.DeferredTransactionId;
            clone.XmlData.Id = this.XmlData.Id;
            clone.XmlData.LocalTransactionId = this.XmlData.LocalTransactionId;
            clone.XmlData.XmlType = this.XmlData.XmlType;
            clone.DatabaseId = this.DatabaseId;
            clone.OrderNumber = this.OrderNumber;
            return clone;
        }

        #endregion
    }
}
