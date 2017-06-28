using System;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Commons.Collections;

namespace Makolab.Fractus.Kernel.Mappers
{
    /// <summary>
    /// Mapper class that contains method that are used in security context.
    /// </summary>
    public class SecurityMapper : Mapper
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="SecurityMapper"/> class.
        /// </summary>
        public SecurityMapper()
        {
        }

        /// <summary>
        /// Gets the application user data in database xml format.
        /// </summary>
        /// <param name="login">User's login.</param>
        /// <returns>Application user data in database xml format.</returns>
        public XDocument GetApplicationUserData(string login)
        {
            return this.ExecuteStoredProcedure(StoredProcedure.contractor_p_getApplicationUser, true, "@login", login);
        }

        /// <summary>
        /// Checks whether <see cref="IBusinessObject"/> version in database hasn't changed against current version.
        /// </summary>
        /// <param name="obj">The <see cref="IBusinessObject"/> containing its version to check.</param>
        public override void CheckBusinessObjectVersion(IBusinessObject obj)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Creates a <see cref="BusinessObject"/> of a selected type.
        /// </summary>
        /// <param name="type">The type of <see cref="IBusinessObject"/> to create.</param>
        /// <param name="requestXml">Client requestXml containing initial parameters for the object.</param>
        /// <returns>A new <see cref="IBusinessObject"/>.</returns>
        public override IBusinessObject CreateNewBusinessObject(BusinessObjectType type, XDocument requestXml)
        {
            throw new NotImplementedException();
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
            throw new NotImplementedException();
        }

        /// <summary>
        /// Creates communication xml for the specified <see cref="IBusinessObject"/> and his children.
        /// </summary>
        /// <param name="obj">Main <see cref="IBusinessObject"/>.</param>
        public override void CreateCommunicationXml(IBusinessObject obj)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Converts Xml in database format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Xml to convert.</param>
        /// <param name="id">Id of the main <see cref="BusinessObject"/>.</param>
        /// <returns>Converted xml.</returns>
        public override XDocument ConvertDBToBoXmlFormat(XDocument xml, Guid id)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Updates <see cref="IBusinessObject"/> dictionary index in the database.
        /// </summary>
        /// <param name="obj"><see cref="IBusinessObject"/> for which to update the index.</param>
        public override void UpdateDictionaryIndex(IBusinessObject obj)
        {
            throw new NotImplementedException();
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
