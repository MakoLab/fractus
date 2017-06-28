using System;
using System.Collections.Generic;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.ObjectFactories;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents.Options
{
    internal class RealizeOrderOption : IDocumentOption
    {
        public RealizeOrderOption()
        {
        }

        public void Execute(Document document)
        {
            if (document.IsBeforeSystemStart)
                return;

            if (document.Source != null && 
                (document.Source.Attribute("type").Value == "order" || document.CheckSourceType(SourceType.SalesOrderRealization)))
            {
                DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();
                CommercialDocument order = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, new Guid(document.Source.Attribute("commercialDocumentId").Value));

                List<WarehouseDocument> warehouses = new List<WarehouseDocument>();
                warehouses.Add((WarehouseDocument)document);

                CommercialWarehouseDocumentFactory.RelateWarehousesLinesToOrderLines(warehouses, order, document.Source, true, false);

                /*if (SalesOrderFactory.TryCloseSalesOrder(order))
                    document.AddRelatedObject(order);*/
            }
            else if (document.Source != null && document.Source.Attribute("type").Value == "multipleReservations")
            {
                DocumentMapper mapper = DependencyContainerManager.Container.Get<DocumentMapper>();
                List<CommercialDocument> reservations = new List<CommercialDocument>();

                foreach (var orderXml in document.Source.Elements())
                {
                    CommercialDocument order = (CommercialDocument)mapper.LoadBusinessObject(BusinessObjectType.CommercialDocument, new Guid(orderXml.Value));
                    reservations.Add(order);
                }

                List<WarehouseDocument> warehouses = new List<WarehouseDocument>();
                warehouses.Add((WarehouseDocument)document);

                CommercialWarehouseDocumentFactory.RelateWarehousesLinesToMultipleOrdersLines(warehouses, reservations, true, false);
            }
        }

        public XElement Serialize()
        {
            XElement element = new XElement("realizeOrder", new XAttribute("selected", "1"));
            return element;
        }

		public bool ExecuteWithinTransaction
		{
			get { return false; }
		}
	}
}
