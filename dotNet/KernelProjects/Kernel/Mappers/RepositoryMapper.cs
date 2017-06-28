using System;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.BusinessObjects.Repository;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Commons.Collections;

namespace Makolab.Fractus.Kernel.Mappers
{
    /// <summary>
    /// Class representing a mapper with methods necessary to operate on file repository.
    /// </summary>
    public class RepositoryMapper : Mapper
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="RepositoryMapper"/> class.
        /// </summary>
        public RepositoryMapper()
            : base()
        {}

        /// <summary>
        /// Checks whether <see cref="IBusinessObject"/> version in database hasn't changed against current version.
        /// </summary>
        /// <param name="obj">The <see cref="IBusinessObject"/> containing its version to check.</param>
        public override void CheckBusinessObjectVersion(IBusinessObject obj)
        {
            if (!obj.IsNew)
            {
                this.ExecuteStoredProcedure(StoredProcedure.repository_p_checkFileDescriptorVersion,
                        false, "@version", obj.Version);
            }
        }

        /// <summary>
        /// Creates a <see cref="BusinessObject"/> of a selected type.
        /// </summary>
        /// <param name="type">The type of <see cref="IBusinessObject"/> to create.</param>
        /// <param name="requestXml">Client requestXml containing initial parameters for the object.</param>
        /// <returns>A new <see cref="IBusinessObject"/>.</returns>
        public override IBusinessObject CreateNewBusinessObject(BusinessObjectType type, XDocument requestXml)
        {
            IBusinessObject bo = null;

            switch (type)
            {
                case BusinessObjectType.FileDescriptor:
                    bo = this.CreateNewFileDescriptor();
                    break;
                default:
                    throw new InvalidOperationException("RepositoryMapper can only create fileDescriptors.");
            }

            bo.GenerateId();
            return bo;
        }

        /// <summary>
        /// Creates a new <see cref="FileDescriptor"/>.
        /// </summary>
        /// <returns>A new <see cref="FileDescriptor"/>.</returns>
        private FileDescriptor CreateNewFileDescriptor()
        {
            FileDescriptor fd = new FileDescriptor(null);
            return fd;
        }

        /// <summary>
        /// Loads the <see cref="BusinessObject"/> with a specified Id.
        /// </summary>
        /// <param name="type">Type of <see cref="BusinessObject"/> to load.</param>
        /// <param name="id"><see cref="IBusinessObject"/>'s id indicating which <see cref="BusinessObject"/> to load.</param>
        /// <returns>
        /// Loaded <see cref="IBusinessObject"/> object.
        /// </returns>
        public override IBusinessObject LoadBusinessObject(BusinessObjectType type, Guid id)
        {
            XDocument xdoc = this.ExecuteStoredProcedure(StoredProcedure.repository_p_getFileDescriptor, true, "@id", id);

            if (xdoc.Root.Element("fileDescriptor").Elements().Count() == 0)
                throw new ClientException(ClientExceptionId.ObjectNotFound);

            xdoc = this.ConvertDBToBoXmlFormat(xdoc, id);

            return this.ConvertToBusinessObject(xdoc.Root.Element("fileDescriptor"), null);
        }

        /// <summary>
        /// Creates communication xml for the specified <see cref="IBusinessObject"/> and his children.
        /// </summary>
        /// <param name="obj">Main <see cref="IBusinessObject"/>.</param>
        public override void CreateCommunicationXml(IBusinessObject obj)
        {
            this.CreateCommunicationXmlForVersionedBusinessObject((IVersionedBusinessObject)obj, SessionManager.VolatileElements.LocalTransactionId.Value,
                SessionManager.VolatileElements.DeferredTransactionId.Value, StoredProcedure.communication_p_createFileDescriptorPackage);
        }

        /// <summary>
        /// Converts Xml in database format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Xml to convert.</param>
        /// <param name="id">Id of the main <see cref="BusinessObject"/>.</param>
        /// <returns>Converted xml.</returns>
        public override XDocument ConvertDBToBoXmlFormat(XDocument xml, Guid id)
        {
            XDocument convertedXml = XDocument.Parse("<root><fileDescriptor type=\"FileDescriptor\" /></root>");

            var fd = from node in xml.Root.Element("fileDescriptor").Elements()
                     where node.Element("id").Value == id.ToUpperString()
                     select node;

            if (fd.Count() == 1)
                convertedXml.Root.Element("fileDescriptor").Add(fd.ElementAt(0).Elements());

            if (convertedXml.Root.Element("fileDescriptor").Attribute("type") == null)
            {
                convertedXml.Root.Element("fileDescriptor").Add(new XAttribute("type", "FileDescriptor"));
            }

            return convertedXml;
        }

        /// <summary>
        /// Updates <see cref="IBusinessObject"/> dictionary index in the database.
        /// </summary>
        /// <param name="obj"><see cref="IBusinessObject"/> for which to update the index.</param>
        public override void UpdateDictionaryIndex(IBusinessObject obj)
        {
            //throw new NotImplementedException();
        }

        /// <summary>
        /// Deletes business object.
        /// </summary>
        /// <param name="type">Type of <see cref="BusinessObject"/> to delete.</param>
        /// <param name="id">Id of the object to delete.</param>
        public override void DeleteBusinessObject(BusinessObjectType type, Guid id)
        {
            if (type == BusinessObjectType.FileDescriptor)
                this.ExecuteStoredProcedure(StoredProcedure.repository_p_deleteFileDescriptor, false, "@id", id);
        }

        /// <summary>
        /// Creates communication xml for objects that are in the xml operations list.
        /// </summary>
        /// <param name="operations"></param>
        public override void CreateCommunicationXml(XDocument operations)
        {
            throw new NotImplementedException();
        }

		public override BidiDictionary<BusinessObjectType, Type> SupportedBusinessObjectsTypes
		{
			get { throw new NotImplementedException(); }
		}
	}
}
