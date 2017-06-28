using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Contractors
{
    /// <summary>
    /// Class representing <see cref="Contractor"/>'s address.
    /// </summary>
    [XmlSerializable(XmlField = "address")]
    [DatabaseMapping(TableName = "contractorAddress")]
    public class ContractorAddress : BusinessObject, IOrderable
    {
        /// <summary>
        /// Object order in the database and in xml node list.
        /// </summary>
        [XmlSerializable(XmlField = "order")]
        [Comparable]
        [DatabaseMapping(ColumnName = "order")]
        public int Order { get; set; }

        /// <summary>
        /// Gets or sets address' description id.
        /// </summary>
        [XmlSerializable(XmlField = "contractorFieldId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "contractorFieldId")]
        public Guid ContractorFieldId { get; set; }

        /// <summary>
        /// Gets or sets complete address. (street)
        /// </summary>
        [XmlSerializable(XmlField = "address")]
        [Comparable]
        [DatabaseMapping(ColumnName = "address")]
        public string Address { get; set; }

		/// <summary>
		/// Gets or sets address number.
		/// </summary>
		[XmlSerializable(XmlField = "addressNumber")]
		[Comparable]
		[DatabaseMapping(ColumnName = "addressNumber")]
		public string AddressNumber { get; set; }

		/// <summary>
		/// Gets or sets flat number.
		/// </summary>
		[XmlSerializable(XmlField = "flatNumber")]
		[Comparable]
		[DatabaseMapping(ColumnName = "flatNumber")]
		public string FlatNumber { get; set; }

        /// <summary>
        /// Gets or sets city. Cannot be null or <see cref="String.Empty"/>.
        /// </summary>
        ///
        [XmlSerializable(XmlField = "city")]
        [Comparable]
        [DatabaseMapping(ColumnName = "city")]
        public string City { get; set; }

        /// <summary>
        /// Gets or sets post code. Cannot be null or <see cref="String.Empty"/>.
        /// </summary>
        [XmlSerializable(XmlField = "postCode")]
        [Comparable]
        [DatabaseMapping(ColumnName = "postCode")]
        public string PostCode { get; set; }

        /// <summary>
        /// Gets or sets post office. Cannot be null or <see cref="String.Empty"/>.
        /// </summary>
        [XmlSerializable(XmlField = "postOffice")]
        [Comparable]
        [DatabaseMapping(ColumnName = "postOffice")]
        public string PostOffice { get; set; }

        /// <summary>
        /// Gets or sets country's id.
        /// </summary>
        [XmlSerializable(XmlField = "countryId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "countryId")]
        public Guid CountryId { get; set; }

        [DatabaseMapping(ColumnName = "contractorId")]
        public Guid ContractorId { get { return this.Parent.Id.Value; } } //for save object reflection purposes

        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorAddress"/> class with a specified xml root element.
        /// </summary>
        /// <param name="parent">Parent <see cref="Contractor"/>.</param>
        public ContractorAddress(Contractor parent)
            : base(parent)
        {
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.ContractorFieldId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:contractorFieldId");

            if(String.IsNullOrEmpty(this.Address) && String.IsNullOrEmpty(this.City) && String.IsNullOrEmpty(this.PostCode) &&
                String.IsNullOrEmpty(this.PostOffice))
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:address");

            if (this.CountryId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:countryId");
        }

        public bool IsDefaultAddress()
        {
            return this.ContractorFieldId == DictionaryMapper.Instance.GetContractorField(ContractorFieldName.Address_Default).Id.Value;
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
            if (this.Id == null)
                this.GenerateId();

            if (this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
            {
                //BusinessObjectHelper.SaveBusinessObjectChanges(this, document, "contractorAddress", "contractorId", null, null);
                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, null, null);
            }
        }
    }
}
