using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using System.Globalization;
using Makolab.Commons.Communication;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Encapsulates the response for GetData method call of <see cref="ISynchronizationService"/>.
    /// </summary>
    [DataContract]
    public class GetDataResponse
    {
        private static GetDataResponse nullObject = new GetDataResponse() { AdditionalData = new AdditionalInfo() { UndeliveredPackagesQuantity = 0 } };
        private static GetDataResponse exceptionObject = new GetDataResponse();

        /// <summary>
        /// Gets the empty response.
        /// </summary>
        /// <value>The empty response.</value>
        public static GetDataResponse EmptyResponse
        {
            get { return nullObject; }
        }

        /// <summary>
        /// Gets the empty response.
        /// </summary>
        /// <value>The empty response.</value>
        public static GetDataResponse ExceptionResponse
        {
            get { return exceptionObject; }
        }

        /// <summary>
        /// Gets or sets the communication package data.
        /// </summary>
        /// <value>The communication package data.</value>
        [DataMember(IsRequired = false)]
        public XmlTransferObject XmlData { get; set; }

        /// <summary>
        /// Gets or sets the additional data like undelivered packages quantity.
        /// </summary>
        /// <value>The additional data.</value>
        [DataMember(IsRequired = false)]
        public AdditionalInfo AdditionalData { get; set; }

        /// <summary>
        /// Gets or sets the database identifier
        /// </summary>
        /// <value>The database id.</value>
        [DataMember(IsRequired = false)]
        public Guid? DatabaseId { get; set; }

        /// <summary>
        /// Returns a <see cref="T:System.String"/> that represents the current <see cref="T:System.Object"/>.
        /// </summary>
        /// <returns>
        /// A <see cref="T:System.String"/> that represents the current <see cref="T:System.Object"/>.
        /// </returns>
        public override string ToString()
        {
            string xmlDataType = (XmlData == null) ? typeof(XmlTransferObject).Name : XmlData.GetType().Name;
            string additionalDataType = (AdditionalData == null) ? typeof(AdditionalInfo).Name : AdditionalData.GetType().Name;
            return String.Format(CultureInfo.InvariantCulture,
                "<XmlData type='{0}'>{1}</XmlData><AdditionalData type='{2}'>{3}</AdditionalData><DatabaseId type='{4}'>{5}</DatabaseId>", xmlDataType, XmlData, additionalDataType, AdditionalData, DatabaseId);
        }
    }
}
