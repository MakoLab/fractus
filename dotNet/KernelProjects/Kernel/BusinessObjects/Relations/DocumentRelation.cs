using System.Collections.Generic;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Managers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Relations
{
    [XmlSerializable(XmlField = "relation")]
    [DatabaseMapping(TableName = "documentRelation")]
    internal class DocumentRelation : BusinessObject
    {
        [XmlSerializable(XmlField = "relationType")]
        [Comparable]
        [DatabaseMapping(ColumnName = "relationType")]
        public DocumentRelationType RelationType { get; set; }

        [XmlSerializable(XmlField = "relatedDocument", AutoDeserialization = false)]
        [Comparable]
        public Document RelatedDocument { get; set; }

        [XmlSerializable(XmlField = "decimalValue")]
        [Comparable]
        [DatabaseMapping(ColumnName = "decimalValue")]
        public decimal? DecimalValue { get; set; }

        public bool DontSave { get; set; }

        public DocumentRelation(Document parent)
            : base(parent, BusinessObjectType.DocumentRelation)
        {
        }

        public override void ValidateConsistency()
        {
            if (this.RelatedDocument == null)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:relatedDocument");
        }

        public override void Deserialize(XElement element)
        {
            base.Deserialize(element);

            this.RelatedDocument = DocumentRelationManager.DeserializeRelatedDocument(this, (XElement)element.Element("relatedDocument").FirstNode);
        }

        public override void SaveChanges(XDocument document)
        {
            if (this.DontSave) return;

            if (this.Id == null)
                this.GenerateId();

            if (this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
            {
                Dictionary<string, object> forcedToSave = new Dictionary<string, object>();

                string parentColumnName = null;
                string relatedDocumentColumnName = null;

                DocumentRelationManager.GetColumnNames(this, ref parentColumnName, ref relatedDocumentColumnName);
                forcedToSave.Add(parentColumnName, this.Parent.Id.ToUpperString());
                forcedToSave.Add(relatedDocumentColumnName, this.RelatedDocument.Id.ToUpperString());

                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, forcedToSave, null);
            }
        }
    }
}
