using System.Collections.Generic;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.Managers;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents
{
    /// <summary>
    /// Class representing <see cref="Document"/>'s attribute.
    /// </summary>
    [XmlSerializable(XmlField = "attribute")]
    [DatabaseMapping(TableName = "documentAttrValue")]
    internal class DocumentAttrValue : AbstractDocAttrValue
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="DocumentAttrValue"/> class with a specified xml root element.
        /// </summary>
        /// <param name="parent">Parent <see cref="Document"/>.</param>
        public DocumentAttrValue(Document parent)
            : base(parent)
        {
        }

		/// <summary>
		/// Recursively creates new children (BusinessObjects) and loads settings from provided xml.
		/// </summary>
		/// <param name="element">Xml element to attach.</param>
		public override void Deserialize(XElement element)
		{
			base.Deserialize(element);
			#region Add current datetime for booldate attributes with '?' value
			if (this.Value == null || System.String.IsNullOrEmpty(this.Value.Value) || this.Value.Value == "?")
			{
				DocumentField df = DictionaryMapper.Instance.GetDocumentField(this.DocumentFieldId);
				if (df.DataType == DataType.BoolDate)
				{
					this.Value.Value = SessionManager.VolatileElements.CurrentDateTime.ToIsoString();
				}
			}
			#endregion
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

                Dictionary<string, object> forcedToSave = new Dictionary<string, object>();

                forcedToSave.Add(this.Parent.ParentIdColumnName, this.Parent.Id.ToUpperString());

                BusinessObjectHelper.SaveBusinessObjectChanges(this, document, forcedToSave, field.Metadata.Element("dataType").Value);
            }
        }
    }
}
