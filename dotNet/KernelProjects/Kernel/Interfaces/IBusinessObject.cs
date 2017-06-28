using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.Interfaces
{
    /// <summary>
    /// Provides the capabilities for an object to be a <see cref="BusinessObject"/>.
    /// </summary>
    public interface IBusinessObject
    {
        /// <summary>
        /// Gets <see cref="BusinessObject"/>'s Id.
        /// </summary>
        Guid? Id { get; }

        /// <summary>
        /// Gets or sets a value indicating the status of the <see cref="BusinessObject"/>.
        /// </summary>
        BusinessObjectStatus Status { get; set; }

        /// <summary>
        /// Gets or sets the alternate version of the <see cref="BusinessObject"/>. For new BO it references to itd old version and for the old BO version it references to its new BO version.
        /// </summary>
        IBusinessObject AlternateVersion { get; set; }

        /// <summary>
        /// Gets or sets <see cref="BusinessObject"/>'s version number.
        /// </summary>
        Guid? Version { get; set; }

        /// <summary>
        /// Gets parent <see cref="IBusinessObject"/>.
        /// </summary>
        IBusinessObject Parent { get; set; }

		/// <summary>
		/// Gets parent id column name -- TODO implement everywhere
		/// </summary>
		string ParentIdColumnName { get; }

        /// <summary>
        /// Gets the xml that object operates on.
        /// </summary>
        XDocument FullXml { get; }

        /// <summary>
        /// Gets the type of the <see cref="BusinessObject"/>.
        /// </summary>
        BusinessObjectType BOType { get; }

        bool IsNew { get; }

        /// <summary>
        /// Validates the <see cref="BusinessObject"/>.
        /// </summary>
        void Validate();

        /// <summary>
        /// Recursively creates new children (BusinessObjects) and loads settings from provided xml.
        /// </summary>
        /// <param name="element">Xml element to attach.</param>
        void Deserialize(XElement element);

        /// <summary>
        /// Sets the alternate version of the <see cref="BusinessObject"/>.
        /// </summary>
        /// <param name="alternate"><see cref="BusinessObject"/> that is to be considered as the alternate one.</param>
        void SetAlternateVersion(IBusinessObject alternate);

        /// <summary>
        /// Checks if the object has changed against <see cref="AlternateVersion"/> and updates its own <see cref="Status"/>.
        /// </summary>
        /// <param name="isNew">Value indicating whether the <see cref="BusinessObject"/> should be considered as the new one or the old one.</param>
        void UpdateStatus(bool isNew);

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        void SaveChanges(XDocument document);

        /// <summary>
        /// Generates new object's Id
        /// </summary>
        void GenerateId();

        XElement Serialize();
        XElement Serialize(bool selfOnly);
    }
}
