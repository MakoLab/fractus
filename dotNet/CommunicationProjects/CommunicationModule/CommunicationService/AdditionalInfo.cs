using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using System.Globalization;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Additional data that can be contained in ISynchronizationService response.
    /// Contains data related to communication state like undelivered packages quantity.
    /// </summary>
    [DataContract]
    public class AdditionalInfo
    {
        /// <summary>
        /// Gets or sets the unsent XML quantity.
        /// </summary>
        /// <value>The unsent XML quantity.</value>
        [DataMember(IsRequired = false)]
        public int? UndeliveredPackagesQuantity { get; set; }

        /// <summary>
        /// Returns a <see cref="T:System.String"/> that represents the current <see cref="T:System.Object"/>.
        /// </summary>
        /// <returns>
        /// A <see cref="T:System.String"/> that represents the current <see cref="T:System.Object"/>.
        /// </returns>
        public override string ToString()
        {
            string undeliveredPackagesQuantityType = (UndeliveredPackagesQuantity == null) ? typeof(int?).Name : UndeliveredPackagesQuantity.GetType().Name;
            return String.Format(CultureInfo.InvariantCulture,
                "<UndeliveredPackagesQuantity type='{0}'>{1}</UndeliveredPackagesQuantity>", undeliveredPackagesQuantityType, UndeliveredPackagesQuantity);
        }
    }
}
