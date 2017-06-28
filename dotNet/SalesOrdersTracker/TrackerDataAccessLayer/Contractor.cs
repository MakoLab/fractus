using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using TrackerDataAccessLayer.Enums;

namespace TrackerDataAccessLayer
{
	[MetadataType(typeof(ContractorMetadata))]
	public partial class Contractor
	{
		public bool HasEmailAddress
		{
			get
			{
				return !String.IsNullOrWhiteSpace(Email);
			}
		}

		public bool HasPhoneNumber
		{
			get
			{
				return !String.IsNullOrWhiteSpace(Phone);
			}
		}

		public ContractorType ContractorType
		{
			get
			{
				return (ContractorType)Type;
			}
		}
	}

	public class ContractorMetadata
	{
		[DisplayName("Nazwa")]
		public string FullName { get; set; }
		[DisplayName("Adres")]
		public string Address { get; set; }
		[DisplayName("Miasto")]
		public string City { get; set; }
	}
}
