using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using System.Globalization;

namespace Makolab.Commons.Communication
{
    /// <summary>
    /// Encapsulates the communication package data that is transfered between branches.
    /// </summary>
    [DataContract]
    [Serializable]
    public class XmlTransferObject
    {
        /// <summary>
        /// Gets or sets the communication package id.
        /// </summary>
        /// <value>The id.</value>
        [DataMember(IsRequired = true)]
        public Guid Id { get; set; }

        /// <summary>
        /// Gets or sets the local transaction id.
        /// </summary>
        /// <value>The local transaction id.</value>
        [DataMember(IsRequired = true)]
        public Guid LocalTransactionId { get; set; }

        /// <summary>
        /// Gets or sets the deferred transaction id.
        /// </summary>
        /// <value>The deferred transaction id.</value>
        [DataMember(IsRequired = true)]
        public Guid DeferredTransactionId { get; set; }

        /// <summary>
        /// Gets or sets the type of the communication package.
        /// </summary>
        /// <value>The type of the XML.</value>
        [DataMember(IsRequired = true)]
        public string XmlType { get; set; }

        /// <summary>
        /// Gets or sets the content of the communication package.
        /// </summary>
        /// <value>The content.</value>
        [DataMember(IsRequired = true)]
        public string Content { get; set; }

        /// <summary>
        /// Returns a <see cref="T:System.String"/> that represents the current <see cref="T:System.Object"/>.
        /// </summary>
        /// <returns>
        /// A <see cref="T:System.String"/> that represents the current <see cref="T:System.Object"/>.
        /// </returns>
        public override string ToString()
        {
            string idType = typeof(Guid).Name;
            string typeType = typeof(string).Name;
            string contentType = (this.Content == null) ? typeof(string).Name : Content.GetType().Name;
            return String.Format(CultureInfo.InvariantCulture, @"<Id type='{0}'>{1}</Id><LocalTransactionId type='{2}'>{3}</LocalTransactionId>
                                    <DeferredTransactionId type='{4}'>{5}</DeferredTransactionId>
                                    <Type type='{6}'>{7}</Type><Content type='{8}'>{9}</Content>",
                                idType, Id.ToString(), idType, LocalTransactionId, idType, DeferredTransactionId,
                                typeType, XmlType, contentType, Content);
        }
    }
}
