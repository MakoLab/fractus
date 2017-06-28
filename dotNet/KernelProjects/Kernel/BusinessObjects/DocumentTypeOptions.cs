using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using System.Xml.Linq;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.BusinessObjects
{
	internal abstract class DocumentTypeOptions
	{
		private DocumentType documentType;

		protected abstract string OptionsRootElementName { get; }

		protected XElement OptionsRootElement { get { return this.documentType.Options.Element(this.OptionsRootElementName); } }

		protected DocumentTypeOptions(DocumentType documentType)
		{
            this.documentType = documentType;
		}

		/// <summary>
		/// Gets the collection of document features id that the document can contain.
		/// </summary>
		public XElement DocumentFeatures
		{
			get
			{
				return this.OptionsRootElement.Element("documentFeatures");
			}
		}

		public bool UpdateLastPurchasePrice
		{
			get
			{
				string value = this.OptionsRootElement.GetAtributeValueOrNull("updateLastPurchasePrice");
				return Convert.ToBoolean(value ?? "false");
			}
		}
	}
}
