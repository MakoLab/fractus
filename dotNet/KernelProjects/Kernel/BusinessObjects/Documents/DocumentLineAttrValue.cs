using System.Collections.Generic;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    /// <summary>
    /// Class representing <see cref="Document"/>'s attribute.
    /// </summary>
    [XmlSerializable(XmlField = "attribute")]
    [DatabaseMapping(TableName = "documentLineAttrValue")]
    internal class DocumentLineAttrValue : AbstractDocAttrValue
    {
        [XmlSerializable(XmlField = "label")]
        public string Label { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="DocumentAttrValue"/> class with a specified xml root element.
        /// </summary>
        /// <param name="parent">Parent <see cref="Document"/>.</param>
        public DocumentLineAttrValue(BusinessObject parent)
            : base(parent)
        {
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
                DocumentField field = DictionaryMapper.Instance.GetDocumentField(this.DocumentFieldId);

                string parentIdColumnName = null;

                if (this.Parent.BOType == BusinessObjectType.CommercialDocumentLine)
                    parentIdColumnName = "commercialDocumentLineId";
                else if (this.Parent.BOType == BusinessObjectType.WarehouseDocumentLine)
                    parentIdColumnName = "warehouseDocumentLineId";
                
                Dictionary<string, object> forcedToSave = new Dictionary<string, object>();

                forcedToSave.Add(parentIdColumnName, this.Parent.Id.ToUpperString());

                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, forcedToSave, field.Metadata.Element("dataType").Value);
            }
        }
    }
}
