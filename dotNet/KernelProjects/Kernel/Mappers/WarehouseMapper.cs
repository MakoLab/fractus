using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Commons.Collections;

namespace Makolab.Fractus.Kernel.Mappers
{
    internal class WarehouseMapper : Mapper
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
						{ BusinessObjectType.ShiftTransaction, typeof(ShiftTransaction) },
						{ BusinessObjectType.Container, typeof(Container) },
					};
				}
				return cachedSupportedBusinessObjectTypes;
			}
		}

		public override BidiDictionary<BusinessObjectType, Type> SupportedBusinessObjectsTypes
		{
			get { return WarehouseMapper.CachedSupportedBusinessObjectTypes; }
		}

		#endregion
		
		public override void CheckBusinessObjectVersion(IBusinessObject obj)
        {
        }

        public override IBusinessObject CreateNewBusinessObject(BusinessObjectType type, XDocument requestXml)
        {
            IBusinessObject bo = null;

            switch (type)
            {
                case BusinessObjectType.ShiftTransaction:
                    bo = new ShiftTransaction(null);
                    break;
                case BusinessObjectType.Container:
                    bo = new Container(null);
                    break;
                default:
                    throw new InvalidOperationException("WarehouseMapper cannot create this type of objects.");
            }

            bo.GenerateId();
            return bo;
        }

        internal ShiftTransaction CreateShiftTransactionFromCommercialShiftTransaction(ShiftTransaction transaction)
        {
            ShiftTransaction st = new ShiftTransaction(null);
            st.ReasonId = transaction.ReasonId;
            st.Status = transaction.Status;

            return st;
        }

        internal XElement GetShiftsById(ICollection<Guid> idCollection)
        {
            XDocument xml = XDocument.Parse("<root/>");

            foreach (Guid id in idCollection)
                xml.Root.Add(new XElement("id", id.ToUpperString()));

            xml = this.ExecuteStoredProcedure(StoredProcedure.warehouse_p_getShiftsById, true, xml);

            return xml.Root;
        }

        internal ShiftTransaction GetShiftForWarehouseDocument(Guid warehouseDocumentHeaderId)
        {
            XDocument xdoc = this.ExecuteStoredProcedure(StoredProcedure.warehouse_p_getShiftForWarehouseDocument, true, "@warehouseDocumentHeaderId", warehouseDocumentHeaderId);

            if (!xdoc.Root.Element("shiftTransaction").HasElements) return null;

            xdoc = this.ConvertDBToBoXmlFormat(xdoc, new Guid(xdoc.Root.Element("shiftTransaction").Element("entry").Element("id").Value));

            return (ShiftTransaction)this.ConvertToBusinessObject(xdoc.Root.Element("shiftTransaction"), null);
        }

        public override IBusinessObject LoadBusinessObject(BusinessObjectType type, Guid id)
        {
            StoredProcedure? sp = null;
            string procedureParamName = null;
            string tableName = null;

            if (type == BusinessObjectType.ShiftTransaction)
            {
                sp = StoredProcedure.warehouse_p_getShiftTransactionData;
                procedureParamName = "@shiftTransactionId";
                tableName = "shiftTransaction";
            }
            else if (type == BusinessObjectType.Container)
            {
                sp = StoredProcedure.warehouse_p_getContainer;
                procedureParamName = "@containerId";
                tableName = "container";
            }
            else
                throw new InvalidOperationException("This type of object is not supported by WarehouseMapper.");

            XDocument xdoc = this.ExecuteStoredProcedure(sp.Value, true, procedureParamName, id);

            if (xdoc.Root.Element(tableName).Elements().Count() == 0)
                throw new ClientException(ClientExceptionId.ObjectNotFound);

            xdoc = this.ConvertDBToBoXmlFormat(xdoc, id);

            return this.ConvertToBusinessObject(xdoc.Root.Element(tableName), null);
        }

        public override void CreateCommunicationXml(IBusinessObject obj)
        {
        }

        public override void CreateCommunicationXml(XDocument operations)
        {
        }

        public XElement GetAvailableLots(Guid itemId, Guid warehouseId)
        {
            /*
             * wejscie:
                <root>
                  <itemId>CE93E0EB-698E-44DB-9889-BB755C570834</itemId>
                  <warehouseId>666A2823-7E23-4DEF-9ED8-1288694F4272</warehouseId>
                </root>
             * 
             * na wyjsciu:
                <root>
	                <shifts shiftId="4ED238E9-6772-4C36-B11C-41045B4F19D2" quantity="3.000000" containerId="A28A28FE-881F-EE90-2887-A1DCE4325530" containerLabel="A1p5" slotContainerLabel="A1p5" incomeDate="2009-10-27T11:18:20" fullNumber="PZ 205/O1/2009" price="0.00" incomeWarehouseDocumentLineId="6117AAF4-190F-49DE-A9F2-3926AF220582" status="40" version="077C670D-11FC-4100-B63A-6BCD10C2F3D6" itemId="CE93E0EB-698E-44DB-9889-BB755C570834" itemCode="2" itemName="Undercity" warehouseId="666A2823-7E23-4DEF-9ED8-1288694F4272" shiftDate="2009-10-27T11:18:20" />
	                <shifts quantity="10.000000" incomeDate="2009-10-27T11:19:24" fullNumber="PZ 206/O1/2009" price="0.00" incomeWarehouseDocumentLineId="B1ABE275-AB69-4C08-923C-60A0401367C8" status="40" version="2C09170C-152D-4AE1-A81E-878153507F84" itemId="CE93E0EB-698E-44DB-9889-BB755C570834" itemCode="2" itemName="Undercity" warehouseId="666A2823-7E23-4DEF-9ED8-1288694F4272" />
                </root>
             */

            XDocument xml = XDocument.Parse("<root><itemId/><warehouseId/></root>");

            xml.Root.Element("itemId").Value = itemId.ToUpperString();
            xml.Root.Element("warehouseId").Value = warehouseId.ToUpperString();

            xml = this.ExecuteStoredProcedure(StoredProcedure.warehouse_p_getAvailableLots, true, xml);

            return xml.Root;
        }

        public MassiveBusinessObjectCollection<Container> GetAllContainers()
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.warehouse_p_getContainers);

            MassiveBusinessObjectCollection<Container> collection = new MassiveBusinessObjectCollection<Container>();
            collection.Deserialize(xml.Root.Element("container"));

            return collection;
        }

        public bool AreContainersEmpty(IEnumerable<Container> containers)
        {
            XDocument xml = XDocument.Parse("<root/>");

            foreach (Container c in containers)
                xml.Root.Add(new XElement("container", new XAttribute("id", c.Id.ToUpperString())));

            xml = this.ExecuteStoredProcedure(StoredProcedure.warehouse_p_checkContainerContent, true, xml);

            if (xml.Root.Elements().Where(e => e.Element("hasContent") != null && e.Element("hasContent").Value == "1").FirstOrDefault() != null)
                return false;
            else
                return true;
        }

        public XElement CreateShiftTransaction(XDocument operations)
        {
            return this.ExecuteStoredProcedure(StoredProcedure.warehouse_p_createShiftTransaction, true, operations).Root;
        }

        public XElement EditShiftTransaction(XDocument operations)
        {
            return this.ExecuteStoredProcedure(StoredProcedure.warehouse_p_editShiftTransaction, true, operations).Root;
        }

        public override XDocument ConvertDBToBoXmlFormat(XDocument xml, Guid id)
        {
            XDocument convertedXml = null;
            
            XElement idElement = xml.Root.Descendants().Where(x => x.Name.LocalName == "id" && x.Value == id.ToUpperString()).First();

            if (idElement.Parent.Parent.Name.LocalName == "shiftTransaction")
            {
                convertedXml = XDocument.Parse("<root><shiftTransaction /></root>");

                this.ConvertShiftTransactionFromDbToBoXmlFormat(xml, id, convertedXml.Root.Element("shiftTransaction"));
            }
            else if (idElement.Parent.Parent.Name.LocalName == "container")
            {
                convertedXml = XDocument.Parse("<root><container /></root>");
                convertedXml.Root.Element("container").Add(idElement.Parent.Elements());
            }

            return convertedXml;
        }

        public string GetContainerSymbolByShiftId(Guid shiftId)
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.warehouse_p_getContainerSymbolByShiftId, true, "@shiftId", shiftId);

            if (xml.Root.Value != String.Empty)
                return xml.Root.Value;
            else
                return null;
        }

        public void DuplicateShiftAttributes(Guid shiftTransactionId)
        {
            XDocument xml = XDocument.Parse("<root/>");
            xml.Root.Add(new XElement("shiftTransactionId", shiftTransactionId.ToUpperString()));
            this.ExecuteStoredProcedure(StoredProcedure.warehouse_p_duplicateShiftAttributes, false, xml);
        }

        public XElement GetShiftsForIncomeWarehouseLines(ICollection<Guid> linesId)
        {
            if (linesId == null || linesId.Count == 0) return new XElement("root");

            XDocument xml = XDocument.Parse("<root/>");

            foreach (Guid id in linesId.Distinct())
            {
                xml.Root.Add(new XElement("line", new XAttribute("id", id.ToUpperString())));
            }

            xml = this.ExecuteStoredProcedure(StoredProcedure.warehouse_p_getShiftsForIncomeWarehouseLines, true, xml);

            return xml.Root;
        }

        public void DeleteShiftsForDocument(Guid warehouseDocumentHeaderId)
        {
            this.ExecuteStoredProcedure(StoredProcedure.warehouse_p_deleteShiftsForDocument, false, "@warehouseDocumentHeaderId", warehouseDocumentHeaderId);
        }

        private void ConvertShiftTransactionFromDbToBoXmlFormat(XDocument xml, Guid id, XElement convertedST)
        {
            string strId = id.ToUpperString();

            XElement shiftTransactionElement = xml.Root.Element("shiftTransaction").Elements().Where(x => x.Element("id").Value == strId).FirstOrDefault();

            if (shiftTransactionElement == null)
                throw new InvalidOperationException("No ShiftTransaction found to convert.");

            foreach (XElement column in shiftTransactionElement.Elements())
            {
                if (column.Name.LocalName != "applicationUserId")
                    convertedST.Add(column); //auto-cloning
                else
                {
                    ContractorMapper contractorMapper = DependencyContainerManager.Container.Get<ContractorMapper>();
                    XDocument contractorXml = contractorMapper.ConvertDBToBoXmlFormat(xml, new Guid(column.Value));

                    convertedST.Add(new XElement("user", contractorXml.Root.Element("contractor")));
                }
            }

            //convert shifts
            XElement shifts = new XElement("shifts");
            convertedST.Add(shifts);

            foreach (XElement shift in xml.Root.Element("shift").Elements().Where(s => s.Element("shiftTransactionId").Value == strId))
            {
                XElement newShift = new XElement("shift", shift.Elements());
                shifts.Add(newShift);

                XElement shiftAttributes = new XElement("attributes");
                newShift.Add(shiftAttributes);

                var attribs = xml.Root.Element("shiftAttrValue").Elements().Where(e => e.Element("shiftId").Value == newShift.Element("id").Value);

                foreach (XElement attrEntry in attribs)
                {
                    XElement attribute = new XElement("attribute");
                    shiftAttributes.Add(attribute);

                    foreach (XElement attrElement in attrEntry.Elements())
                    {
						if (!VariableColumnName.IsVariableColumnName(attrElement.Name.LocalName))
                            attribute.Add(attrElement); //auto-cloning
                        else
                        {
                            ShiftField cf = DictionaryMapper.Instance.GetShiftField(new Guid(attrEntry.Element(XmlName.ShiftFieldId).Value));

                            string dataType = cf.Metadata.Element(XmlName.DataType).Value;

                            if (dataType != DataType.Xml)
                                attribute.Add(new XElement(XmlName.Value, BusinessObjectHelper.ConvertAttributeValueForSpecifiedDataType(attrElement.Value, dataType)));
                            else
								attribute.Add(new XElement(XmlName.Value, attrElement.Elements()));
                        }
                    }
                }
            }

            //convert container shifts
            XElement containerShifts = new XElement("containerShifts");
            convertedST.Add(containerShifts);

            foreach (XElement containerShift in xml.Root.Element("containerShift").Elements().Where(s => s.Element("shiftTransactionId").Value == strId))
                shifts.Add(new XElement("containerShift", containerShift.Elements()));
        }

        public override IBusinessObject ConvertToBusinessObject(XElement objectXml, XElement options)
        {
            BusinessObjectType type;

            try
            {
                type = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), objectXml.Name.LocalName, true);
            }
            catch (ArgumentException)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:125");
                throw new ClientException(ClientExceptionId.UnknownBusinessObjectType, null, "objType:" + objectXml.Attribute("type").Value);
            }

            IBusinessObject bo = this.CreateNewBusinessObject(type, null);
            bo.Deserialize(objectXml);

            return bo;
        }

        public ShiftTransaction GetShiftTransactionByShiftId(Guid shiftId)
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.warehouse_p_getShiftTransactionByShiftId, true, "@shiftId", shiftId);

            if (xml.Root.Element("shiftTransaction").Elements().Count() == 0)
                throw new ClientException(ClientExceptionId.ObjectNotFound);

            xml = this.ConvertDBToBoXmlFormat(xml, new Guid(xml.Root.Element("shiftTransaction").Element("entry").Element("id").Value));

            return (ShiftTransaction)this.ConvertToBusinessObject(xml.Root.Element("shiftTransaction"), null);
        }

        public override void UpdateDictionaryIndex(IBusinessObject obj)
        {
        }
    }
}
