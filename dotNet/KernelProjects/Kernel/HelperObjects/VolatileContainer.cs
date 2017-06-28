using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.MethodInputParameters;

namespace Makolab.Fractus.Kernel.HelperObjects
{
    /// <summary>
    /// Class that contains elements that will be reset on every client request.
    /// </summary>
    public class VolatileContainer
    {
        /// <summary>
        /// Gets or sets the value indicating whether the current client request have checked dictionaries for changes.
        /// </summary>
        public bool IsDictionaryCheckPassed 
		{ get; set; }

        /// <summary>
        /// Gets or sets the value indicating whether the current client request have checked dictionaries for changes having been in a database transaction.
        /// </summary>
        public bool IsDictionaryCheckPassedDuringTransaction { get; set; }

        /// <summary>
        /// Gets or sets the transaction repeat counter that indicates how many times main transaction was rollbacked and repeated.
        /// </summary>
        public int TransactionRepeatCounter { get; set; }

        /// <summary>
        /// Gets or sets the current date time. The field is automatically got from database server.
        /// </summary>
        public DateTime CurrentDateTime { get; private set; }

        public XDocument ClientRequest { get; set; }

		public string ClientCommand { get; set; }

        public Guid? LocalTransactionId { get; set; }
        public Guid? DeferredTransactionId { get; set; }

        public bool WasOperationLogged { get; set; }
        private List<SimpleDocument> savedObjects;

        //parametry na potrzeby faktury do paragonu
        internal CommercialDocument SourceDocument { get; set; }
        internal CommercialDocument LastCorrectiveDocument { get; set; }

        /// <summary>
        /// Gets or sets the dictionary containing mapping from itemId to its itemTypeId.
        /// </summary>
        public IDictionary<Guid, Guid> ItemTypesCache { get; set; }

		public bool WasExceptionThrown { get; set; }

		private List<string> warnings = new List<string>();
		
		/// <summary>
		/// Gets List of warnings through current request
		/// </summary>
		public List<string> Warnings { get { return this.warnings; } }

		/// <summary>
		/// Checks if container has warings recorded
		/// </summary>
		public bool HasWarnings { get { return this.Warnings != null && this.Warnings.Count != 0; } }

		/// Initializes a new instance of the <see cref="VolatileContainer"/> class.
        /// </summary>
        public VolatileContainer()
        {
            this.savedObjects = new List<SimpleDocument>();
            this.CurrentDateTime = Mapper.GetDateTimeFromDatabase();
        }

		/// <summary>
		/// Creates xml element that contains warnings and should be added to result xml returned to the client
		/// </summary>
		/// <returns>Xml element to append to result XML</returns>
		internal XElement WarningsToXmlElement()
		{
			XElement warningsElement = new XElement("warnings");
			foreach (string warning in this.Warnings)
			{
				warningsElement.Add(new XElement("warning", warning));
			}
			return warningsElement;
		}

		internal XElement GetSavedDocuments(Guid mainDocumentId)
        {
            XElement relatedDocuments = new XElement("relatedDocuments");

            foreach (Document doc in this.savedObjects)
            {
                if (doc.Id.Value != mainDocumentId)
                {
                    relatedDocuments.Add(new XElement("id", doc.Id.ToUpperString(), new XAttribute("documentTypeId", doc.DocumentTypeId.ToUpperString())));
                }
            }

            return relatedDocuments;
        }

        internal void AddSavedDocument(SimpleDocument document)
        {
            if (document == null) return;

            if (this.savedObjects.Where(d => d.Id.Value == document.Id.Value).FirstOrDefault() == null)
                this.savedObjects.Add(document);
        }

		internal bool SavedInThisTransaction(Guid id)
		{
			return this.savedObjects.Where(d => d.Id.Value == id).FirstOrDefault() != null;
		}
    }
}
