using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using System.Globalization;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Encapsulates the response for SendData method call of <see cref="ISynchronizationService"/>.
    /// </summary>
    [DataContract]
    public class SendDataResponse
    {
        /// <summary>
        /// Gets or sets a value indicating data transfer result.
        /// </summary>
        /// <value><c>true</c> if data is correctly received; otherwise, <c>false</c>.</value>
        [DataMember(IsRequired = true)]
        public bool Result { get; set; }

        /// <summary>
        /// Gets or sets the additional data like undelivered packages quantity.
        /// </summary>
        /// <value>The additional data.</value>
        [DataMember(IsRequired = false)]
        public AdditionalInfo AdditionalData { get; set; }

        /// <summary>
        /// Returns a <see cref="T:System.String"/> that represents the current <see cref="T:System.Object"/>.
        /// </summary>
        /// <returns>
        /// A <see cref="T:System.String"/> that represents the current <see cref="T:System.Object"/>.
        /// </returns>
        public override string ToString()
        {
            string resultType = typeof(bool).Name;
            string additionalDataType = (AdditionalData == null) ? typeof(AdditionalInfo).Name : AdditionalData.GetType().Name;
            return String.Format(CultureInfo.InvariantCulture, 
                "<Result type='{0}'>{1}</Result><AdditionalData type='{2}'>{3}</AdditionalData>", resultType, Result, additionalDataType, AdditionalData);
        }
    }
}
