using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using System.Globalization;

namespace Makolab.Fractus.Kernel.BusinessObjects.WarehouseManagamentSystem
{
    internal class Shifts : BusinessObjectsContainer<Shift>
    {
        public Shifts(ShiftTransaction parent)
            : base(parent, "shift")
        {
        }

        public override Shift CreateNew()
        {
            ShiftTransaction parent = (ShiftTransaction)this.Parent;

            //create new object and attach it to the element
            Shift line = new Shift(parent);

            line.Order = this.Children.Count + 1;

            //add object to the collection
            this.Children.Add(line);

            return line;
        }

		public Shift CreateNew(XElement shiftElementAvailableLots)
		{
			Shift shift = this.CreateNew();

			if (shiftElementAvailableLots.Attribute("shiftId") != null)
				shift.SourceShiftId = new Guid(shiftElementAvailableLots.Attribute("shiftId").Value);

			shift.IncomeWarehouseDocumentLineId = new Guid(shiftElementAvailableLots.Attribute("incomeWarehouseDocumentLineId").Value);

			shift.Quantity = Convert.ToDecimal(shiftElementAvailableLots.Attribute("quantity").Value, CultureInfo.InvariantCulture);

			return shift;
		}

        /// <summary>
        /// Validates the collection.
        /// </summary>
        public override void Validate()
        {
            //sprawdzamy czy nie przesuwamy z tego samego do tego samego kontenera
            List<Guid> idCollection = new List<Guid>();

            foreach (Shift shift in this.Children)
            {
                if (shift.SourceShiftId != null)
                    idCollection.Add(shift.SourceShiftId.Value);
            }

            XElement shifts = DependencyContainerManager.Container.Get<WarehouseMapper>().GetShiftsById(idCollection);

            //walidujemy
            foreach (Shift shift in this.Children)
            {
                if (shift.SourceShiftId != null)
                {
                    XElement sourceShift = shifts.Element("shift").Elements().Where(x => x.Element("id").Value == shift.SourceShiftId.ToUpperString()).First();

                    //if ((sourceShift.Element("containerId") == null && shift.ContainerId == null) //z nicosci w nicosc
                    //    || (sourceShift.Element("containerId") != null && shift.ContainerId != null && //z tego samego kontenera na ten sam
                    //    sourceShift.Element("containerId").Value == shift.ContainerId.ToUpperString()))
                    //    throw new ClientException(ClientExceptionId.SourceAndDestinationContainersAreTheSame);
                }
            }

            base.Validate();
        }
    }
}
