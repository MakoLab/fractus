using System;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects.Service;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using System.Collections.Generic;
using Makolab.Fractus.Commons.Collections;

namespace Makolab.Fractus.Kernel.Mappers
{
    public class ServiceMapper : Mapper
    {
		#region Supported types

		private static BidiDictionary<BusinessObjectType, Type> cachedSupportedBusinessObjectTypes;

		private static BidiDictionary<BusinessObjectType, Type> CachedSupportedBusinessObjectTypes
		{
			get
			{
				if (cachedSupportedBusinessObjectTypes == null)
				{
					cachedSupportedBusinessObjectTypes = new BidiDictionary<BusinessObjectType, Type>()
					{
						{ BusinessObjectType.ServicedObject, typeof(ServicedObject) },
					};
				}
				return cachedSupportedBusinessObjectTypes;
			}
		}

		public override BidiDictionary<BusinessObjectType, Type> SupportedBusinessObjectsTypes
		{
			get { return ServiceMapper.CachedSupportedBusinessObjectTypes; }
		}

		#endregion
		
		public override void CheckBusinessObjectVersion(IBusinessObject obj)
        {
            if (!obj.IsNew)
            {
                this.ExecuteStoredProcedure(StoredProcedure.service_p_checkServicedObjectVersion,
                        false, "@version", obj.Version);
            }
        }

        public override IBusinessObject CreateNewBusinessObject(BusinessObjectType type, XDocument requestXml)
        {
            IBusinessObject bo = null;

            switch (type)
            {
                case BusinessObjectType.ServicedObject:
                    bo = new ServicedObject();
                    break;
                default:
                    throw new InvalidOperationException("ServiceMapper cannot create such object.");
            }

            bo.GenerateId();
            return bo;
        }

        public override IBusinessObject LoadBusinessObject(BusinessObjectType type, Guid id)
        {
            XDocument xdoc = this.ExecuteStoredProcedure(StoredProcedure.service_p_getServicedObjectData, true, "@servicedObjectId", id);

            if (xdoc.Root.Element("servicedObject").Elements().Count() == 0)
                throw new ClientException(ClientExceptionId.ObjectNotFound);

            xdoc = this.ConvertDBToBoXmlFormat(xdoc, id);

            return this.ConvertToBusinessObject(xdoc.Root.Element("servicedObject"), null);
        }

        public override void CreateCommunicationXml(IBusinessObject obj)
        {
        }

        public override void CreateCommunicationXml(XDocument operations)
        {
        }

        public override XDocument ConvertDBToBoXmlFormat(XDocument xml, Guid id)
        {
            XDocument xdoc = XDocument.Parse("<root><servicedObject type=\"ServicedObject\"></servicedObject></root>");

            var so = xml.Root.Element("servicedObject").Elements().Where(e => e.Element("id").Value == id.ToUpperString()).First();
            xdoc.Root.Element("servicedObject").Add(so.Elements());
            return xdoc;
        }

        public override void UpdateDictionaryIndex(IBusinessObject obj)
        {
        }
    }
}
