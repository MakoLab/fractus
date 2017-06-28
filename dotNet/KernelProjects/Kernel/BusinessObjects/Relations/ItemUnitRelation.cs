using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.Items;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;

namespace Makolab.Fractus.Kernel.BusinessObjects.Relations
{
    /// <summary>
    /// Class representing relation between an item and an unit.
    /// </summary>
    [XmlSerializable(XmlField = "unitRelation")]
    [DatabaseMapping(TableName = "itemUnitRelation")]
    public class ItemUnitRelation : BusinessObject, IBusinessObjectDictionaryRelation
    {
        /// <summary>
        /// Gets or sets a flag that forces the <see cref="BusinessObject"/> to save changes even if no changes has been made.
        /// </summary>
        public bool ForceSave { get; set; }

        /// <summary>
        /// Gets or sets <see cref="BusinessObject"/>'s new version number.
        /// </summary>
        public Guid? NewVersion { get; set; }

        /// <summary>
        /// Gets or sets a flag indicating whether to upgrade version of the main <see cref="BusinessObject"/>.
        /// </summary>
        public bool UpgradeMainObjectVersion { get; set; }

        /// <summary>
        /// Gets or sets <see cref="Unit"/>'s id.
        /// </summary>
        [XmlSerializable(XmlField = "unitId")]
        [Comparable]
        [DatabaseMapping(ColumnName = "unitId")]
        public Guid RelatedDictionaryObjectId { get; set; }

        /// <summary>
        /// Gets or sets precision.
        /// </summary>
        [XmlSerializable(XmlField = "precision")]
        [Comparable]
        [DatabaseMapping(ColumnName = "precision")]
        public decimal Precision { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="ItemUnitRelation"/> class with a specified xml root element.
        /// </summary>
        /// <param name="parent">Parent <see cref="Item"/>.</param>
        public ItemUnitRelation(Item parent)
            : base(parent)
        {
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
            if (this.RelatedDictionaryObjectId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:unitId");
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
                BusinessObjectHelper.SaveDictionaryRelationChanges(this, document);
            }
        }
    }
}
