using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Globalization;
using TrackerDataAccessLayer.Enums;

namespace TrackerDataAccessLayer.Events
{
	public class RelatedDocumentEvent : Event, IEquatable<RelatedDocumentEvent>
	{
		public string RelatedDocumentNumber { get; set; }
		public decimal GrossValue { get; set; }

		protected override List<string> ParametersList
		{
			get
			{
				List<string> result = base.ParametersList;
				if (!String.IsNullOrWhiteSpace(RelatedDocumentNumber))
				{
					result.Add(EventContainerName.RelatedDocumentNumber);
					result.Add(RelatedDocumentNumber);
					result.Add(EventContainerName.RelatedDocumentNumberFiltered);
					result.Add(RelatedDocumentNumber.Replace("/DETAL", String.Empty));
				}
				result.Add(EventContainerName.GrossValue);
				result.Add(GrossValue.ToString("N"));
				result.Add(EventContainerName.GrossValue12);
				result.Add(String.Concat(GrossValue.ToString(CultureInfo.InvariantCulture).Replace('.', ','), "PLN"));
				return result;
			}
		}

		public RelatedDocumentEvent(EventName name, string contractNumber, DateTime date
			, string relatedDocumentNumber, decimal grossValue)
			: base(name, contractNumber, date)
		{
			this.RelatedDocumentNumber = relatedDocumentNumber;
			this.GrossValue = grossValue;
		}

		public bool Equals(RelatedDocumentEvent other)
		{
			if (!base.Equals(other))
				return false;

			if (this.RelatedDocumentNumber != other.RelatedDocumentNumber)
				return false;

			return true;
		}
	}
}
