using System;
using System.Globalization;
using System.Xml.Linq;

namespace Makolab.Fractus.Kernel.MethodInputParameters
{
    public class GetDocumentCostResponse
    {
        public Guid LineId { get; set; }
        public decimal? Quantity { get; set; }
        public decimal? Value { get; set; }

        public GetDocumentCostResponse(XElement line)
        {
            this.LineId = new Guid(line.Attribute("id").Value);

            if (line.Attribute("quantity") != null)
                this.Quantity = Convert.ToDecimal(line.Attribute("quantity").Value, CultureInfo.InvariantCulture);

            if (line.Attribute("value") != null)
                this.Value = Convert.ToDecimal(line.Attribute("value").Value, CultureInfo.InvariantCulture);
        }
    }
}
