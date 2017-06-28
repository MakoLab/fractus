using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using TrackerDataAccessLayer.Enums;

namespace TrackerDataAccessLayer.Events
{
	public class MarkedAsPlannedEvent : Event, IEquatable<MarkedAsPlannedEvent>
	{
		public string ProductionOrderNumber { get; set; }

		protected override List<string> ParametersList
		{
			get
			{
				List<string> result = base.ParametersList;
				if (!String.IsNullOrWhiteSpace(ProductionOrderNumber))
				{
					result.Add(EventContainerName.ProductionOrderNumber);
					result.Add(ProductionOrderNumber);
				}
				return result;
			}
		}

		public MarkedAsPlannedEvent(EventName name, string contractNumber, DateTime date, string productionOrderNumber)
			: base(name, contractNumber, date)
		{
			this.ProductionOrderNumber = productionOrderNumber;
		}

		public bool Equals(MarkedAsPlannedEvent other)
		{
			if (!base.Equals(other))
				return false;

			if (this.ProductionOrderNumber != other.ProductionOrderNumber)
				return false;

			return true;
		}
	}
}
