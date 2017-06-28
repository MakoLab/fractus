using System;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.BusinessObjects
{
    /// <summary>
    /// Collection of business objects used to massive operations.
    /// </summary>
    /// <typeparam name="T">Type of the IBusinessObject.</typeparam>
    internal class MassiveBusinessObjectCollection<T> : BusinessObjectsContainer<T> where T : class, IVersionedBusinessObject
    {
        /// <summary>
        /// <see cref="BusinessObjectType"/> of the children objects.
        /// </summary>
        private BusinessObjectType type;

        /// <summary>
        /// <see cref="BusinessObjectType"/> of the children objects.
        /// </summary>
        public BusinessObjectType Type
        { get { return this.type; } }

        /// <summary>
        /// Initializes a new instance of the <see cref="MassiveBusinessObjectCollection&lt;T&gt;"/> class.
        /// </summary>
        public MassiveBusinessObjectCollection()
            : base(null, typeof(T).Name.Decapitalize())
        {
            this.type = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), typeof(T).Name, true);
        }

        /// <summary>
        /// Creates new child according to the contractor's defaults and attaches it to the parent <see cref="BusinessObject"/>.
        /// </summary>
        /// <returns>A new child.</returns>
        public override T CreateNew()
        {
            T newObj = (T)Mapper.GetMapperForSpecifiedBusinessObjectType(this.Type).CreateNewBusinessObject(this.Type, null);
            this.Children.Add(newObj);
            return newObj;
        }
    }
}
