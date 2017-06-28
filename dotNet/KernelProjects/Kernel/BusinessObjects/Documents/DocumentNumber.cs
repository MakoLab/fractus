using System;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    /// <summary>
    /// Class that represents <see cref="Document"/>'s number.
    /// </summary>
    [XmlSerializable(XmlField = "number")]
    internal class DocumentNumber : BusinessObject
    {
        /// <summary>
        /// Gets or sets document number.
        /// </summary>
        [XmlSerializable(XmlField = "number")]
        public int Number { get; set; }

        [XmlSerializable(XmlField = "SkipAutonumbering", UseAttribute = true)]
        public bool SkipAutonumbering { get; set; }

        /// <summary>
        /// Gets or sets full number of the document.
        /// </summary>
		[Comparable]
        [XmlSerializable(XmlField = "fullNumber")]
        public string FullNumber { get; set; }

        /// <summary>
        /// Gets or sets the number setting id.
        /// </summary>
        [XmlSerializable(XmlField = "numberSettingId")]
        public Guid NumberSettingId { get; set; }

        /// <summary>
        /// Gets or sets the document series id.
        /// </summary>
        [XmlSerializable(XmlField = "seriesId")]
        public Guid? SeriesId { get; set; }

        /// <summary>
        /// Gets or sets the computed series value.
        /// </summary>
        public string ComputedSeriesValue { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="DocumentNumber"/> class.
        /// </summary>
        /// <param name="document">Owner document.</param>
        public DocumentNumber(BusinessObject document)
            : base(document)
        {
            this.Id = null;
        }

		/// <summary>
		/// Checks if the object has changed against <see cref="BusinessObject.AlternateVersion"/> and updates its own <see cref="BusinessObject.Status"/>.
		/// </summary>
		/// <param name="isNew">Value indicating whether the <see cref="BusinessObject"/> should be considered as the new one or the old one.</param>
		public override void UpdateStatus(bool isNew)
		{
			base.UpdateStatus(isNew);
			base.UpdateParentStatus();
		}

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.Parent.IsNew)
            {
                if (this.NumberSettingId == Guid.Empty)
                    throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:numberSettingId");
            }
        }

        /// <summary>
        /// Validates the <see cref="BusinessObject"/>.
        /// </summary>
        public override void Validate()
        {
            base.Validate();

            if (this.SeriesId != null && this.AlternateVersion != null && this.AlternateVersion.Status == BusinessObjectStatus.Modified)
                throw new ClientException(ClientExceptionId.DocumentNumberChangeException);
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
			XElement ownerDocument = (from node in document.Root.Descendants("entry")
									  where node.Element("id").Value == this.Parent.Id.ToUpperString() && node.Parent.Name.LocalName != "serviceHeader"
									  select node).ElementAt(0);
			
			if (this.Parent.Status == BusinessObjectStatus.Modified || this.Parent.Status == BusinessObjectStatus.New && this.SkipAutonumbering)
			{
				ownerDocument.Add(new XElement("number", this.Number));
				ownerDocument.Add(new XElement("fullNumber", this.FullNumber));
			}
			
			if (this.Parent.Status == BusinessObjectStatus.New)
            {
				if (!this.SkipAutonumbering)
                {
                    ownerDocument.Add(new XElement("fullNumber", this.FullNumber));
                    ownerDocument.Add(new XElement("seriesValue", this.ComputedSeriesValue));
					ownerDocument.Add(new XElement("numberSettingId", this.NumberSettingId.ToUpperString()));
				}

                if (this.Parent.BOType == BusinessObjectType.WarehouseDocument && ((WarehouseDocument)this.Parent).WarehouseDirection == WarehouseDirection.IncomeShift)
                {
                    ownerDocument.Add(new XElement("number", this.Number));

                    if (this.SeriesId != null)
                        ownerDocument.Add(new XElement("seriesId", this.SeriesId.ToUpperString()));
                }
            }
        }
    }
}
