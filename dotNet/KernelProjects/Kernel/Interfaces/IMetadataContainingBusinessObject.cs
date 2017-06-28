using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;

namespace Makolab.Fractus.Kernel.Interfaces
{
	internal interface IMetadataContainingBusinessObject
	{
		XElement Metadata { get; set; }
		string FieldId { get; }
	}
}
