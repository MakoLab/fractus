using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using System.Linq;
using System;
using Makolab.Fractus.Kernel.Enums;
using System.Collections.Generic;

namespace Makolab.Fractus.Kernel.BusinessObjects.Relations
{
    internal class DocumentRelations : BusinessObjectsContainer<DocumentRelation>
    {
        public DocumentRelations(Document parent)
            : base(parent, "relation")
        {
        }

        public override DocumentRelation CreateNew()
        {
            DocumentRelation relation = new DocumentRelation((Document)this.Parent);
            this.Children.Add(relation);
            return relation;
        }

		public Document GetRelatedDocument(Guid id)
		{
			DocumentRelation docRelation = this.Children.Where(rel => rel.RelatedDocument.Id == id).FirstOrDefault();
			return docRelation != null ? docRelation.RelatedDocument : null;
		}

		public IEnumerable<Document> GetRelatedDocuments(DocumentRelationType relationType)
		{
			return this.Children.Where(rel => rel.RelationType == relationType).Select(rel => rel.RelatedDocument);
		}

		public bool HasRelations(DocumentRelationType relationType)
		{
			return this.Children.Any(rel => rel.RelationType == relationType);
		}
    }
}
