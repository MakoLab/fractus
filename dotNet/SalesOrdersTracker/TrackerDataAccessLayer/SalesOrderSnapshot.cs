using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using TrackerDataAccessLayer.Enums;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel;

namespace TrackerDataAccessLayer
{
	[MetadataType(typeof(SalesOrderSnapshotMetadata))]
	public partial class SalesOrderSnapshot
	{
		public SalesTypeName SalesTypeName
		{
			get
			{
				return (SalesTypeName)SalesType;
			}
		}

		public SalesOrderStatusName StatusName
		{
			get
			{
				return (SalesOrderStatusName)Status;
			}
		}

		public List<SalesOrderEvent> SalesOrderEventsList
		{
			get
			{
				return SalesOrderEvents.OrderByDescending(soe => soe.Date).ThenByDescending(soe => soe.EventName).ToList();
			}
		}

		public List<Item> Items { get; set; }

		[DisplayName("Status zamówienia")]
		public string DisplayStatus
		{
			get
			{
				string result = "Przyjęte";
				switch (StatusName)
				{
					case SalesOrderStatusName.Cancelled: result = "Anulowane"; break;
					case SalesOrderStatusName.Registered: result = "Przyjęte"; break;
					case SalesOrderStatusName.InProgress: result = "W realizacji"; break;
					case SalesOrderStatusName.Ready: result = 
						SalesTypeName == SalesTypeName.Items ? "Gotowe do odbioru" : "Gotowe do montażu"; break;
					case SalesOrderStatusName.Commited: result = "Zrealizowane"; break;
				}
				return result;
			}
		}

		[DisplayName("Wartość zamówienia")]
		public string DisplayValue { get { return Value.ToString("C"); } }
	}

	public class SalesOrderSnapshotMetadata
	{
		[DisplayName("Numer zamówienia")]
		public string Number { get; set; }

		[DisplayName("Data zamówienia")]
		public DateTime RegistrationDate { get; set; }

		[DisplayName("Wartość zamówienia")]
		public decimal Value { get; set; }

		[DisplayName("Data montażu")]
		public DateTime FittingDate { get; set; }

		[DisplayName("Dane Klienta")]
		public Contractor Contractor { get; set; }
	}
}
